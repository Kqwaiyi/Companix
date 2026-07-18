extends Node

var total_score: int = 0

var tracked_scenes: Dictionary = {
	"res://scenes/cat_game/levels/tutorial00.tscn": true,
	"res://scenes/cat_game/levels/level_01.tscn": true,
	"res://scenes/cat_game/levels/level_02.tscn": true,
	"res://scenes/cat_game/levels/level_03.tscn": true,
	"res://scenes/cat_game/levels/level_04.tscn": true,
	"res://scenes/cat_game/ui/end_screen.tscn": true,
}

var current_minigame_level: String = "res://scenes/cat_game/levels/tutorial00.tscn"

func add_score(amount: int) -> void:
	total_score += amount

func save_progress(next_scene: String) -> void:
	update_minigame_level(next_scene)

func get_next_level(current_scene: String) -> String:
	var levels = tracked_scenes.keys()
	var idx = levels.find(current_scene)
	if idx != -1 and idx + 1 < levels.size():
		return levels[idx + 1]
	return current_scene

func update_minigame_level(new_level: String) -> void:
	var levels = tracked_scenes.keys()
	var current_idx = levels.find(current_minigame_level)
	var new_idx = levels.find(new_level)
	if new_idx > current_idx:
		current_minigame_level = new_level

func get_resume_level(requested_scene: String) -> String:
	if requested_scene == "":
		return current_minigame_level
		
	if tracked_scenes.has(requested_scene):
		var levels = tracked_scenes.keys()
		if levels.find(requested_scene) < levels.find(current_minigame_level):
			return current_minigame_level
			
	return requested_scene

func reset() -> void:
	total_score = 0
	current_minigame_level = "res://scenes/cat_game/levels/tutorial00.tscn"
