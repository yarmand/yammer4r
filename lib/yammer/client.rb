module Yammer
  class Client
    def initialize(options={})
      raise "Yammer::Client should not be instanciated, use Yammer::OAuthClient or Yammer::TokenClient"
    end


    # TODO: modularize message and user handling 
    def messages(action = :all, params = {})
      params.merge!(:resource => :messages)
      params.merge!(:action => action) unless action == :all

      parsed_response = JSON.parse(yammer_request(:get, params).body)
      older_available = parsed_response['meta']['older_available']

      ml = parsed_response['messages'].map do |m|
         mash(m)
      end
        Yammer::MessageList.new(ml, older_available, self)
    end

    # search everyting
    def search(string, params = {})
      raise "you must provide a string to do a search" if string.nil?
      params.merge!(:resource => :search)
      params.merge!(:search => string)
      parsed_response = JSON.parse(yammer_request(:get, params).body)
      mash(parsed_response)
    end

    # POST or DELETE a message
    def message(action, params)
      params.merge!(:resource => :messages)
      yammer_request(action, params)
    end

    def users(params = {})
      params.merge!(:resource => :users)
      JSON.parse(yammer_request(:get, params).body).map { |u| Yammer::User.new(mash(u), self) }
    end

    def user(id)
      u = JSON.parse(yammer_request(:get, {:resource => :users, :id => id}).body)
      Yammer::User.new(mash(u), self)
    end

    def current_user
      u = JSON.parse(yammer_request(:get, {:resource => :users, :action => :current}).body)
      Yammer::User.new(mash(u), self)
    end
    alias_method :me, :current_user

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
