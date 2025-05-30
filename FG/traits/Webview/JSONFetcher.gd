extends Node

var http_request = null

func _ready():
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)

func fetch_json(url: String):
	# Make HTTP request
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error fetching the JSON content")
		return
		
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		push_error("Error parsing JSON.")
		return
		
	var data = json.get_data()
	
	# Example: Process array data
	# Assuming the JSON contains an array at the root level
	if data is Array:
		process_array_data(data)
	elif data is Dictionary:
		# If you need to access a specific array in the JSON
		# Example: {"items": [...]}
		if data.has("items") and data["items"] is Array:
			process_array_data(data["items"])

func process_array_data(array_data: Array):
	# Process your array data here
	for item in array_data:
		print(item)  # Replace with your processing logic
	
	# Optional: Save to file
	save_to_file(array_data)

func save_to_file(data: Array):
	var file = FileAccess.open("user://data.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")  # Pretty print with tabs
		file.store_string(json_string)

# Example usage
func _on_ready():
	fetch_json("https://example.com/data.json")