extends Node2D

func _ready() -> void:
	MusicManager.play_music("scifi_home")
	
	var laptop := get_node_or_null("LaptopUI")
	if laptop:
		laptop.closed.connect(func(): MusicManager.play_music("scifi_home"))
