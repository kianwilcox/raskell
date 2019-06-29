class Object

  def lift
    F(self)
  end

  def call(*args)
    (!args || args.length == 0) ? self : args.map{|f| f.(self) }
  end

  def apply(f)
    f.(self)
  end

end