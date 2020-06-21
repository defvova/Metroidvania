extends Resource

class_name PlayerStats

var MAX_HEALTH: int = 4
var health: int = MAX_HEALTH setget set_health
var max_missiles: int = 3
var missiles: int = max_missiles setget set_missiles
var missiles_unlocked: bool = false setget set_missiles_unlocked

signal player_health_changed(value)
signal player_missiles_changed(value)
signal player_missiles_unlocked(value)
signal player_died

func set_health(value: int) -> void:
	if value < health:
		Events.emit_signal("add_screenshake", 0.4, 0.5)

	health = clamp(value, 0, MAX_HEALTH) as int
	emit_signal("player_health_changed", health)

	if health == 0:
		emit_signal("player_died")

func set_missiles(value: int) -> void:
	missiles = clamp(value, 0, max_missiles) as int
	emit_signal("player_missiles_changed", missiles)

func set_missiles_unlocked(value: bool) -> void:
	missiles_unlocked = value
	emit_signal("player_missiles_unlocked", missiles_unlocked)
