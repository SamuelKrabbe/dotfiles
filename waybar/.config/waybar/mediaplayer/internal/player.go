package internal

import (
	"fmt"
	"strings"
	"time"

	"github.com/godbus/dbus/v5"
)

type Player struct {
	Name           string
	BusName        string // e.g. org.mpris.MediaPlayer2.spotify
	PlaybackStatus string
	Metadata       map[string]dbus.Variant
	LastUpdated    time.Time
}

// NewPlayer creates a player struct from raw DBus data
func NewPlayer(busName string, status string, metadata map[string]dbus.Variant) *Player {
	return &Player{
		Name:           strings.TrimPrefix(busName, "org.mpris.MediaPlayer2."),
		BusName:        busName,
		PlaybackStatus: status,
		Metadata:       metadata,
		LastUpdated:    time.Now(),
	}
}

// FormatMedia returns the "Icon Artist - Title" string
func (p *Player) FormatMedia() string {
	artist := getStringFromMeta(p.Metadata, "xesam:artist")
	title := getStringFromMeta(p.Metadata, "xesam:title")

	// Spotify Ad detection
	trackId := getStringFromMeta(p.Metadata, "mpris:trackid")
	if strings.Contains(trackId, ":ad:") {
		return "Advertisement"
	}

	var label string
	if artist != "" && title != "" {
		label = fmt.Sprintf("%s - %s", artist, title)
	} else if title != "" {
		label = title
	} else {
		label = p.Name
	}

	// Add icons (Nerd Fonts)
	if p.PlaybackStatus == "Playing" {
		return "  " + label
	}
	return "  " + label
}

// Helper to safely extract strings from DBus variants
func getStringFromMeta(meta map[string]dbus.Variant, key string) string {
	val, ok := meta[key]
	if !ok {
		return ""
	}

	// Case 1: It's a simple string
	if s, ok := val.Value().(string); ok {
		return s
	}

	// Case 2: It's a slice of strings (common for artists)
	if s, ok := val.Value().([]string); ok {
		if len(s) > 0 {
			return s[0]
		}
	}

	// Case 3: It's a slice of interface{} (generic D-Bus array)
	if s, ok := val.Value().([]interface{}); ok {
		if len(s) > 0 {
			if str, ok := s[0].(string); ok {
				return str
			}
		}
	}

	return ""
}
