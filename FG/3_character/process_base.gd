extends Node2D
class_name ProcessBase

signal skill_ready
signal health_changed(current_hp: float, max_hp: float)

enum ProcessType {
	BLOCKER,
	SNIPER,
	CASTER,
	HEALER,
	SUPPORT,
	SCOUT
}

# Basic stats
var process_type: ProcessType
var max_hp: float = 100.0
var current_hp: float = max_hp
var attack_damage: float = 10.0
var attack_speed: float = 1.0  # Attacks per second
var defense: float = 5.0
var block_limit: int = 2
var current_blocks: int = 0
var deploy_cost: int = 10

# Skill-related
var skill_cost: int = 3
var skill_cooldown: float = 3.0
var current_cooldown: float = 0.0

func _ready() -> void:
	setup_process()
	
func setup_process() -> void:
	# Override in derived classes to set specific stats
	pass

func _process(delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta
		if current_cooldown <= 0:
			skill_ready.emit()

func take_damage(amount: float) -> void:
	var damage_taken = max(0, amount - defense)
	current_hp = max(0, current_hp - damage_taken)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		queue_free()

func heal(amount: float) -> void:
	current_hp = min(max_hp, current_hp + amount)
	health_changed.emit(current_hp, max_hp)

func can_use_skill() -> bool:
	return current_cooldown <= 0

func use_skill() -> void:
	if can_use_skill():
		_execute_skill()
		current_cooldown = skill_cooldown

func _execute_skill() -> void:
	# Override in derived classes
	pass
