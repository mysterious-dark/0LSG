class_name globalVariables 
extends Node
# Global variables for the game
static var NEWS_URL: String = "https://mysterious-dark.github.io/0LSG/updates/content_Version2.json"
static var GACHA_URL: String = "https://mysterious-dark.github.io/0LSG/updates/gacha.json"

# Database variables
static var db: SQLite 
static var db_initialized: bool = false
static var db_error: String = ""
static var db_path: String = "res://db/system.db"
# Database schema version
static var db_schema_version: int = 1
# Database table names
static var db_table_news: String = "news"
static var db_table_gacha: String = "gacha"
# Database table columns

	
