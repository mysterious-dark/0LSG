class_name GridManager
extends Node

static var instance: GridManager

# Changed to Dictionary to support uneven rows with custom x positions
# Key: z position (row), Value: Array of GridData
var grid_data: Dictionary = {}
var max_width: int = 0  # Track the maximum width for grid boundaries

func _init() -> void:
	instance = self

func initialize_grid(width: int, height: int) -> void:
	grid_data.clear()
	max_width = width
	
	for z in range(height):
		var row: Array[GridData] = []
		for x in range(width):
			var walkable := z == 2
			var texture_id := 1 if walkable else 2
			var y_pos := 1 if walkable else 2
			row.append(GridData.new(walkable, texture_id, y_pos, x))
		grid_data[z] = row

func get_tile_data(x: int, z: int) -> GridData:
	if not grid_data.has(z):
		return null
	
	for tile in grid_data[z]:
		if tile.x_pos == x:
			return tile
	return null

func to_json() -> String:
	var data := []
	for z in grid_data.keys():
		var row_data := []
		for tile in grid_data[z]:
			var tile_dict = {
				"walkable": tile.walkable,
				"texture_id": tile.texture_id,
				"y_pos": tile.y_pos
			}
			if tile.x_pos >= 0:
				tile_dict["x_pos"] = tile.x_pos
			row_data.append(tile_dict)
		data.append(row_data)
	return JSON.stringify(data)

func from_json(json_str: String) -> void:
	var data = JSON.parse_string(json_str)
	if data and data is Array:
		grid_data.clear()
		max_width = 0
		
		for z in range(data.size()):
			var row = data[z]
			var grid_row: Array[GridData] = []
			var next_x = 0  # Track the next available x position
			
			for tile in row:
				var x_pos = tile.get("x_pos", next_x)
				var grid_tile = GridData.new(
					tile.walkable,
					tile.texture_id,
					tile.y_pos,
					x_pos
				)
				grid_row.append(grid_tile)
				next_x = x_pos + 1
				max_width = max(max_width, x_pos + 1)
			
			grid_data[z] = grid_row
