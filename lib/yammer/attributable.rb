module Yammer
  module Attributable

    # initialize instance variables only if a reader is defined
    def init_from_hash(h, options = {} )
      h.keys.each do |k|
        self.instance_variable_set("@#{k}",h[k]) if self.respond_to?(k) || (options[:writers_also] && self.respond_to?("#{k}=") ) 
      end
    end

  end
end
