class_name EndScreen
extends Control

const _SHUFFLE := "0123456789"
const _RED     := Color(0.90, 0.15, 0.10, 1)
const _ORANGE  := Color(1.00, 0.55, 0.10, 1)
const _YELLOW  := Color(0.95, 0.88, 0.15, 1)
const _GREEN   := Color(0.18, 0.88, 0.28, 1)
const _GOLD    := Color(0.96, 0.80, 0.25, 1)

var _total:        int          = 0
var _digit_vals:   Array[int]   = []
var _digit_labels: Array[Label] = []
var _rainbow_active := false
var _rainbow_hue    := 0.0

@onready var _score_row:      HBoxContainer = $Panel/VBox/ScoreCenter/ScoreRow
@onready var _bracket_label:  Label         = $Panel/VBox/BracketLabel
@onready var _play_again_btn: Button        = $Panel/VBox/PlayAgainButton

func _ready() -> void:
	_total = GameState.total_score
	var s := str(max(0, _total))
	for ch in s:
		_digit_vals.append(int(ch))
	_build_digits()
	_play_again_btn.pressed.connect(_on_play_again)
	_animate()

func _build_digits() -> void:
	for _i in _digit_vals.size():
		var lbl := Label.new()
		lbl.text = str(randi() % 10)
		lbl.add_theme_font_size_override("font_size", 68)
		lbl.add_theme_color_override("font_color", Color(0.40, 0.30, 0.20, 1))
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
		lbl.add_theme_constant_override("outline_size", 5)
		_score_row.add_child(lbl)
		_digit_labels.append(lbl)

func _animate() -> void:
	await get_tree().create_timer(0.7).timeout

	# All digits shuffle together
	for _i in 22:
		for lbl in _digit_labels:
			lbl.text = _SHUFFLE[randi() % 10]
		await get_tree().create_timer(0.055).timeout

	# Reveal one digit at a time left → right
	for i in _digit_vals.size():
		var spins := max(5, 13 - i * 3)
		for _s in spins:
			for j in range(i, _digit_labels.size()):
				_digit_labels[j].text = _SHUFFLE[randi() % 10]
			await get_tree().create_timer(0.055).timeout
		_digit_labels[i].text = str(_digit_vals[i])
		_digit_labels[i].add_theme_color_override("font_color", _GOLD)
		await get_tree().create_timer(0.30).timeout

	await get_tree().create_timer(0.55).timeout
	_apply_color()

func _apply_color() -> void:
	if _total >= 10000:
		_rainbow_active = true
		return
	var c: Color
	if   _total >= 7000: c = _GREEN
	elif _total >= 4000: c = _YELLOW
	elif _total >= 2000: c = _ORANGE
	else:                c = _RED
	for lbl in _digit_labels:
		lbl.add_theme_color_override("font_color", c)

func _process(delta: float) -> void:
	if not _rainbow_active:
		return
	_rainbow_hue = fmod(_rainbow_hue + delta * 2.0, 1.0)
	for i in _digit_labels.size():
		var h := fmod(_rainbow_hue + float(i) * 0.25 / float(max(1, _digit_labels.size())), 1.0)
		_digit_labels[i].add_theme_color_override("font_color", Color.from_hsv(h, 1.0, 1.0))

func _on_play_again() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/cat_game/levels/level_01.tscn")
