load 'lib/core/core.rb'
load 'lib/core/folds.rb'

require 'singleton'

infinity = Float::INFINITY
negative_infinity = -infinity

id = ->(x) { x }
flip = -> (f,x,y) { f.(y,x) }

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

plus = ->(x,y) { x + y }
times = ->(x,y) { x * y }
subFrom = ->(x,y) { x - y }
divFrom = ->(x,y) { x / y }
divideBy = ->(y,x) { x / y}
subBy = ->(y,x) { x - y}

max = ->(x,y) { x >= y ? x : y}
min = ->(x,y) { x <= y ? x : y}

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
flatmap = ->(f) { foldl.(->(acc, el) { plus.(acc, f.el) }, []) }
concat = foldl.(plus, [])
enconcat = ->(l, el, r) { l + [el] + r }

replace = ->(toReplace, toReplaceWith) {map.(->(x) { x == toReplace ? toReplaceWith : x })}
replaceWith = ->(toReplaceWith, toReplace) { map.(->(x) { x == toReplace ? toReplaceWith : x }) }
replaceByIf = ->(replace_fn, should_replace_fn) { map.( ->(x) { should_replace_fn.(x) ? replace_fn.(x) : x } ) }

=begin The below is for later implementation
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



