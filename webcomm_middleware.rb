require 'faraday'
require "./online_services.rb"

class WebcommMiddleware < Faraday::Middleware
  def call(request_env)
    request_env[:request_headers].merge!(shared_headers)

    @app.call(request_env).on_complete do |response_env|

    end
  end

  private
  def shared_headers
    headers = {}

    headers['Host'] = 'webcomm.paymark.co.nz'
    headers['Connection'] = 'keep-alive'
    headers['Cache-Control'] = 'max-age=0'
    headers['Upgrade-Insecure-Requests'] = '1'
    headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
    headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    headers['Accept-Encoding'] = 'gzip, deflate, sdch, br'
    headers['Accept-Language'] = 'en,en-US;q=0.8,zh-CN;q=0.6,zh;q=0.4,zh-TW;q=0.2'

    headers
  end
end
