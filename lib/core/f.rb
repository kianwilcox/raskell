require 'singleton'
class F
  include Singleton
  @@prerequisites = {
    infinity: Float::INFINITY,
    negative_infinity: -Float::INFINITY,

    ## functions
    id: Identity.new,
    apply: ->(f, x) { f.(x) },
    flip: -> (f,x,y) { f.(y,x) },
    slf: -> (f, x) { f.(x,x) },

    fix: ->(f, x) { 
    result = x
    next_result = f.(x)
    while result != next_result
      result = next_result
      next_result = f.(result)
    end
    result
    },

    # stream combinators
    to_stream: ToStream.new(),
    from_stream: FromStream.new(),
  }

  @@prerequisites.each_pair {|name, fn| self.define_singleton_method(name) { fn }};1


  @@initials = {

  ## booleans
  nt: ->(x) { !x },
  nd: ->(x,y) { x && y },
  nnd: ->(x,y) { !(x && y) },
  r: ->(x,y) { x || y },
  xr: ->(x,y) { !(x && y) && (x || y) },


  ## numbers
  inc: ->(x) { x + 1 },
  dec: ->(x) { x - 1 },
  
  
  plus: ->(x,y) { x + y },
  times: ->(x,y) { x * y },
  sub_from: ->(x,y) { x - y },
  div_from: ->(x,y) { x / y },
  div_by: ->(y,x) { x / y},
  sub_by: ->(y,x) { x - y},
  
  equals: ->(x,y) { x== y },
  eq: ->(x,y) { x === y },
  gt: ->(x,y) { x > y },
  lt: ->(x,y) { x < y },
  gte: ->(x,y) { x >= y },
  lte: ->(x,y) { x <= y },
  
  #insert  ln, lg, log, log_base, e, pi, exp/pow, square, cube, nth_root, sqrt  here later
  
  max: ->(x,y) { x >= y ? x : y},
  min: ->(x,y) { x <= y ? x : y},
  
  
  ## lists
  first: -> (l) { l[0] },
  last: -> (l) { l[-1] },
  rest: -> (l) { l[1..-1] },
  init: ->(l) { l[0..-2] },
  
  cons: ->(el, l) { [el] + l },
  snoc: ->(l, el) { l + [el] },
  
  
  
  ## functional combinators - higher-order functions generic over their container
  
  foldl: ->(f,u) { 

    ->(stream) {
      next_item = stream.next_item
      result = u
      while next_item != [:done]
        if next_item.first == :skip
          
        elsif next_item.first == :yield
          result = f.(result, next_item[1])
        else
          raise "#{next_item} is a malformed stream response"
        end
        next_item = next_item.last.next_item
      end
      result  
    } * F.to_stream

  }, ## ->(f, u) { Foldl.new([f,u]) }

  ## implement this and foldl instead as first implementing scanl and scanr, and then choosing the very last value of the stream
  ## so that we can have an abort-fold-when that gives the value collected so far like a loop that terminates early
  foldr: ->(f,u) { 
    ->(stream) {
      next_item = stream.next_item
      if next_item == [:done]
        u
      elsif next_item.first == :skip 
        F.foldr.(f, u, next_item.last)
      elsif next_item.first == :yield
        f.(next_item[1], F.foldr.(f, u, next_item.last))
      else
        raise "#{next_item} is improperly formed for a Stream"
      end
    } * F.to_stream
      
  },

  map: ->(fn) { 
    ->(stream) {
      next_fn = ->(next_el) {
        if next_el == [:done]
          [:done]
        elsif next_el.first == :skip
          [:skip, Stream.new(next_fn, next_el.last.state)]
        elsif next_el.first == :yield
          [next_el.first, fn.(next_el[1]), Stream.new(next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * stream.next_item_function
      Stream.new(next_fn, stream.state) 
    } * to_stream
  },

  filter: ->(fn) { 
    ->(stream) {
      next_fn = ->(next_el) {
        if next_el == [:done]
          [:done]
        elsif next_el.first == :skip || (next_el.first == :yield && !fn.(next_el[1]))
          [:skip, Stream.new(next_fn, next_el.last.state)]
        elsif next_el.first == :yield && fn.(next_el[1])
          [next_el.first, next_el[1], Stream.new(next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * stream.next_item_function
      Stream.new(next_fn, stream.state) 
    } * to_stream
  },

  flatmap: ->(fn) { 
    ->(stream) {
      next_fn = ->(next_el) {
        if next_el == [:done]
          [:done]
        elsif next_el.first == :skip || (next_el.first == :yield && !fn.(next_el[1]))
          [:skip, Stream.new(next_fn, next_el.last.state)]
        elsif next_el.first == :yield && fn.(next_el[1])
          [next_el.first, next_el[1], Stream.new(next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * stream.next_item_function
      Stream.new(next_fn, stream.state) 
    } * to_stream
  },

  wrap: ->(x) {
    next_fn = ->(bool) { bool ? [:yield, x, Stream.new(next_fn, false)] : [:done]}
    Stream.new(next_fn, true)
  },

  range: ->(begin_with, end_with) {
    (if begin_with <= end_with
      stream_next_fn = ->(n) { n > end_with  ?  [:done]  :  [:yield, n, Stream.new(stream_next_fn, n + 1)] }
      Stream.new(stream_next_fn, begin_with)
    else
      stream_next_fn = ->(n) { n < end_with  ?  [:done]  :  [:yield, n, Stream.new(stream_next_fn, n - 1)] }
      Stream.new(stream_next_fn, begin_with)
    end)
  },

  append: ->(left_stream, right_stream) {
      right_next_fn = ->(next_el) {
        if next_el == [:done]
          [:done]
        elsif next_el.first == :skip
          [:skip, Stream.new(right_next_fn, next_el.last.state)]
        elsif next_el.first == :yield
          [next_el.first, next_el[1], Stream.new(right_next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * right_stream.next_item_function

      left_next_fn = ->(next_el) {
        if next_el == [:done]
          [:skip, Stream.new(right_next_fn, right_stream.state)]
        elsif next_el.first == :skip
          [:skip, Stream.new(left_next_fn, next_el.last.state)]
        elsif next_el.first == :yield
          [next_el.first, next_el[1], Stream.new(left_next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * left_stream.next_item_function
      
      Stream.new(left_next_fn, left_stream.state)
  },

  zip: ->(left_stream, right_stream) {
    right_next_fn = ->(next_el) {
        if next_el == [:done]
          [:done]
        elsif next_el.first == :skip
          [:skip, Stream.new(right_next_fn, next_el.last.state)]
        elsif next_el.first == :yield
          [next_el.first, next_el[1], Stream.new(right_next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * right_stream.next_item_function

      left_next_fn = ->(next_el) {
        if next_el == [:done]
          [:skip, Stream.new(right_next_fn, right_stream.state)]
        elsif next_el.first == :skip
          [:skip, Stream.new(left_next_fn, next_el.last.state)]
        elsif next_el.first == :yield
          [next_el.first, next_el[1], Stream.new(left_next_fn, next_el.last.state)]
        else
          raise "#{next_el.inspect} is not a valid stream state!"
        end
      } * left_stream.next_item_function
      
      Stream.new(left_next_fn, left_stream.state)
  },


  
  
  unfoldl: -> (next_fn, seed) { 
    stream_next_fn = ->(stream) {
      result = stream.next_item
      if result == [:done] || (result.first == :yield && stop_fn.(result[1]))
        [:done]
      elsif result.first == :skip
        [:skip, Stream.new(stream_next_fn, result.last.state)]
      elsif result.first == :yield
        [:yield, result[1],  Stream.new(stream_next_fn, result.last.state)]
      else
        raise "#{result.inspect} is not of the correct stream result"
      end
    }
    Stream.new(stream_next_fn, seed)
  },

}

  @@initials.each_pair {|name, fn| self.define_singleton_method(name) { fn }};1

  @@requiring_initials = {
  ## numbers
  double: slf.(plus),
  square: slf.(times),
  equal: equals,


  ## lists

  uncons: ->(l) { [first.(l), rest.(l)] },
  unsnoc: ->(l) { [init.(l), last.(l)] },

  fold: foldl, ## we will default folds to be left folds until we have stream fusion in full force
  reverse: foldl.(->(acc, el) { cons.(el, acc) }, []), ## or foldr.(->(el,acc) { snoc.(acc, el) }, [])
  
  length: foldl.(inc, 0),
  
  all: ->(f) { foldl(->(acc, el) { f.(el) && acc }, true) },
  any: ->(f) { foldl(->(acc, el) { acc || f.(el) }, false) },
  
  replace: ->(to_replace, to_replace_with) {map.(->(x) { x== to_replace ? to_replace_with : x })},
  replace_with: ->(to_replace_with, to_replace) { map.(->(x) { x== to_replace ? to_replace_with : x }) },
  replace_by_if: ->(replace_fn, should_replace_fn) { map.( ->(x) { should_replace_fn.(x) ? replace_fn.(x) : x } ) },
  
  ## functions useful for containers of numbers
  sum: foldl.(plus, 0),
  product: foldl.(times, 1),
  mean: ->(l) { div_from(*( (sum + length).(l) )) }, ## this works because (sum + length).(l)== [sum.(l), length.(l)]
  #variance
  #std
  
  ## functions useful for containers of booleans
  ands: foldl.(nd, true),
  ors: foldl.(r, false),
  
  ## functions useful for containers of numbers
  maximum: foldl.(max, infinity),
  minimum: foldl.(min, negative_infinity),
}


@@requiring_initials.each_pair {|name, fn| self.define_singleton_method(name) { fn }};1


=begin
## functionals useful for lists ( but which work on anything supporting .each, and will yield a list )
take
drop
take_while
drop_while
take_until
drop_until
drop_except/last_n


append = ->(l1, l2) { l1 + l2 } 
flatmap = ->(f) { foldl.(->(acc, el) { plus.(acc, f.(el)) }, []) }
concat = foldl.(plus, [])
enconcat = ->(l, el, r) { l + [el] + r }

maximum_by
minimum_by

intercalate = #->(el) { init.(foldl.(, []))}
intersperse = 

intersection
union
difference
cartesian_product

zip_with 
zip = zip_with.(id)
unzip
updated
zip_with_index

last_index_of
last_index_of_slice
last_index_where

first_index_of
first_index_of_slice
first_index_where

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

partition_at
partition_by
split_by
segmentLength
splice
patch
span

transpose

grouped
groupBy
permutations
combinations
sliding/window
sort_by ## insertionSort
scanr
scanl

## functionals useful in untyped languages like ruby - arbitrarily deep map, zip, and merge

deep_map ## for a dictionary, maps across all its values deep until not-a-dictionary
        ## for a list, maps  across all its values deep until not-a-list
        ## in general, it just deeply applies fmap with a particular kind it should only apply to
deep_map_ ## keeps going no matter what the kind is, as long as it supports fmap
deep_zip
deep_merge ## implement with deep_zip and deep_map
deep_diff ## implement with deep_zip and deep_map
  
=end


=begin The below is for later implementation


quicksort ## use stream fusion
mergesort ## use stream fusion

deepMap
deepZip
deepMerge

hylo # unfoldl . foldl
meta # foldl . unfoldl

=end
end