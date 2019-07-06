# raskell
Making Ruby a Joy to Work With 
=======
Making Ruby a Joy to Work With 


Usage:

Reminder: Lambdas can be applied with [\*args] notation and .() is syntactic sugar for .call()
```f = ->(x) { x + 2 } ```
```f[1]``` evaluates as ```3```


Lambdas can be partially applied, yielding a new lambda, with call
```plus = ->(x,y) { x + y }```
```plus10 = plus.(10) ## or plus[10]```
```plus10.(20)``` evaluates as ```30```

Lambda Composition with \* ( (f \* g \* h).() == )
```times10 = ->(x) { x * 10 }```
```minus3 = ->(x) { x - 3 }```
```double = ->(x) { x * 2 }```

```(times10 * minus3 * double).(5)``` evaluates as ```70```
```(double * minus3 * times10).(5)``` evaluates as ```94```


Lambda Pipelining with \| (left-associative)
```(times10 | minus3 | double).(5)``` evaluates as ```94```
```(double | minus3 | times10).(5)``` evaluates as ```70```

Lambda Tupling with + (associative, directionality irrelevant)
```(times10 + minus3 + double).(5)``` evaluates as ```[50, 2, 10]```

Objects, when called, act like constant functions that throw away any values applied to them
```5.call(1,2,3,[4,7])``` evaluates to ```5```

Arrays, when called, map across themselves calling each element with the arguments it was called with
```[times10, minus3, double].(5)``` evaluates to ```5```
```[plus, times10, 3].(0,1)``` evaluates to ```[1, 0, 3]```
Note that ```[plus,times10,3][0,1]``` evaluates to ```[plus]```, not ```[1, 0, 3]```, so be careful where you use ```func[]``` as shorthand ```func.()``` or ```func.call()```!

Preface any collection function with F. to call that particular function
```F.map(times10 * plus10).([1,2,3])``` evaluates as ```[100, 200, 300]```


\*I) partial application for lambdas, treat [] as .call() for lambdas, and add .call(\*args) to objects (a no-op) and arrays (map across calling element.call(\*args) for each element)
\*II) function tupling, composition, and pipelining in the form of +,\*, and |
III) a standard collections library based around fusable stream transducers - (flat)map, filter, fold\*, zip, append, scanl - Scala/Haskell eqv.
\*IV) a very lightweight testing framework, DoubleCheck, built using the above as a demo, along with tests for everything previously built
V) add tupling for stream transducers as well, so that multiple transducers can run in parallel across the same stream in a single pass, w/ tests
VI) add instances of from_stream(ClassName=Array) and to_stream for Dictionary, (Multi?)Set, Array, Range, Integer, and Object
VII) Make everything that isn't a function a 'constant' function that implicitly pushes to an ArgumentStack once lifted, and then returns the ArgumentStack. Modify lambda calling to properly use argument stack if it is passed in.
