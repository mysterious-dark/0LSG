extends Control

var http: HTTPRequest
const REFRESH_TIME = 300
const GITHUB_PAGE_URL = "https://raw.githubusercontent.com/mysterious-dark/0LSG/refs/heads/main/content_Version2.json"
var refresh_timer: Timer

func _ready():
	setup_http_request()
	setup_timer()
	load_content()

func setup_http_request():
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)

func setup_timer():
	refresh_timer = Timer.new()
	add_child(refresh_timer)
	refresh_timer.wait_time = REFRESH_TIME
	refresh_timer.timeout.connect(load_content)
	refresh_timer.start()

func load_content():
	print("Loading content from: ", GITHUB_PAGE_URL)
	# Add error handling
	var headers = ["Accept: application/json"]
	var error = http.request(GITHUB_PAGE_URL, headers)
	if error != OK:
		print("An error occurred while requesting data")

# Fixed unused parameters by adding underscore prefix
func _on_request_completed(_result, _response_code, _headers, body):
	# Add debug print for response
	print("Received response, length: ", body.size())
	
	# Get string from response
	var json_string = body.get_string_from_utf8()
	print("Response string: ", json_string)
	
	# Try parsing JSON with error handling
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		print("Error Line: ", json.get_error_line())
		return
		
	var data = json.get_data()
	if data == null:
		print("Failed to get JSON data")
		return

	update_display(data)

func update_display(data):
	# Clear existing display elements
	for child in get_children():
		if not (child is HTTPRequest or child is Timer):
			child.queue_free()
	
	# Create scroll container with proper sizing
	var scroll = ScrollContainer.new()
	add_child(scroll)
	
	# Make scroll container fill the entire Control node
	scroll.anchor_right = 1
	scroll.anchor_bottom = 1
	scroll.offset_right = 0
	scroll.offset_bottom = 0
	
	# Add content container
	var content = VBoxContainer.new()
	scroll.add_child(content)
	
	# Make content container fill the scroll width
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Add items from the JSON data
	if data.has("items"):
		for item in data["items"]:
			add_item_to_display(content, item)
	else:
		# Add debug label if no items found
		var debug_label = Label.new()
		debug_label.text = "No items found in data: " + str(data)
		content.add_child(debug_label)

func add_item_to_display(container, item):
	# Create a panel that fills the width
	var panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(panel)
	
	# Add padding around content
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	
	# Container for text
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	vbox.add_theme_constant_override("separation", 10)
	
	# Title
	var title = Label.new()
	title.text = item.get("title", "No Title")
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Description
	var desc = Label.new()
	desc.text = item.get("description", "No Description")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 16)
	vbox.add_child(desc)
	
	# Add spacing between items
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	container.add_child(spacer)
