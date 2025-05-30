extends Node

# You'll need to attach this script to a Control node that has a RichTextLabel child
# The RichTextLabel will be used to display the HTML content

@onready var rich_text = $RichTextLabel
var http_request = null

func _ready():
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	load_html("https://raw.githubusercontent.com/mysterious-dark/0LSG/refs/heads/main/Websites/Loading.html")
	http_request.request_completed.connect(_http_request_completed)

func load_html(url: String):
	# Make HTTP request
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error fetching the HTML content")
		return
		
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
	

# Example usage
