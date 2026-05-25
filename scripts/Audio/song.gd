extends Node

class_name Song

var bpm
var ms_per_beat
var beats_per_measure
var ms_per_measure
var ms_per_tick
var songTitle
var trackData = {}
var song : SongData.Songs
const ticks_per_beat := 960 # aka PPQN (pulse per quarter note), set in reaper midi export

func _init(newSong : SongData.Songs, songBpm = 110.0, beatsPerMeasure = 4):
	Log.print("[song] setting up song " + str(SongData.Songs.keys()[newSong]))
	songTitle = str(SongData.Songs.keys()[newSong])
	bpm = songBpm
	ms_per_beat = 60000.0 / bpm
	beats_per_measure = beatsPerMeasure
	ms_per_measure = ms_per_beat * beatsPerMeasure
	ms_per_tick = 60000 / (bpm * ticks_per_beat)
	song = newSong
	for track in TrackData.Tracks.values():
		trackData.set(track, SongTrack.new(newSong, track, TrackData.Level.lv1)) #lv 1 default

#func get_midi_from_track_for_level(track : TrackData.Tracks, level : TrackData.Level) -> Array:
	#return trackData[track].MidiForLevel[level]

func get_audio_path_for_level(track : TrackData.Tracks, level : TrackData.Level) -> String:
	return trackData[track].AudioPathForLevel[level]
	
func set_audio_path_for_level(track : TrackData.Tracks, level : TrackData.Level, path : String):
	trackData[track].AudioPathForLevel[level] = path
	
func set_level_for_track(track : TrackData.Tracks, new_level : TrackData.Level):
	Log.print("[song] set_level_for_track setting track %s to level %d" % [ str(TrackData.Tracks.keys()[track]), new_level ])
	trackData[track].CurrentLevel = new_level
	
func get_current_level_for_track(track : TrackData.Tracks) -> TrackData.Level:
	return trackData[track].CurrentLevel
