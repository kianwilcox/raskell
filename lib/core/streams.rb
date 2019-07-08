class Stream
  include Enumerable

  def each(&fn)
    item = self.next_item
    while item != [:done]
      fn.call(item[1]) if item.first == :yield
      item = item.last.next_item
    end
    self
  end

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
      next1 = self.another
      next2 = stream.another
      equal_so_far = next1 == next2 || (next1.first != :skip && next1[1] == next2[1])
      while equal_so_far && !(next1 == [:done] || next2 == [:done])
        next1 = next1.last.another
        next2 = next2.last.another
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
      next1 = self.another
      next2 = stream.another
      equal_so_far = next1 == next2 || (next1.first != :skip && next1[1] === next2[1])
      while equal_so_far && !(next1 == [:done] || next2 == [:done])
        next1 = next1.last.another
        next2 = next2.last.another
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

  def another
    item = self.next_item
    while item.first == :skip
      item = item.last.next_item
    end
    item
  end

  def foldl(func, unit)
    from_stream.foldl(func, unit)
  end

  def *(stream)
    if stream.kind_of?(Stream)
      next_fn1 = ->(state) {
        #... and then Stream.new(next_fn2, ...)
      }
      next_fn2 = ->(state) {
        #... and then Stream.new(next_fn1, ...)
      }
      Stream.new(next_fn, [self, stream])
    else
      raise "Cannot interleave a stream with a #{to_stream.class}"
    end
  end

  def +(stream)
    if stream.kind_of?(Stream)

    else
      "Cannot append a stream to a #{to_stream.class}"
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
  def initialize(clazz=Array, options={})
    if clazz.kind_of?(Hash)
      options = clazz
      clazz = Array
    end
    @before_function = options['before']
    @after_function = options['after']
    @output_type = clazz
  end

  attr_accessor :before_function, :after_function
  singleton_class.send(:alias_method, :standard_new, :new)
  def self.new(clazz=Array,options={})
    options['before'] && options['after'] ? ->(x) { self.standard_new(clazz,options).(x) } : self.standard_new(clazz,options)
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
    result = @output_type.new
    # puts 'unfolding'
    # puts stream.inspect
    next_val = stream.next_item
    while next_val.first != :done
      #puts next_val.inspect
      result.push(next_val[1]) if next_val.first == :yield
      next_val = next_val.last.next_item
    end
    result
  end

  def join(after)
    before = self
    if after.class == before.class && !after.before_function && !before.after_function
      before.class.new({
        'before' => before.before_function,
        'after' => after.after_function
      })
    elsif ToStream == after.class
      StreamTransducer.new({
        'before' =>  before.before_function,
        'inside' => (after.before_function || Identity.new) * ((after.kind_of?(StreamTransducer) ? inside_function : nil) || Identity.new) * (before.after_function || Identity.new),
        'after' => after.after_function
      })
    elsif StreamTransducer == after.class && !before.after_function && !after.before_function
      StreamTransducer.new({
          'before' => before.before_function,
          'inside' => after.inside_function,
          'after' => after.after_function
        })
    else
      puts "before is "
      puts before.class
      puts "with before function" if before.before_function
      puts "with after function" if before.after_function
      puts "---"
      puts "after is"
      puts after.class
      puts "with before function" if after.before_function
      puts "with after function" if after.after_function
      ->(xs) { after.(before.(xs)) }
    end
  end

  def fuse(before_converter, after_converter)
    before_converter.join(after_converter)
  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif [FromStream, StreamTransducer].include?(lamb.class)
      ## then fuse away the streams by just making this the Identity.new function
      self.fuse(lamb, self)
    else
      self.class.new({ 'before' => (self.before_function || Identity.new) * lamb ,
                       'after' => self.after_function})
    end
  end

  def |(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif [FromStream, ToStream, StreamTransducer].include?(lamb.class)
      ## then fuse away the streams by just making this the Identity.new function
      self.fuse(self, lamb)
    else
      self.class.new({ 'before' => self.before_function,
                       'after' => (self.after_function || Identity.new) | lamb })
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
  def initialize(options={})
    @before_function = options['before']
    @after_function = options['after']
  end

  attr_reader :before_function, :after_function
  singleton_class.send(:alias_method, :standard_new, :new)
  def self.new(options={})
    options['before'] && options['after'] ? ->(x) { self.standard_new(options).(x) } : self.standard_new(options)
  end

  

  alias_method :standard_kind_of?, :kind_of?

  def kind_of?(clazz)
    clazz == Proc || standard_kind_of?(clazz)
  end


  def call(collection)
    before = @before_function
    after = @after_function
    collection = before.(collection) if before
    result = collection.to_stream
    after ? after.(result) : result
  end

  def join(after)
    ## to = ToStream, from = FromStream
    ## to = ToStream, from = ToStream
    ## to = ToStream, from = StreamTransducer
    before = self
    if after.class == before.class && !after.before_function && !before.after_function
      before.class.new({
        'before' => before.before_function,
        'after' => after.after_function
      })
    elsif FromStream == after.class
      StreamTransducer.new({
        'before' =>  before.before_function,
        'inside' => (after.before_function || Identity.new) * ((after.kind_of?(StreamTransducer) ? inside_function : nil) || Identity.new) * (before.after_function || Identity.new),
        'after' => after.after_function
      })
    elsif StreamTransducer == after.class && !before.after_function && !after.before_function
      StreamTransducer.new({
          'before' => before.before_function,
          'inside' => after.inside_function,
          'after' => after.after_function
        })

    else
      # puts "before is "
      # puts before.class
      # puts "with before function" if after.before_function
      # puts "with after function" if after.after_function
      # puts "---"
      # puts "after is"
      # puts after.class
      # puts "with before function" if after.before_function
      # puts "with after function" if after.after_function
      ->(xs) { after.(before.(xs)) }
    end
  end

  def fuse(before_converter, after_converter)
    before_converter.join(after_converter)
  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif [FromStream, ToStream, StreamTransducer].include?(lamb.class)
      ## then fuse away the streams by just making this the Identity.new function
      self.fuse(lamb, self)
    else
      self.class.new({ 'before' => (self.before_function || Identity.new) * lamb ,
                       'after' => self.after_function})
    end
  end

  def |(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif [FromStream, ToStream, StreamTransducer].include?(lamb.class)
      ## then fuse away the streams by just making this the Identity.new function
      self.fuse(self, lamb)
    else
      self.class.new({ 'before' => self.before_function,
                       'after' => (self.after_function || Identity.new) | lamb })
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


  def initialize(options={})
    @before_function = options['before']
    @after_function = options['after']
    @inside_function = options['inside']
  end

  attr_accessor :before_function, :after_function, :inside_function  
  singleton_class.send(:alias_method, :standard_new, :new)
  def self.new(options={})
    if options['inside'] && options['inside'].class != Identity
      options['before'] && options['after'] ? ->(x) { self.standard_new(options).(x) } : self.standard_new(options)
    else
      ->(x) { self.standard_new(options).(x) }
    end
  end

  

  def +(stream_transducer)
    ##TODO handle case where before function and after functions exist
    if stream_transducer.kind_of?(StreamTransducer) && !stream_transducer.before_function && !stream_transducer.after_function && !self.before_function && !self.after_function
      StreamTransducer.new({
        'inside' => self.inside_function + stream_transducer.inside_function
      })
    else
      raise "#{stream_transducer.class} should be of class StreamTransducer to be combined via + with another StreamTransducer"
    end
  end


  alias_method :standard_kind_of?, :kind_of?
  def kind_of?(clazz)
    clazz == Proc || standard_kind_of?(clazz)
  end


  def call(arg)
    before = self.before_function || Identity.new
    after = self.after_function || Identity.new
    after <= (F.from_stream * ->(stream) { 
      next_fn = self.inside_function * stream.next_item_function 
      Stream.new(next_fn, stream)
    } <= F.to_stream.(before.(arg)))
  end

  def join(after)

    ## to = StreamTransducer, from = FromStream
    ## to = StreamTransducer, from = ToStream
    ## to = StreamTransducer, from = StreamTransducer
    before = self
    if after.class == before.class && !after.before_function && !before.after_function
      before.class.new({
        'before' => before.before_function,
        'inside' => after.inside_function * before.inside_function,
        'after' => after.after_function
      })
    elsif [ToStream,FromStream].include?(after.class) && !after.before_function && !before.after_function ## TODO TOMORROW figure this otu
      ## if i am a transducer and have no after, and from has no before
      ## then I cleanly merge with from and make a new transducer
      ## if i have an after, then I produce a lambda?
      ## NEXT STEP is to make a buuunch of test cases for all of this transducer/from/to merge stuff
      ## and then keep implementing until they all pass
      ## then build
      StreamTransducer.new({
        'before' =>  before.before_function,
        'inside' => before.inside_function,
        'after' => after.after_function
      })
    else
      puts "before is "
      puts before.class
      puts "with before function" if before.before_function
      puts "with after function" if before.after_function
      puts "---"
      puts "after is"
      puts after.class
      puts "with before function" if after.before_function
      puts "with after function" if after.after_function
      ->(xs) { after.(before.(xs)) }
    end
  end

  def fuse(before_converter, after_converter)
    before_converter.join(after_converter)
  end

  def *(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif [ToStream, StreamTransducer].include?(lamb.class)
      ## then fuse away the streams by just making this the Identity.new function
      self.fuse(lamb, self)
    else
      self.class.new({ 'before' => (self.before_function || Identity.new) * lamb ,
                       'inside' => self.inside_function,
                       'after' => self.after_function})
    end
  end

  def |(lamb)
    if lamb.kind_of?(Identity)
      self
    elsif [FromStream, ToStream, StreamTransducer].include?(lamb.class)
      ## then fuse away the streams by just making this the Identity.new function
      self.fuse(self, lamb)
    else
      self.class.new({ 'before' => self.before_function,
                       'inside' => self.inside_function,
                       'after' => (self.after_function || Identity.new) | lamb })
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