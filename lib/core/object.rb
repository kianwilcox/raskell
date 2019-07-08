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

end