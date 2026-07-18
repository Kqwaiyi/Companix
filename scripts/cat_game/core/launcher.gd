extends Node2D

func _ready() -> void:
	call_deferred("_swap_to_saved_level")

func _swap_to_saved_level() -> void:
	# Clear whatever placeholder level is in the main scene
	for child in get_children():
		child.queue_free()
		
	var target_scene = GameState.get_resume_level("")
	var packed: PackedScene = load(target_scene)
	if packed:
		add_child(packed.instantiate())
