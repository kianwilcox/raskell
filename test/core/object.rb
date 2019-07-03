tests = [

  ## Check partial application

  ["object.fmap(fn) is fn.(object)",

    ->() { 
      check.("equal", 3, 2.fmap(->(x) { x + 1 }))
    }

  ],

  ["object.lift is a 0-argument Proc",

    ->() { 
      f = 1.lift
      check.("equal", f.class, Proc)
      check.("equal", f.arity, 0)

    }

  ],

  ["object.call(anything) is objejct",

    ->() { 
      f = 1.()
      check.("equal", f, 1)
    }

  ],

  ["object.apply(fn) evaluates fn with object as an argument",

    ->() { 
      f = 1.apply(->(x) { x + 1})
      check.("equal", f.(1), 2)
    }

  ],



]


DoubleCheck.new(tests).run
