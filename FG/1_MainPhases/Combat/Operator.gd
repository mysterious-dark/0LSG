extends Node3D

# Very basic stats - we'll expand these later
var is_deployed = false
var grid_position = Vector2i(-1, -1)  # Current position on grid

# Called when the node enters the scene tree
func _ready():
	# Create a simple visual representation for now
	var mesh = MeshInstance3D.new()
	var cube = BoxMesh.new()
	cube.size = Vector3(1.5, 2.0, 1.5)  # Make it slightly smaller than grid tile
	mesh.mesh = cube
	
	# Add a material to make it blue
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.4, 0.8)  # Blue color
	mesh.material_override = material
	
	add_child(mesh)
	# Raise the character slightly above the grid
	mesh.position.y = 1.0

func deploy(pos: Vector2i, world_pos: Vector3):
	grid_position = pos
	position = world_pos
	position.y = 1.0  # Keep it above the grid
	is_deployed = true
