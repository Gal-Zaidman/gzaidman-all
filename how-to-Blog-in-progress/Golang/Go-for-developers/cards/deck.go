package main

import (
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"strings"
	"time"
)

type deck []string

func (d deck) print() {
	for _, card := range d {
		fmt.Println(card)
	}
}

func newDeck() deck {
	cards := deck{}
	cardsSymbels := []string{"Spades", "Diamond", "Clabs", "Hearts"}
	cardsNumbers := []string{"Ace", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
	for _, s := range cardsSymbels {
		for _, n := range cardsNumbers {
			cards = append(cards, n+" of "+s)
		}
	}
	return cards
}

func deal(d deck, n int) (deck, deck) {
	return d[:n], d[n:]
}

func (d deck) saveToFile(name string) error {
	return ioutil.WriteFile(name, []byte(d.toString()), 0666)
}

func (d deck) toString() string {
	return strings.Join(d, "\n")
}

func (d deck) newDeckFromFile(path string) deck {
	content, err := ioutil.ReadFile(path)
	if err != nil {
		fmt.Println("Error", err)
		os.Exit(1)
	}
	ss := strings.Split(string(content), "\n")
	return deck(ss)
}

func (d deck) shuffle() {
	source := rand.NewSource(time.Now().UnixNano())
	r := rand.New(source)
	for i := range d {
		p := r.Intn(len(d))
		d[p], d[i] = d[i], d[p]
	}
}
