# raskell
Making Ruby a Joy to Work With 
=======


Usage:

Reminder: Lambdas can be applied with [\*args] notation and .() is syntactic sugar for .call()
```f = ->(x) { x + 2 } ```
```f[1]``` evaluates as ```3```


Lambdas can be partially applied, yielding a new lambda, with call
```plus = ->(x,y) { x + y }```
```plus10 = plus.(10) ## or plus[10]```
```plus10.(20)``` evaluates as ```30```

Lambda Composition with \* (right-associative) ```( (f \* g \* h).(x) == f.(g.(h.(x))))```
```times10 = ->(x) { x * 10 }```
```minus3 = ->(x) { x - 3 }```
```double = ->(x) { x * 2 }```

```(times10 * minus3 * double).(5)``` evaluates as ```70```
```(double * minus3 * times10).(5)``` evaluates as ```94```


Lambda Pipelining with \| (left-associative)  ```( (f \| g \| h).(x) == h.(g.(f.(x))) )```
```(times10 | minus3 | double).(5)``` evaluates as ```94```
```(double | minus3 | times10).(5)``` evaluates as ```70```

Lambda Tupling with + (associative)
```(times10 + minus3 + double).(5)``` evaluates as ```[50, 2, 10]```

Objects, when called, act like constant functions that throw away any values applied to them
```5.call(1,2,3,[4,7])``` evaluates to ```5```

Arrays, when called, map across themselves calling each element with the arguments it was called with
```[times10, minus3, double].(5)``` evaluates to ```5```
```[plus, times10, 3].(0,1)``` evaluates to ```[1, 0, 3]```
Note that ```[plus,times10,3][0,1]``` evaluates to ```[plus]```, not ```[1, 0, 3]```, so be careful where you use ```func[]``` as shorthand ```func.()``` or ```func.call()```!

Streams, when called, map across themselves calling each element with the arguments it was called with
```[times10, minus3, double].to_stream.(5)``` evaluates to ```5```
```[plus, times10, 3].to_stream.(0,1)``` evaluates to ```[1, 0, 3].to_stream```
Note that ```[plus,times10,3].to_stream[0,1]``` evaluates to ```[plus].to_stream```, not ```[1, 0, 3].to_stream```, so be careful where you use ```func[]``` as shorthand ```func.()``` or ```func.call()```!

Preface any collection function with F. to call that particular function
```F.map(times10 * plus10).([1,2,3])``` evaluates as ```[100, 200, 300]```


Making Ruby a "Joy" to Work With In X (Easy?) Steps

\*I) partial application for lambdas, treat [] as .call() for lambdas, and add .call(\*args) to objects (a no-op) and arrays (map across calling element.call(\*args) for each element)
\*II) function tupling, composition, and pipelining in the form of +,\*, and \|
\*III) a very lightweight testing framework, DoubleCheck, built using the above as a demo, along with tests for everything previously built
\*IV) a standard collections library based around fusable stream transducers - (flat)map, filter, fold\*, zip, append, scanl - Scala/Haskell eqv.
\*V) add instances of from_stream(ClassName=Array) and to_stream for Dictionary, (Multi?)Set, Array, Range, String, Integer, Object, and Enumerator
\*VI) add tupling for foldl, and (map / scanl with each other, really anything that produces as many outputs as it takes in - so might need a scanl1 and a foldl1, so we can combine any/all of them together and still succeed in only consuming a stream once) as well, so that multiple transducers can run in parallel across the same stream in a single pass
\*VII) Implement Applicative instances for Array and Stream 
VIII) organize code so that it is clear what consumes the entire stream strictly (foldl-based), what consumes the entire stream lazily (scanl, everything else pretty much), and what can be combined via + to avoid multiple passes over a single stream when computing multiple functions of the stream (foldl, scanl) - example, ```(F.length + F.sum + F.product + F.sum_of_squares).([1,2,3,4].to_stream)``` computes all of those statistics in a single pass, yielding ```[4, 10, 24, 30]```, and make sure that all functions are as optimized and elegantly defined as possible. -- probably need a specialized one for very large lists, one for infinite, and one for the rest
IX) modularize for easy addition into other's projects, optimize automatically in the common cases (use array-based functions when possible instead of stream, try to tighten up space (switch to to_streams on arrays have as state the original array and a next index, rather than creating a new array for every new one - just make sure it can't share it externally by deep_cloning it once))
X) Make everything that isn't a function a 'constant' function that implicitly pushes to an ArgumentStack once lifted, and then returns the ArgumentStack. Modify lambda calling to properly use argument stack if it is passed in, and to place unused arguments onto after calling - forking lambdas - i.e. a [fn, fn2,fn3,fn4].(), duplicate argument stacks and create unique new ones in their locations, rather than 'sharing' a common argument stack - turning Raskell into a "Joy" to *work* with




Available Operators to Overload in Ruby

(unary)
!, ~, +, \- 

(binary)
\*\*, \*, /, %, +, \-, <<, >>, &, \|, ^, ||, &&
=, +=, \*=, -=, 
<, <=, =>, >, ==, ===, !=, =~, !~, <=>
[],[]=

Using in Raskell so far
[], \*, \*\*, ^, \|, &, +, %, <=, >=, 

\>, <, >=, 

=~ and !~ will be good for later when I have 'regular expressions' over arbitrary asterated semirings - then i can match if the data, path, whatever matches a regex of allowable types - and this gives us a powerful form of type constraint for free




