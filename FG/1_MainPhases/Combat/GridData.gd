class_name GridData
extends RefCounted

var walkable: bool
var texture_id: int
var y_pos: int  # Store the height position

func _init(w: bool = false, tid: int = 0, y: int = 2) -> void:
	walkable = w
	texture_id = tid
	y_pos = y
