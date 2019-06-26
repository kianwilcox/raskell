class Foldl

   alias_method :standard_ruby_kind_of?, :kind_of?

   def kind_of?(clazz)
     [Foldl, Proc].include?(clazz) || standard_ruby_kind_of(clazz)
   end

   def initialize(monoid) # must be [fn, unit] pair, a monoid
     if monoid.first.kind_of?(Array)
       @monoids = monoid
     else
       @monoids = [monoid]
     end
     self
   end

   def monoids
     @monoids
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
    lamb.(self)
  end

   def +(foldl)
     if foldl.kind_of?(Foldl)
       Foldl.new(self.monoids + foldl.monoids)
     else
       raise "Cannot add two non-folds together"
     end
   end

   def call(*vals)
     if vals != nil && vals != [] && vals.first.class.method_defined?(:foldl)
       val = vals.first
       monoids = self.monoids
       while val.length > 0
         results = []
         monoids = monoids.map do |monoid|
           fn = monoid.first
           unit = monoid.last
           result = fn.(unit, val.first)
           results << result
           [fn, result]
         end
         val = val.drop(1)
       end
       results
     elsif vals == []
       self
     else
       raise "Cannot call Foldl on an object that does not have foldl defined."
     end
   end
end