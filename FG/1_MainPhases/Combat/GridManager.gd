# GridManager class handles the creation, storage, and management of grid data
# It supports uneven grids where each row can have different number of tiles
# and tiles can have custom x positions
class_name GridManager
extends Node

# Static instance for global access to GridManager
# This allows other scripts to access the grid data through a single point
static var instance: GridManager

# Grid data storage using a Dictionary for flexible, uneven grid layouts
# Dictionary structure:
# - Key: z position (represents the row number, starting from 0)
# - Value: Array of GridData objects (represents tiles in that row)
# Using Dictionary instead of Array allows for sparse/uneven row layouts
var grid_data: Dictionary = {}

# Tracks the maximum width of the grid across all rows
# This is needed for:
# - Calculating grid boundaries
# - Centering the grid in the world
# - Determining valid x coordinates
var max_width: int = 0

# Initialize the GridManager
# Sets up the static instance for global access
func _init() -> void:
	instance = self

# Creates a new grid with specified dimensions
# Parameters:
# - width: The maximum number of tiles horizontally
# - height: The number of rows vertically
# This creates a default grid layout if no JSON data is provided
func initialize_grid(width: int, height: int) -> void:
	# Clear any existing grid data
	grid_data.clear()
	max_width = width
	
	# Create grid rows
	for z in range(height):
		var row: Array[GridData] = []
		for x in range(width):
			# Default grid setup:
			# - Middle row (z == 2) is walkable
			# - Walkable tiles have texture_id 1 and y_pos 1
			# - Non-walkable tiles have texture_id 2 and y_pos 2
			var walkable := z == 2
			var texture_id := 1 if walkable else 2
			var y_pos := 1 if walkable else 2
			row.append(GridData.new(walkable, texture_id, y_pos, x))
		grid_data[z] = row

# Retrieves tile data at specified coordinates
# Parameters:
# - x: The horizontal position in the grid
# - z: The vertical position (row number) in the grid
# Returns: GridData object if tile exists, null otherwise
func get_tile_data(x: int, z: int) -> GridData:
	# Check if the row exists
	if not grid_data.has(z):
		return null
	
	# Search for tile with matching x position in the row
	for tile in grid_data[z]:
		if tile.x_pos == x:
			return tile
	return null

# Converts the grid data to JSON format
# Used for:
# - Saving grid layouts
# - Debugging grid data
# - Transferring grid data
# Returns: JSON string representation of the grid
func to_json() -> String:
	var data := []
	# Iterate through each row
	for z in grid_data.keys():
		var row_data := []
		# Convert each tile in the row to a dictionary
		for tile in grid_data[z]:
			var tile_dict = {
				"walkable": tile.walkable,
				"texture_id": tile.texture_id,
				"y_pos": tile.y_pos
			}
			# Only include x_pos if it's explicitly set (>= 0)
			# This allows for automatic positioning when loading
			if tile.x_pos >= 0:
				tile_dict["x_pos"] = tile.x_pos
			row_data.append(tile_dict)
		data.append(row_data)
	return JSON.stringify(data)

# Loads grid data from JSON string
# Parameters:
# - json_str: JSON string containing grid layout data
# This allows for:
# - Loading custom grid layouts
# - Creating uneven grids
# - Specifying custom tile positions
func from_json(json_str: String) -> void:
	var data = JSON.parse_string(json_str)
	if data and data is Array:
		# Clear existing grid data
		grid_data.clear()
		max_width = 0
		
		# Process each row in the JSON data
		for z in range(data.size()):
			var row = data[z]
			var grid_row: Array[GridData] = []
			var next_x = 0  # Tracks next available x position for auto-positioning
			
			# Process each tile in the row
			for tile in row:
				# Get x_pos from JSON or use next available position
				# This allows for both explicit positioning and auto-positioning
				var x_pos = tile.get("x_pos", next_x)
				
				# Create new GridData object with tile properties
				var grid_tile = GridData.new(
					tile.walkable,
					tile.texture_id,
					tile.y_pos,
					x_pos
				)
				grid_row.append(grid_tile)
				
				# Update next available x position and maximum width
				next_x = x_pos + 1
				max_width = max(max_width, x_pos + 1)
			
			# Store the processed row in grid_data
			grid_data[z] = grid_row
