extends Node3D

# Grid configuration
const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 5
const TILE_SIZE: float = 2.0

# Touch control variables
var touch_start_position: Vector2
var camera_start_position: Vector3
var is_dragging: bool = false
var drag_sensitivity: float = 0.01

# For pinch to zoom
var touch_points: Dictionary = {}
var initial_distance: float = 0.0
var initial_camera_z: float = 0.0

# Add these as class variables at the top of your script
var selected_grid_pos: Vector2i = Vector2i(-1, -1)  # Store last selected grid position

# Add path to grid JSON file
const GRID_JSON_PATH := "res://tutorial_grid.json"

@onready var camera: Camera3D = $Camera3D
@onready var grid_container: Node3D = $GridContainer
# Add after @onready variables
var grid_manager: GridManager

func _ready() -> void:
	grid_manager = GridManager.new()
	# grid_manager.initialize_grid(GRID_WIDTH, GRID_HEIGHT)
	load_grid_from_json()
	create_grid()

func create_grid() -> void:
	# Calculate grid boundaries based on actual data
	var grid_width = grid_manager.max_width
	var grid_height = grid_manager.grid_data.size()
	
	grid_container.position = Vector3(
		-(grid_width * TILE_SIZE) / 2.0,
		0,
		-(grid_height * TILE_SIZE) / 2.0
	)
	
	# Create tile mesh
	var tile_mesh := PlaneMesh.new()
	tile_mesh.size = Vector2(TILE_SIZE * 0.9, TILE_SIZE * 0.9)
	
	# Create tiles based on grid data
	for z in grid_manager.grid_data.keys():
		for tile_data in grid_manager.grid_data[z]:
			# Create the tile container
			var tile_container := Node3D.new()
			var x_pos = tile_data.x_pos if tile_data.x_pos >= 0 else 0
			tile_container.position = Vector3(x_pos * TILE_SIZE, tile_data.y_pos, z * TILE_SIZE)
			
			# Create visual mesh
			var tile := MeshInstance3D.new()
			tile.mesh = tile_mesh
			
			# Create static body for collision
			var static_body := StaticBody3D.new()
			var collision_shape := CollisionShape3D.new()
			var box_shape := BoxShape3D.new()
			box_shape.size = Vector3(TILE_SIZE * 0.9, 0.1, TILE_SIZE * 0.9)
			collision_shape.shape = box_shape
			
			# Setup material
			var material := StandardMaterial3D.new()
			if tile_data.walkable:
				material.albedo_color = Color(0.6, 0.6, 0.6)
			else:
				material.albedo_color = Color(0.2, 0.2, 0.2)
			
			tile.material_override = material
			
			# Add everything to the container
			tile_container.add_child(tile)
			tile_container.add_child(static_body)
			static_body.add_child(collision_shape)
			
			grid_container.add_child(tile_container)
			
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Store touch point
		touch_points[event.index] = event.position
		
		# If this is the first touch point
		if touch_points.size() == 1:
			touch_start_position = event.position
			camera_start_position = camera.position
			is_dragging = true
			
			# Raycast for tile selection
			var from := camera.project_ray_origin(event.position)
			var to := from + camera.project_ray_normal(event.position) * 1000.0
			
			var query := PhysicsRayQueryParameters3D.create(from, to)
			query.collision_mask = 1  # Make sure this matches your collision layer
			var result := get_world_3d().direct_space_state.intersect_ray(query)
			
			if not result.is_empty():
				var hit_pos: Vector3 = result.position
				print("Touched position: ", hit_pos)
				selected_grid_pos = world_to_grid(hit_pos)
				print("Grid coordinates: ", selected_grid_pos, " World position: ", hit_pos)
				# Highlight the selected tile or perform actions here
		
		# If this is the second touch point
		elif touch_points.size() == 2:
			var points := touch_points.values()
			initial_distance = points[0].distance_to(points[1])
			initial_camera_z = camera.position.z
			is_dragging = false
	else:
		# Remove touch point
		touch_points.erase(event.index)
		if touch_points.is_empty():
			is_dragging = false

func handle_drag(event: InputEventScreenDrag) -> void:
	# Update stored touch position
	touch_points[event.index] = event.position
	
	match touch_points.size():
		# Single finger drag - move camera
		1:
			if is_dragging:
				var drag_delta := event.position - touch_start_position
				camera.position.x = camera_start_position.x - drag_delta.x * drag_sensitivity
				camera.position.z = camera_start_position.z - drag_delta.y * drag_sensitivity
				camera.position.x = clamp(camera.position.x, -2.0, 2.0)
				camera.position.z = clamp(camera.position.z, 0.0, 4.0)
		
		# Two finger drag - handle pinch to zoom
		2:
			if initial_distance > 0:
				var points := touch_points.values()
				var current_distance: float = points[0].distance_to(points[1])
				var zoom_factor: float = current_distance / initial_distance
				
				# Apply zoom
				var target_z: float = initial_camera_z / zoom_factor
				camera.position.z = clamp(target_z, 3.0, 10.0)

# Update the world_to_grid function to handle uneven grids
func world_to_grid(world_pos: Vector3) -> Vector2i:
# 	# Adjust position relative to grid container's position
	var local_pos: Vector3 = world_pos - grid_container.position
	
# 	# Convert to grid coordinates
	var grid_x: int = int(round(local_pos.x / TILE_SIZE))
	var grid_z: int = int(round(local_pos.z / TILE_SIZE))
	
	# Check if the position is valid in our uneven grid
	if grid_manager.get_tile_data(grid_x, grid_z) != null:
		return Vector2i(grid_x, grid_z)
	return Vector2i(-1, -1)  # Invalid position
	
func load_grid_from_json() -> void:
	# Load the JSON file
	if FileAccess.file_exists(GRID_JSON_PATH):
		var file = FileAccess.open(GRID_JSON_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		# Parse JSON and initialize grid
		var json_data = JSON.parse_string(json_string)
		if json_data and json_data.has("grid"):
			grid_manager.from_json(JSON.stringify(json_data.grid))
		else:
			# Fallback to default grid if JSON is invalid
			grid_manager.initialize_grid(GRID_WIDTH, GRID_HEIGHT)
	else:
		# Fallback to default grid if file doesn't exist
		grid_manager.initialize_grid(GRID_WIDTH, GRID_HEIGHT)
