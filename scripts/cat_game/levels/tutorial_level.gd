extends "res://scripts/cat_game/levels/level_02.gd"

func _process(delta: float) -> void:
	if not _level_active:
		return
	# Time stays frozen at 00:00 in tutorial
	if _hud:
		_hud.update_score(_current_score)

func _on_player_caught() -> void:
	pass  # No penalty or HURT message in tutorial
