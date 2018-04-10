# frozen_string_literal: true

require 'bcrypt'

module DeviseTokenAuth::Concerns::User
  extend ActiveSupport::Concern

  def self.tokens_match?(token_hash, token)
    @token_equality_cache ||= {}

    key = "#{token_hash}/#{token}"
    result = @token_equality_cache[key] ||= (::BCrypt::Password.new(token_hash) == token)
    @token_equality_cache = {} if @token_equality_cache.size > 10000
    result
  end

  included do
    # Hack to check if devise is already enabled
    if method_defined?(:devise_modules)
      devise_modules.delete(:omniauthable)
    else
      devise :database_authenticatable, :registerable,
             :recoverable, :trackable, :validatable, :confirmable
    end

    serialize :tokens, JSON unless tokens_has_json_column_type?

    if DeviseTokenAuth.default_callbacks
      include DeviseTokenAuth::Concerns::UserOmniauthCallbacks
    end

    # can't set default on text fields in mysql, simulate here instead.
    after_save :set_empty_token_hash
    after_initialize :set_empty_token_hash

    # get rid of dead tokens
    before_save :destroy_expired_tokens

    # remove old tokens if password has changed
    before_save :remove_tokens_after_password_reset

    # don't use default devise email validation
    def email_required?; false; end
    def email_changed?; false; end
    def will_save_change_to_email?; false; end

    def password_required?
      return false unless provider == 'email'
      super
    end

    # override devise method to include additional info as opts hash
    def send_confirmation_instructions(opts = {})
      generate_confirmation_token! unless @raw_confirmation_token

      # fall back to "default" config name
      opts[:client_config] ||= 'default'
      opts[:to] = unconfirmed_email if pending_reconfirmation?
      opts[:redirect_url] ||= DeviseTokenAuth.default_confirm_success_url

      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    end

    # override devise method to include additional info as opts hash
    def send_reset_password_instructions(opts = {})
      token = set_reset_password_token

      # fall back to "default" config name
      opts[:client_config] ||= 'default'

      send_devise_notification(:reset_password_instructions, token, opts)
      token
    end

    # override devise method to include additional info as opts hash
    def send_unlock_instructions(opts = {})
      raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
      self.unlock_token = enc
      save(validate: false)

      # fall back to "default" config name
      opts[:client_config] ||= 'default'

      send_devise_notification(:unlock_instructions, raw, opts)
      raw
    end
  end

  def create_token(client_id: nil, token: nil, expiry: nil, **token_extras)
    client_id ||= SecureRandom.urlsafe_base64(nil, false)
    token     ||= SecureRandom.urlsafe_base64(nil, false)
    expiry    ||= (Time.zone.now + token_lifespan).to_i

    tokens[client_id] = {
      token: BCrypt::Password.create(token),
      expiry: expiry
    }.merge!(token_extras)

    clean_old_tokens

    [client_id, token, expiry]
  end

  module ClassMethods
    protected

    def tokens_has_json_column_type?
      database_exists? && table_exists? && columns_hash['tokens'] && columns_hash['tokens'].type.in?([:json, :jsonb])
    end

    def database_exists?
      ActiveRecord::Base.connection_pool.with_connection { |con| con.active? } rescue false
    end
  end

  def valid_token?(token, client_id = 'default')
    return false unless tokens[client_id]
    return true if token_is_current?(token, client_id)
    return true if token_can_be_reused?(token, client_id)

    # return false if none of the above conditions are met
    false
  end

  # this must be done from the controller so that additional params
  # can be passed on from the client
  def send_confirmation_notification?; false; end

  def token_is_current?(token, client_id)
    # ghetto HashWithIndifferentAccess
    expiry     = tokens[client_id]['expiry'] || tokens[client_id][:expiry]
    token_hash = tokens[client_id]['token'] || tokens[client_id][:token]

    return true if (
      # ensure that expiry and token are set
      expiry && token &&

      # ensure that the token has not yet expired
      DateTime.strptime(expiry.to_s, '%s') > Time.zone.now &&

      # ensure that the token is valid
      DeviseTokenAuth::Concerns::User.tokens_match?(token_hash, token)
    )
  end

  # allow batch requests to use the previous token
  def token_can_be_reused?(token, client_id)
    # ghetto HashWithIndifferentAccess
    updated_at = tokens[client_id]['updated_at'] || tokens[client_id][:updated_at]
    last_token = tokens[client_id]['last_token'] || tokens[client_id][:last_token]

    return true if (
      # ensure that the last token and its creation time exist
      updated_at && last_token &&

      # ensure that previous token falls within the batch buffer throttle time of the last request
      Time.parse(updated_at) > Time.zone.now - DeviseTokenAuth.batch_request_buffer_throttle &&

      # ensure that the token is valid
      ::BCrypt::Password.new(last_token) == token
    )
  end

  # update user's auth token (should happen on each request)
  def create_new_auth_token(client_id = nil)
    now = Time.zone.now

    client_id, token = create_token(
      client_id: client_id,
      expiry: (now + token_lifespan).to_i,
      last_token: tokens.fetch(client_id, {})['token'],
      updated_at: now
    )

    update_auth_header(token, client_id)
  end

  def build_auth_header(token, client_id = 'default')
    # client may use expiry to prevent validation request if expired
    # must be cast as string or headers will break
    expiry = tokens[client_id]['expiry'] || tokens[client_id][:expiry]

    {
      DeviseTokenAuth.headers_names[:"access-token"] => token,
      DeviseTokenAuth.headers_names[:"token-type"]   => 'Bearer',
      DeviseTokenAuth.headers_names[:"client"]       => client_id,
      DeviseTokenAuth.headers_names[:"expiry"]       => expiry.to_s,
      DeviseTokenAuth.headers_names[:"uid"]          => uid
    }
  end

  def update_auth_header(token, client_id = 'default')
    headers = build_auth_header(token, client_id)
    clean_old_tokens
    save!

    headers
  end

  def build_auth_url(base_url, args)
    args[:uid]    = uid
    args[:expiry] = tokens[args[:client_id]]['expiry']

    DeviseTokenAuth::Url.generate(base_url, args)
  end

  def extend_batch_buffer(token, client_id)
    tokens[client_id]['updated_at'] = Time.zone.now
    update_auth_header(token, client_id)
  end

  def confirmed?
    devise_modules.exclude?(:confirmable) || super
  end

  def token_validation_response
    as_json(except: %i[tokens created_at updated_at])
  end

  def token_lifespan
    DeviseTokenAuth.token_lifespan
  end

  protected

  def set_empty_token_hash
    self.tokens ||= {} if has_attribute?(:tokens)
  end

  def destroy_expired_tokens
    if tokens
      tokens.delete_if do |cid, v|
        expiry = v[:expiry] || v['expiry']
        DateTime.strptime(expiry.to_s, '%s') < Time.zone.now
      end
    end
  end

  def should_remove_tokens_after_password_reset?
    if Rails::VERSION::MAJOR <= 5
      encrypted_password_changed? &&
        DeviseTokenAuth.remove_tokens_after_password_reset
    else
      saved_change_to_encrypted_password? &&
        DeviseTokenAuth.remove_tokens_after_password_reset
    end
  end

  def remove_tokens_after_password_reset
    return unless should_remove_tokens_after_password_reset?

    if tokens.present? && tokens.many?
      client_id, token_data = tokens.max_by { |cid, v| v[:expiry] || v['expiry'] }
      self.tokens = { client_id => token_data }
    end
  end

  def max_client_tokens_exceeded?
    tokens.length > DeviseTokenAuth.max_number_of_devices
  end

  def clean_old_tokens
    if tokens.present? && max_client_tokens_exceeded?
      # Using Enumerable#sort_by on a Hash will typecast it into an associative
      #   Array (i.e. an Array of key-value Array pairs). However, since Hashes
      #   have an internal order in Ruby 1.9+, the resulting sorted associative
      #   Array can be converted back into a Hash, while maintaining the sorted
      #   order.
      self.tokens = tokens.sort_by { |_cid, v| v[:expiry] || v['expiry'] }.to_h

      # Since the tokens are sorted by expiry, shift the oldest client token
      #   off the Hash until it no longer exceeds the maximum number of clients
      tokens.shift while max_client_tokens_exceeded?
    end
  end
end
