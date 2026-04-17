extends Node

#var kick_scene = preload("res://scenes/attacks/kick.tscn")
#var snare_scene = load()

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

var TrackWeaponSceneMap = {
	Tracks.KICK: load("res://scenes/attacks/kick.tscn")#kick_scene
}

func get_weapon_scene(track : Tracks) -> Resource:
	Log.print("[track_data] getting weapon scene for track %s" % str(Tracks.keys()[track]))
	return TrackWeaponSceneMap[track]
