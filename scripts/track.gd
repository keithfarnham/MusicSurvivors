extends Node

class_name SongTrack

var TrackType : TrackData.Tracks
var CurrentLevel : TrackData.Level
var AudioPathForLevel = {TrackData.Level.lv1: "", TrackData.Level.lv2: "", TrackData.Level.lv3: ""}

var MidiForLevel = {TrackData.Level.lv1: [], TrackData.Level.lv2: [],TrackData.Level.lv3: []} #might want to make this dynamically sized - for now this works

func _init(song : SongData.Songs, track_type : TrackData.Tracks, starting_level : TrackData.Level = TrackData.Level.lv1):
	TrackType = track_type
	CurrentLevel = starting_level
	
	
func _ready():
	_load_midi_for_track(SongData.currentSong.song, TrackType)

func _load_midi_for_track(song : SongData.Songs, track_type : TrackData.Tracks):
	var midi_parser = null
	assert(SongData != null, "ERROR - SongData is null")
	var songInfo = SongData.currentSong as Song#SongData.song_data.get(song) as Song
	for level in TrackData.Level:
		var midi_path = "res://songs/" + songInfo.songTitle + "/midi/" + songInfo.songTitle + "_lv" + str(level) + ".mid"
		var f = FileAccess.open(midi_path, FileAccess.READ)
		if f:
			f.close()
			midi_parser = MidiFileParser.load_file(midi_path)
			for midi_tr_index in range(midi_parser.tracks.size()):
				var midi_tr = midi_parser.tracks[midi_tr_index]
				for ev in midi_tr.events:
					if ev.event_type == MidiFileParser.Event.EventType.META and ev.type == MidiFileParser.Meta.Type.TRACK_NAME:
						var tr_name = ""
						if ev.bytes:
							tr_name = ev.bytes.get_string_from_ascii()
						tr_name = tr_name.to_lower()
						if tr_name.find("kick") >= 0:
							MidiForLevel.set(track_type, midi_tr)
		else:
			print("MIDI not found: " + midi_path)
