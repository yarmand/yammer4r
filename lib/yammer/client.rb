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

    def raw_request(resource,options = {})
      options.merge!({:resource => resource})
      yammer_request(:get,options)
    end

  end
end
