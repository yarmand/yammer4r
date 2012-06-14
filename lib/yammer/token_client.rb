require 'net/http'
require 'net/https'
require 'uri'

module Yammer
  class TokenClient < Yammer::Client
    def initialize(options={})
      options.assert_has_keys(:token)
      
      @yammer_url = options.delete(:yammer_host) || "www.yammer.com"
      @api_path   = "/api/v1/"

      @access_token = options[:token]
    end


    private

    def yammer_request(http_method, options)
      request_uri = @api_path + options.delete(:resource).to_s
      [:action, :id].each {|k| request_uri += "/#{options.delete(k)}" if options.has_key?(k) }
      request_uri += ".json"

      options = { :access_token => @access_token }.merge(options)

      request_uri += "?#{create_query_string(options)}" unless http_method == :post

      http = Net::HTTP.new(@yammer_url, 443)
      http.use_ssl = true
      #  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = case http_method
                when :post
                  request = Net::HTTP::Post.new(request_uri)
                  request.set_form_data(options)
                  request
                else
                  Net::HTTP::Get.new(request_uri)
                end
      handle_response(http.request(request))
    end

    def create_query_string(options)
      options.map {|k, v| "#{OAuth::Helper.escape(k)}=#{OAuth::Helper.escape(v)}"}.join('&')
    end

    def mash(json)
      Mash.new(json)
    end

    def handle_response(response)
      # TODO: Write classes for exceptions
      case response.code.to_i
        when 200..201
          response
        when 400
          raise "400 Bad request"
        when 401
          raise  "Authentication failed. Check your username and password"
        when 503
          raise "503: Service Unavailable"
        else
          raise "Error. HTTP Response #{response.code}"
        end   
    end

  end
end
