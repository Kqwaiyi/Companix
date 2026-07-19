extends Control

@onready var margin_container: MarginContainer = $MarginContainer
@onready var play_button: Button = $MarginContainer/HBoxContainer/LeftSection/PlayButton
@onready var credits_button: Button = $MarginContainer/HBoxContainer/LeftSection/CreditsButton
@onready var title: Label = $MarginContainer/HBoxContainer/LeftSection/Title
@onready var hover_audio: AudioStreamPlayer = $HoverAudio
@onready var click_audio: AudioStreamPlayer = $ClickAudio

@onready var background: ColorRect = $Background
@onready var plexus: Node2D = $PlexusBackground
@onready var credits_terminal: RichTextLabel = $MarginContainer/HBoxContainer/RightSection/CreditsTerminal

var _title_base_pos: Vector2

var _target_parallax: Vector2
var _current_parallax: Vector2
const PARALLAX_AMOUNT = 0.05
const PARALLAX_LERP_SPEED = 3.0

func _ready() -> void:
	MusicManager.play_music("main_menu", true)
	
	# Connect buttons
	play_button.mouse_entered.connect(_on_button_hover.bind(play_button))
	play_button.mouse_exited.connect(_on_button_exit.bind(play_button))
	play_button.pressed.connect(_on_play_pressed)
	
	credits_button.mouse_entered.connect(_on_button_hover.bind(credits_button))
	credits_button.mouse_exited.connect(_on_button_exit.bind(credits_button))
	credits_button.pressed.connect(_on_credits_pressed)
	
	# Start glitch loop
	call_deferred("_start_glitch_loop")

func _process(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var normalized_mouse = (mouse_pos / screen_size) * 2.0 - Vector2(1.0, 1.0)
	
	_target_parallax = normalized_mouse * PARALLAX_AMOUNT
	_current_parallax = _current_parallax.lerp(_target_parallax, delta * PARALLAX_LERP_SPEED)
	
	if background.material:
		background.material.set_shader_parameter("parallax_offset", _current_parallax)

func _start_glitch_loop() -> void:
	_title_base_pos = title.position
	while is_inside_tree():
		var delay = randf_range(2.0, 6.0)
		await get_tree().create_timer(delay).timeout
		if not is_inside_tree(): return
		
		# Perform a glitch
		var glitch_tween = create_tween()
		glitch_tween.tween_property(title, "position:x", _title_base_pos.x + randf_range(-5, 5), 0.05)
		glitch_tween.tween_property(title, "modulate:a", randf_range(0.4, 0.8), 0.05)
		glitch_tween.tween_property(title, "position:x", _title_base_pos.x, 0.05)
		glitch_tween.tween_property(title, "modulate:a", 1.0, 0.05)

func _on_button_hover(btn: Button) -> void:
	hover_audio.play()
	btn.pivot_offset = btn.size / 2.0
	
	# Add Glow Outline
	btn.add_theme_constant_override("outline_size", 8)
	btn.add_theme_color_override("font_outline_color", Color(0, 0.9, 1, 0.3))
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(btn, "theme_override_colors/font_color", Color(0, 0.9, 1, 1), 0.2)
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Global Dimming
	tween.tween_property(title, "modulate:a", 0.3, 0.2)
	tween.tween_property(background, "modulate:a", 0.3, 0.2)
	if plexus: tween.tween_property(plexus, "modulate:a", 0.3, 0.2)
	if btn != play_button: tween.tween_property(play_button, "modulate:a", 0.3, 0.2)
	if btn != credits_button: tween.tween_property(credits_button, "modulate:a", 0.3, 0.2)

func _on_button_exit(btn: Button) -> void:
	if btn.disabled: return
	btn.pivot_offset = btn.size / 2.0
	
	# Remove Glow Outline
	btn.remove_theme_constant_override("outline_size")
	btn.remove_theme_color_override("font_outline_color")
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(btn, "theme_override_colors/font_color", Color(1, 1, 1, 1), 0.2)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Restore World
	tween.tween_property(title, "modulate:a", 1.0, 0.2)
	tween.tween_property(background, "modulate:a", 1.0, 0.2)
	if plexus: tween.tween_property(plexus, "modulate:a", 1.0, 0.2)
	if btn != play_button: tween.tween_property(play_button, "modulate:a", 1.0, 0.2)
	if btn != credits_button: tween.tween_property(credits_button, "modulate:a", 1.0, 0.2)

func _on_play_pressed() -> void:
	click_audio.play()
	MusicManager.stop_music(false, 2.6)
	
	# Disable buttons
	play_button.disabled = true
	credits_button.disabled = true
	
	# Stop cyber button logic and lock in text
	play_button.set_process(false)
	play_button.text = "[ ACCESS GRANTED ]"
	play_button.add_theme_color_override("font_color", Color(0, 1, 1, 1))
	play_button.scale = Vector2(1.1, 1.1)
	
	# Fade other elements to low opacity
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(title, "modulate:a", 0.2, 0.5)
	fade_tween.tween_property(credits_button, "modulate:a", 0.2, 0.5)
	fade_tween.tween_property(background, "modulate:a", 0.2, 0.5)
	if plexus:
		fade_tween.tween_property(plexus, "modulate:a", 0.2, 0.5)
	
	# Wait for dramatic effect
	await get_tree().create_timer(1.0).timeout
	SceneManager.change_scene_to_file("res://scenes/core/exposition.tscn")

func _on_credits_pressed() -> void:
	click_audio.play()
	
	var credits_string = "SYSTEM IDENTIFICATION\nProject: COMPANIX\nStatus: Online\n\nCREDITS LOG\n> Lead Developer: Player 1\n> Visual Engineering: Artificial Intelligence\n> Audio Architecture: Synthesis Engine\n\n// End of file."
	
	if credits_terminal.has_method("type_text"):
		credits_terminal.type_text(credits_string, 0.02)
