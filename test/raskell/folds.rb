tests = [

  ["able to combine two, three, or more foldls in an associative manner to produce a single foldl that traverse the object only once",

    ->() { 
      f1 = F.sum + F.product + F.maximum + F.minimum
      check.("equal", f1.([1,2,3,4,5]), [15, 120, 5, 1])

      f2 = (F.sum + F.product) + (F.maximum + F.minimum)
      check.("equal", f2.([1,2,3,4,5]), [15, 120, 5, 1])

      f3 = (((F.sum + F.product) + F.maximum) + F.minimum)
      check.("equal", f3.([1,2,3,4,5]), [15, 120, 5, 1])

      f4 = (F.sum + (F.product + (F.maximum + F.minimum)))
      check.("equal", f4.([1,2,3,4,5]), [15, 120, 5, 1])
    }

  ],

  ["able to combine two, three, or more maps in an associative manner to produce a single map that traverse the stream only once",

    ->() { 
      squares = F.map.(F.square)
      doubles = F.map.(F.double)
      gt_2 = F.map.(->(x) { x > 2})
      id = F.map.(F.id)

      f1 = id + doubles + gt_2 + squares
      check.("equal", f1.([1,4,5]), [[1, 2, false, 1], [4, 8, true, 16], [5, 10, true, 25]])

      f2 = (id + doubles) + (gt_2 + squares)
      check.("equal", f2.([1,4,5]), [[1, 2, false, 1], [4, 8, true, 16], [5, 10, true, 25]])

      f3 = (((id + doubles) + gt_2) + squares)
      check.("equal", f3.([1,4,5]), [[1, 2, false, 1], [4, 8, true, 16], [5, 10, true, 25]])

      f4 = (id + (doubles + (gt_2 + squares)))
      check.("equal", f4.([1,4,5]), [[1, 2, false, 1], [4, 8, true, 16], [5, 10, true, 25]])
    }

  ],

  ["able to combine two, three, or more scanls in an associative manner to produce a single scanl that traverse the stream only once",

    ->() { 
      sum = F.scanl.(F.plus, 0)
      product = F.scanl.(F.times, 1)
      maximum = F.scanl.(F.max, F.negative_infinity)
      minimum = F.scanl.(F.min, F.infinity)

      f1 = F.rest * (sum + product + maximum + minimum)
      check.("equal", f1.([5,5,5,1]), [[5, 5, 5, 5], [10, 25, 5, 5], [15, 125, 5, 5], [16, 125, 5, 1]])

      f2 = F.rest * ((sum + product) + (maximum + minimum))
      check.("equal", f2.([5,5,5,1]), [[5, 5, 5, 5], [10, 25, 5, 5], [15, 125, 5, 5], [16, 125, 5, 1]])

      f3 = F.rest * (((sum + product) + maximum) + minimum)
      check.("equal", f3.([5,5,5,1]), [[5, 5, 5, 5], [10, 25, 5, 5], [15, 125, 5, 5], [16, 125, 5, 1]])

      f4 = F.rest * (sum + (product + (maximum + minimum)))
      check.("equal", f4.([5,5,5,1]), [[5, 5, 5, 5], [10, 25, 5, 5], [15, 125, 5, 5], [16, 125, 5, 1]])
    }

  ],


  ["composing two maps creates a new map that traverses the object only once",

    ->() { 
      f = F.map.(->(x) { x * 10 })
      g = F.map.(->(x) { x + 1 })

      check.("equal", (f * g).([0]), [10])
      #check.("equal", (f * g).class, Mapl)
    }

  ],

  ["adding two filters creates a new filter that traverses the object only once but does so as a foldl",

    ->() { 
      f = F.filter.(->(x) { x < 10 })
      g = F.filter.(->(x) { x > 1 })
      check.("equal", (f + g).([-1,1,5,8,10,12]), [[-1, 1, 5, 8],[5, 8, 10, 12]])
      #check.("equal", (f * g).class, Filterl)
    }

  ],

  ["composing two filters creates a new filter that traverses the object only once",

    ->() { 
      f = F.filter.(->(x) { x < 10 })
      g = F.filter.(->(x) { x > 1 })
      check.("equal", (f * g).([-1,1,5,8,10,12]), [5,8])
      #check.("equal", (f * g).class, Filterl)

    }

  ],

]


DoubleCheck.new(tests).run
