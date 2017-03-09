require "selenium-webdriver"

class Pages < Object

  attr_reader :driver

  def initialize(data, config, logger)
    ENV["DISPLAY"] = ":10"
    @driver = Selenium::WebDriver.for(:chrome, detach: false)

    @data = data
    @config = config
    @logger = logger
  end

  def open_page(page)
    @logger.info("Start(page): " + page)
    send page
    @logger.info("Finish(page): " + page)
    
  rescue Net::ReadTimeout => e
    @logger.error(e)
    Rollbar.error(e)
    
    retry
  end

  private
  def login
    @driver.navigate.to "https://onlineservices.immigration.govt.nz/secure/Login+Working+Holiday.htm"

    @data["browser_cookie"] = @driver.manage.all_cookies
    @data["cookie"] = @driver.manage.all_cookies.map { |e| e[:name] + "=" + e[:value] }.join("; ")

    @logger.info "Got cookie: #{@data["cookie"]}"
  end

end
