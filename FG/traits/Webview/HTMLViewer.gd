extends Node

@onready var rich_text = $RichTextLabel
var http_request = null
var refresh_timer: Timer = null
var current_url: String = ""

# Configuration
var refresh_interval: float = 10.0  # Refresh every 60 seconds by default
var max_retries: int = 3
var current_retries: int = 0

func _ready():
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	load_html("https://mysterious-dark.github.io/0LSG/Websites/Loading.html")
	# Create refresh timer
	refresh_timer = Timer.new()
	add_child(refresh_timer)
	refresh_timer.one_shot = false  # Make it repeat
	#refresh_timer.timeout.connect(_on_refresh_timer_timeout)

func load_html(url: String, auto_refresh: bool = true):
	current_url = url
	current_retries = 0
	
	# Create headers to prevent caching
	var headers = [
		"Cache-Control: no-cache, no-store, must-revalidate",
		"Pragma: no-cache",
		"Expires: 0"
	]
	
	# Make HTTP request with cache-control headers
	var error = http_request.request(url, headers)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		return
		
	#if auto_refresh:
		#start_refresh_timer()
##
#func start_refresh_timer():
	##refresh_timer.wait_time = refresh_interval
	##refresh_timer.start()
#
#func stop_refresh_timer():
	##refresh_timer.stop()

#func set_refresh_interval(seconds: float):
	#refresh_interval = seconds
	#if refresh_timer.is_stopped() == false:
		## Restart timer with new interval if it's running
		##start_refresh_timer()

#func _on_refresh_timer_timeout():
	## Timer triggered, reload the page
	#load_html(current_url, false)  # Don't pass auto_refresh to avoid recursion
	#start_refresh_timer()  # Restart the timer manually

func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error fetching the HTML content")
		
		# Retry logic
		if current_retries < max_retries:
			current_retries += 1
			# Wait 2 seconds before retrying
			await get_tree().create_timer(2.0).timeout
			load_html(current_url, false)
		return
		
	# Reset retry counter on success
	current_retries = 0
	
	# Convert the body to text
	var html_content = body.get_string_from_utf8()
	
	# Basic HTML parsing (you might want to enhance this based on your needs)
	# Remove HTML tags but preserve line breaks
	html_content = html_content.replace("<br>", "\n")
	html_content = html_content.replace("<p>", "\n")
	html_content = html_content.replace("</p>", "\n")
	
	# Remove other HTML tags
	var regex = RegEx.new()
	regex.compile("<[^>]*>")
	html_content = regex.sub(html_content, "", true)
	
	# Set the processed content to RichTextLabel
	rich_text.text = html_content

# Optional: Add loading indicator
func show_loading():
	rich_text.text = "Loading..."

func hide_loading():
	pass  # Remove loading text is handled by setting new content

# Example usage
# Clean up
func _exit_tree():
	if refresh_timer:
		refresh_timer.stop()
		refresh_timer.queue_free()
