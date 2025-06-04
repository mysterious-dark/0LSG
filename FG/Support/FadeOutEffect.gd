class_name FadeOutEffect
extends Node

static func _on_fadeout(CurrentNode: Node,fade_duration: float = 1.0, nextScene: String = ""):
	# Start the fade-out effect
	# Optional: Add a fade transition
	var transition = ColorRect.new()
	transition.color = Color.AQUA
	transition.modulate = Color(0, 0, 0, 0)  # Start fully transparent
	transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	CurrentNode.add_child(transition)
	
	# Create a tween for the fade effect
	var tween = CurrentNode.create_tween()
	tween.tween_property(transition, "modulate", Color(0, 0, 0, 1),fade_duration)  # Fade to black
	await tween.finished
	
	CurrentNode.get_tree().change_scene_to_file(nextScene)
	# Wait for the fade duration
	# Remove the transition after fading out
	
