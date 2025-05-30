extends Control

func _ready():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# Connect to window size changes
	get_tree().root.size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()

func _on_window_size_changed():
	var window_size = DisplayServer.window_get_size()
	var is_portrait = window_size.y > window_size.x
	
	# Get the HBoxContainer
	var hbox = $MainContainer/HBoxContainer
	# In hub.gd, add to _on_window_size_changed():
	var news_screen = $MainContainer/HBoxContainer/LeftSide/NewsScreen
	news_screen.custom_minimum_size = Vector2(
		DisplayServer.screen_get_size().x * 0.3,  # 30% of screen width
		DisplayServer.screen_get_size().y * 0.4   # 40% of screen height
	)
	# Adjust layout based on orientation
	#if is_portrait:
		#hbox.vertical = true  # Stack vertically on portrait mode
	#else:
		#hbox.vertical = false  # Side by side on landscape
