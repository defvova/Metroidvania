extends KinematicBody2D

export (int) var MAX_SPEED = 15

var motion := Vector2.ZERO as Vector2

func _on_Hurtbox_hit(_damage: int) -> void:
	queue_free()
