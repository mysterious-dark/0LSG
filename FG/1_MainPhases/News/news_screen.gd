extends Control

# Node references
@onready var http_request = $HTTPRequest
@onready var scroll_container = $ScrollContainer
@onready var news_container = $ScrollContainer/VBoxContainer
@onready var timer = $Timer

# Properties to be set from outside
@export var feed_url: String = ""
@export var auto_refresh: bool = true
@export var refresh_interval: float = 10.0
@export var dancingScriptFontLocation: String = "res://2_themes/font/Dancing_Script/DancingScript-VariableFont_wght.ttf"

var dragging = false
var drag_start = Vector2()
var scroll_start = Vector2()
# Load the font
var dancingScriptFont = preload("res://2_themes/font/Dancing_Script/DancingScript-VariableFont_wght.ttf")

func _ready():
	# Configure ScrollContainer for touch scrolling
	scroll_container.scroll_horizontal = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.scroll_vertical = ScrollContainer.SCROLL_MODE_AUTO
	
	# Configure HTTPRequest
	http_request.connect("request_completed", _on_request_completed)
	
	# Start loading news
	fetch_news()
	
	if(!feed_url):
		print("Waiting for forced urls loading")
	# Optional: Set up auto-refresh timer
	timer.connect("timeout", fetch_news)
	timer.start(refresh_interval)  # Update every 10 seconds

# Handle touch input
func _input(event):
	if event is InputEventScreenTouch:
		var touch_pos = event.position
		# Check if touch is inside ScrollContainer
		var scroll_rect = scroll_container.get_global_rect()
		
		if scroll_rect.has_point(touch_pos):
			if event.pressed:
				# Touch began inside scroll area
				dragging = true
				drag_start = touch_pos
				scroll_start = Vector2(
					scroll_container.scroll_horizontal,
					scroll_container.scroll_vertical
				)
			else:
				# Touch ended
				dragging = false
		else:
			# Touch outside scroll area
			dragging = false
	
	elif event is InputEventScreenDrag and dragging:
		# Only process drag if we started dragging from inside the scroll area
		var delta = event.position - drag_start
		scroll_container.scroll_vertical = scroll_start.y - delta.y

func fetch_news():
	if http_request.is_processing() || http_request.is_processing_internal():
		# If a request is already in progress, skip this fetch
		# This prevents multiple requests from being sent simultaneously
		# and avoids potential issues with overlapping requests.
		# You can also choose to wait for the current request to complete
		# before sending a new one, depending on your application's needs.
		# For example, you could log a message or update the UI to indicate
		# that a request is already in progress.
	# Either wait or skip this request
		print("HTTPRequest is already processing, skipping this fetch.")
		return
	else:
		if(feed_url):
			http_request.request(feed_url)
		else:
			print("the fuck is happening?")


func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		print("Failed to parse JSON")
		return
		
	# Clear existing news items
	for child in news_container.get_children():
		child.queue_free()
	
	# Create news items
	if json.has("items"):
		for item in json["items"]:
			var news_item = create_news_item(item["title"], item["description"], 'item["image"], item["icon"], item["hue"]')
			news_container.add_child(news_item)

func create_news_item(title: String, description: String, _image: String="", _icon: String="", _hue: String="") -> PanelContainer:
	# Create a container for the news item
	var panel = PanelContainer.new()
	
	# Create margin container to handle internal padding
	var margin_container = MarginContainer.new()
	var vbox = VBoxContainer.new()
	
	# Configure the margin container (internal padding)
	margin_container.add_theme_constant_override("margin_left", 16)
	margin_container.add_theme_constant_override("margin_right", 16)
	margin_container.add_theme_constant_override("margin_top", 12)
	margin_container.add_theme_constant_override("margin_bottom", 12)
	
	# Create labels for title and description
	var title_label = Label.new()
	var desc_label = Label.new()
	
	# Configure the title label
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	title_label.add_theme_font_override("font", dancingScriptFont)
	
	# Configure the description label
	desc_label.text = description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color(1, 1, 1))
	
	# Add spacing between title and description
	vbox.add_theme_constant_override("separation", 8)
	
	# Set up the hierarchy with the new margin container
	panel.add_child(margin_container)
	margin_container.add_child(vbox)
	vbox.add_child(title_label)
	vbox.add_child(desc_label)
	
	# Add some styling to the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	
	# Add padding to the StyleBoxFlat as well
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	# Optional: Add rounded corners to the panel
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	panel.add_theme_stylebox_override("panel", style)
	
	return panel
