extends Control

# Node references
@onready var http_request = $HTTPRequest
@onready var scroll_container = $ScrollContainer
@onready var news_container = $ScrollContainer/VBoxContainer
@onready var timer = $Timer

# JSON URL
const NEWS_URL = "https://mysterious-dark.github.io/0LSG/content_Version2.json"

func _ready():
	# Configure ScrollContainer for touch scrolling
	scroll_container.scroll_horizontal = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.scroll_vertical = ScrollContainer.SCROLL_MODE_AUTO
	
	# Configure HTTPRequest
	http_request.connect("request_completed", _on_request_completed)
	
	# Start loading news
	fetch_news()
	
	# Optional: Set up auto-refresh timer
	timer.connect("timeout", fetch_news)
	timer.start(10.0)  # Update every 10 seconds
	
func fetch_news():
	http_request.request(NEWS_URL)

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
			var news_item = create_news_item(item["title"], item["description"])
			news_container.add_child(news_item)

func create_news_item(title: String, description: String) -> PanelContainer:
	# Create a container for the news item
	var panel = PanelContainer.new()
	var margin = MarginContainer.new()
	var vbox = VBoxContainer.new()
	
	# Create labels for title and description
	var title_label = Label.new()
	var desc_label = Label.new()
	
	# Configure the title label
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	
	# Configure the description label
	desc_label.text = description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	
	# Set up the hierarchy
	panel.add_child(margin)
	margin.add_child(vbox)
	vbox.add_child(title_label)
	vbox.add_child(desc_label)
	
	# Add some styling
	#margin.add_theme_constant_override("margin_left", 32)
	#margin.add_theme_constant_override("margin_right", 32)
	#margin.add_theme_constant_override("margin_top", 12)
	#margin.add_theme_constant_override("margin_bottom", 12)
	
	vbox.add_theme_constant_override("separation", 8)
	
	# Add some styling to the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	#style.corner_radius_top_left = 8
	#style.corner_radius_top_right = 8
	#style.corner_radius_bottom_left = 8
	#style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	
	# Add margin between news items
	#margin.add_theme_constant_override("margin_bottom", 8)
	
	return panel
