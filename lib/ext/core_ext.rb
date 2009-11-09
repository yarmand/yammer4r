String.class_eval do
  def to_boolean
    case self
    when 'true'
      true
    when 'false'
      false
    else
      nil
    end
  end
end

Hash.class_eval do
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end unless method_defined?(:symbolize_keys)

  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end unless method_defined?(:symbolize_keys!)

  def assert_has_keys(*valid_keys)
    missing_keys = [valid_keys].flatten - keys
    raise(ArgumentError, "Missing Option(s): #{missing_keys.join(", ")}") unless missing_keys.empty?
  end
end
