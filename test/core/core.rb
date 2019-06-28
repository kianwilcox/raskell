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

  ["treating an array as a function and calling it with arguments assumed the arguments are functions, and applies the values in the array to them in turn",

    ->() { 
      f = ->(x) { x + x }
      g = ->(x) { x * x }

      check.("equal", [1,2,3].(f), [2,4,6])
      check.("equal", [1,2,3].(g), [1,4,9])
      check.("equal", [1,2,3].(f, g), [[2,1], [4,4], [6,9]])
      check.("equal", [1,2,3].(f + g), [[2,1], [4,4], [6,9]])
      check.("equal", [1,2,3].(f, g, f + g), [[2,1], [4,4], [6,9]])
      check.("equal", [1,2,3].(f, g, f + g), [[2,1, [2,1]], [4,4, [4,4]], [6,9, [6,9]]])
    }

  ],

  ## try composing functions, one for the key and one for the value, and folding across a dictionary to produce a new dictionary with the key and the value

  ## Check calling on objects

  ["adding two lambdas results in a lambda that, when applied, yields a pair of results, one for each lambda",

    ->() { 
      f = ->(x) { x + x }
      g = ->(x) { x * x }
      
      check.("equal", 1.(f), 2)
      check.("equal", 3.(g), 9)
      check.("equal", 3.(f,g), [6,9])
      check.("equal", 3.(f + g), [6,9])
    }

  ],

]



run_tests.(tests)
