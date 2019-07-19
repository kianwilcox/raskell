
class Proc
  alias_method :standard_ruby_call, :call
  attr_accessor :is_tupled

  def fmap(lamb)
    self * lamb
  end

  def self.pure(arg)
    ->(x) { arg }
  end

  def **(lamb) ## <*> from Control.Applicative
    ->(x) { self.(x, lamb.(x)) }
  end


  ## <**> from Control.Applicative
  def ^(lamb)
    ->(x) { lamb.(self.(x), x) }
  end

  def bind(lamb)
    ->(x) { lamb.(self.(x), x)}
  end
  
  # Just a friendly reminder
  # .() is shorthand for .call() 
  # and self.arity is the number of arguments this Proc takes

  def [](*args)
    call(*args)
  end

  def call(*args)
    args_to_consume = args.take(self.arity < 0 ? self.arity.abs : self.arity) ## the < 1 here is because ruby stores *args as an arity of one more than the required args, in a negative number
    remaining_args = args.drop(self.arity < 0 ? self.arity.abs : self.arity)
    
    if !args_to_consume.respond_to?(:length) ## then we're dealing with a *args-only lambda, and we have enough args. just apply them all
        result = self.standard_ruby_call(*args)
    elsif self.arity == 0
      result = self.standard_ruby_call()
    elsif args.length == 0
      #interpret application with no arguments on a non-zero-arity function as a no-op
      return self
    elsif (self.arity < 0 && args.length >= self.arity.abs - 1) ## then we're dealing with a *args-based lambda, and we have enough args. just apply them all
      result = self.standard_ruby_call(*args)
    elsif args_to_consume.length < self.arity 
      #if you have too few arguments, return a lambda asking for more before attempting to re-apply
      return ->(x) { self.call( *( args + [x] ) ) }
    elsif self.arity < 0
      return ->(*xs) { self.call( *( args + xs.deep_clone ) ) }
    else
      #otherwise, apply the arguments
      result = self.standard_ruby_call(*args_to_consume)
    end
    # if the result is a proc, make sure to unwrap further by recursively calling with any remaining arguments
    (result.kind_of?(Proc) && remaining_args.length > 0) || (result.kind_of?(Proc) && remaining_args.length == 0 && result.respond_to?(:arity) && result.arity == 0) ? result.call(*remaining_args) : result
  end

  def *(lamb)
    # You, then me
    # like function composition
    if lamb.class != Proc
      lamb | self
    else
      ->(x) { self.( lamb.( x ) ) }
    end
  end

  def |(lamb)
    # Me, then you
    # like unix pipes
    if lamb.class != Proc
      lamb * self
    else
      ->(x) { lamb.( self.( x ) ) }
    end
  end

  def +(lamb)
    ## later need to check if they have the same arity, once I've fixed the arity function to handle nesting lambdas
    this = self
    
    result = ->(xs) { 
      if lamb.is_tupled && this.is_tupled 
        this.(xs) + lamb.(xs)
      elsif lamb.is_tupled
        [this.(xs)] + lamb.(xs)
      elsif this.is_tupled
        this.(xs) + [lamb.(xs)]
      else
        [this.(xs),lamb.(xs)] 
      end
    }
    result.is_tupled = true
    result
  end

  def <<(val)
    # feed data from the right
    self.(val.())
  end

  def >>(lamb)
    # feed data from the left, assuming I am a wrapped Object of some sort
    lamb.(self.())
  end

end