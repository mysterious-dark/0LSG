extends Control


# JSON URL
@export var NEWS_URL = "https://mysterious-dark.github.io/0LSG/updates/content_Version2.json"
@export var GACHA_URL = "https://mysterious-dark.github.io/0LSG/updates/gacha.json"
@onready var news_feed = $MainContainer/HBoxContainer/LeftSide/NewsScreen
@onready var news_feed2 = $MainContainer/HBoxContainer/LeftSide/NewsScreen2
@onready var gacha_feed = $MainContainer/HBoxContainer/RightContainer/TopSection/NewsScreen

@onready var startButton = $MainContainer/HBoxContainer/RightContainer/BottomSection/ButtonControl/StartButton

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
	# Connect the start button
	startButton.gui_input.connect(_on_start_button_input)

func _on_start_button_input(event):
	# Handle touch screen input
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_start_button_pressed()
			
func _on_start_button_pressed():
	# Change to the hub scene
	#get_tree().change_scene_to_file("res://1_MainPhases/Hub/hub.tscn")
		# Optional: Add a fade transition
	var transition = ColorRect.new()
	transition.color = Color.BLACK
	transition.modulate = Color(0, 0, 0, 0)  # Start fully transparent
	transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(transition)
	
	# Create a tween for the fade effect
	var tween = create_tween()
	tween.tween_property(transition, "modulate", Color(0, 0, 0, 1), 0.5)  # Fade to black
	await tween.finished
	
	# Change scene
	get_tree().change_scene_to_file("res://1_MainPhases/Hub/hub.tscn")
	
func _on_window_size_changed():
	var window_size = DisplayServer.window_get_size()
	var is_portrait = window_size.y > window_size.x
