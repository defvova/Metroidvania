extends Node

signal enemy_died

export (int) var MAX_HEALTH = 1

onready var health: int = MAX_HEALTH setget set_health

func set_health(value: int) -> void:
	health = clamp(value, 0, MAX_HEALTH) as int

	if health == 0:
		emit_signal("enemy_died")
