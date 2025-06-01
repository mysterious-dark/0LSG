extends TextureButton

@export var press_scale: float = 0.9  # How much the button scales when pressed
@export var animation_speed: float = 0.1  # Speed of the press animation

var original_scale: Vector2
var is_pressed: bool = false
var tween: Tween  # Store the tween for cleanup

func _ready() -> void:
	original_scale = scale
	gui_input.connect(_on_button_input)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_button_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not is_pressed:
			_animate_press()
		elif not event.pressed and is_pressed:
			_animate_release()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_pressed:
				_animate_press()
			elif not event.pressed and is_pressed:
				_animate_release()

func _animate_press() -> void:
	is_pressed = true
	# Kill previous tween if it exists
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", original_scale * press_scale, animation_speed)

func _animate_release() -> void:
	is_pressed = false
	# Kill previous tween if it exists
	if tween and tween.is_valid():
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", original_scale, animation_speed)

func _exit_tree() -> void:
	# Clean up tween when the node is removed
	if tween and tween.is_valid():
		tween.kill()
