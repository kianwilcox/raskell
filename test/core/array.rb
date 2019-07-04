tests = [

  ## Check partial application

  ["fmap is map",

    ->() { 
      check.("equal", [1,2,3].fmap(->(x) { x * 10 }), [10, 20, 30])
    }

  ],

  ["array.take(n) gets the first n items in an array",

    ->() { 
      f = [1,2,3,4,5]
      check.("equal", f.take(3), [1,2,3])
    }

  ],

  ["array.take(n) returns array if n >= array.length",

    ->() { 
      f = [1,2,3,4,5]
      check.("equal", f.take(5), [1,2,3,4,5])
      check.("equal", f.take(10), [1,2,3,4,5])
    }

  ],

  ["array.take(0) is []",

    ->() { 
      f = [1,2,3,4,5]
      check.("equal", f.take(0), [])
    }

  ],

  ["array.drop(n) drops the first n items in an array",

    ->() { 
      f = [1,2,3,4,5]
      check.("equal", f.drop(3), [4,5])
    }

  ],

  ["array.drop(n) returns [] if n >= array.length",

    ->() { 
      f = [1,2,3,4,5]
      check.("equal", f.drop(5), [])
      check.("equal", f.drop(10), [])
    }

  ],

  ["[1,2,3,4].foldl(->(acc, el) { acc+[el+10] }, []) is [11, 12, 13, 14]",

    ->() {
      add10 = [1,2,3,4].foldl(->(acc, el) { acc+[el+10] }, [])
      check.("equal",add10,[11, 12, 13, 14]) 
    }

  ],

  ["[1,2,3,4].foldr(->(el, acc) { [el+10]+acc }, []) is [11, 12, 13, 14]",

    ->() {
      add10 = [1,2,3,4].foldr(->(el, acc) { [el+10]+acc }, [])
      check.("equal", add10, [11, 12, 13, 14])
    }

  ],

  ## Check calling on arrays and other eachable objects

  ["treating an array as a function and calling it with arguments passes those arguments to the functions in each cell of the array",

    ->() { 
      f1 = ->(x) { [x] }
      g1 = ->(x) { x + x }
      h1 = ->(x) { x * x }

      f2 = ->(x,y) { [x,y] }
      g2 = ->(x,y) { x + y }
      h2 = ->(x,y) { x * y }
      

      check.("equal", [f1,g1,h1].(5), [[5], 10,25])
      ## check that it works with more than one argument
      check.("equal", [f2,g2,h2].(3,5), [[3,5], 8, 15])
      ## and due to constant functions throwing away arguments, we can even mix different arity functions and be fine
      check.("equal", [f1,g2,4].(1,2), [[1], 3, 4])
    }

  ],

  ## try composing functions, one for the key and one for the value, and folding across a dictionary to produce a new dictionary with the key and the value

  ## Check calling on objects

  ["[1,2,3] == [1,2,3].to_stream is true",

    ->() { 
      
      check.("equal", [1,2,3].to_stream, [1,2,3].to_stream)
      check.("equal", [1,2,3].to_stream, [1,2,3])
      check.("equal", [1,2,3], [1,2,3].to_stream)
    }

  ],

  ["[1,2,3] === [1,2,3].to_stream is ...", ## do we want this one to be true, === across each item pairwise, or false, because they aren't the same type?

    ->() { 
      check.("eq", [1,2,3].to_stream, [1,2,3].to_stream)
      check.("eq", [1,2,3].to_stream, [1,2,3])
      check.("eq", [1,2,3], [1,2,3].to_stream)
    }

  ],

]


DoubleCheck.new(tests).run
