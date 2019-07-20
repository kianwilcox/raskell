Making Ruby a Joy to Work With In X (Easy?) Steps

\*I) partial application for lambdas, treat [] as .call() for lambdas, and add .call(\*args) to objects (a no-op) and arrays (map across calling element.call(\*args) for each element)
\*II) function tupling, composition, and pipelining in the form of +,\*, and \|
\*III) a very lightweight testing framework, DoubleCheck, built using the above as a demo, along with tests for everything previously built
\*IV) a standard collections library based around fusable stream transducers - (flat)map, filter, fold\*, zip, append, scanl - Scala/Haskell eqv.
\*V) add instances of from_stream(ClassName=Array) and to_stream for Dictionary, (Multi?)Set, Array, Range, String, Integer, Object, and Enumerable
\*VI) add tupling for foldl, and (map / scanl with each other, really anything that produces as many outputs as it takes in - so might need a scanl1 and a foldl1, so we can combine any/all of them together and still succeed in only consuming a stream once) as well, so that multiple transducers can run in parallel across the same stream in a single pass
\*VII) Implement Applicative instances for Proc, Array, and Stream 
VII) modularize for easy addition into other's projects, organize code and test coverage (Procish), reduce code duplication
IX) Document, let simmer with experience, and optimize
X) Make everything that isn't a function a 'constant' function that implicitly pushes to an ArgumentStack once lifted, and then returns the ArgumentStack. Modify lambda calling to properly use argument stack if it is passed in, and to place unused arguments onto after calling - forking lambdas - i.e. a [fn, fn2,fn3,fn4].(), duplicate argument stacks and create unique new ones in their locations, rather than 'sharing' a common argument stack - turning Raskell into a concatenative language - a "Joy" to *work* with