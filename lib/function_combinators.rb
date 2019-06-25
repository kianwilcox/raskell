
flip = -> (f,x,y) { f.(y,x) }
slf = -> (f, x) { f.(x,x) }
foldl = ->(f,u,l) { l.reduce(u) {|acc, el| f.(acc,el)}}
map = ->(f,l) { foldl.(->(acc,el) { acc.push(f.(el))},
                       [], l)}
filter = ->(f,l) { foldl.(->(acc,el) { f.(el) ? acc.push(el) : acc },
                          [], l)}


