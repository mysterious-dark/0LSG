extends Node3D

# Grid configuration
const GRID_WIDTH = 12  # X axis
const GRID_HEIGHT = 5  # Z axis
const TILE_SIZE = 1.0

# Preload the mesh we'll reuse
var tile_mesh: PlaneMesh

func _ready():
	# Create the basic mesh that all tiles will use
	tile_mesh = PlaneMesh.new()
	tile_mesh.size = Vector2(TILE_SIZE * 0.92, TILE_SIZE * 0.92)  # Slightly smaller for visibility
	
	# Generate the grid
	create_grid()

func create_grid():
	var grid = $GridContainer
	
	# Center the grid
	grid.position = Vector3(
		-(GRID_WIDTH * TILE_SIZE) / 2, 
		0, 
		-(GRID_HEIGHT * TILE_SIZE) / 2
	)
	
	# Create tiles
	for z in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile = create_tile()
			tile.position = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			
			# Make middle row walkable (different color)
			#if z == GRID_HEIGHT / 2:
				#tile.get_surface_override_material(0) = $"../StandardMaterial3D_path"
			#else:
				#tile.get_surface_override_material(0) = $"../StandardMaterial3D_base"
				
			grid.add_child(tile)

func create_tile() -> MeshInstance3D:
	var tile = MeshInstance3D.new()
	tile.mesh = tile_mesh
	return tile

# Optional: Add basic mouse interaction
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var camera = $Camera3D
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000.0
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			print("Clicked at: ", result.position)
