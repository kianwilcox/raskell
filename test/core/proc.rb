tests = [

  ## Check partial application

  ["functions can be partially applied",

    ->() { 
      f = ->(a,b,c,d,e,f) { [a,b,c,d,e,f] }

      check.("equal", f.kind_of?(Proc), true)
      check.("equal", f.(1,2).kind_of?(Proc), true)
      check.("equal", f.(1).kind_of?(Proc), true)
      check.("equal", f.().kind_of?(Proc), true)
      check.("equal", f.(1,2,3).kind_of?(Proc), true)
      check.("equal", f.(1,2).(3).(4,5).kind_of?(Proc), true)
      check.("not_equal", f.(1,2).(3).(4,5).(6).kind_of?(Proc), true)
      
    }

  ],

  ["functions can be fully applied",

    ->() { 
      f = ->(a,b,c,d,e,f) { [a,b,c,d,e,f] }
      check.("equal", f.(1,2,3,4,5,6), [1,2,3,4,5,6])
      check.("equal", f.(1,2).(3).(4,5).(6), [1,2,3,4,5,6])
      check.("equal", f.(1,2).(3,4).(5,6), [1,2,3,4,5,6])
      check.("equal", f.(1,2, 3).(4,5).(6), [1,2,3,4,5,6])
      check.("equal", f.(1,2, 3).(4).(5,6), [1,2,3,4,5,6])
      check.("equal", f.(1).(2,3).(4,5,6), [1,2,3,4,5,6])

    }

  ],

  ["functions can be over-applied",

    ->() { 
      f = ->(a,b,c,d,e,f) { [a,b,c,d,e,f] }
      check.("equal", f.(1,2,3,4,5,6,7), [1,2,3,4,5,6])
      check.("equal", f.(1,2).(3).(4,5).(6).(7), [1,2,3,4,5,6])
      check.("equal", f.(1,2).(3,4).(5,6,7), [1,2,3,4,5,6])
      check.("equal", f.(1,2, 3).(4,5).(6,7), [1,2,3,4,5,6])
      check.("equal", f.(1,2, 3).(4).(5,6).(7), [1,2,3,4,5,6])
      check.("equal", f.(1).(2,3).(4,5,6).(7), [1,2,3,4,5,6])
    }

  ],

  # check composition

  ["function composition, *, is associative",

    ->() { 
      f = ->(x) { x + 2 }
      g = ->(x) { x * 10 }
      h = ->(x) { x * x }

      check.("equal", (f * g * h).(3), 92)
      check.("equal", (f * g * h).(3), (f * (g * h)).(3))
      check.("equal", (f * g * h).(3), ((f * g) * h).(3))
      check.("equal", (f * g * h * h).(3), ((f * g) * (h * h)).(3))
      check.("equal", (f * g * h * h).(3), (f * (g * h) * h).(3))

      
    }

  ],

  ["function piping, |, is associative",

    ->() { 
      f = ->(x) { x + 2 }
      g = ->(x) { x * 10 }
      h = ->(x) { x * x }

      check.("equal", (f | g | h).(3), 2500)
      check.("equal", (f | g | h).(3), (f | (g | h)).(3))
      check.("equal", (f | g | h).(3), ((f | g) | h).(3))
      check.("equal", (f | g | h | h).(3), ((f | g) | (h | h)).(3))
      check.("equal", (f | g | h | h).(3), (f | (g | h) | h).(3))

    }

  ],

  ["adding functions produces a function that, when applied to arguments, will return [fn1.(*args), fn2.(*args), fn3...], and is associative",

    ->() { 
      f = ->(x) { x }
      g = ->(x) { x - 1}
      h = ->(x) { x * 2 }
      j = ->(x) { x * x }
      k = f + g + h + j
      check.("equal", k.kind_of?(Proc), true)
      check.("equal", k.class, Proc)
      check.("equal", k.(3), [3, 2, 6, 9])
      check.("equal", (f + (g + (h + j))).(3), [3, 2, 6, 9])
      check.("equal", (((f + g) + h) + j).(3), [3, 2, 6, 9])
      check.("equal", ((f + g) + (h + j)).(3), [3, 2, 6, 9])
      check.("equal", (f + (g + h) + j).(3), [3, 2, 6, 9])
    }

  ],

  [">= feeds data from the left and requires the value to be 'lifted' to lambda-space first",

    ->() { 
      f = ->(x) { x }
      check.("equal", f.(2), 2)
      check.("equal", 2.lift.class, Proc)
      check.("equal", 2.lift >= f, 2)
    }

  ],

  ["<= feeds data from the right and works on lifted or unlifted values",

    ->() { 
      f = ->(x) { x }
      check.("equal", f.(2), 2)
      check.("equal", f <= 2, 2)
      check.("equal", f <= 2.lift, 2)
    }

  ],


]


DoubleCheck.new(tests).run
