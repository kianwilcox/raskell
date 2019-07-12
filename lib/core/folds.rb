require 'singleton'


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
       Foldl.new(*(self.monoids + foldl.monoids))
     else
       raise "Cannot add two non-folds together"
     end
   end

   def call(stream)
     if stream.respond_to?(:to_stream)
        if @monoids.length > 1
          fn = ->(acc, el) { F.zip_with.(F.apply_fn).(@monoids.map(&:first), acc, @monoids.map {|x| el }).to_a }
          F.foldleft.(fn, @monoids.map(&:last)).(stream).to_a
        else
          F.foldleft.(*@monoids.first).(stream)
        end
     else
       raise "Cannot call Foldl on an object that does not have to_stream defined."
     end
   end

  @@foldl = ->(f,u) { Foldl.new([f,u])} 
  def self.foldl
    @@foldl
  end
end

class F
  include Singleton
end

F.define_singleton_method(:foldl) { Foldl.foldl }

class Scanl
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

   def +(scanl)
     if scanl.kind_of?(Scanl)
       Scanl.new(*(self.monoids + scanl.monoids))
     else
       raise "Cannot add two non-folds together"
     end
   end

   def call(stream)
     if stream.respond_to?(:to_stream)
        if @monoids.length > 1
          fn = ->(acc, el) { F.zip_with.(F.apply_fn).(@monoids.map(&:first), acc, @monoids.map {|x| el }).to_a }
          F.scanleft.(fn, @monoids.map(&:last)).(stream)
        else
          F.scanleft.(*@monoids.first).(stream)
        end
     else
       raise "Cannot call Foldl on an object that does not have to_stream defined."
     end
   end

  @@scanl = ->(f,u) { Scanl.new([f,u])} 
  def self.scanl
    @@scanl
  end
end
F.define_singleton_method(:scanl) { Scanl.scanl }