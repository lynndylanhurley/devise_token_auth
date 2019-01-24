# frozen_string_literal: true

module DeviseTokenAuth::Url

  def self.generate(url, params = {})
    uri = URI(url)
    query_params = Hash[URI.decode_www_form(uri.query || '')].merge(params)
    uri.query = URI.encode_www_form(query_params)

    uri.to_s
  end

  def self.whitelisted?(url)
    url.nil? || \
      !!DeviseTokenAuth.redirect_whitelist.find do |pattern|
        !!Wildcat.new(pattern).match(url)
      end
  end

  # wildcard convenience class
  class Wildcat
    def self.parse_to_regex(str)
      escaped = Regexp.escape(str).gsub('\*','.*?')
      Regexp.new("^#{escaped}$", Regexp::IGNORECASE)
    end

    def initialize(str)
      @regex = self.class.parse_to_regex(str)
    end

    def match(str)
      !!@regex.match(str)
    end
  end

end
