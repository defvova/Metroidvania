extends Resource

class_name PlayerStats

var MAX_HEALTH: int = 4
var health: int = MAX_HEALTH setget set_health

signal player_died

func set_health(value: int) -> void:
	health = clamp(value, 0, MAX_HEALTH) as int
	if health == 0:
		emit_signal("player_died")
