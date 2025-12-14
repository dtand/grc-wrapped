package models

type Email struct {
	ID        int    `db:"id" json:"id"`
	Title     string `db:"title" json:"title"`
	Body      string `db:"body" json:"body"`
	Date      string `db:"date" json:"date"`
	Sender    string `db:"sender" json:"sender"`
	Recipient string `db:"recipient" json:"recipient"`
}
