class_name globalFunctions
extends Node
# Global functions for the game

static func initialize_database():
	# Create table if it doesn't exist
	var query = """
	CREATE TABLE IF NOT EXISTS news_cache (
		json_data TEXT NOT NULL,
		etag TEXT DEFAULT '',
		content_hash TEXT DEFAULT '',
		timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
	)
	"""
	
	globalVariables.db.query(query)

static func check_for_character() -> bool:
	# TODO: Implement your character check logic here
	# This could involve checking a save file, database, or other storage
	
	return true
	# # Example implementation:
	# var save_file = FileAccess.open("user://player_data.save", FileAccess.READ)
	# if save_file == null:
	# 	return false
		
	# # Read and parse your save data here
	# # For example:
	# # var data = JSON.parse_string(save_file.get_as_text())
	# # return data != null and data.has("character_created") and data.character_created
	
	# # Temporary return false to force character creation
	# return false
