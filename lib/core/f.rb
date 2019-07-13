
## module System 
class F ## System::F to use 3;) --- or, you can just extend with System, and get the F for free.
  # stream combinators
  @@to_stream = ->(xs) { xs.to_stream }
  
  def self.to_stream
    @@to_stream
  end

  def self.from_stream(*args)
    if args.length > 0
      FromStream.new().(*args)
    else
      FromStream.new()
    end
  end

  def self.to_array
    FromStream.new(Array)
  end

  def self.to_hash
    FromStream.new(Hash)
  end

  def self.to_set
    FromStream.new(Set)
  end

  def self.to_a
    self.to_array
  end

  def self.to_h
    self.to_hash
  end


  @@stage_0_defs = {
    infinity: Float::INFINITY,
    negative_infinity: -Float::INFINITY, 
    inf: Float::INFINITY,
    ninf: -Float::INFINITY,
    id: Identity.new, # ->(x) { x }
    apply_with2: ->(y, f, x) { f.(x,y)},
    apply: ->(f, *xs) { f.(*xs) },
    apply_with: ->(x,f) { f.(x) }, # flip * apply
    compose: ->(f,g) { f * g },
    flip: -> (f,x,y) { f.(y,x) },
    slf: -> (f, x) { f.(x,x) }, ## square = slf * times
    fix: ->(f, x) { 
      result = x
      next_result = f.(x)
      while result != next_result
        result = next_result
        next_result = f.(result)
      end
      result
    },   
    ## next_stream_fn yields Nothing for stop, and the next stream to go to otherwise
    ## yield_fn yields a Nothing for skip, and the next value to yield otherwise
    cstep: ->(next_stream_fn, yield_fn) {
      ## next_stream_fn :: state -> next_fn -> Maybe(stream)
      ## yield_fn :: state -> Maybe(item)
      next_fn = ->(state) {
        next_stream = next_stream_fn.(state)
        to_yield = yield_fn.(state) if to_skip != Nothing
        if next_stream == Nothing
          [:done]
        elsif to_yield == Nothing
          [:skip, next_stream]
        else
          [:yield, to_yield, next_stream]
        end
      }
      next_fn
    },
    step: ->(transition_fn, yield_fn) {
      ## transition_fn :: state -> Maybe(state)
      ## yield_fn :: state -> Maybe(item)
      next_fn = ->(state) {
        next_state = transition_fn.(state)
        to_yield = yield_fn.(state) if next_state != Nothing
        if next_state == Nothing
          [:done]
        elsif to_yield == Nothing
          [:skip, Stream.new(next_fn, next_state)]
        else
          [:yield, to_yield, Stream.new(next_fn, next_state)]
        end
      }
      next_fn
    },

    ## booleans
    not: ->(x) { !x },
    and: ->(x,y) { x && y },
    nand: ->(x,y) { !(x && y) },
    or: ->(x,y) { x || y },
    nor: ->(x,y) { !x && !y },
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
    is_gt: ->(y,x) { x > y },
    is_lt: ->(y,x) { x < y },
    is_gte: ->(y,x) { x >= y },
    is_lte: ->(y,x) { x <= y },
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
      ->(stream) {
        Stream.new(->(x) { [:yield, el, stream] } , Nothing) 
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
      next_item = stream.next_item
      next_item == [:done] ? Nothing : next_item.last
    } * to_stream,

    take: ->(n) {
      raise("#{n} must be a positive number") if n < 0
      ->(stream) {
        next_fn = step.(->(state){
            if state.first == 0
              Nothing
            else
              next_item = state.last.next_item
              count = next_item.first == :skip ? state.first : state.first-1
              next_item == [:done] ? Nothing : [count, next_item.last]
            end
          },
          ->(state) { 
            next_item = state.last.next_item
            next_item.first == :yield ? next_item[1] : Nothing
          })
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 
    drop: ->(n) {
      raise("#{n} must be a positive number") if n < 0
      ->(stream) {
        next_fn = step.(->(state){
            next_item = state.last.next_item
            count = next_item.first == :skip || state.first == 0 ? state.first : state.first-1
            next_item == [:done] ? Nothing : [count, next_item.last]
          },
          ->(state) { 
            count = state.first
            next_item = state.last.next_item
            next_item.first == :yield && count == 0 ? next_item[1] : Nothing
          })
        Stream.new(next_fn, [n, stream])
      } * to_stream
    }, 
    drop_except: ->(n) {
      raise("#{n} must be a positive number") if n < 0
      ->(stream) {
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
              [:skip, next_strm]
            elsif tag == :yield
              [:skip, next_strm]
            else
              raise "#{next_item} is a malformed stream response!"
            end
          end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    },

    init: ->(stream) { 
      next_fn = ->(state) {
        strm = state.last
        next_item = strm.next_item
        if next_item == [:done] && state.first == Nothing
          raise "init requires a stream length of at least 1"
        elsif next_item == [:done]
          [:done]
        elsif next_item.first == :skip 
          [:skip, Stream.new(next_fn, [state.first, next_item.last])]
        elsif next_item.first == :yield && state.first == Nothing
          [:skip, Stream.new(next_fn, [next_item[1], next_item.last])]
        elsif next_item.first == :yield
          [:yield, state.first, Stream.new(next_fn, [next_item[1], next_item.last])]
        else
          raise "#{next_item} is a malformed stream response"
        end
      }
      Stream.new(next_fn, [Nothing, stream])
    } * to_stream,

    take_while: ->(fn) {
      raise("take_while requires a function") unless fn.kind_of?(Proc)
      ->(stream) {
        next_fn = ->(state) {
            next_item = state.next_item
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
        }
        Stream.new(next_fn, stream)
      } * to_stream
    }, 

    drop_while: ->(fn) {
      raise("drop_while requires a function") unless fn.kind_of?(Proc)
      ->(stream) {
        next_fn = ->(state) {
            next_item = state.next_item
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip || (tag == :yield && fn.(val))
              [:skip, Stream.new(next_fn, next_strm)]
            elsif tag == :yield
              [:yield, val, next_strm]
            else
              raise("#{next_item} is a malformed stream response!")
            end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    }, 

    take_until: ->(fn) {
      raise("take_while requires a function") unless fn.kind_of?(Proc)
      ->(stream) {
        next_fn = ->(state) {
            next_item = state.next_item
            tag = next_item.first
            val = next_item[1]
            next_stream = next_item.last
            if tag == :done || (tag == :yield && fn.(val))
              [:done]
            elsif tag == :skip
              [:skip, Stream.new(next_fn, next_stream)]
            elsif tag == :yield
              [:yield, val, Stream.new(next_fn, next_stream)]
            else
              raise("#{next_item} is a malformed stream response!")
            end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    }, 

    drop_until: ->(fn) {
      raise("drop_while requires a function") unless fn.kind_of?(Proc)
      ->(stream) {
        next_fn = ->(state) {
            next_item = state.next_item
            tag = next_item.first
            val = next_item[1]
            next_strm = next_item.last
            if tag == :done
              [:done]
            elsif tag == :skip || (tag == :yield && !fn.(val))
              [:skip, Stream.new(next_fn, next_strm)]
            elsif tag == :yield
              [:yield, val, next_strm]
            else
              raise("#{next_item} is a malformed stream response!")
            end
        }
        Stream.new(next_fn, stream)
      } * to_stream
    }, 

    zip_with: ->(fn) {
      ->(left_stream, right_stream, *streams) {
          streams = ([left_stream, right_stream] + streams).map(&:to_stream)
          next_fn = ->(state) {
            val_so_far = state.first
            strms = state.drop(1)
            next_stream = strms.first
            next_item = next_stream.next_item
            new_streams = strms.drop(1) + [next_stream.next_item.last == :done ? empty : next_item.last]
            tag = next_item.first
            val = tag == :done ? nil : next_item[1]
            if tag == :done
              [:done]
            elsif tag == :skip
              [:skip, Stream.new(next_fn, [val_so_far] +  new_streams)]
            elsif tag == :yield && val_so_far.length == streams.length - 1
              [:yield, fn.(*(val_so_far + [val])), Stream.new(next_fn, [[]] + new_streams)]
            elsif tag == :yield
              [:skip, Stream.new(next_fn, [val_so_far + [val]] + new_streams)]
            else
              raise "#{next_item} is a malformed stream response!"
            end
          }
    
          Stream.new(next_fn, [[]] + streams)
        }
    },

    ## lists
    list: ->(*items) { items }
  }

  @@stage_0_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}


  @@stage_0_5_defs={
    empty?: F.equal.(empty),
    null?: F.equal.(empty),
    double: slf.(plus),
    square: slf.(times),
    app: ->(*fs) { apply.(fs.first, fs.drop(1)) },
    snoc: ->(el) {

       ->(stream) { 
        # next_fn = step.(->(stream) {
        #     next_item = stream.next_item
        #     next_item == [:done] ? wrap.(el) : next_item.last
        #   }, 
        #   ->(stream) {
        #     next_item = stream.next_item
        #     next_item.first == :skip ? Nothing : next_item[1]
        # })
        next_fn = ->(s) {
          next_item = s.next_item
          if next_item == [:done]
            [:skip, wrap.(el)]
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
    zip: zip_with.(list),

    unfoldl: -> (next_fn, stop_fn, seed) { 
      stream_next_fn = ->x { x }
      Stream.new(stream_next_fn, seed)
    },
    transducer: ->(next_val_fn, next_state_fn, stop_fn) {
      ->(stream) {
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

    mapleft: ->(fn) { 
        ->(stream) {
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

    foldleft: ->(f,u) { 
    
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

    scanleft: ->(f,u) { 
      ->(stream) {
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
  }
  @@stage_0_5_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  self.define_singleton_method(:zip_with_index) { F.zip_with.(F.list).(F.range.(0, F.infinity)) }

  @@stage_1_defs = {

    apply_fn: -> (f, *args) { f.(*args)},
  
    ## functional combinators - higher-order functions generic over their container

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

    filter: ->(fn) { 
      ->(stream) {
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
    
       ->(stream) {
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
      ->(right_stream) {
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
    initial: ->(stream) {
      next_fn = ->(strm) {
        next_item = strm.next_item
        if next_item.first == :done
          raise "Must have at least one item inside of the stream!"
        elsif next_item.first == :yield
          [:yield, next_item[1], empty]
        elsif next_item.first == :skip
          [:skip, next_item.last]
        else
          raise("#{next_item} is a malformed stream response!")
        end
      }
      Stream.new(next_fn, stream)
      },
    final: -> (stream) { 
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

    

    suffixes: ->(stream) {
      next_fn = ->(strm) {
        puts strm.inspect
        next_item = strm.next_item
        if next_item.first == :done
          [:yield, strm, empty]
        elsif next_item.first == :yield
          [:yield, strm, Stream.new(next_fn, next_item.last)]
        elsif next_item.first == :skip
          [:skip, Stream.new(next_fn, next_item.last)]
        else
          raise("#{next_item} is a malformed stream response!")
        end
      }
      Stream.new(next_fn, stream)
    } * to_stream,
    


  }

  @@stage_1_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  @@stage_1_5_defs = {
    prefixes: foldr.(->(el, acc) { cons.(empty, map.(cons.(el), acc)) }, wrap.(empty)),
  }

  @@stage_1_5_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  @@stage_2_defs = {
    ## stream functions
    last: first * final,
    uncons: ->(s) { append(first.(l), wrap(rest.(l)))  } * to_stream,
    unsnoc: ->(s) { append(wrap(init.(s)), last.(s)) } * to_stream,
    reverse: foldl.(->(acc, el) { cons.(el, acc) }, []), ## or foldr.(->(el,acc) { snoc.(acc, el) }, [])
    length: foldl.(inc, 0),
    length_at_least: ->(n) { ->(x) { x != Nothing } * find_where.(equals.(n)) * scanl.(inc, 0) },
    concat: flatmap.(to_stream),
    enconcat: ->(left_stream, el,right_stream) { append.(left_stream.to_stream) * cons.(el) * to_stream <= right_stream },
    
    replace: ->(to_replace, to_replace_with) {map.(->(x) { x == to_replace ? to_replace_with : x })},
    replace_with: ->(to_replace_with, to_replace) { map.(->(x) { x == to_replace ? to_replace_with : x }) },
    find_where: ->(fn){ first * filter.(fn) },
    find_last_where: ->(fn){ last * filter.(fn) },
    transpose: ->(stream_of_streams) { zip.( *(stream_of_streams.to_stream) ) },
    tail: rest,
    prefix: init,
    suffix: rest,
    head: first,
    inits: prefixes,
    tails: suffixes,
    starts_with: ->(slice, xs) {  },
    ends_with: ->(slice, xs) {  },
    intersperse: ->(x, xs) { rest * flatmap.(->(y) { [x, y] }) <= xs.to_stream },

    # stream folds useful for containers of numbers (core statistics algorithms)
    
    maximum: foldl.(max, negative_infinity),
    minimum: foldl.(min, infinity),
    maximum_by: ->(fn) { foldl.(->(max_so_far, el) { max_so_far == Nothing || fn.(el) > fn.(max_so_far) ? el : max_so_far}, Nothing) },
    minimum_by:  ->(fn) { foldl.(->(min_so_far, el) { min_so_far == Nothing || fn.(el) < fn.(min_so_far) ? el : min_so_far}, Nothing) },

    sum: foldl.(plus, 0),
    product: foldl.(times, 1),
    
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
    first_index_where: ->(fn) { first * find_where.( fn * last ) * zip_with_index },
    last_index_where: ->(fn) { first * last * filter.( fn * last ) * zip_with_index },
    
    mean: ->(l) { div_from.(*( [sum,length].(l) )) }, ## this works because (sum + length).(l)== [sum.(l), length.(l)]
    sum_of_squares: sum * map.(square),
    ## this is a two-pass algorithm
    sum_of_square_difference_from_mean_two_pass: ->(mean) { sum * map.(square * sub_by.(mean)) } * ->(l) { div_from(*( (sum + length).(l) )) },

    sum_of_differences_from_estimated_mean: ->(xs) {
      sum * map.(square * sub_by.())
    },

    # stream folds useful for containers of booleans
    ands: ->(x) { x == Nothing } * find_where.(F.equals.(false)),
    ors: ->(x) { x != Nothing } * find_where.(F.equals.(true)),

    
    ## stream functionals
    contains?: ->(el) { F.not * F.equal.(Nothing) * find_where.(equals.(el)) },
    does_not_contain?: ->(el) { F.equal.(Nothing) * find_where.(equals.(el)) },
    contains_slice?: ->(slice) { any?.(starts_with.(slice)) * tails },
    all?: ->(f) { ->(x) { x == Nothing } * find_where.(->(x) { !f.(x)})}, ## this is going to become equal.(Nothing) * first * find_where.(F.not.(f))
    any?: ->(f) { ->(x) { x != Nothing } * find_where.(f)},
    fold: ->(fn, u) { final * scanl.(fn, u) },
    slice_by: ->(starts_with_fn, ends_with_fn) { take_until.(ends_with_fn) * drop_until.(starts_with_fn) },
    interleave: ->(xs, ys) { concat <= zip_with.(list).(xs,ys) }, ## remove the xs ys when I fix zip_with to work with *args and return a lambda expecting another if it only gets one stream to zip
    intercalate: ->(xs, xss) { concat.intersperse.(xs, xss) },
    contains_slice?: ->(stream) {  },
    partition_by: ->(fn, xs) {
      folded_filter = ->(f) { foldl.(->(acc, el) { acc << el if f.(el); acc }, []) }
      (folded_filter.(fn) + folded_filter.(->(x) { !fn.(x) })) * to_stream <= xs
    },

  }

  @@stage_3_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}

  @@stage_4_defs = {
    last_index_of: ->(x) { last_index_where.(F.equal.(x)) },
    first_index_of: ->(x) { first_index_where.( F.equal.(x) ) },

    union: ->(xs) {
      ->(ys) {
          to_stream * to_set <= append.(xs, ys)
        } * to_stream
    } * to_stream,

    intersect: ->(xs) {
      ->(ys) {
          to_stream <= (to_set.(xs) & to_set.(ys))
        } * to_stream
    } * to_stream,

    difference: ->(xs) {
      ->(ys) {
          to_remove = to_set.(ys)
          filter.(->(x) { !ys.include?(x)}) <= xs
        } * to_stream
    } * to_stream,

    cartesian_product: ->(xs) {
      ->(ys) {
          flatmap.(->(x) { map.(->(y) { [x,y] }, ys) }, xs)
        } * to_stream
    } * to_stream,

    unzip: ->(xs) {
      map.(xs) + map.(last) <= xs
    } * to_stream,
=begin
    group_by: ->(fn, xs) {
      foldl.(->(acc, el) { 
          key = fn.(el)
          acc[key] ||= []
          acc[key] << el
          acc 
        }, {}).(to_stream.(xs))
    },
    group_by_and_summarize: ->(group_fn, summary_fn) {
      map.(summary_fn) * group_by.(group_fn)
    },
=end
    window: ->(n) {
      map.(take.(n)) * suffixes
    },

    subsequences: ->() {
      subs = ->(ys) { ys == empty ? wrap.(empty) : subs.(rest.(ys)) ** [F.id, F.cons.(first.(ys))].to_stream }
    }.(), #wrap.(empty),
    ## Using Control.Applicative
    # subs [] = [[]]
    # subs (x:xs) = subs xs <**> [id, (x :)] 
    ## subsequences is useful for fuzzy sequence matching style algorithms a la command tab in sublime, 
    ### or figuring out if some melody or progressionis an elaboration of another (same thing), etc...
    ## is there any way to do this with a left fold instead of a right one?


    continuous_subsequences: filter.(F.not * empty?) * flatmap.(prefixes) * suffixes,
    ## continuous subsequences is useful for exact inside sequence matching a la find in sublime
    
=begin
    quicksort: ->() {
      qs = ->(xs) {
        pivot = head.(xs)
        if xs == empty
          empty
        else
          partitions = partition_by.(F.is_gt.(pivot)) <= tail.(xs)
          enconcat.(qs * first <= partitions, pivot, qs * last <= partitions)
        end
      } * to_stream ### if only this wasn't infinitely recursing...
    }.(),
=end

    group_by: ->(fn) { 
      next_fn = ->(state) {
        strm = state.last
        group = state.first
        next_item = strm.next_item
        tag = next_item.first
        val = next_item[1]
        next_stream = next_item.last
        if tag == :done && group == []
          [:done]
        elsif tag == :done
          [:yield, group, empty]
        elsif tag == :skip
          [:skip, Stream.new(next_fn, [group, next_stream])]
        elsif tag == :yield && (group.length == 0 || fn.(val) == fn.(group.last))
          [:skip, Stream.new(next_fn, [group + [val], next_stream])]
        elsif tag == :yield
          [:yield, group, Stream.new([[], next_stream])]
        else
          raise "#{next_item} is a malformed stream response!"
        end
      }
      Stream.new(next_fn, [[], state])
    } * to_stream,



  }

  @@stage_4_defs.each_pair {|name, fn| self.define_singleton_method(name) { fn }}
  self.define_singleton_method(:group) { ->(xs) { group_by.(id) } }
end
  #std

class Stream

  def [](first, last=-1)
    if last == -1
      i = args.first
      F.first * F.drop.(i)
    elsif first < 0 && last < 0
      F.drop_except.(last.abs - 1) * F.drop_except.(first.abs) <= self
      ##todo 
    else
      raise ""
    end

  end

  def first
    F.first.(self)
  end

  def last
    F.last.(self)
  end

  def rest
    F.rest.(self)
  end

  def any?(fn=F.id)
    F.any?(fn) <= self   
  end

  def all?(fn=F.id)
    F.all?(fn) <= self   
  end

  ## Applicative <**> 
  ## [1,2,3] ** [id, double]
  ## [1,2,2,4,3,6]
  ## defaults to cartesian product if you haven't got any procs in there
  def **(stream_of_fns)
    !F.any?.(->(x) { x.kind_of? Proc }) ? self^stream_of_fns : F.flatmap.(->(x) { stream_of_fns.(x).to_stream }).(self)
  end

  #cartesian product
  def ^(stream)
    F.cartesian_product.(self, stream)
  end

  ## zip or applicative * depending on if there any function values in the array/stream ## or should it be interleave to go with % below?
  #[id, double] * [1,2,3]
  #[1,2,3,2,4,6]
  def *(stream, is_zip=false)
    is_zip || !F.any?.(->(x){ x.kind_of? Proc }) ? F.zip.(self, stream) : F.flatmap.(->(f) { F.map.(f) <= stream.to_stream }).(self.to_stream)
  end

  ## %2 is odds, rest %2 is evens. doing % 3 breaks into every third item. % n does every nth as a stream
  ## [odds, evens].(interleave.(xs,ys)) == [xs,ys] 
  def %(n)
    F.filter.(->(x) { x % n == 0}).(self)
  end

  def +(stream)
     F.append.(self, stream)
  end

  def -(stream)
    F.difference.(self, stream)
  end

  ## this kind of conflicts with | being function pipelining - maybe change that to use < and >  instead of * and |  so we can keep ruby-ishness
  ## but we'll still need something for >>=, <**>, <$> and <.> later...

  def |(stream) #
    F.union.(self, stream)
  end

  def &(stream)
    F.intersect.(self, stream)
  end
end

class Array

  ## Applicative <**> 
  ## [1,2,3] ** [id, double]
  ## [1,2,2,4,3,6]
  def **(arr)
    !arr.any?{|x| x.kind_of? Proc } ? self^arr : F.flatmap.(->(x) { arr.to_stream.(x) }).(self).to_a
  end

  ## cartesian product
  def ^(arr)
    self.map {|x| arr.to_a.map { |y| [x,y] } }.foldl(->(acc,el) { acc.push(el) }, [])
  end

  ## cartesian product or applicative * depending on if there any function values in the array/stream
  #[id, double] * [1,2,3]
  #[1,2,3,2,4,6]
  def *(arr, is_zip=false)
    is_zip || !self.any?{|x| x.kind_of? Proc } ? self.zip(arr.to_a) : F.flatmap.(->(f) { F.map.(f) <= arr.to_stream }).(self.to_stream).to_a
  end


end

=begin
## functionals useful for lists ( but which work on anything supporting .each, and will yield a list )



updated

last_index_of_slice
first_index_of_slice
nth
index_of
index_where
findIndex?

random
randomN
segmentLength

partition_at = ->(n) { take.(n) + drop.(n) }
split_by = ->(fn) { take_while.(fn) + drop_while.(fn) }

splice
patch
span

permutations
combinations

sort_by ## insertionSort
scanr

## functionals useful in untyped languages like ruby - arbitrarily deep map, zip, and merge - and deep_clone

deep_map ## for a dictionary, maps across all its values deep until not-a-dictionary
        ## for a list, maps  across all its values deep until not-a-list
        ## in general, it just deeply applies fmap with a particular kind it should only apply to
deep_map_ ## keeps going no matter what the kind is, as long as it supports fmap
deep_zip
deep_merge ## implement with deep_zip and deep_map
deep_diff ## implement with deep_zip and deep_map
  
=end


=begin The below is for later implementation


quicksort ## use stream fusion == quicksort 
mergesort ## use stream fusion

deepMap
deepZip
deepMerge

hylo # unfoldl . foldl
meta # foldl . unfoldl

=end