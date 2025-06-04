extends Node3D

# Grid configuration
const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 5
const TILE_SIZE: float = 1.0

# Touch control variables
var touch_start_position: Vector2
var camera_start_position: Vector3
var is_dragging: bool = false
var drag_sensitivity: float = 0.01

# For pinch to zoom
var touch_points: Dictionary = {}
var initial_camera_z: float = 0.0

@onready var camera: Camera3D = $Camera3D
@onready var grid_container: Node3D = $GridContainer

func _ready() -> void:
	create_grid()

func create_grid() -> void:
	# Center the grid
	grid_container.position = Vector3(
		-(GRID_WIDTH * TILE_SIZE) / 2.0, 
		0, 
		-(GRID_HEIGHT * TILE_SIZE) / 2.0
	)
	
	# Create tile mesh
	var tile_mesh := PlaneMesh.new()
	tile_mesh.size = Vector2(TILE_SIZE * 0.9, TILE_SIZE * 0.9)
	
	# Create tiles
	for z in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile := MeshInstance3D.new()
			tile.mesh = tile_mesh
			tile.position = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			
			# Make middle row walkable (different color)
			var material := StandardMaterial3D.new()
			if z == GRID_HEIGHT / 2:
				material.albedo_color = Color(0.4, 0.4, 0.4)
			else:
				material.albedo_color = Color(0.2, 0.2, 0.2)
			
			tile.material_override = material
			grid_container.add_child(tile)

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
		# If this is the second touch point
		elif touch_points.size() == 2:
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
	
	# Handle different touch scenarios
	match touch_points.size():
		# Single finger drag - move camera
		1:
			if is_dragging:
				var drag_delta: Vector2 = event.position - touch_start_position
				
				camera.position.x = camera_start_position.x - drag_delta.x * drag_sensitivity
				camera.position.z = camera_start_position.z - drag_delta.y * drag_sensitivity
				
				# Optional: Add bounds to camera movement
				camera.position.x = clamp(camera.position.x, -5.0, 5.0)
				camera.position.z = clamp(camera.position.z, 0.0, 10.0)
		
		# Two finger drag - handle pinch to zoom
		2:
			var touch_points_array: Array = touch_points.values()
			var current_distance: float = touch_points_array[0].distance_to(touch_points_array[1])
			var initial_distance: float = touch_start_position.distance_to(touch_points_array[1])
			
			if initial_distance > 0:
				var zoom_factor: float = current_distance / initial_distance
				var target_z: float = initial_camera_z / zoom_factor
				
				# Clamp zoom level
				camera.position.z = clamp(target_z, 3.0, 10.0)

# Optional: Add raycast for tile selection
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var ray_length: float = 1000.0
		var from: Vector3 = camera.project_ray_origin(event.position)
		var to: Vector3 = from + camera.project_ray_normal(event.position) * ray_length
		
		var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
		var result: Dictionary = space.intersect_ray(query)
		
		if not result.is_empty():
			print("Touched position: ", result.position)
