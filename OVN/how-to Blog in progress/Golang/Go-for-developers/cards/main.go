package main

import "fmt"

func main() {
	cards := newDeck()
	cards.print()
	fmt.Println("------------------------------------------------")
	cards.shuffle()
	cards.print()
}
