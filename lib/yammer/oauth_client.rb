module Yammer
  class OAuthClient < Yammer::Client
    def initialize(options={})
      options.assert_has_keys(:consumer, :access) unless options.has_key?(:config)
      
      yammer_url = options.delete(:yammer_host) || "https://www.yammer.com"
      @api_path   = "/api/v1/"

      if options[:config]
        config              = YAML.load(open(options[:config]))
        options[:consumer]  = config['consumer'].symbolize_keys
        options[:access]    = config['access'].symbolize_keys
      end

      consumer_opts = {:site => yammer_url}
      consumer_opts[:proxy] = options[:proxy] unless options[:proxy].nil?

      consumer = OAuth::Consumer.new(options[:consumer][:key], options[:consumer][:secret], consumer_opts)
      consumer.http.set_debug_output($stderr) if options[:verbose] == true
      @access_token = OAuth::AccessToken.new(consumer, options[:access][:token], options[:access][:secret])
    end

    private

    def yammer_request(http_method, options)
      request_uri = @api_path + options.delete(:resource).to_s
      [:action, :id].each {|k| request_uri += "/#{options.delete(k)}" if options.has_key?(k) }
      request_uri += ".json"

      if options.any?
        request_uri += "?#{create_query_string(options)}" unless http_method == :post
      end

      if http_method == :post
        handle_response(@access_token.send(http_method, request_uri, options))
      else
        handle_response(@access_token.send(http_method, request_uri))
      end
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
