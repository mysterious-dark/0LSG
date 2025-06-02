extends Node

func _ready() -> void:
	
	# making directory in user folder when we actually deploy the game
	var dir = DirAccess.open("user://")
	dir.make_dir("db")  
	
	if(globalVariables.db==null):
		print("db not existed, creating new db")

		var db_exists := FileAccess.file_exists(globalVariables.db_path)
		if db_exists:
			print("Database file already exists, will try to open it")

		globalVariables.db = SQLite.new()
		globalVariables.db.path = globalVariables.db_path
		globalVariables.db.open_db()  # a1: always do this

		if not db_exists:
			globalFunctions.initialize_database()  # b1: only if file didn't exist
	else:
		print("Bug #000-25")
	
	call_deferred("_change_scene")

func _change_scene() -> void:
	get_tree().change_scene_to_file("res://1_MainPhases/StartMenu.tscn")
