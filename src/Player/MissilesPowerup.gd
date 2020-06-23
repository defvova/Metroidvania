extends Powerup

func _ready() -> void:
	if SaveAndLoader.custom_data.missiles_unlocked:
		queue_free()

func _pickup() -> void:
	._pickup()
	PlayerStats.missiles_unlocked = true
	queue_free()
