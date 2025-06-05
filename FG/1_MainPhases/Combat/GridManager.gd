class_name GridManager
extends Node

# Static instance for global access
static var instance: GridManager

# Grid data storage
var grid_data: Array[Array] = []

func _init() -> void:
	instance = self

func initialize_grid(width: int, height: int) -> void:
	grid_data.clear()
	
	for z in range(height):
		var row: Array[GridData] = []
		for x in range(width):
			# Default configuration
			var walkable := z == height/2  # Middle row is walkable
			var texture_id := 1 if walkable else 2
			var y_pos := 1 if walkable else 2
			row.append(GridData.new(walkable, texture_id, y_pos))
		grid_data.append(row)

func get_tile_data(x: int, y: int) -> GridData:
	if x >= 0 and x < grid_data[0].size() and y >= 0 and y < grid_data.size():
		return grid_data[y][x]
	return null

func set_tile_data(x: int, y: int, data: GridData) -> void:
	if x >= 0 and x < grid_data[0].size() and y >= 0 and y < grid_data.size():
		grid_data[y][x] = data

# Add to GridManager.gd
func to_json() -> String:
	var data := []
	for row in grid_data:
		var row_data := []
		for tile in row:
			row_data.append({
				"walkable": tile.walkable,
				"texture_id": tile.texture_id,
				"y_pos": tile.y_pos
			})
		data.append(row_data)
	return JSON.stringify(data)

func from_json(json_str: String) -> void:
	var data = JSON.parse_string(json_str)
	if data and data is Array:
		grid_data.clear()
		for row in data:
			var grid_row: Array[GridData] = []
			for tile in row:
				grid_row.append(GridData.new(
					tile.walkable,
					tile.texture_id,
					tile.y_pos
				))
			grid_data.append(grid_row)
