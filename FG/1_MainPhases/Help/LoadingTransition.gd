extends Control

signal transition_completed

# Scene paths - adjust these to match your actual scene paths
const CHARACTER_CREATION_SCENE = "res://1_MainPhases/CharacterCreation/character_creation.tscn"
const HUB_SCENE = "res://1_MainPhases/Hub/hub.tscn"

@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var status_label = $CenterContainer/VBoxContainer/StatusLabel

func _ready():
	# Start the loading process
	progress_bar.value = 0
	start_loading_sequence()

func start_loading_sequence():
	# Create a tween for smooth progress bar animation
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 30, 0.5)
	
	# Perform initial checks
	status_label.text = "Checking save data..."
	await get_tree().create_timer(0.5).timeout
	
	# Update progress
	tween = create_tween()
	tween.tween_property(progress_bar, "value", 60, 0.5)
	
	# Check if player has created a character
	status_label.text = "Checking character data..."
	var has_character = check_for_character()
	await get_tree().create_timer(0.5).timeout
	
	# Final progress update
	tween = create_tween()
	tween.tween_property(progress_bar, "value", 100, 0.5)
	
	# Determine which scene to load
	status_label.text = "Preparing scene..."
	await get_tree().create_timer(0.5).timeout
	
	if has_character:
		load_hub_scene()
	else:
		load_character_creation_scene()

func check_for_character() -> bool:
	# TODO: Implement your character check logic here
	# This could involve checking a save file, database, or other storage
	
	return true
	# # Example implementation:
	# var save_file = FileAccess.open("user://player_data.save", FileAccess.READ)
	# if save_file == null:
	# 	return false
		
	# # Read and parse your save data here
	# # For example:
	# # var data = JSON.parse_string(save_file.get_as_text())
	# # return data != null and data.has("character_created") and data.character_created
	
	# # Temporary return false to force character creation
	# return false

func load_hub_scene():
	status_label.text = "Loading hub..."
	# You might want to use ResourceLoader.load_threaded() for larger scenes
	get_tree().change_scene_to_file(HUB_SCENE)

func load_character_creation_scene():
	status_label.text = "Preparing character creation..."
	get_tree().change_scene_to_file(CHARACTER_CREATION_SCENE)
