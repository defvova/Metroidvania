extends Node2D

#const WORLD = preload("res://src/World/Level.tscn")

func _ready() -> void:
	var parent: Node = get_parent()

	if parent.name == "Level":
		parent.currentLevel = self

func save() -> Dictionary:
	var save_dictionary = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}

	return save_dictionary
