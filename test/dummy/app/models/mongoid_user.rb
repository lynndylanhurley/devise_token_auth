class MongoidUser
  include Mongoid::Document
  include DeviseTokenAuth::Concerns::User
  include Mongoid::Timestamps

  field :email, type: String
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: Time
  field :reset_password_redirect_url, type: String

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count, type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at, type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip, type: String

  ## Confirmable
  field :confirmation_token, type: String
  field :confirmed_at, type: Time
  field :confirmation_sent_at, type: Time
  field :confirm_success_url, type: String
  field :unconfirmed_email, type: String

  field :name, type: String
  field :nickname, type: String
  field :image, type: String

  field :provider, type: String
  field :uid, default: ""

  ## Tokens
  field :tokens, type: Hash, default: { }

  ## Index
  index({email: 1, uid: 1, reset_password_token: 1}, {unique: true})

  field :operating_thetan, type: Integer
  field :favorite_color, type: String

  validates :operating_thetan, numericality: true, allow_nil: true
  validate :ensure_correct_favorite_color

  def ensure_correct_favorite_color

    if favorite_color and favorite_color != ""
      unless ApplicationHelper::COLOR_NAMES.any?{ |s| s.casecmp(favorite_color)==0 }
        matches = ApplicationHelper::COLOR_SEARCH.search(favorite_color)
        closest_match = matches.last[:string]
        second_closest_match = matches[-2][:string]
        errors.add(:favorite_color, "We've never heard of the color \"#{favorite_color}\". Did you mean \"#{closest_match}\"? Or perhaps \"#{second_closest_match}\"?")
      end
    end
  end
end
