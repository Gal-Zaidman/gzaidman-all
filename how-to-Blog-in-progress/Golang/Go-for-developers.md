# Notes

- Go is a staticly typed landguade, much like Java and C++.


## Packages

- each file needs to declare at the first line - to what package it belongs. For example "package main".
- There are 2 types of packages in go:
  - executable - generates a executable file **must be with package main**.
  - Reusable - reusable logic, common helpers, libraries and so on.

## Syntax

### Variables

- We can declere a **new** variable in a number of ways:
  - `var message string = "blabla"` - which is the full deceleration.
  - `message := "blabla` - In which we basically trust the go compiler to understand that we are creating a var of type string
- Basic data types: bool, string, int. float64.
- Variables can be initialized outside of a function, but cannot be assigned a variable.

### type

- the **type** keyword allows use to extend the basic language types and create custom types.
  `type deck []string`
- With custom types we can create functions that can be activated only with the custom type, just like a class has it own methods on OOP.

### Functions and Return Types

- When we declare a function we mush specify the type of data which will be returned.
- Functions can return multiple values.

  Examples:

  ```go
  // regular function
  func print () {
    fmt.Println("bla")
  }

  func message () (string, string) {
    return "bla", "blue"
  }
  ```

- Special Functions:
  - receiver functions - Probably the most important speical function in Golang. Those are function that are specific to a certain type. We can think of the type like a Class in OOP and the reciver function as the method

    ```go
    func (m message) print () {
      fmt.Println(string(m))
    }

    m := message{"blabla"}
    m.print
    ```

  - Function literal (lambda) - a function without a name. it is the equivalent of an anonymous function in JS.

    ```go
    func () {
      // Do something
    }()
    ```

  - Variadic function - a function that can accept a any number of arguments. Go will convert all the args given to the function to a slice. We create the variadic function by prefixing the last param with ..., then the function can accept any number of arguments for that parameter.
  Notice that only the last parameter of a function can be variadic.

      ```go
      func hello(a int, b ...int) {
        // Do something
      }
      hello(1, 2)
      hello(5, 6, 7, 8, 9)
      ```

### Slices and Arrays

- In Golang there are 2 data types for holding a list of variables:
  - Array - a primitive datatype with fixed length.
  - Slice - a wrapper around the array that can grow and shrink.
- I practice we will ususally use only slices in our code.
- When we create a slice go does 2 things:
  - creates an array with the elements that we defined
  - creates a slice data type that holds: the length of the array, the capacity of the array and a pointer to the array.

  ```go
  // Slice
  messages := []string{} # Empty slice
  // Notice that append dosen't modify the slice, it returns a new slice
  messages = append(messages, "blabla0")
  messages = append(messages, "blabla1")
  messages = append(messages, "blabla2")


  ```
- Slices and Arrays should contain the same type always.
- Select element within a slice:
  - messages[0] ==> "blabla0"
  - messages[0:2] == messages[:2] ==> ["blabla0", "blabla1"]

### Loops

- In for loops on each iteration we discard the variables index and item from the previous iteration and create new ones, that is why the := syntax is being used.
- We can skip on assiging a variable with the _ sign.
- To exit a for loop in the middle we use the **break** keyword
- To skip the current iteration of the for loop we use the **continue** keyword

  ```go
  // equal to while true {}
  for {
    // Do something

  }

  // Regular for loop with a break
  for i := 0; i < len(arr); i++ {
    if condition {
      break
    }
  }

  for index, item := range messages {
    // Do something with index and item
  }
  for _, item := range messages {
    // Do something with index and item
  }
  ```

### Testing

- To create a test in go we just need to create a file with the_test ending in its name.
- Like every other go file we have to say at the top to which package that file belongs to.
- Each test function needs to start with a capital letter.

### Structs

- A struct is a datatype that can group to gather multipule types
- A struct is similar to object in Javascript or a dict in Python.
- When you create a variable of a strict and don't initialize the fields then they get a default zero value, **not nil**. string --> "", int/float --> 0, boolean --> false.
- Struct can be nested meaning a struct can contain another struct

```go
// Defining a Struct
type person struct {
  fName string
  lName string
}

// Using a struct
gal := person{"Gal", "Zaidman"}                     // Option1 Unsafe
gal2 := person{fName: "Gal", lName: "Zaidman"}      // Option2 Safe
var gal3 person                                     // Option3 Zero Values
fmt.Printf("%+v",gal3)//==> {fName: "", lName: ""}  //Print a struct in a field:value format

// A struct can contain another struct
type Employe struct {
  person      // equest to writing person person
  job string
}
```

### Maps

- A Map Collection of key:value pairs.
- Maps are all keys and values needs have the same type, but a key can have a different type then its value.
  ```go
  m1 := map[string]int        // Define a map with key of type string and value of type int
  var m2 map[string]int       // Define an empty map
  m3 := make(map[string]int)  // Define an empty map
  m3["1"] = 1                 // Adding a key value to a map
  delete(m3,"1")              // Removing a key value from a map
  ```
- Iterating over a map is the same as iterating over a slice.

### Maps vs Structs

- Maps are reference type object meaning they hold references to their key:value pairs and Structs are Value type object meaning they hold the actual values in them.
- In maps support iteration.
- In maps all keys/values needs to have the same type and with structs we can mix.
- Usage:
  - Maps group together a collection of related values.
  - Struct is used to represent a "thing" with different properties.

### Pointers

Go is a "Pass By Value Language" that means then whenever we are passing a value to a function in Golang then Go will **copy** that value and save it in a temporary location in memory.
That means that if we pass a var to a function and change a field in it, the **original var will not get updated!** ==> To solve that we have POINTERS!

  ```go
  func (p person) updateName(n string) {
    p.fName = n
  }

  gal := person{fName: "Gal", lName: "Zaidman"}
  gal.updateName("bla")
  fmt.Println(gal)  ==> {"Gal", "Zaidman"}
  ```

- A pointer is a datatype that hold the memory address of a variable, there are 2 important symbols/operator we need to remember '*' and '&':

  ```go
  pv := &Var  // Give me the memory address of Var and put it in the pv variable.
  v := *pv    // Give me the value this memory address holds.
  ```

- Above I said that a pointer is a type like string, int and so on... so How can we declare a pointer? This is always confusing at first but a it will always be like this *typeOfVar so:

```go
  - var ps *string // pointer to string
  - var ps *person // pointer to custom type (person).
```

- We can use the pointer object with receiver function that except the pointer to actually update the inner struct field:

  ```go
  func (pointerP *person) updateName(n string) {
    (*pointerP).fName = n
  }

  // The long way of updating the name
  pointerGal := &gal
  pointerGal.updateName("bla")
  fmt.Println(gal)  ==> {"Gal", "bla"}
  ```
- Since creating the pointer var all the time is annoying and makes code harder to read, go offers us some syntactic sugar to call the receive function by using the variable.
  
  ```go
  // The Short Way
  gal.updateName("bla")
  fmt.Println(gal)  ==> {"Gal", "bla"}
  ```

- Since Slices are wrappers to arrays and the actual values in the slice are saved in the array it is pointing to we can update a slice we pass to a function:

  ```go
  func update(n []s) {
    s[0] = "1"
  }

  // The long way of updating the name
  t := []string{"2","2","3"}
  update(t)
  fmt.Println(t)  ==> ["1","2","3"]
  ```

** same goes for any reference type: slice, map, channels...

### Interfaces

- Interfaces in go are similar to any other language, they define an abstract type that contains no data but defines a contract for methods provided by a type.
- Interfaces are implicit in GO, meaning when we define an interface GO searches for a struct that has all the functions that are listed in the interface (has receiver functions) and if GO finds any, they automatically become a part of the interface.
- Defining an interface is very simple and similar to a struct that contains functions:

  ```go
  type animal interface {
    makeSound() string
  }
  ```

- We can Combine multiple interfaces:

  ```go
  type Reader interface {
      Read(p []byte) (n int, err error)
  }
  type Closer interface {
    Close() error
  }
  type ReadCloser interface {
    Reader
    Closer
    }
  ```

## Concurrency

### Go Routines

You can think of a go routine as a thread that runs your go program, when ever you lunch a go program a go routine is created. To enable concurrency we need to span new thread within our application meaning new go routines.
To create a go routine within our application we use the go keyword:

```go
go someFunctionThatTakeAlotOfTime()
```

Notice that concurrency is not parallelism meaning that when we have multiple go routines or threads running in our program they are all under the same process so they will all be executed on one CPU core, therefor we will not have two go routines running at the same time.

### Go Channel

A type in go which is used to share data between go routines.
It is a shard space where each route can place a value and it will be accessible to all the other routes that have the channel.
Here is how to use a channel:

```go
func someFunctionThatTakeAlotOfTime(c chan string) {
  // Do something
  c <- "done" // Send done to all the routines on the channel
}

c := make(chan string) // Create a channel that expects strings

go someFunctionThatTakeAlotOfTime(c) // Pass the channel to a new routine we create

// The naive approach
for {
v <- c  // wait fot a value on the chanel
  if v == "done" {
    os.Exit()
  }
}
// Using some syntactic sugar
for m := range c {
  if m == "done" {
    os.Exit()
  }
}
```