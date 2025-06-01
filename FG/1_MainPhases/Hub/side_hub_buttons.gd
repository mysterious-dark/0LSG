extends Control

# Reference to your buttons
@onready var events_button = $EventsHBoxContainer/Events
@onready var attack_button = $EventsHBoxContainer/Attack
@onready var shop_button = $ItemsHBoxContainer/Shop
@onready var inventory_button = $ItemsHBoxContainer/Inventory

func _ready():
	# Connect touch/press signals for each button
	# Connect signals using the new Godot 4.x syntax
	events_button.gui_input.connect(_on_button_input.bind("Events"))
	attack_button.gui_input.connect(_on_button_input.bind("Attack"))
	shop_button.gui_input.connect(_on_button_input.bind("Shop"))
	inventory_button.gui_input.connect(_on_button_input.bind("Inventory"))

func _on_button_input(event: InputEvent, button_name: String):
	# Check for touch/mouse press events
	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_button_press(button_name)
			
	## Also handle mouse clicks for testing in editor
	#elif event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#_handle_button_press(button_name)

func _handle_button_press(button_name: String):
	match button_name:
		"Events":
			print("Events button pressed")
			# Add your events button logic here
			
		"Attack":
			print("Attack button pressed")
			# Add your attack button logic here
			
		"Shop":
			print("Shop button pressed")
			# Add your shop button logic here
			
		"Inventory":
			print("Inventory button pressed")
			# Add your inventory button logic here
