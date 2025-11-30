package main

import (
	"flag"
	"log"
	"strings"

	"mediaplayer/internal"

	"github.com/godbus/dbus/v5"
)

func main() {
	// Parse arguments
	playerArg := flag.String("player", "", "Filter for specific player")
	excludeArg := flag.String("exclude", "", "Comma-separated list of excluded players")
	flag.Parse()

	excluded := strings.Split(*excludeArg, ",")

	conn, err := dbus.ConnectSessionBus()
	if err != nil {
		log.Fatalf("Failed to connect to session bus: %v", err)
	}
	defer conn.Close()

	mgr := internal.NewManager(conn, *playerArg, excluded)
	mgr.LoadExisting()
	go mgr.Listen()

	select {}
}
