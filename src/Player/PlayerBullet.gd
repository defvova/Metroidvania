extends "res://src/Player/Projectile.gd"

func _ready() -> void:
	SoundFx.play("Bullet", rand_range(0.6, 1.0))
	set_process(false)
