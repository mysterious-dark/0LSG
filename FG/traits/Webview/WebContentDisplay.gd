extends Control

# HTTPRequest node for fetching web content
var http: HTTPRequest

# How often to refresh content in seconds (5 minutes)
const REFRESH_TIME = 300

# Your GitHub Pages URL - CHANGE THIS TO YOUR URL
const GITHUB_PAGE_URL = "https://raw.githubusercontent.com/mysterious-dark/0LSG/refs/heads/main/content_Version2.json"

# Reference to refresh timer
var refresh_timer: Timer

# Called when the node enters the scene tree
func _ready():
	# Create and set up the HTTPRequest node
	setup_http_request()
	
	# Create and set up the refresh timer
	setup_timer()
	
	# Do initial content load
	load_content()

# Sets up the HTTPRequest node
func setup_http_request():
	http = HTTPRequest.new()
	add_child(http)  # Add it to the scene
	http.request_completed.connect(_on_request_completed)  # Connect the completion signal

# Sets up the timer for periodic updates
func setup_timer():
	refresh_timer = Timer.new()
	add_child(refresh_timer)  # Add it to the scene
	refresh_timer.wait_time = REFRESH_TIME
	refresh_timer.timeout.connect(load_content)  # Connect timeout to load_content
	refresh_timer.start()

# Loads content from GitHub Pages
func load_content():
	# Print debug info
	print("Loading content from: ", GITHUB_PAGE_URL)
	
	# Make the HTTP request
	var error = http.request(GITHUB_PAGE_URL)
	if error != OK:
		print("An error occurred while requesting data")

# Called when the HTTP request is completed
func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Failed to get data, error code: ", result)
		return

	# Convert the response body to string and parse JSON
	var json_string = body.get_string_from_utf8()
	var json = JSON.parse_string(json_string)
	
	if json == null:
		print("Failed to parse JSON")
		print(json_string)
		return

	# Update the display with the new content
	update_display(json)

# Updates the GUI with the new content
func update_display(data):
	# Clear existing children of this Control node
	for child in get_children():
		if not (child is HTTPRequest or child is Timer):  # Don't remove our HTTP or Timer nodes
			child.queue_free()
	
	# Create a scroll container for the content
	var scroll = ScrollContainer.new()
	var content = VBoxContainer.new()
	scroll.add_child(content)
	add_child(scroll)
	
	# Make scroll container fill the entire Control node
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Add items from the JSON data
	if data.has("items"):
		for item in data["items"]:
			add_item_to_display(content, item)

func update_display_string(data):
	# Clear existing children of this Control node
	for child in get_children():
		if not (child is HTTPRequest or child is Timer):  # Don't remove our HTTP or Timer nodes
			child.queue_free()
	
	# Create a scroll container for the content
	var scroll = ScrollContainer.new()
	var content = VBoxContainer.new()
	scroll.add_child(content)
	add_child(scroll)
	
	# Make scroll container fill the entire Control node
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Add items from the JSON data

	add_item_to_display(content, data)

# Adds a single item to the display
func add_item_to_display(container, item):
	# Create a panel for the item
	var panel = Panel.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Add some padding
	vbox.add_theme_constant_override("separation", 10)
	
	# Create and add title label
	var title = Label.new()
	title.text = item.get("title", "No Title")
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	# Create and add description label
	var desc = Label.new()
	desc.text = item.get("description", "No Description")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	# Add the panel to the container
	container.add_child(panel)
	
	# Add some spacing between items
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	container.add_child(spacer)
