require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe Yammer::TokenClient do

  context "search" do
  
    before(:each) do
      @yammer = Yammer::TokenClient.new(:token => TOKEN)
    end
  
    it "it should find my topic" do
      name = "Approval"
      topic = Yammer::Topic.find_by_name(name,@yammer)
      fail unless topic.web_url =~ /https:\/\/www.yammer.com\/.*\/topics\/#{topic.id}/
    end

  end   
end

