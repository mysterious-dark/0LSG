extends Control

var popup_menu: PopupMenu

func _ready():
	# Setup popup menu
	popup_menu = $PopupMenu
	
	# Ensure the layout scales with the screen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Initialize touch controls
	#setup_touch_controls()

#func setup_touch_controls():
	#for button in get_tree().get_nodes_in_group("touch_buttons"):
		#button.connect("pressed", self, "_on_button_pressed", [button.name])

func _on_button_pressed(button_name: String):
	match button_name:
		"AttackButton":
			popup_menu.popup_centered()
		"InventoryButton":
			popup_menu.popup_centered()
		# Add more button handlers as needed
