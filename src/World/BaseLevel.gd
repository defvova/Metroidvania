extends Node2D

#const WORLD = preload("res://src/World/Level.tscn")

func _ready() -> void:
	var parent: Node = get_parent()

	if parent.name == "Level":
		parent.currentLevel = self
