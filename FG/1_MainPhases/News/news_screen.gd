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
@export var dancingScriptFont = preload("res://2_themes/font/Dancing_Script/DancingScript-VariableFont_wght.ttf")

# Add these new variables at the top with other properties
var last_etag: String = ""
var last_modified: String = ""
var last_content_hash: String = ""

var dragging = false
var drag_start = Vector2()
var scroll_start = Vector2()
# Load the font

var db=globalVariables.db

var db_error = globalVariables.db_error
var json_string: String = ""

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
		# If a request is already in progress, skip this fetch
		# This prevents multiple requests from being sent simultaneously
		# and avoids potential issues with overlapping requests.
		# You can also choose to wait for the current request to complete
		# before sending a new one, depending on your application's needs.
		# For example, you could log a message or update the UI to indicate
		# that a request is already in progress.
	# Either wait or skip this request
	if http_request.is_processing() || http_request.is_processing_internal():
		#print("HTTPRequest is already processing, skipping this fetch.")
		return
	else:
		var err = globalVariables.globalHttpClient.connect_to_host("8.8.8.8", 53) # DNS check
	
		#if false:
		if err != OK:
			print("No internet connection, using cached data")
			load_cached_news()
			return
		elif(feed_url):
			# Create a dictionary for headers
			var headers = [
				"If-None-Match: " + last_etag,
				"If-Modified-Since: " + last_modified
			]
			# Make request with headers
			http_request.request(feed_url, headers)
		else:
			print("Feed URL not set")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Request failed with result: %s" % result)
		load_cached_news()
		return
	
	# Check for 304 Not Modified response
	if response_code == 304:
		#print("Content hasn't changed, using cached version")
		return
		
	# Update ETag and Last-Modified from headers
	for header in headers:
		var header_lower = header.to_lower()
		if header_lower.begins_with("etag:"):
			last_etag = header.substr(5).strip_edges()
		elif header_lower.begins_with("last-modified:"):
			last_modified = header.substr(14).strip_edges()
	
	json_string = body.get_string_from_utf8()
	var content_hash = str(json_string.hash())
	
	# Check if content has actually changed
	if content_hash == last_content_hash:
		#print("Content hash matches, no update needed")
		return
		
	# Update the stored hash
	last_content_hash = content_hash
	
	# Parse and process the new content
	var json = JSON.parse_string(json_string)
	if json == null:
		push_error("Failed to parse JSON")
		load_cached_news()
		return
	
	# Save the new data to cache
	save_to_cache(json_string, last_etag, content_hash)
	
	# Display the news items
	display_news_items(json)

func display_news_items(json: Dictionary):
	# Clear existing news items
	for child in news_container.get_children():
		child.queue_free()
	
	# Create news items
	if json.has("items"):
		for item in json["items"]:
			var news_item = create_news_item(item["title"], item["description"], 'item["image"], item["icon"], item["hue"]')
			news_container.add_child(news_item)

func save_to_cache(json_data: String, etag: String, content_hash: String):
	# First, clear existing cache
	var clear_result = db.query("DELETE FROM news_cache")
	if clear_result == false:
		push_error("Failed to clear cache: %s" % clear_result)
		return
	
	# Escape double quotes in json string to avoid SQL errors
	json_data = json_data.replace('"', '""')
	etag = etag.replace('"', '""')
	content_hash = content_hash.replace('"', '""')

	# Build SQL string manually (⚠️ make sure input is safe)
	var sql = '''
		INSERT INTO news_cache (json_data, etag, content_hash)
		VALUES ("%s", "%s", "%s")
	''' % [json_data, etag, content_hash]

	var insert_result = db.query(sql)
	#print(sql)

	if not insert_result:
		push_error("Failed to insert cache: %s" % insert_result)
		return

func load_cached_news():
	var columns = ["*"]
	var query_result = db.select_rows("news_cache","",columns)
	
	#print("testing\n\n", query_result)
		
		#var row = result[0]
		#if row.has_all(["etag", "last_modified", "content_hash", "json_data"]):
			#last_etag = result["etag"]
			#last_modified = result["last_modified"]
			#last_content_hash = result["content_hash"]
			#
			## Parse and display cached JSON data
			#var json = JSON.parse_string(result["json_data"])
			#if json != null:
				#display_news_items(json)
			#else:
#
				#push_error("Failed to parse cached JSON data")
		#else:
			#push_error("Cached data is missing required fields")

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
