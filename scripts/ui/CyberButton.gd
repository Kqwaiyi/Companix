extends Button
class_name CyberButton

var original_text: String
var _is_hovered: bool = false
var _scramble_progress: float = 0.0
var _scramble_pool: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
var _tween: Tween

func _ready() -> void:
	# Save the initial text (strip leading/trailing whitespace if any)
	original_text = text
	
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)

func _process(_delta: float) -> void:
	if _is_hovered and _scramble_progress >= 1.0:
		# Blinking cursor effect (toggles every 0.3 seconds)
		var show_cursor = int(Time.get_ticks_msec() / 300.0) % 2 == 0
		var cursor = " _" if show_cursor else "  "
		text = "[ " + original_text + " ]" + cursor

func _on_hover_enter() -> void:
	_is_hovered = true
	if _tween and _tween.is_valid():
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_method(_update_scramble, 0.0, 1.0, 0.2)

func _on_hover_exit() -> void:
	if disabled: return
	
	_is_hovered = false
	if _tween and _tween.is_valid():
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_method(_update_scramble, _scramble_progress, 0.0, 0.1)

func _update_scramble(progress: float) -> void:
	_scramble_progress = progress
	
	if progress <= 0.01:
		text = original_text
		return
		
	if progress >= 1.0 and not _is_hovered:
		# Should not normally happen if exiting, but just in case
		text = original_text
		return

	# If fully scrambled and hovered, _process handles the blinking cursor
	if progress >= 1.0 and _is_hovered:
		return
		
	# Intermediate scramble state
	var result = ""
	for i in range(original_text.length()):
		# The further along the progress, the more characters settle to original
		# We use a threshold based on position so it descrambles left-to-right
		var char_threshold = float(i) / float(original_text.length())
		if progress > char_threshold + 0.2:
			result += original_text[i]
		else:
			var rand_idx = randi() % _scramble_pool.length()
			result += _scramble_pool[rand_idx]
			
	# Add glitchy brackets during scramble
	var brackets = ["{", "}", "<", ">", "[", "]", "/", "\\"]
	var left = brackets[randi() % brackets.size()]
	var right = brackets[randi() % brackets.size()]
	
	text = left + " " + result + " " + right
