extends Node

func print(text : String):
	#wrapper for prints so that they won't be output in non-debug builds
	if OS.is_debug_build():
		print("[%d] %s" % [Time.get_ticks_msec(), text])

func debug_print_loaded_tracks():
	Log.print("\n=== Loaded Audio Tracks ===")
	for track in TrackData.Tracks.values():
		var track_name = TrackData.Tracks.keys()[track]
		Log.print("[audio] Track %s (%d):" % [track_name, track])
		for level in TrackData.Level.values():
			var path = SongData.currentSong.get_audio_path_for_level(track, level)
			if path and path != "":
				Log.print("  lv%d: %s" % [level, path])
			else:
				Log.print("  lv%d: [EMPTY]" % [level])
