extends Control

var popup_menu: PopupMenu

func _ready():
	# Setup popup menu
	popup_menu = $PopupMenu
	
	# Ensure the layout scales with the screen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
