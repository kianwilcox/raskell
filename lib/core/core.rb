def F(x)
  x.kind_of?(Proc) ? x : -> { x }
end

class Object

  def lift
    F(self)
  end

  def call(*args)
    self
  end

  def apply(f)
    f.(self)
  end

end

class Integer
  def foldr(func, unit)
    i = 0
    while i <= self
      unit = func.(unit, i)
      i+=1
    end
    unit
  end

  def foldl(func, unit)
    i = self
    while i >= 0
      unit = func.(i, unit)
      i-=1
    end
    unit
  end
end

class Array
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
end


class Proc
  alias_method :standard_ruby_call, :call
  
  # Just a friendly reminder
  # .() is shorthand for .call() 
  # and self.arity is the number of arguments this Proc takes

  def call(*args)
    args = args || []

    args_to_consume = args.take(self.arity)
    remaining_args = args.drop(self.arity)
    
    if self.arity == 0
      result = self.standard_ruby_call()
    elsif args.length == 0
      #interpret application with no arguments on a non-zero-arity function as a no-op
      return self
    elsif args_to_consume.length < self.arity
      #if you have too few arguments, return a lambda asking for more before attempting to re-apply
      return ->(x) { call( *( args.push(x) ) ) }
    else
      #otherwise, apply the arguments
      result = self.standard_ruby_call(*args_to_consume)
    end
    # if the result is a proc, make sure to unwrap further by recursively calling with any remaining arguments
    result.kind_of?(Proc) ? result.call(*remaining_args) : result
  end
  
  def *(lamb)
    ->(x) { self.( lamb.( x ) ) }
  end

  def |(lamb)
    ->(x) { lamb.( self.( x ) ) }
  end

  def <=(val)
    self.(val.())
  end

  def >=(lamb)
    lamb.(self.())
  end

end
