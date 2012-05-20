class Yammer::Topic
  include Yammer::Attributable

  attr_reader :id, :name, :web_url

  def self.find_by_name(name, client)
    response = client.search(name).topics.select {|t| t.name == name }.first
    Yammer::Topic.new(response) unless response.nil?
  end

  def initialize(m)
    init_from_hash(m)
  end
end
