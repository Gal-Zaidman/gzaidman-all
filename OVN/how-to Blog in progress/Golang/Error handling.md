# Error handling

## Defer?
Defer statement is used to execute a function call just before the surrounding function where the defer statement is present returns.

So for example the following will print:
Start swap
Finished swap

a is b b is a

```go
func finished() {
    fmt.Println("Finished swap")
}

func swap(a *string, b *string) {  
    defer finished()
    fmt.Println("Start swap")
    *a, *b = *b, *a
}

func main() {
    a := "a"
    b := "b"
    swap(&a,&b)
    fmt.Println("a is " + a + " b is " + b)
}
```

When a function has multiple defer calls, they are pushed on to a stack and executed in Last In First Out (LIFO) order.
Defer is used in places where a function call should be executed irrespective of the code flow.

## Errors

Errors in Go are plain old values. Errors are represented using the built-in error type.