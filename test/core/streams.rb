tests = [

  ## Check partial application

  ["streams are equal if their elements are equal",

    ->() { 
      s1 = [1,2,3,4,5].to_stream
      s2 = [1,2,3,4,5].to_stream
      s3 = [5,4,3,2,1].to_stream
      check.("equal", s1, s2)
      check.("not_equal", s2, s3)
    }

  ],

  ["streams and any container that supports F.to_stream are equal if they are element-wise equal",

    ->() { 
      s1 = [1,2,3,4,5,6].to_stream
      s2 = [1,2,3,3,5,6].to_stream
      
      l1 = [1,2,3,4,5,6]
      l2 = [1,2,3,3,5,6]
      check.("equal", l1, s1)
      check.("equal", s1, l1)

      check.("equal", l2, s2)
      check.("equal", s2, l2)

      check.("not_equal", s1, l2)
      check.("not_equal", l2, s1)

    }

  ],

  ["streams also act as functions - calling a stream with arguments is equivalent to a new stream where each value is the result of calling the element with those arguments",

    ->() { 
      s = [F.plus, F.times.(10), 3].to_stream
      check.("equal", s.(1,5), [6,10,3])
      check.("equal", s.(1,5).class, Stream)
    }

  ],

  ["applying the Identity.new function to anything returns anything",

    ->() { 
      f = Identity.new
      check.("equal", f.(1), 1)
    }

  ],

  ["composing the Identity.new function with anything returns anything",

    ->() { 
      f = ->(x) { 1 }
      g = Identity.new
      check.("equal", (f * g).(10), 1)
      check.("equal", (g * f).(10), 1)
      check.("equal", (g * g).(10), 10)
    }
  ],

  ["able to fuse away a to_stream composed with a from_stream, but not the other way around",

    ->() { 
      f = F.to_stream * F.from_stream
      g = F.to_stream * (F.to_stream * F.from_stream) * F.from_stream
      h = F.from_stream | (F.from_stream | F.to_stream) | F.to_stream
      i = F.to_stream | F.from_stream
      j = F.from_stream * F.to_stream
      ## should be fusing 7 times
      check.("equal", f.class, Identity)
      check.("equal", g.class, Identity)
      check.("equal", h.class, Identity)
      check.("equal", i.class, Proc)
      check.("equal", i.class, Proc)
    }

  ],

  ["able to fuse away two streams into an Identity.new function even when F.to_stream and F.from_stream have been composed with another lambda",

    ->() { 
      f = F.from_stream * ->(x) { x }
      g = ->(x) { x } * F.to_stream
      h = ->(x) { x } | F.from_stream
      i = F.to_stream | ->(x) { x }

      f2 = F.to_stream * ->(x) { x }
      g2 = ->(x) { x } * F.from_stream
      h2 = ->(x) { x } | F.from_stream
      i2 = F.to_stream | ->(x) { x }

      ## what we really want is to check if there's fusion happening at all
      ## there should be 4 fusion events below, but are currenlty none
      check.("equal", (g * f).([1,2,3,4,5].to_stream), [1,2,3,4,5])
      check.("equal", (h | i).([1,2,3,4,5].to_stream), [1,2,3,4,5])

      check.("equal", (g2 * f2).([1,2,3,4,5].to_stream), [1,2,3,4,5])
      check.("equal", (h2 | i2).([1,2,3,4,5].to_stream), [1,2,3,4,5])
    }

  ],

  #TODO: FILL IN THE TESTS BELOW WITH REAL STUFF

  ["composing a ToStream with a normal lambda on both sides returns a ToStream with a before and after",

    ->() { 
      f = F.to_stream * ->(x) { x }
      g = ->(x) { x } * f
      check.("equal", f.class, ToStream)
      check.("equal", f.before_function.class, Proc)
      check.("equal", f.after_function, nil)
      check.("equal", g.after_function.class, Proc)
      check.("equal", g.before_function.class, Proc)
      check.("equal", g.class, ToStream)

    }

  ],

  ["piping a ToStream with a normal lambda returns on both sides returns a proc",

    ->() { 
      f = ->(x) { x } | F.to_stream 
      g = f | ->(x) { x }
      check.("equal", f.class, ToStream)
      check.("equal", f.before_function.class, Proc)
      check.("equal", f.after_function, nil)
      check.("equal", g.after_function.class, Proc)
      check.("equal", g.before_function.class, Proc)
      check.("equal", g.class, ToStream)
    }

  ],

  ["composing a FromStream with a normal lambda on both sides returns a proc",

    ->() { 
      f = F.from_stream * ->(x) { x }
      g = ->(x) { x } * f
      check.("equal", f.class, FromStream)
      check.("equal", f.before_function.class, Proc)
      check.("equal", f.after_function, nil)
      check.("equal", g.after_function.class, Proc)
      check.("equal", g.before_function.class, Proc)
      check.("equal", g.class, FromStream)
    }

  ],

  ["piping a FromStream with a normal lambda returns on both sides returns a proc",

    ->() { 
      f = ->(x) { x } | F.from_stream 
      g = f | ->(x) { x }
      check.("equal", f.class, FromStream)
      check.("equal", f.before_function.class, Proc)
      check.("equal", f.after_function, nil)
      check.("equal", g.after_function.class, Proc)
      check.("equal", g.before_function.class, Proc)
      check.("equal", g.class, FromStream)
    }

  ],


  ["composing a FromStream with a normal lambda with a ToStream returns a StreamTransducer",

    ->() { 
      f = F.from_stream * ->(x) { x } * F.to_stream
      check.("equal", f.([1,2,3].to_stream), [1,2,3])
      check.("equal", f.class, StreamTransducer)
    }

  ],

  ["piping a ToStream with a stream function with a FromStream returns a StreamTransducer",

    ->() { 
      f = F.to_stream | F.map.(F.times.(10)) | F.from_stream
      check.("equal", f.class, StreamTransducer)
      check.("equal", f.([1,2,3]), [10,20,30])
    }

  ],

  ["composing two StreamTransducers fuses away intermediate data structures",

    ->() { 
      f = F.from_stream * F.map.(F.times.(10)) * F.to_stream
      g = F.from_stream * F.map.(F.plus.(10)) * F.to_stream
      check.("equal", (f*g).class, StreamTransducer)
      check.("equal", (f*g).after_function, nil)
      check.("equal", (f*g).before_function, nil)
      check.("equal", (f*g).([1,2,3]), [110,120,130])
    }

  ],

  ["piping two StreamTransducers fuses away intermediate data structures",

    ->() { 
      f = F.to_stream | F.map.(F.times.(10)) | F.from_stream
      g = F.to_stream | F.map(F.plus.(10)) | F.from_stream
      check.("equal", (g|f).([1,2,3]), [110,120,130])
      check.("equal", (g|f).class, StreamTransducer)
    }

  ],

  ["composing an arbitrary number of lambdas on only one side of a ToStream doesn't stop it from being fusable with a FromStream on the other",

    ->() { 
      f = F.to_stream *  F.map.(->(y) { y*2 }) *  F.map.(->(x) { x+10 })
      g = F.from_stream
      check.("equal", f.class, ToStream)
      check.("equal", g.(f.([1])), [22])
      ## there should be a check for fusion here
      check.("equal", (g * f).class, StreamTransducer)
      check.("equal", (f | g).class, StreamTransducer)
    }

  ],

  ["composing an arbitrary number of lambdas on only one side of a FromStream doesn't stop it from being fusable with a ToStream on the other",

    ->() { 
      f = F.from_stream *  F.map.(->(y) { y*2 }) *  F.map.(->(x) { x+10 })
      g = F.to_stream
      check.("equal", f.class, FromStream)
      check.("equal", g.(f.([1])), [22])
      ## there should be a check for fusion on each of the following
      check.("equal", (g * f).class, Proc)
      check.("equal", (f | g).class, Proc)
    }

  ],

  ["piping an arbitrary number of lambdas on only one side of a ToStream doesn't stop it from being fusable with a FromStream on the other",

    ->() { 
      f = F.to_stream |  F.map.(->(y) { y*2 }) |  F.map.(->(x) { x+10 })
      g = F.from_stream
      check.("equal", f.class, ToStream)
      check.("equal", g.(f.([1])), [12])
      ## there should be a check for fusion here
      check.("equal", (f * g).class, Proc)
      check.("equal", (g | f).class, Proc)
    }

  ],

  ["piping an arbitrary number of lambdas on only one side of a FromStream doesn't stop it from being fusable with a ToStream on the other",

    ->() { 
      f = F.from_stream |  F.map.(->(y) { y*2 }) |  F.map.(->(x) { x+10 })
      g = F.to_stream
      check.("equal", f.class, FromStream)
      check.("equal", g.(f.([1])), [12])
      ## there should be a check for fusion here
      check.("equal", (f * g).class, Proc)
      check.("equal", (g | f).class, Proc)
    }

  ],

  ## Next step, StreamTransducers
  # first, confirm that foldl





  



]


DoubleCheck.new(tests).run