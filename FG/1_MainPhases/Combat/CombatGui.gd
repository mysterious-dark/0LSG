extends Control

# References to UI elements
@onready var health_bar = $GUI/HUDContainer/TopBar/PlayerStats/HealthBar
@onready var stamina_bar = $GUI/HUDContainer/TopBar/PlayerStats/StaminaBar
@onready var turn_label = $GUI/HUDContainer/TopBar/CombatInfo/TurnLabel
@onready var action_points = $GUI/HUDContainer/TopBar/CombatInfo/ActionPoints
@onready var enemy_health_bar = $GUI/HUDContainer/TopBar/EnemyStats/EnemyHealthBar
@onready var combat_scene = $Combat
@onready var action_buttons = $GUI/HUDContainer/BottomBar/ActionButtons
@onready var placement_button = $GUI/HUDContainer/BottomBar/ActionButtons/PlaceOperatorButton

#var placement_button

# Combat state
var max_health: float = 100.0
var current_health: float = 100.0
var max_stamina: float = 100.0
var current_stamina: float = 100.0
var max_ap: int = 3
var current_ap: int = 3
var is_player_turn: bool = true

# Touch handling
var touch_events = {}
var dragging = false
var minimum_drag_distance = 5

func _ready() -> void:
	# Initialize the HUD
	update_health_display()
	update_stamina_display()
	update_ap_display()
	update_turn_display()
	
	# Make sure GUI layer is set up for touch input
	set_process_input(true)
	
	# Set up buttons
	setup_action_buttons()

# Add this function to handle the button press
func _on_place_operator_pressed() -> void:
	combat_scene.enter_placement_mode()
	
	# Visual feedback for button press
	_show_button_feedback(placement_button)
	# DisplayServer.vibrate_handheld(20)  # Tactile feedback
	
func setup_action_buttons() -> void:
	# Get references to buttons
	var attack_button = $GUI/HUDContainer/BottomBar/ActionButtons/AttackButton
	var defend_button = $GUI/HUDContainer/BottomBar/ActionButtons/DefendButton
	var skills_button = $GUI/HUDContainer/BottomBar/ActionButtons/SkillsButton
	var items_button = $GUI/HUDContainer/BottomBar/ActionButtons/ItemsButton
	
	# Connect button signals
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	skills_button.pressed.connect(_on_skills_pressed)
	items_button.pressed.connect(_on_items_pressed)
	
	# Make buttons larger and more touch-friendly
	for button in [attack_button, defend_button, skills_button, items_button]:
		button.custom_minimum_size = Vector2(120, 60)  # Larger touch target
		button.focus_mode = Control.FOCUS_NONE  # Disable focus for touch

	# Add some visual styling for mobile
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.4, 0.8, 0.8)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	placement_button.add_theme_stylebox_override("normal", style)
	
	placement_button.pressed.connect(_on_place_operator_pressed)
	
	
func _input(event: InputEvent) -> void:
	# Handle touch events
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Store touch event
		touch_events[event.index] = {
			"position": event.position,
			"start_time": Time.get_ticks_msec()
		}
		
		# Check if touch is on a UI element
		var touch_pos = event.position
		if _is_position_in_hud(touch_pos):
			get_viewport().set_input_as_handled()
	else:
		# Touch released
		if touch_events.has(event.index):
			var touch_data = touch_events[event.index]
			var duration = Time.get_ticks_msec() - touch_data.start_time
			
			# Handle tap if it was short and didn't move much
			if duration < 200 and not dragging:  # 200ms tap threshold
				_handle_tap(touch_data.position)
			
			touch_events.erase(event.index)
		
		# Reset dragging state if no touches remain
		if touch_events.is_empty():
			dragging = false

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if touch_events.has(event.index):
		var touch_data = touch_events[event.index]
		var drag_distance = event.position.distance_to(touch_data.position)
		
		# If drag distance exceeds minimum, mark as dragging
		if drag_distance > minimum_drag_distance:
			dragging = true
			
			# Update stored position
			touch_data.position = event.position
			touch_events[event.index] = touch_data

func _is_position_in_hud(position2: Vector2) -> bool:
	# Check if position is within any HUD container
	if $GUI/HUDContainer/TopBar.get_global_rect().has_point(position2):
		return true
	if $GUI/HUDContainer/BottomBar.get_global_rect().has_point(position2):
		return true
	return false

func _handle_tap(position2: Vector2) -> void:
	# Check which UI element was tapped
	for child in action_buttons.get_children():
		if child is Button and child.get_global_rect().has_point(position2):
			child.emit_signal("pressed")
			_show_button_feedback(child)
			return

# Update functions
func update_health_display() -> void:
	health_bar.value = (current_health / max_health) * 100

func update_stamina_display() -> void:
	stamina_bar.value = (current_stamina / max_stamina) * 100

func update_ap_display() -> void:
	action_points.text = "AP: %d/%d" % [current_ap, max_ap]

func update_turn_display() -> void:
	turn_label.text = "Current Turn: %s" % ("Player" if is_player_turn else "Enemy")

# Button handlers
func _on_attack_pressed() -> void:
	if current_ap > 0 and is_player_turn:
		_show_button_feedback($GUI/HUDContainer/BottomBar/ActionButtons/AttackButton)
		set_ap(current_ap - 1)
		#DisplayServer.vibrate_handheld(20)  # Short vibration feedback (Android/iOS)

func _on_defend_pressed() -> void:
	if current_ap > 0 and is_player_turn:
		_show_button_feedback($GUI/HUDContainer/BottomBar/ActionButtons/DefendButton)
		set_ap(current_ap - 1)
		#DisplayServer.vibrate_handheld(20)

func _on_skills_pressed() -> void:
	if is_player_turn:
		_show_button_feedback($GUI/HUDContainer/BottomBar/ActionButtons/SkillsButton)
		#DisplayServer.vibrate_handheld(20)

func _on_items_pressed() -> void:
	if is_player_turn:
		_show_button_feedback($GUI/HUDContainer/BottomBar/ActionButtons/ItemsButton)
		#DisplayServer.vibrate_handheld(20)

# Visual feedback
func _show_button_feedback(button: Button) -> void:
	if not button:
		return
		
	# Save original scale
	var original_scale = button.scale
	
	# Create tween for button press animation
	var tween = create_tween()
	tween.tween_property(button, "scale", original_scale * 0.9, 0.1)
	tween.tween_property(button, "scale", original_scale, 0.1)

# Public setters
func set_health(new_health: float) -> void:
	current_health = clamp(new_health, 0, max_health)
	update_health_display()

func set_stamina(new_stamina: float) -> void:
	current_stamina = clamp(new_stamina, 0, max_stamina)
	update_stamina_display()

func set_ap(new_ap: int) -> void:
	current_ap = clamp(new_ap, 0, max_ap)
	update_ap_display()

func set_turn(is_player: bool) -> void:
	is_player_turn = is_player
	update_turn_display()

func set_enemy_health(current: float, maximum: float) -> void:
	enemy_health_bar.value = (current / maximum) * 100
