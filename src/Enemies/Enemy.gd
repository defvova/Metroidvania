extends KinematicBody2D

export (int) var MAX_SPEED = 15

var motion := Vector2.ZERO as Vector2

onready var stats = $EnemyStats

func _on_Hurtbox_hit(damage: int) -> void:
	stats.health -= damage

func _on_EnemyStats_enemy_died() -> void:
	queue_free()
