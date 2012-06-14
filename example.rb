require 'yammer4r'

config_path = File.dirname(__FILE__) + '/oauth.yml'
yammer = Yammer::OAuthClient.new(:config => config_path)
## comment previous line and uncomment next to try Token based client.
#  You have to set the token. you can find it in your file oauth.yml or use on given by a 3rd party oauth2 tool
# yammer = Yammer::TokenClient.new(:token => "d2wBYkJrgspivfpmJgu1VQ")

# Get all messages
messages = yammer.messages
puts messages.size
puts messages.last.body.plain
puts messages.last.body.parsed

# Print out all the users
yammer.users.each do |u|
  puts "#{u.name} - #{u.me?}"
end

# a more complex example to find all pages attached to message from a given topic.
# note the usage of raw_request
#
### uncomment following lines to test it ###
#topic=Yammer::Topic.find_by_name("a_topic",yammer)
#parsed_all = JSON.parse(yammer.raw_request("messages/about_topic/#{topic.id}").body) unless topic.nil?
#msg_with_attach = parsed_all["messages"].select{|m| !m["attachments"].empty? }
#pages_json = []
#msg_with_attach.each do |m|
#  m["attachments"].each do |a|
#    pages_json = pages_json.push(a["real_id"]) if a["real_type"] == "page" 
#  end
#end
#puts pages_json
#############################################
