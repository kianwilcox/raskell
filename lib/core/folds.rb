#Origami Fusion
#Stream fusion takes a simple three step approach:
#1. Convert recursive structures into non-recursive co-structures; 
#2. Eliminate superfluous conversions between structures and co-structures;
#3. Finally, use general optimisations to fuse the co-structure code

class Foldl

   alias_method :standard_ruby_kind_of?, :kind_of?

   def kind_of?(clazz)
     [Proc].include?(clazz) || standard_ruby_kind_of?(clazz)
   end

   def initialize(*monoids) # must be [fn, unit] pair, a monoid
       @monoids = monoids
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


class FlatMapl < Foldl
  def initialize(*lambdas)
    @lambdas = lambdas
    flat_map_lambda_to_foldl_lambda = ->(lamb) { ->(acc, el) { acc + lamb.(el) } }
    @monoids = lambdas.map{|lamb| [flat_map_lambda_to_foldl_lambda.(lamb), []]}
  end

  def lambdas
    @lambdas
  end

  def *(lamb)
    if lamb.kind_of?(Mapl)
      super(lamb)
    elsif lamb.kind_of?(FlatMapl)
      super(lamb)
    else
      super(lamb)
    end
  end

  def |(lamb)
    if lamb.kind_of?(Mapl)
      super(lamb)
    elsif lamb.kind_of?(FlatMapl)
      super(lamb)
    else
      super(lamb)
    end
  end

end

class Mapl < FlatMapl

end

class Filterl < FlatMapl

end