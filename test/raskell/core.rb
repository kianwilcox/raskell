tests = [

  ## Check partial application

  ["able to partially apply a lambda and receive a lambda in return",

    ->() { 
      f = ->(x,y) { x + y }
      check.("equal", f.(1).lambda?, true)
    }

  ],

  ["partial application with zero arguments unwraps a zero-arity lambda",

    ->() { 
      f = ->() { 1 }
      check.("equal", f.(), 1)
    }

  ],

  ["partial application with zero arguments unwraps nested zero-arity lambdas entirely",

    ->() { 
      f = ->() { ->() { 1 } }
      check.("equal", f.(), 1)
    }

  ],

  ["partial application with zero arguments is a no-op on a nonzero-arity lambda",

    ->() { 
      f = ->(x,y) { x + y }
      zero_applied = f.()
      check.("equal", zero_applied.lambda?, true)
      check.("equal", zero_applied.(1,2), 3)
    }

  ],

  ["able to fully apply a lambda in any arbitrary order",

    ->() {
      f = ->(a,b,c,d,e,f,g) { [a,b,c,d,e,f,g] }
      check.("equal",f.(1,2,3,4,5,6,7), [1,2,3,4,5,6,7]) 
      check.("equal",f.(1,2,3).(4).(5,6,7), [1,2,3,4,5,6,7]) 
      check.("equal",f.(1).(2,3).(4,5,6).(7), [1,2,3,4,5,6,7]) 
      check.("equal",f.(1).(2,3).(4,5).(6,7), [1,2,3,4,5,6,7])
      check.("equal",f.(1).(2,3).().(4,5).(6,7), [1,2,3,4,5,6,7]) 
      check.("equal",f.(1).(2,3).(4,5).(6,7).(), [1,2,3,4,5,6,7])
    }

  ],

  ## Check adding functions

  ["adding two lambdas results in a lambda that, when applied, yields a pair of results, one for each lambda",

    ->() { 
      f = ->(x) { x + x }
      g = ->(x) { x * x }
      added_lambdas = f + g
      check.("equal", added_lambdas.lambda?, true)
      check.("equal", added_lambdas.(3), [6, 9])
    }

  ],

  ## Check calling on arrays and other eachable objects

  ["treating an array as a function and calling it with arguments passes those arguments to the functions in each cell of the array",

    ->() { 
      f = ->(x) { x + x }
      g = ->(x) { x * x }

      check.("equal", [f,g].(5), [10,25])
      check.("equal", (f + g).(5), [10, 25])
    }

  ],

  ## try composing functions, one for the key and one for the value, and folding across a dictionary to produce a new dictionary with the key and the value

  ## Check calling on objects

  ["adding lambdas results in a lambda that, when applied, yields a list of results, one for each lambda",

    ->() { 
      f = ->(x) { x }
      g = ->(x) { x + x }
      h = ->(x) { x * x }
      
      check.("equal", f.(3), 3)
      check.("equal", g.(3), 6)
      check.("equal", h.(3), 9)
      check.("equal", [f,g].(3), [3,6])
      check.("equal", (f + g).(3), [3,6])
      check.("equal", [f,g,h].(3), [3,6,9])
      check.("equal", ((f + g) + h).(3), [3,6,9])
      check.("equal", (f + (g + h)).(3), [3,6,9])
      check.("equal", ((f + g) + (h + h)).(3), [3,6,9,9])
    }

  ],

]


DoubleCheck.new(tests).run
