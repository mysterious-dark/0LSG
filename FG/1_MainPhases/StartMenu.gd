extends Control


# JSON URL
@export var NEWS_URL = "https://mysterious-dark.github.io/0LSG/updates/content_Version2.json"
@export var GACHA_URL = "https://mysterious-dark.github.io/0LSG/updates/gacha.json"
@onready var news_feed = $MainContainer/HBoxContainer/LeftSide/NewsScreen
@onready var news_feed2 = $MainContainer/HBoxContainer/LeftSide/NewsScreen2
@onready var gacha_feed = $MainContainer/HBoxContainer/RightContainer/TopSection/NewsScreen

func _ready():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# Assign URLS
	news_feed.feed_url = NEWS_URL
	news_feed2.feed_url = NEWS_URL
	gacha_feed.feed_url = GACHA_URL
	
	news_feed.fetch_news()
	news_feed2.fetch_news()
	gacha_feed.fetch_news()
	
	# Connect to window size changes
	get_tree().root.size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()

func _on_window_size_changed():
	var window_size = DisplayServer.window_get_size()
	var is_portrait = window_size.y > window_size.x
