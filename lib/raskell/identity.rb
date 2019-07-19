class Identity

  alias_method :standard_kind_of?, :kind_of?
  def kind_of?(clazz)
    clazz == Proc || standard_kind_of?(clazz)
  end

  def call(arg)
    arg
  end

  def *(lamb)
    lamb
  end

  def |(lamb)
    lamb
  end

  def +(lamb)
    ->(x) { x } + lamb
  end

  def <<(val)
    # feed data from the right
    self.(val.())
  end

  def >>(lamb)
    # feed data from the left, assuming I am a wrapped Object of some sort
    lamb.(self)
  end

end
