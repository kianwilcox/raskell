class Integer
  def self.empty
    0
  end

  def foldl(func, unit)
    i = 0
    while i <= self
      unit = func.(unit, i)
      i+=1
    end
    unit
  end

  def foldr(func, unit)
    i = self
    while i >= 0
      unit = func.(i, unit)
      i-=1
    end
    unit
  end
end