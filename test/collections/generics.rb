=begin The below is the surface

flip = -> (f,x,y) { f.(y,x) }


gt = ->(x,y) { x > y }
lt = ->(x,y) { x < y }
gte = ->(x,y) { x >= y }
lte = ->(x,y) { x <= y }

max = ->(x,y) { x >= y ? x : y}
min = ->(x,y) { x <= y ? x : y}

nd = ->(x,y) { x && y }
nnd = ->(x,y) { !(x && y) }
r = ->(x,y) { x || y }
xr = ->(x,y) { !(x && y) && (x || y) }

nt = ->(x) { !x }

fix = ->(f, x) { 
  result = x
  next_result = f.(x)
  while result != next_result
    result = next_result
    next_result = f.(result)
  end
  result
}




first = -> (l) { l[0] }
last = -> (l) { l[-1] }
rest = -> (l) { l[1..-1] }
init = ->(l) { l[0..-2] }

cons = ->(el, l) { [el] + l }
snoc = ->(l, el) { l + [el] }

uncons = ->(l) { [first.(l), rest.(l)] }
unsnoc = ->(l) { [init.(l), last.(l)]}

slf = F.-> (f, x) { f.(x,x) }
foldl = ->(f, u) { Foldl.new([f,u]) }
foldr = ->(f,u,l) { l.foldr(u) { |el, acc| f.(el, acc) } }

unfoldl = -> (next_fn, stop_fn, seed) { 
  intermediate_result = seed
  while !stop_fn.(intermediate_result)
    intermediate_result = next_fn.(intermediate_result)
  end
  intermediate_result
}

map = ->(f) { foldl.(->(acc,el) { acc.push(f.(el)) }, [])}

sum = foldl.(plus, 0)
product = foldl.(times, 1)
reverse = foldl.(snoc, [])

ands = foldl.(nd, true)
ors = foldl.(r, false)
all = ->(f) { foldl(->(acc, el) { f.(el) && acc }, true) }
any = ->(f) { foldl(->(acc, el) { acc || f.(el) }, false) }
maximum = foldl.(max, F.infinity)
minimum = foldl.(min, F.negative_infinity)
reverse = foldl.(->(acc, el) { cons.(el, acc) }, []) ## or foldr.(->(el,acc) { snoc.(acc, el) })
filter = ->(f) { foldl.(->(acc,el) { f.(el) ? snoc.(acc,el) : acc }, []) }
append = ->(l1, l2) { l1 + l2 } 
flatmap = ->(f) { foldl.(->(acc, el) { plus.(acc, f.(el)) }, []) }
concat = foldl.(plus, [])
enconcat = ->(l, el, r) { l + [el] + r }

replace = ->(toReplace, toReplaceWith) {map.(->(x) { x == toReplace ? toReplaceWith : x })}
replaceWith = ->(toReplaceWith, toReplace) { map.(->(x) { x == toReplace ? toReplaceWith : x }) }
replaceByIf = F.->(replace_fn, should_replace_fn) { map.( ->(x) { should_replace_fn.(x) ? replace_fn.(x) : x } ) }


intercalate = #->(el) { init.(foldl.(, []))}
intersperse

intersection
union
difference
cartesian_product

zip_with 
zip = zip_with.(id)
unzip
updated
zipWithIndex

last_index_of
last_index_of_slice
last_index_where

first_index_of
first_index_of_slice
first_index_where

partition_at
partition_by
split_by
span

transpose

take
drop
takeWhile
dropWhile
takeUntil
dropUntil

drop_except/last_n
mean
variance
std

maximum_by
minimum_by

elem/member/find/contains
subsequence/containsSlice
endsWith
startsWith

notElem

findBy

index/nth
indexOf
first_index_of_slice
indexWhere
elemIndex
findIndex
random
randomN

segmentLength
splice
patch
span

grouped
groupBy
permutations
combinations
sliding/window
sortBy ## insertionSort
scanr
scanl
deepMap
deepZip
deepMerge

quicksort
mergesort

deepMap
deepZip
deepMerge

hylo # unfoldl . foldl
meta # foldl . unfoldl

=end


##TODO: A bunch - just check the original generics and make sure each function is tested in here in the order it appears there


tests = [


  ## The foundational functions


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


=begin
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

=end

]


DoubleCheck.new(tests).run
