extends Node

enum Level
{
	lv1 = 1,
	lv2,
	lv3
}

enum Tracks {KICK, SNARE, CYMB, SAMPLE, BASS, LEAD, ARP, CHORD}

var MidiTrackNameMap = {
	Tracks.KICK: "kick",
	Tracks.SNARE: "snare",
	Tracks.CYMB: "cymb",
	Tracks.SAMPLE: "sample",
	Tracks.BASS: "bass",
	Tracks.LEAD: "lead",
	Tracks.ARP: "arp",
	Tracks.CHORD: "chord"
}
