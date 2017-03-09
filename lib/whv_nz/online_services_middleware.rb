require 'faraday'

class OnlineServicesMiddleware < Faraday::Middleware
  def call(request_env)
    form = request_env.url.path.split(".").first.split("/").last.underscore

    request_env[:request_headers].merge!(shared_headers)
    request_env[:request_headers]['Cookie'] = $whv.data["cookie"] || ""

    @app.call(request_env).on_complete do |response_env|
      update_cookie(response_env[:response_headers]["set-cookie"])

      if error?(response_env.body)
        $whv.save_cookie(nil)

        $whv.pages.open_page "login"
        $whv.online_services.send_request "login"
      end
    end
  end

  private
  def shared_headers
    headers = {}

    headers['Host'] = 'onlineservices.immigration.govt.nz:443'
    headers['Connection'] = 'keep-alive'
    headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    headers['Origin'] = 'https://onlineservices.immigration.govt.nz'
    headers['Upgrade-Insecure-Requests'] = '1'
    headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
    headers['Content-Type'] = 'application/x-www-form-urlencoded'
    headers['Accept-Encoding'] = 'gzip, deflate'
    headers['Accept-Language'] = 'en,en-US;q=0.8,zh-CN;q=0.6,zh;q=0.4,zh-TW;q=0.2'

    headers
  end

  def error?(body)
    body.include?("accessdenied") || body.include?("Invalid Request") || body.include?("enable JavaScript")
  end

  def update_cookie(set_cookie)
    if set_cookie    
      set_cookie.gsub!(/path=\/|,\s/i, "")

      hash = cookie_hash($whv.data["cookie"]).merge(cookie_hash(set_cookie))

      cookie = hash.map { |key, value|  key + "=" + value }.join("; ")
      $whv.save_cookie(cookie)
    end
  end

  def cookie_hash(cookie)
    hash = {}
    cookie.split("; ").each do |e|
      parts = e.partition("=")
      hash[parts[0]] = parts[2]
    end

    hash
  end

end
