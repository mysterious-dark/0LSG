extends Node3D

# Add at the top with your existing constants
var Operator = preload("res://1_MainPhases/Combat/Operator.tscn")  # Make sure to save Operator as a scene
var current_operator = null  # Reference to the currently selected operator
var placement_mode = false
var valid_placement_color = Color(0.2, 0.8, 0.2, 0.5)  # Green for valid
var invalid_placement_color = Color(0.8, 0.2, 0.2, 0.5)  # Red for invalid

# Grid configuration
const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 5
const TILE_SIZE: float = 2.0

# Add at the top with other signals
signal tile_selected(tile_node: Node3D, grid_pos: Vector2i)

# Add to your existing signals
signal operator_placed(grid_pos: Vector2i)

# Add path to grid JSON file
const GRID_JSON_PATH := "res://tutorial_grid.json"

# Touch control variables
var touch_start_position: Vector2
var camera_start_position: Vector3
var is_dragging: bool = false
var drag_sensitivity: float = 0.01

# For pinch to zoom
var touch_points: Dictionary = {}
var initial_distance: float = 0.0
var initial_camera_z: float = 0.0
var zoom_speed: float = 0.5

# Add these as class variables at the top of your script
var selected_grid_pos: Vector2i = Vector2i(-1, -1)  # Store last selected grid position

@onready var camera: Camera3D = $Camera3D
@onready var grid_container: Node3D = $GridContainer
@onready var touch_control: Control = $TouchControls/CameraControl
@onready var text_label3: Label = $HBoxContainer/Label3
@onready var text_label2: Label = $HBoxContainer/Label2

# Add after @onready variables
var grid_manager: GridManager

func _ready() -> void:
	grid_manager = GridManager.new()
	# grid_manager.initialize_grid(GRID_WIDTH, GRID_HEIGHT)
	load_grid_from_json()
	create_grid()
	# Connect touch control signals
	touch_control.gui_input.connect(_on_touch_control_input)

	# Connect our own tile_selected signal to the handler
	self.tile_selected.connect(_on_tile_selected)  # Add this line

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
			
func _on_touch_control_input(event: InputEvent) -> void:
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
			query.collision_mask = 1
			var result := get_world_3d().direct_space_state.intersect_ray(query)
			
			if not result.is_empty():
				var hit_pos: Vector3 = result.position
				print("Touched position: ", hit_pos)
				selected_grid_pos = world_to_grid(hit_pos)
				print("Grid coordinates: ", selected_grid_pos, " World position: ", hit_pos)
				# Highlight the selected tile or perform actions here
				# Get the tile node that was hit
				var tile_node = result.collider.get_parent()  # Since the StaticBody3D is child of the tile container
				
				# Emit the signal with the tile node and grid position
				emit_signal("tile_selected", tile_node, selected_grid_pos)
		
		# If this is the second touch point
		elif touch_points.size() == 2:
			print("vcl 2")
			text_label3.text = str(camera.position.z)
			var points := touch_points.values()
			initial_distance = points[0].distance_to(points[1])
			initial_camera_z = camera.position.z
			is_dragging = false
		else:
			text_label2.text = "Dragging"
			print("dcm")
	else:
		# Remove touch point
		touch_points.erase(event.index)
		if touch_points.size() < 2:
			initial_distance = 0.0
		if touch_points.is_empty():
			is_dragging = false

func handle_drag(event: InputEventScreenDrag) -> void:
	# Update stored touch position
	touch_points[event.index] = event.position
	
	if touch_points.size() == 2:
		# Handle pinch zoom
		var points := touch_points.values()
		var current_distance: float = points[0].distance_to(points[1])
		
		if initial_distance > 0:
			var zoom_factor = (initial_distance - current_distance) * zoom_speed
			var new_z = camera.position.z + zoom_factor
			camera.position.z = clamp(new_z, 3.0, 10.0)
			initial_distance = current_distance
			
			# Add zoom logic here
			current_distance = points[0].distance_to(points[1])
			if initial_distance != 0:  # Prevent division by zero
				var zoom_delta = (current_distance - initial_distance) * 0.01  # Adjust sensitivity as needed
				camera.position.z = clamp(camera.position.z - zoom_delta, 3.0, 10.0)
	
	elif touch_points.size() == 1 and is_dragging:
		# Handle camera movement
		var drag_delta := event.position - touch_start_position
		camera.position.x = camera_start_position.x - drag_delta.x * drag_sensitivity
		camera.position.z = camera_start_position.z - drag_delta.y * drag_sensitivity
		
		# Update constraints for single finger drag
		camera.position.x = clamp(camera.position.x, -2.0, 2.0)
		camera.position.z = clamp(camera.position.z, 0.0, 4.0)

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

# arknight logic
# Add this function to create an operator
func spawn_operator() -> void:
	if current_operator != null:
		return  # Don't spawn if we already have one being placed
		
	current_operator = Operator.instantiate()
	add_child(current_operator)
	current_operator.visible = false  # Hide until we start placement

# Modify your existing tile_selected signal handling
func _on_tile_selected(tile_node: Node3D, grid_pos: Vector2i) -> void:
	if placement_mode:
		var tile_data = grid_manager.get_tile_data(grid_pos.x, grid_pos.y)
		if tile_data and tile_data.walkable:
			# Calculate world position
			var world_pos = Vector3(
				grid_pos.x * TILE_SIZE,
				0,
				grid_pos.y * TILE_SIZE
			) + grid_container.position
			
			# Place the operator
			if current_operator == null:
				current_operator = Operator.instantiate()
				add_child(current_operator)
			
			current_operator.deploy(grid_pos, world_pos)
			emit_signal("operator_placed", grid_pos)
			
			# Exit placement mode
			placement_mode = false
			clear_tile_highlights()
		else:
			# Optionally provide feedback that this tile is invalid
			#DisplayServer.vibrate_handheld(20)  # Short vibration on invalid placement
			print("fuck you")

# Add function to highlight valid placement tiles
func show_valid_placement_tiles() -> void:
	for child in grid_container.get_children():
		var grid_pos = world_to_grid(child.position)
		var tile_data = grid_manager.get_tile_data(grid_pos.x, grid_pos.y)
		if tile_data and tile_data.walkable:
			var tile_mesh = child.get_node("MeshInstance3D")
			if tile_mesh:
				var material = tile_mesh.material_override.duplicate()
				material.albedo_color = Color(0.2, 0.8, 0.2, 0.5)  # Green for valid placement
				tile_mesh.material_override = material

# Add function to clear highlights
func clear_tile_highlights() -> void:
	for child in grid_container.get_children():
		var grid_pos = world_to_grid(child.position)
		var tile_data = grid_manager.get_tile_data(grid_pos.x, grid_pos.y)
		var tile_mesh = child.get_node("MeshInstance3D")
		if tile_mesh:
			var material = tile_mesh.material_override.duplicate()
			material.albedo_color = Color(0.6, 0.6, 0.6) if (tile_data and tile_data.walkable) else Color(0.2, 0.2, 0.2)
			tile_mesh.material_override = material

# Function to enter placement mode
func enter_placement_mode() -> void:
	placement_mode = true
	show_valid_placement_tiles()
