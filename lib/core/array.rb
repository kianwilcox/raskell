class Array

  def call(*args)
    (!args || args.length == 0) ? self : self.map{|x| args.map {|f| f.(x) } }
  end

  def take(n)
    if n == 0
      []
    elsif n >= self.length
      self
    else
      self.slice(0, n)
    end
  end

  def drop(n)
    if n == 0
      self
    elsif n >= self.length
      []
    else
      self.slice(n, self.length)
    end
  end

  def foldr(func, unit)
    (self.length-1).foldr(->(idx, acc) { func(self[idx], acc) }, unit)
  end

  def foldl(func, unit)
    (self.length-1).foldl(->(idx, acc) { func(self[idx], acc) }, unit)
  end
  
  def self.next_item
    ->(xs) { xs.empty? ? [:done] : [:item, xs.first, Array.to_stream(xs.drop(1))] }
  end

  def self.to_stream(xs)
    Stream.new(self.next_item, xs)
  end

  def to_stream
    ToStream.new().(self)
  end

  alias_method :standard_equals, :==
  def ==(obj)
    obj.kind_of?(Stream) ? self.to_stream == obj : standard_equals(obj)
  end
end