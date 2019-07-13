class Object

  def self.empty
    Self.new
  end

  def fmap(fn)
  	fn.(self)
  end

  def lift
    ->() { self }
  end

  def call(*args)
  	self
  end

  def apply(fn)
    fn.(self)
  end

  def deep_clone
    self.respond_to?(:clone) && !self.kind_of?(Numeric) && !self.kind_of?(TrueClass) && !self.kind_of?(FalseClass) && !self.kind_of?(NilClass) ? self.clone : self
  end

end