module DeviseTokenAuth::Url

  def self.generate(url, params = {})
    uri = URI(url)

    res = "#{uri.scheme}://#{uri.host}"
    res += ":#{uri.port}" if (uri.port and uri.port != 80 and uri.port != 443)
    res += "#{uri.path}" if uri.path
    res += "?#{params.to_query}"
    res += "##{uri.fragment}" if uri.fragment

    return res
  end

end