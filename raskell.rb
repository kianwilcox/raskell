class Object

  def lift
    -> { self }
  end

  def call(*args)
    self
  end

end

class Proc
  
  alias_method :standard_ruby_call, :call
  
  # Just a friendly reminder
  # .() is shorthand for .call() 
  def call(*args)
    arity_difference = args.length - self.arity
    if arity_difference > 0
      call_with_too_many_arguments(args)
    elsif arity_difference < 0
      call_with_too_few_arguments(args)
    else
      standard_ruby_call(*args)
    end
  end
  
  def *(proc)
    ->(x) { self.( proc.( x ) ) }
  end

  def |(proc)
    ->(x) { proc.( self.( x ) ) }
  end

  def <=(val)
    self.(val.())
  end

  def >=(proc)
    proc.(self.())
  end

  private

  def call_with_too_many_arguments(args)
    # TODO later after I add tests
  end

  def call_with_too_few_arguments(args)
    # TODO later after I add tests
  end

end
