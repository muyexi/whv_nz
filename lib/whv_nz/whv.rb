require 'yaml'
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'pry'
require 'slop'
require 'mailgun'
require 'rollbar'
require 'sucker_punch'

class Whv

  attr_reader :data, :pages, :online_services

  def initialize
    @opts = Slop.parse do
      on '-n', '--new', 'Generate config file'
      
      on '-c', '--config=', 'Config file path'

      on '-p', '--production', 'Use real account'

      on '-d', '--daemon', 'In background'
      
      on '-h', '--help', 'Show help info'
    end
  end

  def start
    begin
      if @opts.daemon?
        ::Process.daemon(true, true)
        start_apply
      elsif @opts.new?
        path = File.dirname(__FILE__) + "/config.yml"
        FileUtils.cp(path, Dir.pwd)
      elsif @opts[:config]
        prestart
        start_apply
      else
        puts @opts
      end

      exit 0
    rescue StandardError => e
      @logger.fatal(e)
      Rollbar.critical(e)
      
      raise e
    end
  end

  def prestart
    if !Dir.exist?("log")
      Dir.mkdir("log")
    end

    @data_path = Dir.pwd + "/log/data.yml"
    if !File.exist?(@data_path)
      File.new(@data_path, "w+")
    end    

    @env = @opts.production? ? "production" : "development"
    @file_data = YAML.load(File.read(@data_path)) || {}

    @data = @file_data[@env] || {}
    @config = YAML.load(File.read(@opts[:config]))[@env]

    log_path = Dir.pwd + "/log/whv.log"
    logdev = @opts.daemon? ? log_path : "| tee #{log_path}"
    @logger = Logger.new(logdev, 0, 100 * 1024 * 1024)

    @pages = Pages.new(@data, @config, @logger)
    @online_services = OnlineServices.new(@data, @config, @logger)

    Rollbar.configure do |config|
      config.access_token = @config["rollbar_token"]
      config.enabled = @config["rollbar_token"]

      config.use_sucker_punch
    end

    Signal.trap("INT") { 
      save_data
      exit 2
    }

    Signal.trap("TERM") {
      save_data
      exit 2
    }    
  end

  def save_cookie(cookie)
    @data["cookie"] = cookie
    save_data

    @logger.info "updated cookie: #{cookie}"
  end

  def success
    @file_data = YAML.load(File.read(@data_path)) || {}
    @data = @file_data[@env] || {}

    @data["success"]
  end

  private
  def submit_forms
    @config["forms"].each do |e|
      thread = Thread.new { @online_services.send_request e }
      thread.join
    end
  end

  def start_apply
    if !@data["cookie"]
      @pages.open_page "login"

      @online_services.send_request "login"
    else
      @logger.info "use saved cookie: #{@data["cookie"]}"
    end

    is_success = false
    while !is_success
      is_success = @online_services.send_request "create"

      if !is_success
        @pages.open_page "login"

        @online_services.send_request "login"
      end
    end

    submit_forms

    is_submit = false
    while !is_submit
      is_submit = @online_services.send_request "submit"
    end

    link = ""
    while !link.start_with?("https://webcomm.paymark.co.nz/hosted/?hk=")
      link = @online_services.send_request("on_line_payment") || ""
    end

    hk_id = URI(link).query.split("=").last
    @logger.info "hk_id: #{hk_id}"

    webcomm = Webcomm.new(@config, hk_id, @logger)
    webcomm.pay

    send_notification
  end

  def send_notification
    if @config["mailgun"]["key"]
      client = Mailgun::Client.new @config["mailgun"]["key"]

      message_params =  { from: @config["mailgun"]["from"],
                          to:   @config["mailgun"]["to"],
                          subject: 'WHV: SUCCESS!',
                          text:    'WHV: SUCCESS!'
                        }

      client.send_message '', message_params
    end
  end

  def save_data
    @file_data[@env] = @data
    File.write(@data_path, @file_data.to_yaml)
  end
end
