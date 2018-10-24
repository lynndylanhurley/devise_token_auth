module DeviseTokenAuth::Concerns::ActiveRecordSupport
  extend ActiveSupport::Concern

  included do
    serialize :tokens, JSON unless tokens_has_json_column_type?

    # can't set default on text fields in mysql, simulate here instead.
    after_save :set_empty_token_hash
    after_initialize :set_empty_token_hash
  end

  class_methods do
    # It's abstract replacement .find_by
    def dta_find_by(attrs = {})
      find_by(attrs)
    end

    protected

    def tokens_has_json_column_type?
      database_exists? && table_exists? && columns_hash['tokens'] && columns_hash['tokens'].type.in?([:json, :jsonb])
    end

    def database_exists?
      ActiveRecord::Base.connection_pool.with_connection { |con| con.active? } rescue false
    end
  end

  protected

  def set_empty_token_hash
    self.tokens ||= {} if has_attribute?(:tokens)
  end
end
