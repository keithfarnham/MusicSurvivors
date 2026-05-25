extends Node

class_name SongTrack #Track is taken by the midi parser, this is SongTrack now

var TrackType : TrackData.Tracks
var CurrentLevel : TrackData.Level
var AudioPathForLevel = {TrackData.Level.lv1: "", TrackData.Level.lv2: "", TrackData.Level.lv3: ""}

var MidiForLevel = {} #{TrackData.Level.lv1: MidiFileParser.Track, TrackData.Level.lv2: MidiFileParser.Track,TrackData.Level.lv3: MidiFileParser.Track} #might want to make this dynamically sized - for now this works
var MidiProcess = {}

func GetMidiForLevel(level : TrackData.Level) -> MidiFileParser.Track:
	var midi = MidiForLevel[TrackData.Level.keys()[level - 1]]
	assert(midi != null, "midi returned null for level ")
	return MidiForLevel.values()[level - 1]

func _init(song : SongData.Songs, track_type : TrackData.Tracks, starting_level : TrackData.Level = TrackData.Level.lv1):
	Log.print("[track] Initializing track " + str(TrackData.Tracks.keys()[track_type]))
	TrackType = track_type
	CurrentLevel = starting_level
	_load_midi_for_track(song, track_type)

func _load_midi_for_track(song : SongData.Songs, track_type : TrackData.Tracks):
	var midi_parser : MidiFileParser = null
	assert(SongData != null, "ERROR - SongData is null")
	for level in TrackData.Level:
		var midi_path = "res://songs/" + str(SongData.Songs.keys()[song]) + "/midi/" + str(SongData.Songs.keys()[song]) + "_" + str(level) + ".mid"
		var f = FileAccess.open(midi_path, FileAccess.READ)
		if f:
			f.close()
			midi_parser = MidiFileParser.load_file(midi_path) as MidiFileParser
			for midi_tr_index in range(midi_parser.tracks.size()):
				var midi_tr = midi_parser.tracks[midi_tr_index] as MidiFileParser.Track
				for ev in midi_tr.events:
					if ev.event_type == MidiFileParser.Event.EventType.META and ev.type == MidiFileParser.Meta.Type.TRACK_NAME:
						var tr_name = ""
						if ev.bytes:
							tr_name = ev.bytes.get_string_from_ascii()
						tr_name = tr_name.to_lower()
						if tr_name.find(str(TrackData.Tracks.keys()[track_type]).to_lower()) >= 0:
							Log.print("[track] Loaded midi for track %s at level %s" % [TrackData.Tracks.keys()[track_type], level])
							assert(midi_tr != null, "midi for track is null")
							MidiForLevel[level] = midi_tr
							break
		else:
			Log.print("[track] MIDI not found for track %s at path %s " % [TrackData.Tracks.keys()[track_type], midi_path])
