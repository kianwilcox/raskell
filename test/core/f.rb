=begin The below is the surface

nd = ->(x,y) { x && y }
nnd = ->(x,y) { !(x && y) }
r = ->(x,y) { x || y }
xr = ->(x,y) { !(x && y) && (x || y) }

nt = ->(x) { !x }



first = -> (l) { l[0] }
last = -> (l) { l[-1] }
rest = -> (l) { l[1..-1] }
init = ->(l) { l[0..-2] }

cons = ->(el, l) { [el] + l }
snoc = ->(l, el) { l + [el] }

uncons = ->(l) { [first.(l), rest.(l)] }
unsnoc = ->(l) { [init.(l), last.(l)]}

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

  ## core stream combinators

  ["to_stream transforms an array of elements into a stream",

    ->() { 
      f = F.to_stream
      check.("equal", f.([1,2,3,4,5]), [1,2,3,4,5].to_stream)
      check.("equal", f.([1,2,3,4,5]).class, Stream)
      
    }

  ],

  ["from_stream transforms a stream of elements into an array",

    ->() { 
      f = F.from_stream
      check.("equal", f.([1,2,3,4,5].to_stream), [1,2,3,4,5])
      check.("equal", f.([1,2,3,4,5].to_stream).class, Array)
      
    }

  ],

  ["wrap takes a single element and wraps it into a single-element stream",

    ->() { 
      f = F.wrap
      check.("equal", f.(5), [5])
      check.("equal", f.(5).class, Stream)
      
    }

  ],

  ["map takes a function and a stream and returns a new stream that applies this function to every element in the old stream",

    ->() { 
      f = F.map.(F.plus.(10))
      check.("equal", f.([1,2,3,4].to_stream), [11,12,13,14])
      check.("equal", f.([1,2,3,4].to_stream).class, Stream)
      
    }

  ],

  ["filter takes a function and a stream, and returns a new stream that is the result of only keeping items from the original stream that match the function",

    ->() { 
      f = F.filter.(F.lt.(3))
      check.("equal", f.([1,2,3,4].to_stream), [1,2])
      check.("equal", f.([1,2,3,4].to_stream).class, Stream)
      
    }

  ],

  ["flatmap takes a function that produces a list, and a stream, and produces a new stream from concatenating the result of applying the function to every element",

    ->() { 
      f = F.flatmap.(->(x) { [x,x,x] })
      check.("equal", f.([1,2].to_stream), [1,1,1,2,2,2])
      check.("equal", f.([1,2].to_stream).class, Stream)
      
    }

  ],

  ["range takes a start and an end, and produces a stream of integers starting at start and ending with end",

    ->() { 
      f = F.range.(3, 7)
      g = F.range.(3, -1)
      h = F.range.(-1, 3)
      i = F.range.(-1, -4)
      j = F.range.(1,1)
      check.("equal", f.to_a, [3,4,5,6,7])
      check.("equal", g.to_a, [3,2,1,0,-1]) 
      check.("equal", h.to_a, [-1,0,1,2,3])
      check.("equal", i.to_a, [-1,-2,-3,-4])
      check.("equal", j.to_a, [1])
      check.("equal", f.class, Stream)
      check.("equal", g.class, Stream)
      check.("equal", h.class, Stream)
      check.("equal", i.class, Stream)
    }

  ],

  ["append should take two streams, and produce a stream that is the result of concatenating the two streams together",

    ->() { 
      f = F.append
      check.("equal", f.([1,2,3,4].to_stream, [5,6,7,8].to_stream), [1,2,3,4,5,6,7,8])
      check.("equal", f.([1,2,3,4].to_stream, [5,6,7,8].to_stream).class, Stream)
    }

  ],

  ["zip should take two streams, and produce a stream that is a result of pairing the two streams together until the shorter is exhausted",

    ->() { 
      f = F.zip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream), [[1,5], [2,6], [3,7], [4,8]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream).class, Stream)
    }

  ],

  ["multizip should take n streams, and produce a stream that is a result of making a list of the n streams together until the shorter is exhausted",

    ->() { 
      f = F.multizip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream), [[1,5,9], [2,6,10], [3,7,11], [4,8,12]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream).class, Stream)
    }

  ],

  ["long_zip should take two streams, and produce a stream that is a result of pairing the two streams together",

    ->() { 
      f = F.long_zip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream), [[1,5], [2,6], [3,7], [4,8], [0, nil]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream).class, Stream)
    }

  ],

  ["long_multizip should take n streams, and produce a stream that is a result of making a list of the n streams together",

    ->() { 
      f = F.long_multizip
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream), [[1,5,9], [2,6,10], [3,7,11], [4,8,12], [0, nil, nil]])
      check.("equal", f.([1,2,3,4,0].to_stream, [5,6,7,8].to_stream, [9,10,11,12].to_stream).class, Stream)
    }

  ],

  ["interleave should take two streams, and produce a stream that is a result of interleaving the two streams together",

    ->() { 
      f = F.interleave
      check.("equal", f.([1,2,3,4].to_stream, [5,6,7,8].to_stream), [1,5,2,6,3,7,4,8])
      check.("equal", f.([1,2,3,4,0,5].to_stream, [5,6,7,8].to_stream), [1,5,2,6,3,7,4,8,0,5])
      check.("equal", f.([1,2,3,4].to_stream, [5,6,7,8].to_stream).class, Stream)
    }

  ],

  ["interweave should take n streams, and produce a stream that is a result of interleaving the n streams together",

    ->() { 
      f = F.interweave
      check.("equal", f.([1,2,3,4,0,5].to_stream, [5,6,7,8].to_stream, [9,10,11,12,1].to_stream), [1, 5, 9, 2, 6, 10, 3, 7, 11, 4, 8, 12, 0, 1, 5])
      check.("equal", f.([1,2,3,4,0,5].to_stream, [5,6,7,8].to_stream, [9,10,11,12,1].to_stream).class, Stream)
    }

  ],


  
  ["foldl works over streams" ,

    ->() { 
      f = F.foldl.(F.plus, 0)
      g = F.foldl.(F.times, 1)
      h = F.foldl.(->(acc, el) { acc + [el+10]}, [])
      check.("equal", f.([1,2,3,4].to_stream), 10)
      check.("equal", g.([1,2,3,4].to_stream), 24)
      check.("equal", h.([1,2,3,4].to_stream), [11,12,13,14])
      check.("equal", h.([1,2,3,4].to_stream).class, Array)
    }

  ],

  ["foldr works over streams",

    ->() { 
      f = F.foldr.(F.plus, 0)
      g = F.foldr.(F.times, 1)
      h = F.foldr.(->(el, acc) { [el+10] + acc}, [])
      check.("equal", f.([1,2,3,4].to_stream), 10)
      check.("equal", g.([1,2,3,4].to_stream), 24)
      check.("equal", h.([1,2,3,4].to_stream), [11,12,13,14])
      check.("equal", h.([1,2,3,4].to_stream).class, Array)
    }

  ]

]


DoubleCheck.new(tests).run
