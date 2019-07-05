require 'singleton'

class F
  include Singleton
  def self.infinity
    Float::INFINITY
  end

  def self.negative_infinity
    -Float::INFINITY
  end

  def self.inf
    Float::INFINITY
  end

  def self.ninf
    -Float::INFINITY
  end

  ## functions
  def self.id
    Identity.new
  end

  def self.apply
    ->(f, x) { f.(x) }
  end

  def self.flip
    -> (f,x,y) { f.(y,x) }
  end

  def self.slf
    -> (f, x) { f.(x,x) }
  end

  def self.fix
    ->(f, x) { 
    result = x
    next_result = f.(x)
    while result != next_result
      result = next_result
      next_result = f.(result)
    end
    result
    }
  end

  # stream combinators
  def self.to_stream
    ToStream.new()
  end
  
  def self.from_stream
    FromStream.new()
  end

  def self.not
    ->(x) { !x }
  end
  
  def self.and
    ->(x,y) { x && y }
  end
  
  def self.nand
    ->(x,y) { !(x && y) }
  end
  
  def self.or
    ->(x,y) { x || y }
  end
  
  def self.xor
    ->(x,y) { !(x && y) && (x || y) }
  end


  ## numbers
  def self.inc
    ->(x) { x + 1 }
  end
  
  def self.dec
    ->(x) { x - 1 }
  end
  
  def self.plus
    ->(x,y) { x + y }
  end
  
  def self.times
    ->(x,y) { x * y }
  end
  
  def self.sub_from
    ->(x,y) { x - y }
  end

  def self.div_from
    ->(x,y) { x / y }
  end
  
  def self.div_by
    ->(y,x) { x / y}
  end
  
  def self.sub_by
    ->(y,x) { x - y}
  end
  
  def self.equals
    ->(x,y) { x == y }
  end

  def self.equal
    ->(x,y) { x == y }
  end

  def self.equal
    equals
  end

  def self.eq
    ->(x,y) { x === y }
  end

  def self.gt
    ->(x,y) { x > y }
  end

  def self.lt
    ->(x,y) { x < y }
  end
  
  def self.gte
    ->(x,y) { x >= y }
  end

  def self.lte
    ->(x,y) { x <= y }
  end
  
  #insert  ln, lg, log, log_base, e, pi, exp/pow, square, cube, nth_root, sqrt  here later
  def self.max
    ->(x,y) { x >= y ? x : y}
  end

  def self.min
    ->(x,y) { x <= y ? x : y}
  end

  def self.double
    slf.(plus)
  end

  def self.square
    slf.(times)
  end
  
  
  ## stream functionals
  def self.empty
      Stream.new(->(x) { [:done] }, Nothing)
  end

  def self.wrap
     ->(x) {
      next_fn = ->(bool) { bool ? [:yield, x, Stream.new(next_fn, false)] : [:done]}
      Stream.new(next_fn, true)
    }
  end

  def self.cons
     ->(el) { 
      ->(stream) {
        Stream.new(->(x) { [:yield, el, stream] } , Nothing) 
      } * to_stream
    }
  end

  def self.first
    -> (stream) { 
      next_item = stream.next_item
      while next_item.first == :skip
        next_item = next_item.last.next_item
      end
      next_item.first == :yield ? next_item[1] : raise("first requires the stream to have at least one item")
    } * to_stream
  end
  
  def self.last ## implement as a stream
     -> (stream) { 
      next_fn = {

      }
      Stream.new(next_fn, stream)
    } * to_stream
  end

  def self.rest
     -> (stream) { 
      stream.next_item.last
    } * to_stream
  end

  def self.init ## implement as a stream
     ->(stream) {
      next_fn = ->(s) {
        next_item = s.next_item
        if next_item == [:done]
          raise "init requires a stream length of at least 1"
        elsif next_item.first == :skip 
          [:skip, Stream.new(next_fn, next_item.last)]
        elsif next_item.first == :yield && next_fn.(next_item.last) == [:done]
          [:done]
        elsif next_item.first == :yield
          [:yield, next_item[1], Stream.new(next_fn, next_item.last)]
        else
          raise "#{next_item} is a malformed stream response"
        end
      }
      Stream.new(next_fn, stream)
    } * to_stream
  end

  def self.snoc
    ->(el) {
       ->(stream) { 
        next_fn = ->(s) {
          next_item = s.next_item
          if next_item == [:done]
            [:skip, swrap.(el)]
          elsif next_item.first == :skip
            [:skip, Stream.new(next_fn, next_item.last)]
          elsif next_item.first == :yield
            [:yield, next_item[1], Stream.new(next_fn, next_item.last)]
          else 
            raise "#{next_item} is a malformed stream result"
          end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    }
  end
  
  ## functional combinators - higher-order functions generic over their container
  def self.foldl
    ->(f,u) { 
    
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
        } * to_stream
    
      }
  end

  ## implement this and foldl instead as first implementing scanl and scanr, and then choosing the very last value of the stream
  ## so that we can have an abort-fold-when that gives the value collected so far like a loop that terminates early
  def self.foldr
    ->(f,u) { 
        ->(stream) {
          next_item = stream.next_item
          if next_item == [:done]
            u
          elsif next_item.first == :skip 
            foldr.(f, u, next_item.last)
          elsif next_item.first == :yield
            f.(next_item[1], foldr.(f, u, next_item.last))
          else
            raise "#{next_item} is improperly formed for a Stream"
          end
        } * to_stream
          
      }
  end

  def self.scanl
    ->(f,u) { 
       ->(stream) {
        next_fn =  ->(next_el) {
          result_so_far = next_el.first
          new_stream = next_el.last
          next_item = new_stream.next_item
          if next_item == [:done]
            [:done]
          elsif next_item.first == :skip
            [:skip, [result_so_far, next_item.last]]
          elsif next_item.first == :yield
            new_result_so_far = f.(result_so_far)
            [:yield, new_result_so_far, [new_result_so_far, next_item.last]]
          else
            raise "#{next_item} is a malformed stream response"
          end
        }
        Stream.new(next_fn, [u, stream])
      } * to_stream
    }
  end

  def self.map
     ->(fn) { 
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
    }
  end
  
  def self.filter
     ->(fn) { 
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
    }
  end

  def self.flatmap
    ->(fn) { 
    
       ->(stream) {
        next_fn = ->(next_el) {
          puts next_el.inspect
          state = next_el.first
          potential_stream = next_el.last
          if potential_stream == Nothing
            next_el = stream.next_item_function.(state)
            if next_el == [:done]
              [:done]
            elsif next_el.first == :skip
              [:skip, Stream.new(next_fn, [next_el.last.state, Nothing])]
            elsif next_el.first == :yield
              [:skip, Stream.new(next_fn, [next_el.last.state, fn.(next_el[1])])]
            else
              raise "#{next_el.inspect} is not a valid stream state!"
            end
          else
            next_el = potential_stream.next_item
            if next_el == [:done]
              [:skip, Stream.new(next_fn, [state, Nothing])]
            elsif next_el.first == :skip
              [:skip, Stream.new(next_fn, [state, next_el.last])]
            elsif next_el.first == :yield
              [:yield, next_el[1], Stream.new(next_fn, [state, next_el.last])]
            else
              raise "#{next_el.inspect} is not a valid stream state!"
            end
          end
        }
        Stream.new(next_fn, [stream.state, Nothing]) 
      } * to_stream
    
    }
  end  


  def self.range
     ->(begin_with, end_with) {
      (if begin_with <= end_with
        stream_next_fn = ->(n) { n > end_with  ?  [:done]  :  [:yield, n, Stream.new(stream_next_fn, n + 1)] }
        Stream.new(stream_next_fn, begin_with)
      else
        stream_next_fn = ->(n) { n < end_with  ?  [:done]  :  [:yield, n, Stream.new(stream_next_fn, n - 1)] }
        Stream.new(stream_next_fn, begin_with)
      end)
    }
  end

  def self.append
    ->(left_stream) {
      ->(right_stream) {
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
      } * to_stream
      
    } * to_stream
  end
  
  def self.zip
     ->(left_stream, right_stream) {
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
    }
  end

  def self.unfoldl
    -> (next_fn, stop_fn, seed) { 
        stream_next_fn = ->(x) {
          result = next_fn.(x)
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
    }
  end


  ## lists

  def self.uncons
     ->(s) { append(wrap(first.(l)), wrap(rest.(l)))  } * to_stream
  end

  def self.unsnoc
     ->(s) { append(wrap(init.(s)), wrap(last.(s))) } * to_stream
  end

  def self.fold
    foldl ## we will default folds to be left folds until we have stream fusion in full force
  end

  def self.reverse
    foldl.(->(acc, el) { cons.(el, acc) }, []) ## or foldr.(->(el,acc) { snoc.(acc, el) }, [])
  end
  
  def self.length
    foldl.(inc, 0)
  end

  def self.concat
    flatmap.(id)
  end
  
  def self.all?
    ->(f) { foldl(->(acc, el) { f.(el) && acc }, true) }
  end

  def self.any?
    ->(f) { foldl(->(acc, el) { acc || f.(el) }, false) }
  end
  
  def self.replace
     ->(to_replace, to_replace_with) {map.(->(x) { x== to_replace ? to_replace_with : x })} * to_stream
  end

  def self.replace_with
     ->(to_replace_with, to_replace) { map.(->(x) { x== to_replace ? to_replace_with : x }) } * to_stream
  end

  def self.replace_by_if
     ->(replace_fn, should_replace_fn) { map.( ->(x) { should_replace_fn.(x) ? replace_fn.(x) : x } ) } * to_stream
  end
  
  ## functions useful for containers of booleans
  def self.ands
    foldl.(nd, true)
  end

  def self.ors
    foldl.(r, false)
  end
  
  ## functions useful for containers of numbers
  def self.maximum
    foldl.(max, infinity)
  end

  def self.minimum
    foldl.(min, negative_infinity)
  end

  ## functions useful for streams of numbers
  def self.sum
    foldl.(plus, 0)
  end

  def self.product
    foldl.(times, 1)
  end

  def self.mean
    ->(l) { div_from(*( (sum + length).(l) )) } ## this works because (sum + length).(l)== [sum.(l), length.(l)]
  end

  def self.sum_of_squares
    foldl.(square, 0)
  end

  def self.sum_of_differences
    foldl.(sub_from)
  end

  #sum_of_squares_of_differences_from_mean_iterative

  #core_statistics
  
  ## - need length, sum, sum_of_squares, M1,M2,M3, deltas, etc... see https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
  def self.population_variance
    ->(l) {
    
    }
  end

  def self.sample_variance
    ->(l) { 
      len, sm, sm_sqrs = (length + sum + sum_of_squares).(l)
    }
  end
end
  #std

=begin
## functionals useful for lists ( but which work on anything supporting .each, and will yield a list )
take
drop
take_while
drop_while
take_until
drop_until
drop_except/last_n

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