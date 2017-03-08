require 'faraday'
require 'nokogiri'

require 'faraday_middleware'
require './webcomm_middleware.rb'

class Webcomm
  def initialize(config, hk_id, logger)
    @hk_id = hk_id
    @logger = logger
    @config = config

    @conn = 
    Faraday.new(:url => 'https://webcomm.paymark.co.nz/hosted/') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, @logger, { :bodies => false }

      faraday.use WebcommMiddleware
      faraday.use FaradayMiddleware::Gzip
      faraday.use FaradayMiddleware::FollowRedirects
      faraday.adapter  Faraday.default_adapter
    end
  end

  def pay
    send_request "hk"
    send_request "rm"
    send_request "hkc"
  end

  def send_request(form)
    @logger.info("Start(webcomm): " + form)
    send form
    @logger.info("Finish(webcomm): " + form)
  rescue Faraday::ClientError => e
    @logger.error(e)
    Rollbar.error(e)

    retry
  end

  def hk
    res = @conn.get do |req|
      req.params['hk'] = @hk_id
    end

    doc = Nokogiri::HTML(res.body)
    @rm_id = doc.xpath('//form').first.attributes["action"].value.split("=").last

    @logger.info "rm_id: #{@rm_id}"
  end

  def rm
    res = @conn.post do |req|
      req.params['rm'] = @rm_id
      req.body = {
        "hk"                       => @hk_id,
        "hosted_responsive_format" => "N",
        "card_type_MASTERCARD.x"   => "54",
        "card_type_MASTERCARD.y"   => "15",
        "card_type_MASTERCARD"     => "MASTERCARD",
        "processingStage"          => "card_entry",
        "future_pay"               => "",
        "future_pay_save_only"     => ""
      }.to_query
    end

    form = Nokogiri::HTML(res.body).xpath('//form').first
    @hkc_id = form.attributes["action"].value.split("&").first.split("=").last

    @logger.info "hkc_id: #{@hkc_id}"
  end

  def hkc
    if $whv.success
      @logger.info "exit"
      exit 2
    end

    res = @conn.post do |req|
      req.params['hkc'] = @hkc_id
      req.params['rm'] = @rm_id
      
      credit_card = @config["credit_card"]
      req.body = {
        "cardnumber"                           => credit_card["cardnumber"],
        "use_card_security_code"               => "Y",
        "enforce_card_security_code"           => "N",
        "enforce_card_security_code_3party"    => "Y",
        "enforce_card_security_code_futurepay" => "Y",
        "cardverificationcode"                 => credit_card["cardverificationcode"],
        "expirymonth"                          => credit_card["expirymonth"],
        "expiryyear"                           => credit_card["expiryyear"],
        "hk"                                   => @hk_id,
        "hosted_responsive_format"             => "N",
        "cardtype"                             => "MASTERCARD",
        "future_pay"                           => "N",
        "future_pay_save_only"                 => "",
        "cardholder"                           => credit_card["cardholder"],
        "pay_now"                              => "Pay Now"
      }.to_query
    end

    @logger.info res.body
    $whv.data["success"] = true
  end
end
