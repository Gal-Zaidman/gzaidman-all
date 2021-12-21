package main

import (
	"fmt"
	"net/http"
	"os"
)

func makeHTTPRequest(url string, c chan string) {
	_, err := http.Get(url)
	if err != nil {
		fmt.Printf("Site %v is not responding\n", url)
		c <- "bad"
		return
	}
	fmt.Printf("Site %v is OK\n", url)
	c <- "good"
}

func main() {
	links := []string{
		"http://google.com",
		"http://facebook.com",
		"http://stackoverflow.com",
		"http://golang.org",
		"http://amazon.com",
	}
	c := make(chan string)
	for _, l := range links {
		go makeHTTPRequest(l, c)
	}
	for i := 0; i < len(links); i++ {
		v <- c // wait fot a value on the chanel
	}
	os.Exit()
}
