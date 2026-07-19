extends SceneTree

func _init():
	var stream = AudioStreamMP3.new()
	var file = FileAccess.open("res://assets/music/snake tower/leaderboard.mp3", FileAccess.READ)
	if file:
		stream.data = file.get_buffer(file.get_length())
		print("DURATION: ", stream.get_length())
	else:
		print("FILE NOT FOUND")
	quit()
