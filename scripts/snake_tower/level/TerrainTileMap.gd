extends TileMapLayer

func _ready():
	for cell in get_used_cells():
		LevelManager.register_cell(cell, LevelManager.CellType.TERRAIN)
