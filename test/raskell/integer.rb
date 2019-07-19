tests = [

  ## Check partial application

  ["3.foldl(->(acc,el) { acc + [el] }, []) is [0,1,2,3]",

    ->() { 
      check.("equal", 3.foldl(->(acc,el) { acc + [el] }, []), [0,1,2,3])
    }

  ],

  ["3.foldr(->(el, acc) { acc + [el] }, []) is [3,2,1,0]",

    ->() { 
      check.("equal", 3.foldr(->(el, acc) { acc + [el] }, []), [3,2,1,0])
    }

  ]

]


DoubleCheck.new(tests).run
