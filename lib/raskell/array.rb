

class Array

  def deep_clone
    map(&:deep_clone)
  end

  def empty
    []
  end

  def fmap(fn)
    map {|x| x.fmap(fn) }
  end

  def call(*args)
    #functions = self.map { |x| x.kind_of?(Proc) ? self : ->() { x } }
      self.any? {|x| x.kind_of? Proc } ? fmap(->(f) { f.(*args)}) : self
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
    next_fn = ->(state) { 
      i = state.first
      arr = state.last
      if i == arr.length
        [:done]
      else
        [:yield, arr[i], Stream.new(next_fn, [i+1, arr])]
      end
    }
  end

  def self.to_stream(xs)
    Stream.new(self.next_item, [0, xs.deep_clone])
  end

  def to_stream
    self.class.to_stream(self)
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

class String

  def self.empty
    ""
  end

  def empty?
    self == ""
  end

  def first
    self[0]
  end

  def take(n)
    if n == 0
      ""
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
      ""
    else
      self.slice(n, self.length)
    end
  end

  def self.next_item
    next_fn = ->(xs) { xs.empty? ? [:done] : [:yield, xs.first, Stream.new(next_fn, xs.drop(1))] }
    next_fn
  end

  def self.to_stream(xs)
    Stream.new(self.next_item, xs)
  end

  def to_stream
    self.class.to_stream(self)
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

require 'set'

class Set

  def self.to_stream(set)
    set.to_a.sort.to_stream
  end

  def to_stream
    self.class.to_stream(self)
  end 

  def push(item)
    self << item
    self
  end

end



class Hash
  
  def fmap(fn)
    self.to_a.map { |x| [x[0], x[1].fmap(fn)] }.to_h
  end

  def <<(keyval)
    raise("Can only push pairs into a dictionary") unless (keyval.kind_of?(Array) || keyval.kind_of?(Stream))
    self[keyval.first]=keyval.last
    self
  end

  def push(pair)
    self <<(pair)
    self
  end

  def to_stream
    ## have to sort to ensure stream == works
    self.class.to_stream(self)
  end

  def self.to_stream(xs)
    ## have to sort to ensure steream == works
    xs.to_a.sort {|x,y| x.first <=> y.first}.to_stream
  end

  alias_method :standard_equals, :==
  def ==(obj)
    obj.kind_of?(Stream) ? self.sort.to_stream == obj : standard_equals(obj)
  end

  alias_method :standard_triple_equals, :===
  def ===(obj)
    obj.kind_of?(Stream) ? self.to_stream === obj : standard_triple_equals(obj)
  end

  def deep_clone
    Hash.new(self.map{|k,v| [k.deep_clone, v.deep_clone]})
  end

end

# class Range
#   def to_stream
#     F.range(self.min, self.max)
#   end

#   def self.to_stream(range)
#     F.range.(range.min, range.max)
#   end
# end
