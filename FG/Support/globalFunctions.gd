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
