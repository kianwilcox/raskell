class Stream
  attr_accessor :state
  def initialize(next_item, state)
    @next_item = next_item
    @state = state
    ## step_fn should return one of [:done], [:yield element stream], or [:skip stream]
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

  def to_a
    from_stream
  end

  def next_item
    @next_item.(@state)
  end

  def next_item_function
    @next_item
  end 

  def foldl(func, unit)
    from_stream.foldl(func, unit)
  end

  def *(to_stream)
    if to_stream.kind_of?(Stream)
      next_fn = ->(state) {

      }
      Stream.new(next_fn, [self, to_stream])
    else
      raise "Cannot interleave a stream with a #{to_stream.class}"
    end
  end

  def call(*args)
    next_fn = ->(next_item) {
      tag = next_item.first
      fn = next_item[1]
      stream = next_item.last
      if tag == :done
        [:done]
      elsif tag == :skip
        [:skip, Stream.new(next_fn, stream.state)]
      elsif tag == :yield
        [:yield, fn.(*args), Stream.new(next_fn, stream.state)]
      else
        raise "#{next_item} is a malformed stream result!"
      end
    } * self.next_item_function
    Stream.new(next_fn, self.state)
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
    #puts 'unfolding'
    #puts stream.inspect
    next_val = stream.next_item
    while next_val.first != :done
      #puts next_val.inspect
      result.push(next_val[1]) if next_val.first == :yield
      next_val = next_val.last.next_item
    end
    result
  end

  def join(converter)
    if converter.class == self.class && !converter.before_function && !self.after_function
      self.class.new({
        'before' => self.before_function,
        'after' => converter.after_function
      })
    elsif [ToStream, StreamTransducer].include?(converter.class) && !converter.before_function && !self.after_function
      puts "Fused"
      (converter.after_function || Identity.new) * (self.before_function || Identity.new)
    else
      ->(xs) { converter.(self.(xs)) }
    end
  end

  def fuse(before_converter, after_converter)
    if (before_converter.class == after_converter.class) || (before_converter.after_function == nil && after_converter.before_function == nil)
      before_converter.join(after_converter)
    else
      ->(xs) { after_converter.(before_converter.(xs)) }
    end

  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif lamb.kind_of?(FromStream) || lamb.kind_of?(ToStream) 
      ## then fuse away the streams by just making this the Identity.new function
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
      ## then fuse away the streams by just making this the Identity.new function
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

  def join(from)
    to = self
    if from.class == to.class && !from.before_function && !to.after_function
      to.class.new({
        'before' => to.before_function,
        'after' => from.after_function
      })
    elsif [FromStream, StreamTransducer].include?(from.class) && !from.before_function && !to.after_function
      StreamTransducer.new({
        'before' =>  to.before_function,
        'after' => from.after_function
      })
    else
      ->(xs) { from.(to.(xs)) }
    end
  end

  def fuse(before_converter, after_converter)
    if (before_converter.class == after_converter.class) || (before_converter.after_function == nil && after_converter.before_function == nil)
      before_converter.join(after_converter)
    else
      ->(xs) { after_converter.(before_converter.(xs)) }
    end

  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif lamb.kind_of?(FromStream) || lamb.kind_of?(ToStream) 
      ## then fuse away the streams by just making this the Identity.new function
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
      ## then fuse away the streams by just making this the Identity.new function
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

class StreamTransducer

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
    #puts 'unfolding'
    #puts stream.inspect
    next_val = stream.next_item
    while next_val.first != :done
      #puts next_val.inspect
      result.push(next_val[1]) if next_val.first == :yield
      next_val = next_val.last.next_item
    end
    result
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