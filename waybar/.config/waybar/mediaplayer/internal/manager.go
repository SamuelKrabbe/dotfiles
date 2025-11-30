package internal

import (
	"encoding/json"
	"fmt"
	"log"
	"sort"
	"strings"
	"time"

	"github.com/godbus/dbus/v5"
)

// WaybarOutput represents the JSON structure Waybar expects
type WaybarOutput struct {
	Text  string `json:"text"`
	Class string `json:"class"`
	Alt   string `json:"alt"`
}

type Manager struct {
	conn            *dbus.Conn
	players         map[string]*Player
	filterPlayer    string
	excludedPlayers map[string]bool
}

func NewManager(conn *dbus.Conn, filter string, excluded []string) *Manager {
	exMap := make(map[string]bool)
	for _, p := range excluded {
		if p != "" {
			exMap[strings.TrimSpace(p)] = true
		}
	}

	return &Manager{
		conn:            conn,
		players:         make(map[string]*Player),
		filterPlayer:    filter,
		excludedPlayers: exMap,
	}
}

// LoadExisting scans for currently running players at startup
func (m *Manager) LoadExisting() {
	var names []string
	err := m.conn.BusObject().Call("org.freedesktop.DBus.ListNames", 0).Store(&names)
	if err != nil {
		return
	}

	for _, name := range names {
		if strings.HasPrefix(name, "org.mpris.MediaPlayer2.") {
			m.addPlayer(name)
		}
	}
	m.RefreshOutput()
}

// Start listening to signals
func (m *Manager) Listen() {
	// We listen for new names (players opening) and property changes (pausing/skipping)
	rules := []string{
		"type='signal',member='NameOwnerChanged',path='/org/freedesktop/DBus',interface='org.freedesktop.DBus'",
		"type='signal',member='PropertiesChanged',path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties'",
	}

	for _, r := range rules {
		call := m.conn.BusObject().Call("org.freedesktop.DBus.AddMatch", 0, r)
		if call.Err != nil {
			log.Fatalf("Failed to add match: %v", call.Err)
		}
	}

	signals := make(chan *dbus.Signal, 10)
	m.conn.Signal(signals)

	for s := range signals {
		m.HandleSignal(s)
	}
}

// HandleSignal routes DBus signals to specific logic
func (m *Manager) HandleSignal(sig *dbus.Signal) {
	switch sig.Name {
	case "org.freedesktop.DBus.NameOwnerChanged":
		if len(sig.Body) != 3 {
			return
		}
		name := sig.Body[0].(string)
		newOwner := sig.Body[2].(string)

		if strings.HasPrefix(name, "org.mpris.MediaPlayer2.") {
			if newOwner != "" {
				m.addPlayer(name)
			} else {
				m.removePlayer(name)
			}
			m.RefreshOutput()
		}

	case "org.freedesktop.DBus.Properties.PropertiesChanged":
		if player, exists := m.players[sig.Sender]; exists {
			if len(sig.Body) < 2 {
				return
			}
			changes, ok := sig.Body[1].(map[string]dbus.Variant)
			if !ok {
				return
			}

			updated := false
			if val, ok := changes["PlaybackStatus"]; ok {
				player.PlaybackStatus = val.Value().(string)
				updated = true
			}
			if val, ok := changes["Metadata"]; ok {
				player.Metadata = val.Value().(map[string]dbus.Variant)
				updated = true
			}

			if updated {
				player.LastUpdated = time.Now()
				m.RefreshOutput()
			}
		}
	}
}

func (m *Manager) addPlayer(busName string) {
	playerName := strings.TrimPrefix(busName, "org.mpris.MediaPlayer2.")

	if m.excludedPlayers[playerName] {
		return
	}
	if m.filterPlayer != "" && m.filterPlayer != playerName {
		return
	}

	var unique string

	err := m.conn.BusObject().
		Call("org.freedesktop.DBus.GetNameOwner", 0, busName).
		Store(&unique)

	if err != nil {
		fmt.Println("Failed to get unique name for", busName, ":", err)
		return
	}

	obj := m.conn.Object(busName, "/org/mpris/MediaPlayer2")

	variant, err := obj.GetProperty("org.mpris.MediaPlayer2.Player.PlaybackStatus")
	if err != nil {
		return
	}
	status := variant.Value().(string)

	variant, err = obj.GetProperty("org.mpris.MediaPlayer2.Player.Metadata")
	metadata := make(map[string]dbus.Variant)
	if err == nil && variant.Value() != nil {
		metadata = variant.Value().(map[string]dbus.Variant)
	}

	m.players[unique] = NewPlayer(busName, status, metadata)
}

func (m *Manager) removePlayer(busName string) {
	delete(m.players, busName)
}

func (m *Manager) RefreshOutput() {
	active := m.pickMostImportantPlayer()

	if active == nil {
		fmt.Println("") // Clear waybar
		return
	}

	text := active.FormatMedia()

	class := "custom-" + active.Name
	if active.PlaybackStatus != "Playing" {
		class += " disabled"
	}

	output := WaybarOutput{
		Text:  text,
		Class: class,
		Alt:   active.Name,
	}

	jsonBytes, _ := json.Marshal(output)
	fmt.Println(string(jsonBytes))
}

func (m *Manager) pickMostImportantPlayer() *Player {
	if len(m.players) == 0 {
		return nil
	}

	var candidates []*Player
	for _, p := range m.players {
		candidates = append(candidates, p)
	}

	// Sort: Playing first, then by LastUpdated descending
	sort.Slice(candidates, func(i, j int) bool {
		if candidates[i].PlaybackStatus == "Playing" && candidates[j].PlaybackStatus != "Playing" {
			return true
		}
		if candidates[i].PlaybackStatus != "Playing" && candidates[j].PlaybackStatus == "Playing" {
			return false
		}
		return candidates[i].LastUpdated.After(candidates[j].LastUpdated)
	})

	return candidates[0]
}
