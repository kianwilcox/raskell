class Array

  def fmap(fn)
    map {|x| fn.(x) }
  end

  def call(*args)
    #functions = self.map { |x| x.kind_of?(Proc) ? self : ->() { x } }
    if !args || args.length == 0 || !self.any? { |x| x.kind_of?(Proc) }
      self
    else
      unit = self.first.kind_of?(Proc) ? self.first : ->() { self.first }
      function = self.drop(1).reduce(unit) do |new_fn, func| 
        func_to_add = func.kind_of?(Proc) ? func : ->() { func }
        new_fn + func_to_add
      end
      while args.length != 0
        function = function.(args.first)
        args = args.drop(1)
      end
      function
    end
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
    (self.length-1).foldr(->(idx, acc) { func.(self[idx], acc) }, unit)
  end

  def foldl(func, unit)
    (self.length-1).foldl(->(acc, idx) { func.(acc, self[idx]) }, unit)
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

  alias_method :standard_triple_equals, :===
  def ===(obj)
    obj.kind_of?(Stream) ? self.to_stream === obj : standard_triple_equals(obj)
  end
  
end