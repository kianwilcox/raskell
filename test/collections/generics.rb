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

slf = -> (f, x) { f.(x,x) }
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
maximum = foldl.(max, infinity)
minimum = foldl.(min, negative_infinity)
reverse = foldl.(->(acc, el) { cons.(el, acc) }, []) ## or foldr.(->(el,acc) { snoc.(acc, el) })
filter = ->(f) { foldl.(->(acc,el) { f.(el) ? snoc.(acc,el) : acc }, []) }
append = ->(l1, l2) { l1 + l2 } 
flatmap = ->(f) { foldl.(->(acc, el) { plus.(acc, f.(el)) }, []) }
concat = foldl.(plus, [])
enconcat = ->(l, el, r) { l + [el] + r }

replace = ->(toReplace, toReplaceWith) {map.(->(x) { x == toReplace ? toReplaceWith : x })}
replaceWith = ->(toReplaceWith, toReplace) { map.(->(x) { x == toReplace ? toReplaceWith : x }) }
replaceByIf = ->(replace_fn, should_replace_fn) { map.( ->(x) { should_replace_fn.(x) ? replace_fn.(x) : x } ) }


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
      f = id
      check.("equal", f.(1), 1)
      check.("equal", f.(true), true)
      check.("equal", f.([1,2,3]), [1,2,3])
    }

  ],

  ["flip.(->(x,y) { x - y}).(2,3) equals 1",

    ->() { 
      f = flip.(->(x,y) { x - y })
      check.("equal", f.(2,3), 1)
    }

  ],

  ["slf.(->(x,y) { x * y}).(3) equals 9",

    ->() { 
      f = slf.(->(x,y) { x * y})
      check.("equal", f.(3), 9)
    }

  ],

  ["fix.(->(x) { x < 5  ?  x  :  x - 1 }).(10) equals 4",

    ->() { 
      f = fix.(->(x) { x < 5  ?  x  :  x - 1 })
      check.("equal", f.(10), 4)
    }

  ],


  ## then the basic arithmetic functions

  ["inc.(1) equals 2",

    ->() { 
      f = inc
      check.("equal", f.(1), 2)
    }

  ],

  ["dec.(1) equals 0",

    ->() { 
      f = dec
      check.("equal", f.(1), 0)
    }

  ],

  ["plus.(1,2) equals 3",

    ->() { 
      f = plus
      check.("equal", f.(1,2), 3)
    }

  ],

  ["times(3,2) equals 6",

    ->() { 
      f = times
      check.("equal", f.(3,2), 6)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_by(2,7) equals 5",

    ->() { 
      f = sub_by
      check.("equal", f.(2,7), 5)
    }

  ],

  ["div_from(6,2) equals 3",

    ->() { 
      f = div_from
      check.("equal", f.(6,2), 3)
    }

  ],

  ["div_by(2,10) equals 5",

    ->() { 
      f = div_by
      check.("equal", f.(2,10), 5)
    }

  ],

  ["sub_from(infinity,2) equals infinity",

    ->() { 
      f = sub_from
      check.("equal", f.(infinity,2), infinity)
    }

  ],

  ["sub_from(negative_infinity,2) equals negative_infinity",

    ->() { 
      f = plus
      check.("equal", f.(negative_infinity,2), negative_infinity)
    }

  ],


  ## then ln, lg, log, log_base, e, pi, exp, square, sqrt - later


  ## then max and min


  ["max(5,2) is 5",

    ->() { 
      f = max
      check.("equal", f.(5,2), 5)
    }

  ],

  ["max(2,5) is 5",

    ->() { 
      f = max
      check.("equal", f.(2,5), 5)
    }

  ],

  ["max(infinity,5) is infinity",

    ->() { 
      f = max
      check.("equal", f.(infinity,5), infinity)
    }

  ],

  ["max(2,negative_infinity) is 2",

    ->() { 
      f = max
      check.("equal", f.(2,negative_infinity), 2)
    }

  ],

  ["min(5,2) is 2",

    ->() { 
      f = min
      check.("equal", f.(5,2), 2)
    }

  ],

  ["min(2,5) is 2",

    ->() { 
      f = min
      check.("equal", f.(2,5), 2)
    }

  ],

  ["min(infinity,5) is infinity",

    ->() { 
      f = min
      check.("equal", f.(infinity,5), 5)
    }

  ],

  ["min(2,negative_infinity) is 2",

    ->() { 
      f = min
      check.("equal", f.(2,negative_infinity), negative_infinity)
    }

  ],


  ## then arithmetic comparison functions


  ["gt(5,2) is true",

    ->() { 
      f = gt
      check.("equal", f.(5,2), true)
    }

  ],

  ["gt(5,5) is false",

    ->() { 
      f = gt
      check.("equal", f.(5,5), false)
    }

  ],

  ["gt(4,5) is false",

    ->() { 
      f = gt
      check.("equal", f.(4,5), false)
    }

  ],

  ["gt(infinity,500000) is true",

    ->() { 
      f = gt
      check.("equal", f.(infinity,500000), true)
    }

  ],

  ["gt(500000,infinity) is false",

    ->() { 
      f = gt
      check.("equal", f.(500000, infinity), false)
    }

  ],

  ["gt(negative_infinity,-500000) is false",

    ->() { 
      f = gt
      check.("equal", f.(negative_infinity,-500000), false)
    }

  ],

  ["gt(-500000,negative_infinity) is true",

    ->() { 
      f = gt
      check.("equal", f.(-500000, negative_infinity), true)
    }

  ],

  ["gte(5,2) is true",

    ->() { 
      f = gte
      check.("equal", f.(5,2), true)
    }

  ],

  ["gte(5,5) is true",

    ->() { 
      f = gte
      check.("equal", f.(5,5), true)
    }

  ],

  ["gte(4,5) is false",

    ->() { 
      f = gte
      check.("equal", f.(4,5), false)
    }

  ],

  ["gte(infinity,500000) is true",

    ->() { 
      f = gte
      check.("equal", f.(infinity,500000), true)
    }

  ],

  ["gte(500000,infinity) is false",

    ->() { 
      f = gte
      check.("equal", f.(500000, infinity), false)
    }

  ],

  ["gte(negative_infinity,-500000) is false",

    ->() { 
      f = gte
      check.("equal", f.(negative_infinity,-500000), false)
    }

  ],

  ["gte(-500000,negative_infinity) is true",

    ->() { 
      f = gte
      check.("equal", f.(-500000, negative_infinity), true)
    }

  ],

  ["lt(5,2) is false",

    ->() { 
      f = lt
      check.("equal", f.(5,2), false)
    }

  ],

  ["lt(5,5) is false",

    ->() { 
      f = lt
      check.("equal", f.(5,5), false)
    }

  ],

  ["lt(4,5) is true",

    ->() { 
      f = lt
      check.("equal", f.(5,4), false)
    }

  ],

  ["lt(infinity,500000) is false",

    ->() { 
      f = lt
      check.("equal", f.(infinity,500000), false)
    }

  ],

  ["lt(500000,infinity) is true",

    ->() { 
      f = lt
      check.("equal", f.(500000, infinity), true)
    }

  ],

  ["lt(negative_infinity,-500000) is true",

    ->() { 
      f = lt
      check.("equal", f.(negative_infinity,-500000), true)
    }

  ],

  ["lte(-500000,negative_infinity) is false",

    ->() { 
      f = lte
      check.("equal", f.(-500000, negative_infinity), false)
    }

  ],

  ["lte(5,2) is false",

    ->() { 
      f = lte
      check.("equal", f.(5,2), false)
    }

  ],

  ["lte(5,5) is true",

    ->() { 
      f = lte
      check.("equal", f.(5,5), true)
    }

  ],

  ["lte(4,5) is true",

    ->() { 
      f = lte
      check.("equal", f.(5,4), false)
    }

  ],

  ["lte(infinity,500000) is false",

    ->() { 
      f = lte
      check.("equal", f.(infinity,500000), false)
    }

  ],

  ["lte(500000,infinity) is true",

    ->() { 
      f = lte
      check.("equal", f.(500000, infinity), true)
    }

  ],

  ["lte(negative_infinity,-500000) is true",

    ->() { 
      f = lte
      check.("equal", f.(negative_infinity,-500000), true)
    }

  ],

  ["lte(-500000,negative_infinity) is false",

    ->() { 
      f = lte
      check.("equal", f.(-500000, negative_infinity), false)
    }

  ],


  ## and equality marks our transition from numbers to other kinds of 'sequences' - === is eq, == is equals


  ["equals(5,2) is false",

    ->() { 
      f = equals
      check.("equals", f.(5,2), false)
    }

  ],

  ["equals(5,5) is true",

    ->() { 
      f = equals
      check.("equal", f.(5,5), true)
    }

  ],

  ["equals([[1],[2],[3]], [[1],[2],[3]]) is true for structurally deep objects",

    ->() { 
      f = equals
      check.("equal", f.([[1],[2],[3]], [[1],[2],[3]]), true)
    }

  ],

  ["eq(5,2) is false",

    ->() { 
      f = eq
      check.("equal", f.(5,2), false)
    }

  ],

  ["eq(5,5) is true",

    ->() { 
      f = eq
      check.("equal", f.(5,5), true)
    }

  ],


  ## 


  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],


=begin
  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

  ["sub_from(5,2) equals 3",

    ->() { 
      f = sub_from
      check.("equal", f.(5,2), 3)
    }

  ],

=end

]



run_tests.(tests)
