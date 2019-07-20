# raskell
Functional and Concatenative Stream Programming in Ruby
=======


Usage:

Reminder: Lambdas can be applied with [\*args] notation and .() is syntactic sugar for .call()
```f = ->(x) { x + 2 } ```
```f[1]``` , ```f.(1)```, and ```f.call(1)``` all evaluate as ```3```


Lambdas can be partially applied, yielding a new lambda, with call
```plus = ->(x,y) { x + y }```
```plus10 = plus.(10) ## or plus[10]```
```plus10.(20)``` evaluates as ```30```

Lambda Composition with \* (right-associative) ```( (f * g * h).(x) == f.(g.(h.(x))))```
```times10 = ->(x) { x * 10 }```
```minus3 = ->(x) { x - 3 }```
```double = ->(x) { x * 2 }```

```(times10 * minus3 * double).(5)``` evaluates as ```70```
```(double * minus3 * times10).(5)``` evaluates as ```94```


Lambda Pipelining with \| (left-associative)  ```(f | g | h).(x) == h.(g.(f.(x)))```
```(times10 | minus3 | double).(5)``` evaluates as ```94```
```(double | minus3 | times10).(5)``` evaluates as ```70```

Lambda Tupling with + (associative)
```(times10 + minus3 + double).(5)``` evaluates as ```[50, 2, 10]```

Objects, when called, act like constant functions that throw away any values applied to them
```5.(1,2,3,[4,7])``` evaluates to ```5```

Arrays, when called, map across themselves calling each element with the arguments it was called with
```[times10, minus3, double].(5)``` evaluates to ```[50, -15, 10]```
```[plus, times10, 3].(0,1)``` evaluates to ```[1, 0, 3]```
Note that ```[plus,times10,3][0,1]``` evaluates to ```[plus]```, not ```[1, 0, 3]```, so be careful where you use ```func[]``` as shorthand ```func.()``` or ```func.call()```!

Streams, when called, map across themselves calling each element with the arguments it was called with
```[times10, minus3, double].to_stream.(5).to_a``` evaluates to ```[50, -15, 10]```
```[plus, times10, 3].to_stream.(0,1)``` evaluates to ```[1, 0, 3].to_stream```
Note that ```[plus,times10,3].to_stream[0,1]``` evaluates to ```[plus].to_stream```, not ```[1, 0, 3].to_stream```, so be careful where you use ```func[]``` as shorthand ```func.()``` or ```func.call()```!

Preface any collection function with F. to call that particular function
```F.map.(times10 * plus10).([1,2,3])``` evaluates as ```[100, 200, 300]```




Available Operators to Overload in Ruby


(unary)
!, ~, +, \- 

(binary)
\*\*, \*, /, %, +, \-, <<, >>, &, \|, ^, ||, &&
=, +=, \*=, -=, 
<, <=, >=, >, ==, ===, !=, =~, !~, <=>
[],[]=

Using in Raskell so far
[], \*, \*\*, ^, \|, &, +, %, <<, >>

=~ and !~ will be good for later when I have 'regular expressions' over arbitrary asterated semirings - then i can match if the data, path, whatever matches a regex of allowable types - this gives us a powerful form of type constraint for free




