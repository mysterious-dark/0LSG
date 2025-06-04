extends Control

const GRID_SIZE = Vector2(10, 5) # 10 columns x 5 rows
const TILE_SIZE = Vector2(80, 80) # Size of each tile

func _ready():
	generate_grid()

func generate_grid():
	var grid = $GridContainer
	
	# Set up grid properties
	grid.columns = int(GRID_SIZE.x)
	
	# Generate tiles
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var panel = Panel.new()
			panel.custom_minimum_size = TILE_SIZE
			
			# Make middle row (y == 2) walkable
			#if y == 2:
				#panel.add_theme_stylebox_override("panel", preload("res://StyleBoxFlat_walk"))
			#else:
				#panel.add_theme_stylebox_override("panel", preload("res://StyleBoxFlat_unwlk"))
			
			grid.add_child(panel)
