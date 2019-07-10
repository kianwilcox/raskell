tests = [


  ## The foundational functions

  ["to_stream works on an Array, Hash, or Set depending on what you pass it",

    ->() { 
      f = F.to_stream
      check.("equal", f.([1,2,3]), [1,2,3])
      check.("equal", f.(Set.new([1,2,3,2,3])), [1,2,3])
      check.("equal", f.({'one' => 1, "two" => 2, "three" => 3}).to_a, [["one", 1],["three", 3], ["two", 2],]) ## by default orders by key
      check.("equal", f.([1,2,3]).class, Stream)
      check.("equal", f.(Set.new([1,2,3,2,3])).class, Stream)
      check.("equal", f.({'one' => 1, "two" => 2, "three" => 3}).class, Stream)
    }

  ],


  ["from_stream on a stream equals an Array, Hash, or Set depending on what you pass it",

    ->() { 
      f = F.to_a
      g = F.to_h
      h = F.to_set
      s1 = [1,2,3,4].to_stream
      s2 = ["one", "two", "three", "four"].to_stream
      s3 = [3,4,5,6].to_stream
      check.("equal", f.(s1).class, Array)
      check.("equal", f.(s1), [1,2,3,4])
      check.("equal", g.(s2.to_a.zip(s1.to_a).to_stream).class, Hash)
      check.("equal", g.(s2.to_a.zip(s1.to_a).to_stream), {"one"=>1, "two"=>2, "three"=>3, "four"=>4})
      check.("equal", h.(s1).class, Set)
      check.("equal", h.(s1), Set.new(s1))
    }

  ],

  ["apply.(f,x) equals f.(x)",

    ->() { 
      f = ->(x) { x * 2 }
      check.("equal", F.apply.(f, 2), 4)
    }

  ],

  ["apply_with.(x,f) equals f.(x)",

    ->() { 
      f = ->(x) { x * 2 }
      check.("equal", F.apply_with.(2,f), 4)
    }

  ],

  ["id.(x) equals x",

    ->() { 
      f = F.id
      check.("equal", f.(1), 1)
      check.("equal", f.(true), true)
      check.("equal", f.([1,2,3]), [1,2,3])
    }

  ],

  ["flip.(->(x,y) { x - y}).(2,3) equals 1",

    ->() { 
      f = F.flip.(->(x,y) { x - y })
      check.("equal", f.(2,3), 1)
    }

  ],

  ["slf.(->(x,y) { x * y}).(3) equals 9",

    ->() { 
      f = F.slf.(->(x,y) { x * y})
      check.("equal", f.(3), 9)
    }

  ],

  ["fix.(->(x) { x < 5  ?  x  :  x - 1 }).(10) equals 4",

    ->() { 
      f = F.fix.(->(x) { x < 5  ?  x  :  x - 1 })
      check.("equal", f.(10), 4)
    }

  ],

  ## then booleans

  ["the basic boolean functions all work",

    ->() { 
      check.("equal", F.not.(true), false)
      check.("equal", F.not.(false), true)
      
      check.("equal", F.and.(true, true), true)
      check.("equal", F.and.(true, false), false)
      check.("equal", F.and.(false, true), false)
      check.("equal", F.and.(false, false), false)

      check.("equal", F.nand.(true, true), false)
      check.("equal", F.nand.(true, false), true)
      check.("equal", F.nand.(false, true), true)
      check.("equal", F.nand.(false, false), true)

      check.("equal", F.or.(true, true), true)
      check.("equal", F.or.(true, false), true)
      check.("equal", F.or.(false, true), true)
      check.("equal", F.or.(false, false), false)

      check.("equal", F.nor.(true, true), false)
      check.("equal", F.nor.(true, false), false)
      check.("equal", F.nor.(false, true), false)
      check.("equal", F.nor.(false, false), true)
      
      check.("equal", F.xor.(true, true), false)
      check.("equal", F.xor.(true, false), true)
      check.("equal", F.xor.(false, true), true)
      check.("equal", F.xor.(false, false), false)
    }

  ],


  ## then the basic arithmetic functions

  ["inc.(1) equals 2",

    ->() { 
      f = F.inc
      check.("equal", f.(1), 2)
    }

  ],

  ["dec.(1) equals 0",

    ->() { 
      f = F.dec
      check.("equal", f.(1), 0)
    }

  ],

  ["plus.(1,2) equals 3",

    ->() { 
      f = F.plus
      check.("equal", f.(1,2), 3)
    }

  ],

  ["times(3,2) equals 6",

    ->() { 
      f = F.times
      check.("equal", f.(3,2), 6)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = F.sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_by(2,7) equals 5",

    ->() { 
      f = F.sub_by
      check.("equal", f.(2,7), 5)
    }

  ],

  ["div_from(6,2) equals 3",

    ->() { 
      f = F.div_from
      check.("equal", f.(6,2), 3)
    }

  ],

  ["div_by(2,10) equals 5",

    ->() { 
      f = F.div_by
      check.("equal", f.(2,10), 5)
    }

  ],

  ["sub_from(F.infinity,2) equals F.infinity",

    ->() { 
      f = F.sub_from
      check.("equal", f.(F.infinity,2), F.infinity)
    }

  ],

  ["sub_from(F.negative_infinity,2) equals F.negative_infinity",

    ->() { 
      f = F.plus
      check.("equal", f.(F.negative_infinity,2), F.negative_infinity)
    }

  ],


  ## then ln, lg, log, log_base, e, pi, exp, square, sqrt - later


  ## then max and min


  ["max(5,2) is 5",

    ->() { 
      f = F.max
      check.("equal", f.(5,2), 5)
    }

  ],

  ["max(2,5) is 5",

    ->() { 
      f = F.max
      check.("equal", f.(2,5), 5)
    }

  ],

  ["max(F.infinity,5) is F.infinity",

    ->() { 
      f = F.max
      check.("equal", f.(F.infinity,5), F.infinity)
    }

  ],

  ["max(2, F.negative_infinity) is 2",

    ->() { 
      f = F.max
      check.("equal", f.(2, F.negative_infinity), 2)
    }

  ],

  ["min(5,2) is 2",

    ->() { 
      f = F.min
      check.("equal", f.(5,2), 2)
    }

  ],

  ["min(2,5) is 2",

    ->() { 
      f = F.min
      check.("equal", f.(2,5), 2)
    }

  ],

  ["min(F.infinity,5) is F.infinity",

    ->() { 
      f = F.min
      check.("equal", f.(F.infinity,5), 5)
    }

  ],

  ["min(2, F.negative_infinity) is 2",

    ->() { 
      f = F.min
      check.("equal", f.(2, F.negative_infinity), F.negative_infinity)
    }

  ],


  ## then arithmetic comparison functions


  ["gt(5,2) is true",

    ->() { 
      f = F.gt
      check.("equal", f.(5,2), true)
    }

  ],

  ["gt(5,5) is false",

    ->() { 
      f = F.gt
      check.("equal", f.(5,5), false)
    }

  ],

  ["gt(4,5) is false",

    ->() { 
      f = F.gt
      check.("equal", f.(4,5), false)
    }

  ],

  ["gt(F.infinity,500000) is true",

    ->() { 
      f = F.gt
      check.("equal", f.(F.infinity,500000), true)
    }

  ],

  ["gt(500000,infinity) is false",

    ->() { 
      f = F.gt
      check.("equal", f.(500000, F.infinity), false)
    }

  ],

  ["gt(F.negative_infinity,-500000) is false",

    ->() { 
      f = F.gt
      check.("equal", f.(F.negative_infinity,-500000), false)
    }

  ],

  ["gt(-500000, F.negative_infinity) is true",

    ->() { 
      f = F.gt
      check.("equal", f.(-500000, F.negative_infinity), true)
    }

  ],

  ["gte(5,2) is true",

    ->() { 
      f = F.gte
      check.("equal", f.(5,2), true)
    }

  ],

  ["gte(5,5) is true",

    ->() { 
      f = F.gte
      check.("equal", f.(5,5), true)
    }

  ],

  ["gte(4,5) is false",

    ->() { 
      f = F.gte
      check.("equal", f.(4,5), false)
    }

  ],

  ["gte(F.infinity,500000) is true",

    ->() { 
      f = F.gte
      check.("equal", f.(F.infinity,500000), true)
    }

  ],

  ["gte(500000,infinity) is false",

    ->() { 
      f = F.gte
      check.("equal", f.(500000, F.infinity), false)
    }

  ],

  ["gte(F.negative_infinity,-500000) is false",

    ->() { 
      f = F.gte
      check.("equal", f.(F.negative_infinity,-500000), false)
    }

  ],

  ["gte(-500000, F.negative_infinity) is true",

    ->() { 
      f = F.gte
      check.("equal", f.(-500000, F.negative_infinity), true)
    }

  ],

  ["lt(5,2) is false",

    ->() { 
      f = F.lt
      check.("equal", f.(5,2), false)
    }

  ],

  ["lt(5,5) is false",

    ->() { 
      f = F.lt
      check.("equal", f.(5,5), false)
    }

  ],

  ["lt(4,5) is true",

    ->() { 
      f = F.lt
      check.("equal", f.(5,4), false)
    }

  ],

  ["lt(F.infinity,500000) is false",

    ->() { 
      f = F.lt
      check.("equal", f.(F.infinity,500000), false)
    }

  ],

  ["lt(500000,infinity) is true",

    ->() { 
      f = F.lt
      check.("equal", f.(500000, F.infinity), true)
    }

  ],

  ["lt(F.negative_infinity,-500000) is true",

    ->() { 
      f = F.lt
      check.("equal", f.(F.negative_infinity,-500000), true)
    }

  ],

  ["lte(-500000, F.negative_infinity) is false",

    ->() { 
      f = F.lte
      check.("equal", f.(-500000, F.negative_infinity), false)
    }

  ],

  ["lte(5,2) is false",

    ->() { 
      f = F.lte
      check.("equal", f.(5,2), false)
    }

  ],

  ["lte(5,5) is true",

    ->() { 
      f = F.lte
      check.("equal", f.(5,5), true)
    }

  ],

  ["lte(4,5) is true",

    ->() { 
      f = F.lte
      check.("equal", f.(5,4), false)
    }

  ],

  ["lte(F.infinity,500000) is false",

    ->() { 
      f = F.lte
      check.("equal", f.(F.infinity,500000), false)
    }

  ],

  ["lte(500000,infinity) is true",

    ->() { 
      f = F.lte
      check.("equal", f.(500000, F.infinity), true)
    }

  ],

  ["lte(F.negative_infinity,-500000) is true",

    ->() { 
      f = F.lte
      check.("equal", f.(F.negative_infinity,-500000), true)
    }

  ],

  ["lte(-500000, F.negative_infinity) is false",

    ->() { 
      f = F.lte
      check.("equal", f.(-500000, F.negative_infinity), false)
    }

  ],


  ## and equality marks our transition from numbers to other kinds of 'sequences' - === is eq, == is equals

  ["equal(5,2) is false",

    ->() { 
      f = F.equal
      check.("equals", f.(5,2), false)
    }

  ],

  ["equals(5,2) is false",

    ->() { 
      f = F.equals
      check.("equal", f.(5,2), false)
    }

  ],

  ["equals(5,5) is true",

    ->() { 
      f = F.equals
      check.("equal", f.(5,5), true)
    }

  ],

  ["equals([[1],[2],[3]], [[1],[2],[3]]) is true for structurally deep objects",

    ->() { 
      f = F.equals
      check.("equal", f.([[1],[2],[3]], [[1],[2],[3]]), true)
    }

  ],

  ["eq(5,2) is false",

    ->() { 
      f = F.eq
      check.("equal", f.(5,2), false)
    }

  ],

  ["eq(5,5) is true",

    ->() { 
      f = F.eq
      check.("equal", f.(5,5), true)
    }

  ],


  ## 


  ["sub_from(5,2) equals 3",

    ->() { 
      f = F.sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = F.sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ## core stream combinators

  ["to_stream transforms an array of elements into a stream",

    ->() { 
      f = F.to_stream
      check.("equal", f.([1,2,3,4,5]), [1,2,3,4,5].to_stream)
      check.("equal", f.([1,2,3,4,5]).class, Stream)
      
    }

  ],

  ["from_stream transforms a stream of elements into an array",

    ->() { 
      f = F.from_stream
      check.("equal", f.([1,2,3,4,5].to_stream), [1,2,3,4,5])
      check.("equal", f.([1,2,3,4,5].to_stream).class, Array)
      
    }

  ],

  ["empty returns a stream whose next_item is [:done]",

    ->() { 
      check.("equal", F.empty.class, Stream)
      check.("equal", F.empty.next_item, [:done])
      check.("equal", F.empty, [])
      
    }

  ],

  ["wrap takes a single element and wraps it into a single-element stream",

    ->() { 
      f = F.wrap
      check.("equal", f.(5), [5])
      check.("equal", f.(5).class, Stream)
      
    }

  ],

  ["cons takes an element and a stream and returns a new stream with the element added to the front of the old stream",

    ->() { 
      f = F.cons
      check.("equal", f.(1,[2,3,4]), [1,2,3,4])
      check.("equal", f.(1,[2,3,4]).class, Stream)
      
    }

  ],

  ["first takes a stream and returns the first element, or raises an exception if there is none",

    ->() { 
      f = F.first
      check.("equal", f.([2,3,4].to_stream), 2)
      check.("equal", f.(F.empty), Nothing)
      
    }

  ],

  ["rest takes a stream and returns the rest of the stream after discarding the first element, or raises an exception if there is none",

    ->() { 
      f = F.rest
      check.("equal", f.([2,3,4].to_stream), [3,4])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      check.("equal", f.(F.empty), Nothing)
      
    }

  ],


  ["take.(n) takes n items from a stream. If there are less than n items, it returns the stream",

    ->() { 
      f = F.take.(3)
      s1 = [1,2].to_stream
      s2 = [1,2,3,4].to_stream
      check.("equal", f.(s1), [1,2])
      check.("equal", f.(s2), [1,2,3])
      check.("equal", f.(s1).class, Stream)
      
    }

  ],

  ["drop.(n) drops n items from a stream. If there are less than n items, it returns the empty stream",

    ->() { 
      f = F.drop.(3)
      s1 = [1,2].to_stream
      s2 = [1,2,3,4].to_stream
      check.("equal", f.(s1), [])
      check.("equal", f.(s2), [4])
      check.("equal", f.(s1).class, Stream)
      
    }

  ],
=begin
  ["take_except.(n) takes all but the last n items from a stream. If there are less than n items, it returns the empty stream",

    ->() { 
      f = F.rest
      check.("equal", f.([2,3,4].to_stream), [3,4])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],
=end

  ["drop_except.(n) drops all but n items from a stream. If there are less than n items, it returns the stream",

    ->() { 
      f = F.drop_except.(2)
      check.("equal", f.([2,3,4]), [3,4])
      check.("equal", f.([2,3,4]).class, Stream)
      check.("equal", f.([4].to_stream), [4])
      #check.("equal", f.([1,2]), "foobar")
      
    }

  ],

  ["take_while.(fn) takes items from a stream while the function matches, then discards the remainder",

    ->() { 
      f = F.take_while.(F.gt.(3))
      check.("equal", f.([1,2,3,4]), [1,2])
      check.("equal", f.([1,2,3,4]).class, Stream)
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["drop_while.(n) drops items from a stream while the function matches, then returns the remainder",

    ->() { 
      f = F.drop_while.(F.lt.(3))
      check.("equal", f.([5,4,3,2,1]), [3,2,1])
      check.("equal", f.([1,2,3,4]).class, Stream)
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["take_until.(fn) takes items from a stream until the function matches, then discards the remainder",

    ->() { 
      f = F.take_until.(F.lt.(5))
      check.("equal", f.([1,2,3,4,5,6,7]), [1,2,3,4,5])
      check.("equal", f.([2,3,4]).class, Stream)
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["drop_until.(n) drops items from a stream until the function matches, then returns the remainder",

    ->() { 
      f = F.drop_until.(F.lt.(5))
      check.("equal", f.([2,3,4,5,6,7,8]), [6,7,8])
      check.("equal", f.([2,3,4]).class, Stream)
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["init returns all but the last element of the stream",

    ->() { 
      f = F.init
      check.("equal", f.([2,3,4]), [2,3])
      check.("equal", f.([2,3,4]).class, Stream)
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["zip_with.(fn) zips n streams together and then applies a function to each zipped set. i.e., zip = zip_with(list), zip_with.(fn) = map(apply.(fn)) * zip, zip_with(plus) adds elements, etc",

    ->() { 
      f = F.zip_with.(F.list)
      g = F.zip_with.(F.plus)
      
      
      check.("equal", f.([2,3,4]).([4,5,6]), [[2,4], [3,5], [4,6]])
      check.("equal", g.([2,3,4]).([4,5,6]), [6, 8, 10])
      check.("equal", f.([2,3,4]).([4,5,6]).class, Stream)
      check.("equal", f.([2,3,4]).([4,5,6],[7,8,9]), [[2,4,7], [3,5,8], [4,6,9]])
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["list takes any number of arguments and returns all of them listed together in order",

    ->() { 
      f = F.list
      check.("equal", f.(1,2,3), [1,2,3])
      check.("equal", f.(1,2,3).class, Array)
      #check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["double(3) == 6, double(-3) == -6",

    ->() { 
      f = F.double
      check.("equal", f.(3), 6)
      
    }

  ],

  ["square(3) == 9, square(-3) == 9",

    ->() { 
      f = F.square
      check.("equal", f.(3), 9)
      
    }

  ],

  ["snoc adds an element to the end of a stream",

    ->() { 
      f = F.snoc
      check.("equal", f.(5,[2,3,4]), [2,3,4,5])
      check.("equal", f.(5,[2,3,4]).class, Stream)
      
    }

  ],

  ["final takes a stream and returns a stream with only the last element",

    ->() { 
      f = F.final
      check.("equal", f.([2,3,4]), [4])
      check.("equal", f.([2,3,4]).class, Stream)
      
    }

  ],

  ["last takes the last element in a stream, or raises an error if the stream is empty",

    ->() { 
      f = F.last
      check.("equal", f.([2,3,4].to_stream), 4)
      check.("raises", -> { f.(F.empty) }, "Must have at least one item")
      
    }

  ],
=begin
  ["uncons",

    ->() { 
      f = F.rest
      check.("equal", f.([2,3,4].to_stream), [3,4])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],

  ["unsnoc",

    ->() { 
      f = F.rest
      check.("equal", f.([2,3,4].to_stream), [3,4])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      check.("raises", -> { f.(F.empty) }, "foobar")
      
    }

  ],
=end
  ["reverse",

    ->() { 
      f = F.reverse
      check.("equal", f.([2,3,4]), [4,3,2])
      check.("equal", f.([2,3,4]).class, Stream)
      
    }

  ],

  ["length",

    ->() { 
      f = F.length
      check.("equal", f.([2,3,4].to_stream), 3)
      
    }

  ],

  ["concat",

    ->() { 
      f = F.concat
      check.("equal", f.([[2,3,4], [2,3,4], [2,3,4]]), [2,3,4,2,3,4,2,3,4])
      check.("equal", f.([[2,3,4], [2,3,4], [2,3,4]]).class, Stream)
      
    }

  ],

  ["enconcat adds an item between two other streams",

    ->() { 
      f = F.enconcat
      check.("equal", f.([2,3,4], 5, [6,7]), [2,3,4,5,6,7])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      
    }

  ],

  ["all? checks if every element in the stream satisfies a relation. It should short-circuit",

    ->() { 
      f = F.all?.(F.gt.(3))
      check.("equal", f.([1,1,1,1]), true)
      check.("equal", f.([1,1,3,1]), false)
      
    }

  ],

  ["any? checks if any element in the stream satisfies a relation. It should short-circuit",

    ->() { 
      f = F.any?.(F.gt.(3))
      check.("equal", f.([3,1,3,3]), true)
      check.("equal", f.([3,3,3,3]), false)
      
    }

  ],

  ["replace.(x,y) replaces every element that == x with y",

    ->() { 
      f = F.replace.(1,2)
      check.("equal", f.([1,2,3,4,1]), [2,2,3,4,2])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      
    }

  ],

  
  ["replace_with takes an element, and an element to replace,and replaces them",

    ->() { 
      f = F.replace_with.(3,4)
      check.("equal", f.([1,2,4,4,1]), [1,2,3,3,1])
      check.("equal", f.([2,3,4].to_stream).class, Stream)
      
    }

  ],
  
  ["find_where returns the first item in the stream matching a function ",

    ->() { 
      f = F.find_where.(F.lt.(1))
      check.("equal", f.([1,2,4,4,1]), 2)
      check.("equal", f.([-1,-2,-4,-4,-1]), Nothing)
      
    }

  ],

  ["transpose is just a multidimensional zip. Also, transpose^n, where n is the depth of list nesting, is equivalent to identity",

    ->() { 
      f = F.transpose
      check.("equal", f.([[1,1,1], [2,2,2]]), [[1,2], [1,2], [1,2]])
      check.("equal", f.(f.([[1,1,1], [2,2,2]])), [[1,1,1], [2,2,2]])
      check.("equal", f.([[1,1,1], [2,2,2]]).class, Stream)
      
    }

  ],

  ["ands returns true if all booleans in a stream are true. short-circuits",

    ->() { 
      f = F.ands
      check.("equal", f.([true,false,true]), false)
      check.("equal", f.([true,true,true]), true)
      
    }

  ],

  ["ors returns true if any booleans in a stream are true. short-circuits",

    ->() { 
      f = F.ors
      check.("equal", f.([true,false,true]), true)
      check.("equal", f.([false,false,false]), false)
      
    }

  ],

  ["maximum returns the largest element in a stream",

    ->() { 
      f = F.maximum
      check.("equal", f.([2,4,3]), 4)
      
    }

  ],

  ["minimum returns the smallest element in a stream",

    ->() { 
      f = F.minimum
      check.("equal", f.([4,2,3]), 2)
      
    }

  ],

  ["maximum_by returns the largest element in a stream according to the function passed in",

    ->() { 
      f = F.maximum_by.(F.square)
      check.("equal", f.([2,-4,3]), -4)
      
    }

  ],

  ["minimum_by returns the smallest element in a stream according to the function passed in",

    ->() { 
      f = F.minimum_by.(->x { - x })
      check.("equal", f.([2,4,3]), 4)
      
    }

  ],

  ["sum adds all the elements in a stream",

    ->() { 
      f = F.sum
      check.("equal", f.([2,3,4]), 9)
      
    }

  ],

  ["product multiplies all the elements in a stream",

    ->() { 
      f = F.product
      check.("equal", f.([2,3,4]), 24)
      
    }

  ],

  ["sum_of_squares adds the square of all the elements in a stream",

    ->() { 
      f = F.sum_of_squares
      check.("equal", f.([2,3,4]), 29)
      
    }

  ],

  ["mean finds the mean value of a stream of numbers",

    ->() { 
      f = F.mean
      check.("equal", f.([2,3,4]), 3)
      
    }

  ],

  ["contains? returns true if the stream contains an element",

    ->() { 
      f = F.contains?.(3)
      check.("equal", f.([2,3,4]), true)
      check.("equal", f.([2,4,4]), false)
      
    }

  ],

  ["does_not_contain? returns true if the stream does not contain an element",

    ->() { 
      f = F.does_not_contain?.(3)
      check.("equal", f.([2,3,4]), false)
      check.("equal", f.([2,4,4]), true)
      
    }

  ],

  ["fold is a stream-continuant version of foldl - it's just the final of scanl",

    ->() { 
      f = F.fold.(F.plus, 0)
      check.("equal", f.([2,3,4]), [10])
      check.("equal", f.([2,3,4]).class, Stream)
      
    }

  ],

  ["slice_by takes a function for starting a slice, and a function for stopping it, and then slices out a segment based on those functions",

    ->() { 
      f = F.slice_by.(F.gt.(3), F.lt.(4))
      check.("equal", f.([4,4,4,4,5,2,1,2,4,5,8,3,4]), [2,1,2,4])
      check.("equal", f.([2,3,4]).class, Stream)
      
    }

  ],


  ["map takes a function and a stream and returns a new stream that applies this function to every element in the old stream",

    ->() { 
      f = F.map.(->(x) { x * 10 })
      g = F.map.(F.times.(10))
      check.("equal", f.([1,2,3,4]), [10,20,30,40])
      check.("equal", g.([1,2,3,4]), [10,20,30,40])
      #check.("equal", f.([1,2,3,4]).class, Stream)
      #check.("equal", (F.to_stream * f).([1,2,3]).class, Stream)
      
    }

  ],

  ["filter takes a function and a stream, and returns a new stream that is the result of only keeping items from the original stream that match the function",

    ->() { 
      f = F.filter.(->(x) { 2 < x })
      g = F.filter.(F.lt.(2))
      check.("equal", f.([1,2,3,4]), [3,4])
      check.("equal", g.([1,2,3,4]), [3,4])
      check.("equal", f.([1,2,3,4]).class, Stream)
    }

  ],

  ["flatmap takes a function that produces a list, and a stream, and produces a new stream from concatenating the result of applying the function to every element",

    ->() { 
      f = F.flatmap.(->(x) { [x,x,x].to_stream })
      g = F.flatmap.(->(x) { [x+3].to_stream })
      h = F.flatmap.(F.wrap)
      i = F.flatmap.(F.wrap * F.times.(10))
      
      check.("equal", f.([1,2].to_stream), [1,1,1,2,2,2])
      check.("equal", g.([1,2].to_stream), [4,5])
      check.("equal", h.([1,2].to_stream), [1,2])
      check.("equal", i.([1,2].to_stream), [10,20])
      
      check.("equal", f.([1,2].to_stream).class, Stream)
      check.("equal", h.([1,2].to_stream).class, Stream)
      
    }

  ],

  ["range takes a start and an end, and produces a stream of integers starting at start and ending with end",

    ->() { 
      f = F.range.(3, 7)
      g = F.range.(3, -1)
      h = F.range.(-1, 3)
      i = F.range.(-1, -4)
      j = F.range.(1,1)
      check.("equal", f, [3,4,5,6,7])
      check.("equal", g, [3,2,1,0,-1]) 
      check.("equal", h, [-1,0,1,2,3])
      check.("equal", i, [-1,-2,-3,-4])
      check.("equal", j, [1])
      check.("equal", f.class, Stream)
      check.("equal", g.class, Stream)
      check.("equal", h.class, Stream)
      check.("equal", i.class, Stream)
      check.("equal", j.class, Stream)
    }

  ],
  ["append should take two streams, and produce a stream that is the result of concatenating the two streams together",

    ->() { 
      f = F.append
      check.("equal", f.([1,2,3,4]).([5,6,7,8]), [1,2,3,4,5,6,7,8])
      check.("equal", f.([1,2,3,4]).([5,6,7,8]).class, Stream)
    }

  ],

  ["scanl should produce a stream of intermediate foldl results",

    ->() { 
      f = F.scanl.(F.plus, 0)
      check.("equal", f.([1,2,3,4]), [1,3,6,10])
      check.("equal", f.([1,2,3,4]).class, Stream)
    }

  ],

  ["zip should take two streams, and produce a stream that is a result of pairing the two streams together until the shorter is exhausted",

    ->() { 
      f = F.zip
      check.("equal", f.([1,2,3,4,0]).([5,6,7,8]), [[1,5], [2,6], [3,7], [4,8]])
      check.("equal", f.([1,2,3,4,0]).([5,6,7,8]).class, Stream)
    }

  ],

=begin
  ["multizip should take n streams, and produce a stream that is a result of making a list of the n streams together until the shorter is exhausted",

    ->() { 
      f = F.multizip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream), [[1,5,9], [2,6,10], [3,7,11], [4,8,12]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream).class, Stream)
    }

  ],

  ["long_zip should take two streams, and produce a stream that is a result of pairing the two streams together",

    ->() { 
      f = F.long_zip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream), [[1,5], [2,6], [3,7], [4,8], [0, nil]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream).class, Stream)
    }

  ],

  ["long_multizip should take n streams, and produce a stream that is a result of making a list of the n streams together",

    ->() { 
      f = F.long_multizip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream), [[1,5,9], [2,6,10], [3,7,11], [4,8,12], [0, nil, nil]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream).class, Stream)
    }

  ],

  ["interleave should take two streams, and produce a stream that is a result of interleaving the two streams together",

    ->() { 
      f = F.interleave
      check.("equal", f.([1,2,3,4].to_stream, [5,6,7,8].to_stream), [1,5,2,6,3,7,4,8])
      check.("equal", f.([1,2,3,4,0,5].to_stream, [5,6,7,8].to_stream), [1,5,2,6,3,7,4,8,0,5])
      check.("equal", f.([1,2,3,4].to_stream, [5,6,7,8].to_stream).class, Stream)
    }

  ],

  ["interweave should take n streams, and produce a stream that is a result of interleaving the n streams together",

    ->() { 
      f = F.interweave
      check.("equal", f.([1,2,3,4,0,5].to_stream, [5,6,7,8].to_stream, [9,10,11,12,1].to_stream), [1, 5, 9, 2, 6, 10, 3, 7, 11, 4, 8, 12, 0, 1, 5])
      check.("equal", f.([1,2,3,4,0,5].to_stream, [5,6,7,8].to_stream, [9,10,11,12,1].to_stream).class, Stream)
    }

  ],
=end


  
  ["foldl works over streams" ,

    ->() { 
      f = F.foldl.(F.plus, 0)
      g = F.foldl.(F.times, 1)
      h = F.foldl.(->(acc, el) { acc + [el+10]}, [])
      check.("equal", f.([1,2,3,4].to_stream), 10)
      check.("equal", g.([1,2,3,4].to_stream), 24)
      check.("equal", h.([1,2,3,4].to_stream), [11,12,13,14])
      check.("equal", h.([1,2,3,4].to_stream).class, Array)
    }

  ],

  ["foldr works over streams",

    ->() { 
      f = F.foldr.(F.plus, 0)
      g = F.foldr.(F.times, 1)
      h = F.foldr.(->(el, acc) { [el+10] + acc}, [])
      check.("equal", f.([1,2,3,4].to_stream), 10)
      check.("equal", g.([1,2,3,4].to_stream), 24)
      check.("equal", h.([1,2,3,4].to_stream), [11,12,13,14])
      check.("equal", h.([1,2,3,4].to_stream).class, Array)
    }

  ]

]


DoubleCheck.new(tests).run
