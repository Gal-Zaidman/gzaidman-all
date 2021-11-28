package main

import (
	"os"
	"testing"
)

func TestNewDeck(t *testing.T) {
	cards := newDeck()
	if len(cards) != 4*10 {
		t.Errorf("Expected newDEck with len of 40 but got %v", len(cards))
	}
}

func TestSaveToFileAndNewDeckFromFile(t *testing.T) {
	deckFile := "_deck_file.txt"
	os.Remove(deckFile)
	// if the file don't exist we don't care
	cards := newDeck()
	err := cards.saveToFile(deckFile)
	if err != nil {
		t.Errorf("Failed to save deck to file, error is %v", err)
	}
	cardsNew := cards.newDeckFromFile(deckFile)
	if len(cardsNew) != len(cards) {
		t.Errorf("Loaded card deck loaded from %v to have the same len as the original deck, original decl len %v vs loaded deck len %v", deck_file, len(cards), len(cardsNew))
	}
	for i := range cardsNew {
		if cardsNew[i] != cards[i] {
			t.Errorf("card at index %v is different old: %v new %v", i, cards[i], cardsNew[i])
		}
	}
	os.Remove(deckFile)
}
