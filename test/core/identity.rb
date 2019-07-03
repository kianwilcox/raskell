tests = [

  ## Check partial application

  ["Identity.new is a kind of Proc",

    ->() { 
      check.("equal", Identity.new.kind_of?(Proc), true)
      check.("equal", Identity.new.kind_of?(Identity), true)
      check.("equal", Identity.new.class, Identity)
    }

  ],

  ["Identity.new.(x) is x",

    ->() { 
      f = Identity.new
      check.("equal", f.(2), 2)

    }

  ],

  ["Identity.new <= x is x",

    ->() { 
      f = Identity.new
      check.("equal", f <= 2, 2)
    }

  ],

  ["x.lift >= Identity.new is x",

    ->() { 
      f = Identity.new
      check.("equal", 2.lift >= f, 2)
    }

  ],

  ["Identity.new * fn is fn",

    ->() { 
      f = Identity.new * ->(x) { x }
      check.("equal", f.(2), 2)
      check.("equal", f.kind_of?(Proc), true)
      check.("equal", f.class, Proc)
      check.("not_equal", f.kind_of?(Identity), true)
      
    }

  ],

  ["fn * Identity.new is fn",

    ->() { 
      f = ->(x) { x } * Identity.new
      check.("equal", f.(2), 2)
      check.("equal", f.kind_of?(Proc), true)
      check.("equal", f.class, Proc)
      check.("not_equal", f.kind_of?(Identity), true)
    }

  ],

  ["fn | Identity.new is fn",

    ->() { 
      f = ->(x) { x } | Identity.new
      check.("equal", f.(2), 2)
      check.("equal", f.kind_of?(Proc), true)
      check.("equal", f.class, Proc)
      check.("not_equal", f.kind_of?(Identity), true)
    }

  ],

  ["Identity.new | is fn",

    ->() { 
      f = Identity.new | ->(x) { x }
      check.("equal", f.(2), 2)
      check.("equal", f.kind_of?(Proc), true)
      check.("equal", f.class, Proc)
      check.("not_equal", f.kind_of?(Identity), true)
    }

  ],



]


DoubleCheck.new(tests).run
