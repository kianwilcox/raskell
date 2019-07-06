require 'singleton'

class F
  # stream combinators
  def self.to_stream(*args)
    if args.length > 0
      ToStream.new().(*args)
    else
      ToStream.new()
    end
  end
  
  def self.from_stream(*args)
    if args.length > 0
      FromStream.new().(*args)
    else
      FromStream.new()
    end
  end

  include Singleton

  @@stage_0_defs = {
    infinity: Float::INFINITY,
    negative_infinity: -Float::INFINITY, 
    inf: Float::INFINITY,
    ninf: -Float::INFINITY,
    id: Identity.new,
    apply: ->(f, x) { f.(x) },
    apply_with: ->(x,f) { f.(x) },
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

    step: ->(step_fn, stop_fn) { ## if next_fn returns nothing, skip
      next_fn = ->(next_item) {
        tag = next_item.first
        val = next_item[1]
        next_stream = next_item.last
        next_val = next_fn.(val) if tag == :yield
        if tag == :done || (tag == :yield && stop_fn.(val))
          [:done]
        elsif tag == :skip || next_val == Nothing
          [:skip, Stream.new(next_fn, next_stream)]
        elsif tag == :yield
          [:yield, next_val, Stream.new(next_fn, next_stream)]
        else
          raise "#{next_item.inspect} is a malformed stream response!\nExpected one of [:done], [:skip, stream], [:yield, item, stream]"
        end
      }
      next_fn
    },

    ## booleans
    not: ->(x) { !x },
    and: ->(x,y) { x && y },
    nand: ->(x,y) { !(x && y) },
    or: ->(x,y) { x || y },
    xor: ->(x,y) { !(x && y) && (x || y) },

    ## numbers
    inc: ->(x) { x + 1 },
    dec: ->(x) { x - 1 },
    plus: ->(x,y) { x + y },
    times: ->(x,y) { x * y },
    sub_from: ->(x,y) { x - y },
    div_from: ->(x,y) { x / y },
    div_by: ->(y,x) { x / y},
    sub_by: ->(y,x) { x - y},
    equals: ->(x,y) { x == y },
    equal: ->(x,y) { x == y },
    eq: ->(x,y) { x === y },
    gt: ->(x,y) { x > y },
    lt: ->(x,y) { x < y },
    gte: ->(x,y) { x >= y },
    lte: ->(x,y) { x <= y },
  
    #insert  ln, lg, log, log_base, e, pi, exp/pow, square, cube, nth_root, sqrt  here later
    max: ->(x,y) { x >= y ? x : y},
    min: ->(x,y) { x <= y ? x : y},

    ## streams
    empty: Stream.new(->(x) { [:done] }, Nothing),
    wrap: ->(x) {
      next_fn = ->(bool) { bool ? [:yield, x, Stream.new(next_fn, false)] : [:done]}
      Stream.new(next_fn, true)
    },
    cons: ->(el) { 
      from_stream * ->(stream) {
        Stream.new(->(x) { [:yield, el, stream] } , Nothing) 
      } * to_stream
    },

    ## lists
    list: ->(*items) {
      items
    }
  }

  @@stage_0_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}


  @@stage_0_5_defs={
    unfoldl: -> (next_fn, stop_fn, seed) { 
      stream_next_fn = step.(next_fn, stop_fn)
      Stream.new(stream_next_fn, seed)
    },
    transducer: ->(next_val_fn, next_state_fn, stop_fn) {
      from_stream * ->(stream) {
        next_fn = ->(state) {
          if stop_fn.(state)
            [:done]
          elsif (next_val = next_val_fn.(state)) == Nothing
            [:skip, next_state_fn.(state)]
          else
            [:yield,  next_val_fn.(state), next_state_fn.(state)]
          end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    },
  }
  @@stage_0_5_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  @@stage_1_defs = {

    ## stream functions

    take: ->(n) {
      raise("#{n} must be a positive number") if n < 0
      from_stream * ->(stream) {
        next_fn = ->(state) {
          countdown = state.first
          strm = state.last
          if countdown == 0
            [:done]
          else
            next_item = strm.next_item
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip
              [:skip, [countdown, next_strm]]
            elsif tag == :yield
              [:yield, val, [countdown-1, ]]
            else
              raise "#{next_item} is a malformed stream response!"
            end
          end
        }
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 
    drop: ->(n) {
      raise("#{n} must be a positive number") if n < 0
      from_stream * ->(stream) {
        next_fn = ->(state) {
          countdown = state.first
          strm = state.last
          if countdown == 0
            [:skip, strm]
          else
            next_item = strm.next_item
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip
              [:skip, [countdown, next_strm]]
            elsif tag == :yield
              [:skip, [countdown-1, next_strm]]
            else
              raise "#{next_item} is a malformed stream response!"
            end
          end
        }
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 
    drop_except: ->(n) {
      raise("#{n} must be a positive number") if n < 0
      from_stream * ->(stream) {
        next_fn = ->(strm) { 
          potential_stream = take.(n+1) <= strm
          if (length.(potential_stream)) < n+1
            [:skip, take.(n) <= strm]
          else
            next_item = strm.next_item
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip
              [:skip, [countdown, next_strm]]
            elsif tag == :yield
              [:skip, [countdown-1, next_strm]]
            else
              raise "#{next_item} is a malformed stream response!"
            end
          end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    },

    take_while: ->(fn) {
      raise("take_while requires a function") unless fn.kind_of?(Proc)
      from_stream * ->(stream) {
        next_fn = ->(state) {
            tag = next_item.first
            val = next_item[1]
            next_stream = next_item.last
            if tag == :done || (tag == :yield && !fn.(val))
              [:done]
            elsif tag == :skip
              [:skip, Stream.new(next_fn, next_stream)]
            elsif tag == :yield
              [:yield, val, Stream.new(next_fn, next_stream)]
            else
              raise("#{next_item} is a malformed stream response!")
            end
        } * stream.next_item_function
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 

    drop_while: ->(fn) {
      raise("drop_while requires a function") unless fn.kind_of?(Proc)
      from_stream * ->(stream) {
        next_fn = ->(next_item) {
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip || (tag == :yield && fn.(val))
              [:skip, Stream.new(next_fn, next_strm)]
            elsif tag == :yield
              [:skip, next_strm]
            else
              raise("#{next_item} is a malformed stream response!")
            end
        } * stream.next_item_function
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 

    take_until: ->(fn) {
      raise("take_until requires a function") unless fn.kind_of?(Proc)
      from_stream * ->(stream) {
        next_fn = ->(state) {
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done || (tag == :yield && fn.(val))
              [:done]
            elsif tag == :skip
              [:skip, Stream.new(next_fn, next_strm)]
            elsif tag == :yield
              [:yield, val, Stream.new(next_fn, next_strm)]
            else
              raise "#{next_item} is a malformed stream response!"
            end
        } * stream.next_item_function
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 

    drop_until: ->(fn) {
      raise("drop_until requires a function") unless fn.kind_of?(Proc)
      from_stream * ->(stream) {
        next_fn = ->(next_item) {
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip || (tag == :yield && !fn.(val))
              [:skip, Stream.new(next_fn, next_strm)]
            elsif tag == :yield
              [:skip, next_strm]
            else
              raise "#{next_item} is a malformed stream response!"
            end
        } * stream.next_item_function
        Stream.new(next_fn, [n, stream])
      } * to_stream
    },
    first: -> (stream) { ## should offer an equivalent that returns a stream with a single element
      next_item = stream.next_item
      while next_item.first == :skip
        next_item = next_item.last.next_item
      end
      next_item.first == :yield ? next_item[1] : Nothing
    } * to_stream,
    rest: -> (stream) { 
      next_item = stream.next_item.last
      next_item == [:done] ? Nothing : next_item.last
    } * to_stream,
    init: ->(stream) { 
                       #### call it a step-transformer, or step-transducer, or just a step function or stepper
                       #### write a function that produces a function that processes a single next item
                       #### it should take a function for what to do when it's done, when it's skip, and when it's yield
                       #### and those functions should yield 'step's in a stream
      next_fn = ->(next_item) {
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
      } * s.next_item_function
      Stream.new(next_fn, stream)
    } * to_stream,
    snoc: ->(el) {
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
    },
  
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
      } * to_stream
    
    },

    ## implement this and foldl instead as first implementing scanl and scanr, and then choosing the very last value of the stream
    ## so that we can have an abort-fold-when that gives the value collected so far like a loop that terminates early
    foldr: ->(f,u) { 
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
        
    },

    scanl: ->(f,u) { 
      from_stream * ->(stream) {
        next_fn = ->(state) {
          result_so_far = state.first
          strm = state.last
          next_item = strm.next_item
          tag = next_item[0]
          val = next_item[1]
          next_stream = next_item.last
          if tag == :done
            [:done]
          elsif tag == :skip
            [:skip, Stream.new(next_fn, [result_so_far, next_stream])]
          elsif tag == :yield
            new_result = f.(result_so_far, val)
            [:yield, new_result, Stream.new(next_fn, [new_result, next_stream]) ]
          else
            raise "#{next_item} is a malformed stream response"
          end
        }
        Stream.new(next_fn, [u, stream])
      } * to_stream
    
    },
    map: ->(fn) { 
        from_stream * ->(stream) {
          next_fn = ->(state) {
            next_el = state.next_item
            if next_el == [:done]
              [:done]
            elsif next_el.first == :skip
              [:skip, Stream.new(next_fn, next_el.last)]
            elsif next_el.first == :yield
              [:yield, fn.(next_el[1]), Stream.new(next_fn, next_el.last)]
            else
              raise "#{next_el.inspect} is not a valid stream state!"
            end
          } 
          Stream.new(next_fn, stream) 
        } * to_stream
    },
    filter: ->(fn) { 
      from_stream * ->(stream) {
        next_fn = ->(state) {
          next_el = state.next_item
          if next_el == [:done]
            [:done]
          elsif next_el.first == :skip || (next_el.first == :yield && !fn.(next_el[1]))
            [:skip, Stream.new(next_fn, next_el.last)]
          elsif next_el.first == :yield && fn.(next_el[1])
            [next_el.first, next_el[1], Stream.new(next_fn, next_el.last)]
          else
            raise "#{next_el.inspect} is not a valid stream state!"
          end
        }
        Stream.new(next_fn, stream) 
      } * to_stream
    },
    flatmap: ->(fn) { 
    
       from_stream * ->(stream) {
        next_fn = ->(next_el) {
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
    append: ->(left_stream) {
      from_stream * ->(right_stream) {
        left_next_fn = ->(next_el) {
          if next_el == [:done]
            [:skip, right_stream]
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
      
    } * to_stream,
    zip: ->(left_stream) {
      from_stream * ->(right_stream) {
        next_fn = ->(state) {
          val_so_far = state.first
          l_stream = state[1]
          r_stream = state[2]
          next_stream = l_stream if val_so_far.empty?
          next_stream = r_stream if val_so_far.length == 1
          next_item = next_stream.next_item
          if val_so_far.empty?
            l_stream = next_item.last == :done ? empty : next_item.last
          elsif val_so_far.length == 1
            r_stream = next_item.last == :done ? empty : next_item.last
          end
          tag = next_item.first
          val = next_item[1] == :done ? nil : next_item[1]
          if tag == :done && l_stream == empty && r_stream == empty
            [:done]
          elsif tag == :skip
            [:skip, Stream.new(next_fn, [val_so_far, l_stream, r_stream])]
          elsif tag == :yield && val_so_far.length == 1
            [:yield, val_so_far + [val], Stream.new(next_fn, [[], l_stream, r_stream])]
          elsif tag == :yield
            [:skip, Stream.new(next_fn, [val_so_far + [val], l_stream, r_stream])]
          else
            raise "#{next_item} is a malformed stream response!"
          end
        }
  
      Stream.new(next_fn, [[], left_stream, right_stream])
      } * to_stream
    } * to_stream,
  
    

  }

  @@stage_1_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  @@stage_2_defs = {
    double: slf.(plus),
    square: slf.(times),

    ## stream functions
    last: first * -> (stream) { 
      next_fn = ->(state) {
        prev_step = state.first
        strm = state.last
        raise("Must have at least one item inside of the stream!") if prev_step == [:done]
        next_item = strm.next_item
        if prev_step.first == :skip
          [:skip, Stream.new(next_fn, [next_item, next_item.last])]
        elsif next_item == [:done]
          [:yield, prev_step[1], empty]
        elsif next_item.first == :yield
          [:skip, Stream.new(next_fn, [next_item, next_item.last])]
        elsif next_item.first == :skip
          [:skip, Stream.new(next_fn, [prev_step, next_item.last])]
        else
          raise "#{next_item} is a malformed stream result"
        end
      }
      next_item = stream.next_item
      Stream.new(next_fn, [next_item, next_item.last])
    } * to_stream,
    uncons: ->(s) { append(first.(l), wrap(rest.(l)))  } * to_stream,
    unsnoc: ->(s) { append(wrap(init.(s)), last.(s)) } * to_stream,
    reverse: foldl.(->(acc, el) { cons.(el, acc) }, []), ## or foldr.(->(el,acc) { snoc.(acc, el) }, [])
    length: foldl.(inc, 0),
    concat: flatmap.(id),
    enconcat: ->(left_stream, item, right_stream) {
      append.(left_stream, cons.(item, right_stream))
    },
    all?: ->(f) { foldl(->(acc, el) { f.(el) && acc }, true) },
    any?: ->(f) { foldl(->(acc, el) { acc || f.(el) }, false) },
    replace: ->(to_replace, to_replace_with) {map.(->(x) { x == to_replace ? to_replace_with : x })},
    replace_with: ->(to_replace_with, to_replace) { map.(->(x) { x == to_replace ? to_replace_with : x }) },
    find_where: ->(fn) {
      first * filter.(fn)
    },
    
  
    # stream folds useful for containers of booleans
    ands: foldl.(self.and, true),
    ors: foldl.(self.or, false),

    # stream folds useful for containers of numbers (core statistics algorithms)
    
    maximum: foldl.(max, infinity),
    minimum: foldl.(min, negative_infinity),
    maximum_by: ->(fn) { foldl.(->(max_so_far, el) { fn.(el) > fn.(max_so_far) ? el : max_so_far}, negative_infinity) },
    minimum_by:  ->(fn) { foldl.(->(min_so_far, el) { fn.(el) < fn.(min_so_far) ? el : min_so_far}, infinity) },

    sum: foldl.(plus, 0),
    product: foldl.(times, 1),
    mean: ->(l) { div_from(*( (sum + length).(l) )) }, ## this works because (sum + length).(l)== [sum.(l), length.(l)]
    sum_of_squares: foldl.(plus, 0) * map.(slf.(times)),
    ## this is a two-pass algorithm
    sum_of_differences_from_mean_two_pass: ->(mean) { foldl.(plus, 0) * map.(sub_by.(mean)) } * ->(l) { div_from(*( (sum + length).(l) )) }
    ## this is a one-pass algorithm, but only an estimate
    #sum_of_squares_of_differences_from_mean_iterative
    ## - need length, sum, sum_of_squares, M1,M2,M3, deltas, etc... see https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
    ## population_variance
    ## sample_variance
    #->(l) { 
    #  len, sm, sm_sqrs = (length + sum + sum_of_squares).(l)
    #}
  }

  @@stage_2_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  @@stage_3_defs = {
    contains?: ->(el) { Nothing != find_where(equals.(el)) },
    does_not_contain?: ->(el) { Nothing == find_where(equals.(el)) },

    ## stream functionals
    fold: last * scanl,
    
  }
  @@stage_3_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}
end
  #std

=begin
## functionals useful for lists ( but which work on anything supporting .each, and will yield a list )





intercalate = #->(el) { init.(foldl.(, []))}
intersperse = 

intersection
union
difference
cartesian_product

zip_with 
zip = zip_with.(list)
unzip
updated
zip_with_index

last_index_of
last_index_of_slice
last_index_where

first_index_of
first_index_of_slice
first_index_where

subsequence/containsSlice
endsWith
startsWith

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
sliding/window

permutations
combinations

sort_by ## insertionSort
scanr

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