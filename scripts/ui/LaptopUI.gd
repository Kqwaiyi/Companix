extends CanvasLayer

signal opened
signal closed

@onready var viewport = $CenterContainer/Panel/SubViewportContainer/SubViewport
@onready var close_button = $CenterContainer/Panel/CloseButton
@onready var transition_rect = $CenterContainer/Panel/TransitionRect

func _ready():
	# Ensure the UI can process even when the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect the close button
	close_button.pressed.connect(close_laptop)
	
	# Start hidden
	hide()

func open_laptop(minigame_scene_path: String = "", fade_duration: float = 0.5):
	show()
	# Pause the main game
	get_tree().paused = true
	
	# Load the minigame if a path is provided
	if minigame_scene_path != "":
		load_minigame(minigame_scene_path, fade_duration)
		
	opened.emit()

func close_laptop():
	hide()
	# Unpause the main game
	get_tree().paused = false
	
	# Optional: Clear the viewport when closed to free memory and reset state
	clear_minigame()
	
	# Notify all minigame time trackers to pause their timers when laptop closes
	get_tree().call_group("minigame_time_trackers", "pause_time")
	
	closed.emit()

func load_minigame(path: String, fade_duration: float = 0.5):
	# Use the global SceneManager to fade out the screen, load the new minigame into the viewport, and fade in
	SceneManager.change_scene_in_viewport(path, viewport, transition_rect, fade_duration)

func clear_minigame():
	for child in viewport.get_children():
		child.queue_free()
