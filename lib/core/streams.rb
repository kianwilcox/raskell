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
      equal_so_far = next1 == next2 || next1[1] == next2[1]
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

end

class ToStream
  ## Represents a generic to_stream function

  alias_method :standard_kind_of?, :kind_of?
  def kind_of?(clazz)
    clazz == "Proc" || standard_kind_of?(clazz)
  end

  def call(collection)
    collection.class.to_stream(collection)
  end

  def *(lamb)
    if lamb.kind_of?(FromStream)
      ## then fuse away the streams by just making this the identity function
      puts "applying stream fusion"
      Identity.new
    elsif lamb.kind_of?(ToStream)
      raise "Can't compose two ToStream functions together"
    elsif lamb.kind_of?(Identity)
      self
    else
      ->(x) { self.(lamb.(x)) }
    end
  end

  def |(lamb)
    if lamb.kind_of?(FromStream)
      ## then fuse away the streams by just making this the identity function
      puts "applying stream fusion"
      Identity.new
    elsif lamb.kind_of?(ToStream)
      raise "Can't compose two ToStream functions together"
    elsif lamb.kind_of?(Identity)
      self
    else
      ->(x) { self.(lamb.(x)) }
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

class FromStream

  alias_method :standard_kind_of?, :kind_of?
  def kind_of?(clazz)
    clazz == "Proc" || standard_kind_of?(clazz)
  end


  def initialize(func={})
    @before_function = func['before']
    @after_function = func['after']
  end

  def before?
    !!@before_function
  end

  def after?
    !!@after_function
  end

  def unfold(stream)
    result = []
    next_val = stream.next_item
    while next_val.first != :done
      result.push(next_val[1]) if next_val.first == :item
      next_val = next_val.last.next_item
    end
    result
  end

  def after_fns
    @after_fns
  end

  def before_fns
    @before_fns
  end

  def *(lamb)
    if lamb.kind_of?(ToStream)
      ## then fuse away the streams by just making this the identity function
      puts "applying stream fusion"
      Identity.new
    elsif lamb.kind_of?(FromStream)
      raise "Can't compose two FromStream functions together"
    elsif lamb.kind_of?(Identity)
      self
    else
      ->(x) { self.(lamb.(x)) }
    end
  end

  def |(lamb)
    if lamb.kind_of?(ToStream)
      ## then fuse away the streams by just making this the identity function
      puts "applying stream fusion"
      Identity.new
    elsif lamb.kind_of?(FromStream)
      raise "Can't compose two FromStream functions together"
    elsif lamb.kind_of?(Identity)
      self
    else
      ->(x) { self.(lamb.(x)) }
    end
  end

  def call(stream)
    self.unfold(stream)
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

