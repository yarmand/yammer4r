require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Yammer::TokenClient do

  context "connection" do
    it "token should be valid in "+File.expand_path(File.dirname(__FILE__) + "/spec_helper") do
      yammer = Yammer::TokenClient.new(:token => TOKEN)
      yammer.messages
    end
  end
end

