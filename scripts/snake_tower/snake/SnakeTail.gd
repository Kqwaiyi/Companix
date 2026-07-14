extends Node2D
class_name SnakeTail

var grid_position: Vector2i

func _ready():
	if not is_in_group("snake_tail"):
		add_to_group("snake_tail")
	
	# Initial position to grid
	grid_position = Vector2i((global_position / float(Globals.TILE_SIZE)).round())
	
	# Wait for LevelManager to be ready before registering
	call_deferred("_register")

func _register():
	LevelManager.register_cell(grid_position, LevelManager.CellType.SNAKE_BODY, self)
