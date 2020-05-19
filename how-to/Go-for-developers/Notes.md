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
- We can create a function that are used only for specific types, those functions are called receiver functions
- Functions can return multiple values

```go
// regular function
func print () {
  fmt.Println("bla")
}

func message () (string, string) {
  return "bla", "blue"
}

// receiver function
func (m message) print () {
  fmt.Println(m)
}
```

### Slices and Arrays

- In Golang there are 2 data types for holding a list of variables:
  - Array - which is a fixed length list of variables.
  - Slice - An array that can grow or shrink.
  
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

  ```go
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