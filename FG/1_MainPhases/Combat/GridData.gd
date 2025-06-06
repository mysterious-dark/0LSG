class_name GridData
extends RefCounted

var walkable: bool
var texture_id: int
var y_pos: int  # Store the height position
var x_pos: int = -1  # -1 means position should be calculated automatically

func _init(w: bool = false, tid: int = 0, y: int = 2, x: int = -1) -> void:
	walkable = w
	texture_id = tid
	y_pos = y
	x_pos = x
