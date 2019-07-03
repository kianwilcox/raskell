class Stream
  def initialize(next_item, state)
    @next_item = next_item
    @state = state
    ## step_fn should return one of [:done], [:item element stream], or [:skip stream]
    self
  end

  def ==(stream)
    if stream.respond_to?(:to_stream)
      stream = stream.to_stream
      next1 = self.next_item
      next2 = stream.next_item
      equal_so_far = next1 == next2 || (next1.first != :skip && next1[1] == next2[1])
      while equal_so_far && !(next1 == [:done] || next2 == [:done])
        next1 = next1.last.next_item
        next2 = next2.last.next_item
        equal_so_far = next1 == next2
      end
      equal_so_far
    else
      false
    end
  end

  def ===(stream)
    if stream.respond_to?(:to_stream)
      stream = stream.to_stream
      next1 = self.next_item
      next2 = stream.next_item
      equal_so_far = next1 == next2 || (next1.first != :skip && next1[1] === next2[1])
      while equal_so_far && !(next1 == [:done] || next2 == [:done])
        next1 = next1.last.next_item
        next2 = next2.last.next_item
        equal_so_far = next1 === next2
      end
      equal_so_far
    else
      false
    end
  end

  def self.to_stream(stream)
    stream
  end

  def to_stream
    self
  end

  def from_stream
    FromStream.new().(self)
  end

  def next_item
    result = @next_item.(@state)
    while result.first == :skip
      result = result.last.next_item
    end
    @next_item.(@state)
  end

  def foldl(func, unit)
    from_stream.foldl(func, unit)
  end

end

class StreamTransducer
  def initialize(*fns)
    @functions = fns
  end
end

class ToStream
  ## Represents a generic to_stream function

  attr_reader :before_function, :after_function
  def initialize(options={})
    @before_function = options['before']
    @after_function = options['after']
    @before_function && @after_function ? ->(x) { self.(x) } : self
  end


  alias_method :standard_kind_of?, :kind_of?

  def kind_of?(clazz)
    clazz == Proc || standard_kind_of?(clazz)
  end


  def call(collection)
    before = @before_function
    after = @after_function
    collection = before.(collection) if before
    result = collection.class.to_stream(collection)
    after ? after.(result) : result
  end

  def join(converter)
    if converter.class == self.class
      self.class.new({
        'before' => self.before_function,
        'after' => converter.after_function
      })
    elsif !converter.after_function && !self.before_function
      puts "Fused"
      Identity.new
    else
      puts "Fused"
      ->(xs) { 
        xs = self.before_function.(xs) if self.before_function
        xs = converter.after_function.(xs) if converter.after_function
        xs
      }
    end
  end

  def fuse(before_converter, after_converter)
    if (before_converter.class == after_converter.class) || (before_converter.after_function == nil && after_converter.before_function == nil)
      before_converter.join(after_converter)
    else
      ->(xs) { after_converter.(self.(before_converter.(xs))) }
    end

  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif lamb.kind_of?(FromStream) || lamb.kind_of?(ToStream) 
      ## then fuse away the streams by just making this the identity function
      self.fuse(lamb, self)
    elsif !self.after_function
      self.class.new({ 'before' => self.before_function  ?  self.before_function * lamb  :  lamb })
    else
      ->(xs) { self.(lamb.(xs))}
    end
  end

  def |(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif lamb.kind_of?(FromStream) || lamb.kind_of?(ToStream) 
      ## then fuse away the streams by just making this the identity function
      self.fuse(self, lamb)
    elsif !self.before_function
      self.class.new({ 'after' => self.after_function  ?  self.after_function | lamb : lamb })
    else
      ->(xs) { lamb.(self.(xs)) }
    end
  end

  def <=(val)
    # feed data from the right
    self.(val.())
  end

  def >=(lamb)
    # feed data from the left, assuming I am a wrapped Object of some sort
    lamb.(self)
  end
end


class FromStream

  attr_accessor :before_function, :after_function
  def initialize(options={})
    @before_function = options['before']
    @after_function = options['after']
    @before_function && @after_function ? ->(x) { self.(x) } : self
  end


  alias_method :standard_kind_of?, :kind_of?
  def kind_of?(clazz)
    clazz == Proc || standard_kind_of?(clazz)
  end


  def call(stream)
    before = @before_function
    after = @after_function
    stream = before.(stream) if before
    result = self.unfold(stream)
    after ? after.(result) : result
  end

  def unfold(stream)
    result = []
    stream = stream.to_stream
    next_val = stream.next_item
    while next_val.first != :done
      result.push(next_val[1]) if next_val.first == :item
      next_val = next_val.last.next_item
    end
    result
  end

  def join(converter)
    if converter.class == self.class
      self.class.new({
        'before' => self.before_function,
        'after' => converter.after_function
      })
    elsif !converter.after_function && !self.before_function
      puts "Fused"
      Identity.new
    else
      puts "Fused"
      ->(xs) { 
        xs = self.before_function.(xs) if self.before_function
        xs = converter.after_function.(xs) if converter.after_function
        xs
      }
    end
  end

  def fuse(before_converter, after_converter)
    if (before_converter.class == after_converter.class) || (before_converter.after_function == nil && after_converter.before_function == nil)
      before_converter.join(after_converter)
    else
      ->(xs) { after_converter.(self.(before_converter.(xs))) }
    end

  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif lamb.kind_of?(FromStream) || lamb.kind_of?(ToStream) 
      ## then fuse away the streams by just making this the identity function
      self.fuse(lamb, self)
    elsif !self.after_function
      self.class.new({ 'before' => self.before_function  ?  self.before_function * lamb  :  lamb })
    else
      ->(xs) { self.(lamb.(xs))}
    end
  end

  def |(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif lamb.kind_of?(FromStream) || lamb.kind_of?(ToStream) 
      ## then fuse away the streams by just making this the identity function
      self.fuse(self, lamb)
    elsif !self.before_function
      self.class.new({ 'after' => self.after_function  ?  self.after_function | lamb : lamb })
    else
      ->(xs) { lamb.(self.(xs)) }
    end
  end

  def <=(val)
    # feed data from the right
    self.(val.())
  end

  def >=(lamb)
    # feed data from the left, assuming I am a wrapped Object of some sort
    lamb.(self.())
  end
end

