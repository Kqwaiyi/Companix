extends CanvasLayer

@onready var _prompt_container: Control = $PromptRoot/PromptContainer
@onready var _prompt_label: Label = $PromptRoot/PromptContainer/HBox/PromptLabel
@onready var _glitch_overlay: ColorRect = $PromptRoot/PromptContainer/GlitchOverlay

var _is_interacting := false
var _base_prompt_y := 0.0
var _current_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_prompt_container.scale.y = 0.0
	# Defer to get correct position after layout
	call_deferred("_setup")

func _setup() -> void:
	_base_prompt_y = _prompt_container.position.y
	_show_prompt()

func _process(_delta: float) -> void:
	if not _is_interacting and _base_prompt_y != 0.0:
		_prompt_container.position.y = _base_prompt_y + sin(Time.get_ticks_msec() * 0.003) * 6.0
	
	if not _is_interacting and Input.is_action_just_pressed("interact"):
		_confirm_prompt()

func _show_prompt() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	_prompt_label.text = "  > PROCEED TO ENDING"
	_prompt_label.visible_ratio = 0.0
	_prompt_container.modulate = Color(1, 1, 1, 1)
	
	var mat = _glitch_overlay.material as ShaderMaterial
	
	_current_tween = create_tween().set_parallel(true)
	
	_prompt_container.scale.y = 0.0
	_current_tween.tween_property(_prompt_container, "scale:y", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if mat:
		mat.set_shader_parameter("intensity", 0.8)
		_current_tween.tween_method(func(v): mat.set_shader_parameter("intensity", v), 0.8, 0.05, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	_current_tween.tween_property(_prompt_label, "visible_ratio", 1.0, 0.25).set_delay(0.15)

func _confirm_prompt() -> void:
	_is_interacting = true
	
	var click_audio := AudioStreamPlayer.new()
	click_audio.stream = load("res://assets/sounds/futuristic_ui/Click.mp3")
	get_tree().root.add_child(click_audio)
	click_audio.play()
	click_audio.finished.connect(click_audio.queue_free)
	
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	_prompt_label.text = "  CONFIRMED..."
	_prompt_label.visible_ratio = 1.0
	
	var mat = _glitch_overlay.material as ShaderMaterial
	
	_current_tween = create_tween()
	
	# Flash effect
	_current_tween.tween_property(_prompt_container, "modulate", Color(0.2, 1.5, 2.0, 1.0), 0.05)
	if mat:
		_current_tween.parallel().tween_method(func(v): mat.set_shader_parameter("intensity", v), 0.05, 0.7, 0.05)
		
	# Hold briefly
	_current_tween.tween_interval(0.15)
	
	# Collapse
	_current_tween.tween_property(_prompt_container, "scale:y", 0.0, 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	# Change Scene
	_current_tween.tween_callback(func():
		# Try to use SceneManager if it exists, otherwise get_tree()
		var scene_mgr = get_node_or_null("/root/SceneManager")
		if scene_mgr:
			if scene_mgr.has_method("change_scene_with_fade"):
				scene_mgr.change_scene_with_fade("res://scenes/core/ending_sequence.tscn", 1.0)
			else:
				scene_mgr.change_scene_to_file("res://scenes/core/ending_sequence.tscn", 1.0)
		else:
			get_tree().change_scene_to_file("res://scenes/core/ending_sequence.tscn")
		queue_free()
	)
