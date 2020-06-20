extends Powerup

func _pickup() -> void:
	PlayerStats.missiles_unlocked = true
	queue_free()
