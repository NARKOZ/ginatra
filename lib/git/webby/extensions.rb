class Hash
  # Convert to Struct including all values that are Hash class.
  def to_struct
    keys    = self.keys.sort
    members = keys.map(&:to_sym)
    Struct.new(*members).new(*keys.map do |key|
      (self[key].kind_of? Hash) ?  self[key].to_struct : self[key]
    end) unless self.empty?
  end
end
