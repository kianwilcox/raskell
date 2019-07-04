tests = [
  ["able to combine two, three, or more foldls in an associative manner to produce a single foldl that traverse the object only once",

    ->() { 
      f1 = F.sum + F.product + F.maximum + F.minimum
      check.("equal", f1.([1,2,3,4,5], [15, 120, 5, 1]))

      f2 = (F.sum + F.product) + (F.maximum + F.minimum)
      check.("equal", f2.([1,2,3,4,5], [15, 120, 5, 1]))

      f3 = (((F.sum + F.product) + F.maximum) + F.minimum)
      check.("equal", f3.([1,2,3,4,5], [15, 120, 5, 1]))

      f4 = (F.sum + (F.product + (F.maximum + F.minimum)))
      check.("equal", f4.([1,2,3,4,5], [15, 120, 5, 1]))
    }

  ],
=begin
  ["composing two maps creates a new map that traverses the object only once",

    ->() { 
      f = F.map.(->(x) { x * 10 })
      g = F.map.(->(x) { x + 1 })

      check.("equal", (f * g).(0), 11)
      #check.("equal", (f * g).class, Mapl)
    }

  ],

  ["composing two filters creates a new filter that traverses the object only once",

    ->() { 
      f = F.filter.(->(x) { x < 10 })
      g = F.filter.(->(x) { x > 1 })
      check.("equal", (f * g).([-1,1,5,8,10,12]), [[5],[8]])
      #check.("equal", (f * g).class, Filterl)
    }

  ],

  ["composing a splittable function with a foldl should create a new foldl that traverses the object only once",

    ->() { 
      f = ->(x,y) { x + y }
      zero_applied = f.()
      check.("equal", zero_applied.lambda?, true)
      check.("equal", zero_applied.(1,2), 3)
    }

  ],

  ["composing a splittable foldl with another foldl should create a new foldl that traverses the object only once",

    ->() {
      f = ->(a,b,c,d,e,f,g) { [a,b,c,d,e,f,g] }
      check.("equal",f.(1,2,3,4,5,6,7), [1,2,3,4,5,6,7])
    }

  ],

  ["composing a flatmap with any of a flatmap, filter, map, splittable function, or splittable foldl produces a function that traverses the object only once",

    ->() {
      f = ->(a,b,c,d,e,f,g) { [a,b,c,d,e,f,g] }
      check.("equal",f.(1,2,3,4,5,6,7), [1,2,3,4,5,6,7])
    }

  ]
=end
]


DoubleCheck.new(tests).run