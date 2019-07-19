
## module System 
class F ## @@System||=:F to use 3;) --- or, you can just extend with System, and get the F for free.
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
    
  def self.id
    Identity.new # ->(x) { x }
  end

  def self.apply_with2
    @@apply_with2||= ->(y, f, x) { f.(x,y)}
  end

  def self.apply
    @@apply||= ->(f, *xs) { f.(*xs) }
  end

  def self.apply_with
    @@apply_with||= ->(x,f) { f.(x) } # flip * apply
  end

  def self.compose
    @@compose||= ->(f,g) { f * g }
  end

  def self.flip
    @@flip||= -> (f,x,y) { f.(y,x) }
  end

  def self.slf
    @@slf||= -> (f, x) { f.(x,x) } ## square = slf * times
  end

  def self.fix
    @@fix||= ->(f, x) { 
      result = x
      next_result = f.(x)
      while result != next_result
        result = next_result
        next_result = f.(result)
      end
      result
    }
  end

  ## next_stream_fn yields Nothing for stop, and the next stream to go to otherwise
  ## yield_fn yields a Nothing for skip, and the next value to yield otherwise
  def self.cstep
    @@cstep||= ->(next_stream_fn, yield_fn) {
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
    }
  end

  def self.step
    @@step||= ->(transition_fn, yield_fn) {
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
    }
  end

    ## booleans
  def self.not
    @@not||= ->(x) { !x }
  end
    
  def self.and
    @@and||= ->(x,y) { x && y }
  end

  def self.nand
    @@nand||= ->(x,y) { !(x && y) }
  end

  def self.or
    @@or||= ->(x,y) { x || y }
  end
  
  def self.nor
    @@nor||= ->(x,y) { !x && !y }
  end

  def self.xor
    @@xor||= ->(x,y) { !(x && y) && (x || y) }
  end

    ## numbers
  def self.inc
    @@inc||= ->(x) { x + 1 }
  end

  def self.dec
    @@dec||= ->(x) { x - 1 }
  end

  def self.plus
    @@plus||= ->(x,y) { x + y }
  end

  def self.times
    @@times||= ->(x,y) { x * y }
  end

  def self.sub_from
    @@sub_from||= ->(x,y) { x - y }
  end

  def self.div_from
    @@div_from||= ->(x,y) { x / y }
  end
  
  def self.div_by
    @@div_by||= ->(y,x) { x / y}
  end

  def self.sub_by
    @@sub_by||= ->(y,x) { x - y}
  end
  
  def self.equals
    @@equals||= ->(x,y) { x == y }
  end
  
  def self.equal
    @@equal||= ->(x,y) { x == y }
  end
  
  def self.eq
    @@eq||= ->(x,y) { x === y }
  end
  
  def self.is_gt
    @@is_gt||= ->(y,x) { x > y }
  end
  
  def self.is_lt
    @@is_lt||= ->(y,x) { x < y }
  end
  
  def self.is_gte
    @@is_gte||= ->(y,x) { x >= y }
  end
  
  def self.is_lte
    @@is_lte||= ->(y,x) { x <= y }
  end
  
  def self.gt
    @@gt||= ->(x,y) { x > y }
  end
  
  def self.lt
    @@lt||= ->(x,y) { x < y }
  end
  
  def self.gte
    @@gte||= ->(x,y) { x >= y }
  end
  
  def self.lte
    @@lte||= ->(x,y) { x <= y }
  end
  
    #insert  ln, lg, log, log_base, e, pi, exp/pow, square, cube, nth_root, sqrt  here later
  def self.max
    @@max||= ->(x,y) { x >= y ? x : y}
  end
  
  def self.min
    @@min||= ->(x,y) { x <= y ? x : y}
  end

    ## streams
  def self.empty
    @@empty||= Stream.new(->(x) { [:done] }, Nothing)
  end

  def self.wrap
    @@wrap||= ->(x) {
      next_fn = ->(bool) { bool ? [:yield, x, Stream.new(next_fn, false)] : [:done]}
      Stream.new(next_fn, true)
    }
  end

  def self.cons
   @@cons||= ->(el) { 
      ->(stream) {
        Stream.new(->(x) { [:yield, el, stream] } , Nothing) 
      } * to_stream
    }
  end


  def self.first
    @@first||= -> (stream) { ## should offer an equivalent that returns a stream with a single element
      next_item = stream.next_item
      while next_item.first == :skip
        next_item = next_item.last.next_item
      end
      next_item.first == :yield ? next_item[1] : Nothing
    } * to_stream
  end

  def self.rest
    @@rest||= -> (stream) { 
      next_item = stream.next_item
      next_item == [:done] ? Nothing : next_item.last
    } * to_stream
  end

  def self.take
    @@take||= ->(n) {
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
    }
  end 

  def self.drop
    @@drop||= ->(n) {
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
    }
  end 

  def self.drop_except
    @@drop_except||= ->(n) {
      raise("#{n} must be a positive number") if n < 0
      ->(stream) {
        next_fn = ->(strm) { 
          potential_stream = take.(n+1) << strm
          if (length.(potential_stream)) < n+1
            [:skip, take.(n) << strm]
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
    }
  end

  def self.init
    @@init||= ->(stream) { 
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
    } * to_stream
  end

  def self.take_while
    @@take_while||= ->(fn) {
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
    }
  end 

  def self.drop_while
    @@drop_while||= ->(fn) {
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
    }
  end 

  def self.take_until
    @@take_until||= ->(fn) {
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
    }
  end 

  def self.drop_until
    @@drop_until||= ->(fn) {
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
    }
  end 

  def self.zip_with
    @@zip_with||= ->(fn) {
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
    }
  end

    ## lists
  def self.list
    @@list||= ->(*items) { items }
  end

  def self.empty?
    @@empty_p||= F.equal.(empty)
  end
  
  def self.null?
    @@null_p||= F.equal.(empty)
  end

  def self.double
    @@double||= slf.(plus)
  end

  def self.square
    @@square||= slf.(times)
  end

  def self.app
    @@app||= ->(*fs) { apply.(fs.first, fs.drop(1)) }
  end
  
  def self.snoc
    @@snoc||= ->(el) {

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
    }
  end

  def self.zip
    @@zip||= zip_with.(list)
  end

  def self.unfoldl
    @@unfoldl||= -> (next_fn, stop_fn, seed) { 
      stream_next_fn = ->x { x }
      Stream.new(stream_next_fn, seed)
    }
  end


  def self.transducer
    @@transducer||= ->(next_val_fn, next_state_fn, stop_fn) {
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
    }
  end

  def self.mapleft
    @@mapleft||= ->(fn) { 
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
    }
  end

  def self.foldleft
    @@foldleft||= ->(f,u) { 
    
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

  def self.scanleft
    @@scanleft||= ->(f,u) { 
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
    
    }
  end

  def self.zip_with_index
    @@zip_with_index||= F.zip_with.(F.list).(F.range.(0, F.infinity))
  end

  def self.apply_fn
    @@apply_fn||= -> (f, *args) { f.(*args)}
  end
  
    ## functional combinators - higher-order functions generic over their container

    ## implement this and foldl instead as first implementing scanl and scanr, and then choosing the very last value of the stream
    ## so that we can have an abort-fold-when that gives the value collected so far like a loop that terminates early
  def self.foldr
    @@foldr||= ->(f,u) { 
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

  def self.filter
    @@filter||= ->(fn) { 
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
    }
  end
  
  def self.flatmap
    @@flatmap||= ->(fn) { 
    
       ->(stream) {
        next_fn = ->(next_el) {
          state = next_el.first
          potential_stream = next_el.last
          if potential_stream == Nothing
            next_el = state.next_item
            if next_el == [:done]
              [:done]
            elsif next_el.first == :skip
              [:skip, Stream.new(next_fn, [next_el.last, Nothing])]
            elsif next_el.first == :yield
              [:skip, Stream.new(next_fn, [next_el.last, fn.(next_el[1])])]
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
        Stream.new(next_fn, [stream, Nothing]) 
      } * to_stream
    
    }
  end

  def self.range
    @@range||= ->(begin_with, end_with) {
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
    @@append||= ->(left_stream) {
      ->(right_stream) {
        left_next_fn = ->(stream) {
          next_el = stream.next_item
          if next_el == [:done]
            [:skip, right_stream]
          elsif next_el.first == :skip
            [:skip, Stream.new(left_next_fn, next_el.last)]
          elsif next_el.first == :yield
            [next_el.first, next_el[1], Stream.new(left_next_fn, next_el.last)]
          else
            raise "#{next_el.inspect} is not a valid stream state!"
          end
        }
        
        Stream.new(left_next_fn, left_stream)
      } * to_stream
      
    } * to_stream
  end

  def self.initial
    @@initial||= ->(stream) {
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
      }
  end

  def self.final
    @@final||= -> (stream) { 
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
    } * to_stream
  end

    

  def self.suffixes
    @@suffixes||= ->(stream) {
      next_fn = ->(strm) {
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
    } * to_stream
  end


  def self.prefixes
    @@prefixes||= foldr.(->(el, acc) { cons.(empty, map.(cons.(el), acc)) }, wrap.(empty))
  end

  def self.naturals
    @@naturals||= range.(1, infinity)
  end

    ## stream functions
  def self.last
    @@last||= first * final
  end

  def self.uncons
    @@uncons||= ->(s) { append(first.(l), wrap(rest.(l)))  } * to_stream
  end

  def self.unsnoc
    @@unsnoc||= ->(s) { append(wrap(init.(s)), last.(s)) } * to_stream
  end

  def self.reverse
    @@reverse||= foldl.(->(acc, el) { cons.(el, acc) }, []) ## or foldr.(->(el,acc) { snoc.(acc, el) }
  end
  
  def self.length
    @@length||= foldl.(inc, 0)
  end

  def self.length_at_least
    @@length_at_least||= ->(n) { ->(x) { x != Nothing } * find_where.(equals.(n)) * scanl.(inc, 0) }
  end

  def self.concat
    @@concat||= flatmap.(to_stream)
  end

  def self.enconcat
    @@enconcat||= ->(left_stream, el) { append.(left_stream.to_stream) * cons.(el) * to_stream }
  end
    
  def self.replace
    @@replace||= ->(to_replace, to_replace_with) {map.(->(x) { x == to_replace ? to_replace_with : x })}
  end
  
  def self.replace_with
    @@replace_with||= ->(to_replace_with, to_replace) { map.(->(x) { x == to_replace ? to_replace_with : x }) }
  end
  
  def self.find_where
    @@find_where||= ->(fn){ first * filter.(fn) }
  end
  
  def self.find_last_where
    @@find_last_where||= ->(fn){ last * filter.(fn) }
  end
  
  def self.transpose
    @@transpose||= ->(stream_of_streams) { zip.( *(stream_of_streams.to_stream) ) }
  end
  
  def self.tail
    @@tail||= rest
  end

  def self.prefix
    @@prefix||= init
  end

  def self.suffix
    @@suffix||= rest
  end

  def self.head
    @@head||= first
  end

  def self.inits
    @@inits||= prefixes
  end

  def self.tails
    @@tails||= suffixes
  end

  def self.starts_with
    @@starts_with||= ->(slice, xs) {  }
  end

  def self.ends_with
    @@ends_with||= ->(slice, xs) {  }
  end
  
  def self.intersperse
    @@intersperse||= ->(x, xs) { rest * flatmap.(->(y) { [x, y] }) << xs.to_stream }
  end

    # stream folds useful for containers of numbers (core statistics algorithms)
  
  def self.maximum  
    @@maximum||= foldl.(max, negative_infinity)
  end

  def self.minimum
    @@minimum||= foldl.(min, infinity)
  end

  def self.maximum_by
    @@maximum_by||= ->(fn) { foldl.(->(max_so_far, el) { max_so_far == Nothing || fn.(el) > fn.(max_so_far) ? el : max_so_far}, Nothing) }
  end
  
  def self.minimum_by
    @@minimum_by||=  ->(fn) { foldl.(->(min_so_far, el) { min_so_far == Nothing || fn.(el) < fn.(min_so_far) ? el : min_so_far}, Nothing) }
  end

  def self.sum
    @@sum||= foldl.(plus, 0)
  end

  def self.product
    @@product||= foldl.(times, 1)
  end

    ## this is a one-pass algorithm, but only an estimate
    #sum_of_squares_of_differences_from_mean_iterative
    ## - need length, sum, sum_of_squares, M1,M2,M3, deltas, etc... see @@https||=//en.wikipedia.org/wiki/Algorithms_for_calculating_variance
    ## population_variance
    ## sample_variance
    #->(l) { 
    #  len, sm, sm_sqrs = (length + sum + sum_of_squares).(l)
    #}
  

  def self.repeat
    @@repeat||= ->(n, fn, x) {
      result = x
      count = n
      while count > 0
        result = fn.(result)
      end
      result
    }
  end
  
  def self.rotate
    @@rotate||= ->(s) { append.(tail.(s), initial.(s)) }
  end
  
  def self.first_index_where
    @@first_index_where||= ->(fn) { first * find_where.( fn * last ) * zip_with_index }
  end
  
  def self.last_index_where
    @@last_index_where||= ->(fn) { first * last * filter.( fn * last ) * zip_with_index }
  end
    
  def self.mean
    @@mean||= ->(l) { div_from.(*( (sum + length).(l) )) }
  end ## this works because (sum + length).(l)== [sum.(l), length.(l)]
  
  def self.sum_of_squares  
    @@sum_of_squares||= sum * map.(square)
  end

## this is a two-pass algorithm
    
  def self.sum_of_differences_from_estimated_mean
    @@sum_of_differences_from_estimated_mean||= ->(xs) {
      sum * map.(square * sub_by.())
    }
  end

    # stream folds useful for containers of booleans
  def self.ands
    @@ands||= ->(x) { x == Nothing } * find_where.(F.equals.(false))
  end

  def self.ors
    @@ors||= ->(x) { x != Nothing } * find_where.(F.equals.(true))
  end

    
    ## stream functionals
  def self.contains?
    @@contains_p||= ->(el) { F.not * F.equal.(Nothing) * find_where.(equals.(el)) }
  end

  def self.does_not_contain?
    @@does_not_contain_p||= ->(el) { F.equal.(Nothing) * find_where.(equals.(el)) }
  end
  
  def self.contains_slice?
    @@contains_slice_p||= ->(slice) { any?.(starts_with.(slice)) * tails }
  end
  
  def self.all?
    @@all_p||= ->(f) { ->(x) { x == Nothing } * find_where.(->(x) { !f.(x)})}
  end ## this is going to become equal.(Nothing) * first * find_where.(F.not.(f))
  
  def self.any?
    @@any_p||= ->(f) { ->(x) { x != Nothing } * find_where.(f)}
  end
  
  def self.fold
    @@fold||= ->(fn, u) { final * scanl.(fn, u) }
  end
  
  def self.slice_by
    @@slice_by||= ->(starts_with_fn, ends_with_fn) { take_until.(ends_with_fn) * drop_until.(starts_with_fn) }
  end
  
  def self.interleave
    @@interleave||= ->(xs, *ys) { ys.length > 0 ? (concat * zip).(*([xs]+ys)) : ->(zs, *ys) { concat << zip.(*([xs,zs]+ys)) } }
  end ## you can undo this with % n, where n is the number of streams
  
  def self.intercalate
    @@intercalate||= ->(xs, xss) { concat.intersperse.(xs, xss) }
  end
  
  def self.partition_by
    @@partition_by||= ->(fn) {
      folded_filter = ->(f) { foldl.(->(acc, el) { f.(el) ?  acc << el : acc }, []) }
      (folded_filter.(fn) + folded_filter.(->(x) { !fn.(x) })) * to_stream
    }
  end

  def self.partition_at
    @@partition_at||= ->(n) { take.(n) + drop.(n) }
  end

  def self.split_by
    @@split_by = ->(fn) { take_while.(fn) + drop_while.(fn) }
  end

  def self.sum_of_square_difference_from_mean_two_pass
    @@sum_of_square_difference_from_mean_two_pass||= ->(l) { sum * map.(square * sub_by.(mean.(l))) << l }
  end
  
  def self.last_index_of
    @@last_index_of||= ->(x) { last_index_where.(F.equal.(x)) }
  end
  
  def self.first_index_of
    @@first_index_of||= ->(x) { first_index_where.( F.equal.(x) ) }
  end

  def self.union
    @@union||= ->(xs) {
      ->(ys) {
          to_stream * to_set << append.(xs, ys)
        } * to_stream
    } * to_stream
  end

  def self.interesect
    @@intersect||= ->(xs) {
      ->(ys) {
          to_stream << (to_set.(xs) & to_set.(ys))
        } * to_stream
    } * to_stream
  end

  def self.difference
    @@difference||= ->(xs) {
      ->(ys) {
          to_remove = to_set.(ys)
          filter.(->(x) { !ys.include?(x)}) << xs
        } * to_stream
    } * to_stream
  end

  def self.cartesian_product
    @@cartesian_product||= ->(xs) {
      ->(ys) {
          flatmap.(->(x) { map.(->(y) { [x,y] }, ys) }, xs)
        } * to_stream
    } * to_stream
  end

  def self.unzip
    @@unzip||= ->(xs) {
      map.(first) + map.(last) << xs
    } * to_stream
  end

  def self.bucket_by
    @@bucket_by||= ->(fn, xs) {
      foldl.(->(acc, el) { 
          key = fn.(el)
          acc[key] ||= []
          acc[key] << el
          acc 
        }, {}).(to_stream.(xs))
    }
  end
  
  def self.bucket_by_and_summarize
    @@bucket_by_and_summarize||= ->(group_fn, summary_fn) {
      map.(summary_fn) * bucket_by.(group_fn)
    }
  end

  def self.window
    @@window||= ->(n) {
      map.(take.(n)) * suffixes
    }
  end

  def self.subsequences
    @@subsequences||= ->() { ## Using the applicative instance for <**>, which is ^ in Raskell
      subs = ->(ys) { ys == empty ? wrap.(empty) : subs.(rest.(ys)) ^ [F.id, F.cons.(first.(ys))].to_stream }
    }.() #wrap.(empty)
  end
    ## Using Control.Applicative
    # subs [] = [[]]
    # subs (@@x||=xs) = subs xs <**> [id, (x :)] 
    ## subsequences is useful for fuzzy sequence matching style algorithms a la command tab in sublime, 
    ### or figuring out if some melody or progressionis an elaboration of another (same thing), etc...
    ## is there any way to do this with a left fold instead of a right one?


  def self.continuous_subsequences
    @@continuous_subsequences||= filter.(F.not * empty?) * flatmap.(prefixes) * suffixes
  end
  ## continuous subsequences is useful for exact inside sequence matching a la find in sublime
    
  def self.quicksort
    ->(xs) {
      if empty?.(xs)
        empty
      else
        pivot = head.(xs)
        partitions = (F.map.(self.quicksort) * partition_by.(F.is_lte.(pivot)) << tail.(xs)).to_a
        append.(partitions[0],cons.(pivot, partitions[1]))
      end
    } * to_stream ### if only this wasn't infinitely recursing...
 end

  def self.group_by
    @@group_by||= ->(fn) { 
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
    } * to_stream
  end

  def self.lines_from_file
    @@lines_from_file||= ->(filepath, options={}) {
      (options['separator'] ? IO.foreach(filepath, options['separator']) : IO.foreach(filepath)  ).to_stream
    }
  end

  def self.group 
    @@group||= ->(xs) { group_by.(id) }
  end
end
  #std

class Stream

  def deep_clone
    Stream.new(self.next_item_function, self.state.deep_clone)
  end

  def [](first, last=-1)
    if last == -1
      i = first
      F.first * F.drop.(i)
    elsif first < 0 && last < 0
      F.drop_except.(last.abs - 1) * F.drop_except.(first.abs) << self
      ##todo 
    else
      raise ""
    end

  end

=begin ## ruby doesn't allow you to override the return value on []=, which means we'd have to destructively alter this Stream
## but for some reason that isn't working very well - probably due to the need for self-reference. Guess my deep_clone isn't working 100%?
  def []=(index, item)
    next_fn = ->(state) {
      i = state.first
      strm = state.last
      if 
        [:yield, item, strm.next_item.last]
      else
        next_item = strm.next_item
        tag = next_item.first
        val = next_item[1]
        next_stream = next_item.last
        if tag == :done && i < index
          [:skip, F.snoc(item, Array.new(index - i-1, Nothing).to_stream)]
        elsif tag == :skip
          [:skip, Stream.new(next_fn, next_stream)]
        elsif tag == :yield && i == index
          [:yield, item, next_stream]
        elsif tag == :yield 
          [:yield, val, Stream.new(next_fn, next_stream)]
        else
          raise "#{next_item} is a malformed stream response"
        end
      end
    }
    state = [0, self.deep_clone]
    self.next_item_function = next_fn
    self.state = state
  end
=end

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
    F.any?(fn) << self   
  end

  def all?(fn=F.id)
    F.all?(fn) << self   
  end

  ## Applicative <**> 
  ## [1,2,3] ** [id, double]
  ## [1,2,2,4,3,6]
  ## defaults to cartesian product if you haven't got any procs in there
  def ^(stream_of_fns, is_cartesian=false)
    is_cartesian || !F.any?.(->(x) { x.kind_of? Proc }) ? self.cartesian_product.(stream_of_fns) : F.flatmap.(->(x) { stream_of_fns.(x).to_stream }).(self)
  end

  ## zip or Applicative <*> depending on if there any function values in the array/stream ## or should it be interleave to go with % below?
  #[id, double] * [1,2,3]
  #[1,2,3,2,4,6]
  def **(stream, is_zip=false)
    is_zip || !F.any?.(->(x){ x.kind_of? Proc }) ? F.zip.(self, stream) : F.flatmap.(->(f) { F.map.(f) << stream.to_stream }).(self.to_stream)
  end

  def *(stream) ## * and % are opposites
    F.interleave.(self, stream)
  end

  ## %2 is odds, rest %2 is evens. doing % 3 breaks into every third item. % n does every nth as a stream
  ## [odds, evens].(interleave.(xs,ys)) == [xs,ys] 
  def %(n=2) 
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
  def ^(arr, is_cartesian=false)
    is_cartesian || !arr.any?{|x| x.kind_of? Proc } ? self.cartesian_product(arr) : F.flatmap.(->(x) { arr.to_stream.(x) }).(self).to_a
  end

  ## cartesian product

  def cartesian_product(arr)
    self.map {|x| arr.to_a.map { |y| [x,y] } }.foldl(->(acc,el) { acc.push(el) }, [])
  end

  ## zip or Applicative <*> depending on if there any function values in the array/stream
  #[id, double] * [1,2,3]
  #[1,2,3,2,4,6]
  def **(arr, is_zip=false)
    is_zip || !self.any?{|x| x.kind_of? Proc } ? self.zip(arr.to_a) : F.flatmap.(->(f) { F.map.(f) << arr.to_stream }).(self.to_stream).to_a
  end


end

class Enumerator

  def self.to_stream(enum)
    enumerator_to_use = enum.clone.lazy
    enumerator_to_store = enumerator_to_use.clone

    next_fn = ->(state) {
      idx = state[0]
      enum_frozen = state[1]
      enum_next = state[2]

      next_state = [idx+1, enum_frozen, enum_next]
      next_tag = :yield
      begin
        begin
        next_item = enum_next.next
     
        rescue StopIteration => e
          next_tag = :done
        end
      rescue IOError => e
        next_state = [idx, enum_frozen, enum_frozen.clone.drop(i)]
        next_tag = :skip
      end
      ## this {@@type||= "enumerator" is a dirty hack - there has to be a better way to restore state after calling next_item}
      next_tag == :done  ?  [:done]  :  [next_tag] + (next_tag == :yield ? [next_item] : []) + [Stream.new(next_fn, next_state, {type: "enumerator"})]

    }
    Stream.new(next_fn, [0, enumerator_to_store, enumerator_to_use], {type: "enumerator"})
  end

  def to_stream
    self.class.to_stream(self)
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
