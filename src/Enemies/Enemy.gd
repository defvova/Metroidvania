extends KinematicBody2D

const EnemyDeathEffect = preload("res://src/Effects/EnemyDeathEffect.tscn")

export (int) var MAX_SPEED = 15

var motion := Vector2.ZERO as Vector2

onready var stats = $EnemyStats

func _on_Hurtbox_hit(damage: int) -> void:
	stats.health -= damage

func _on_EnemyStats_enemy_died() -> void:
# warning-ignore:return_value_discarded
	Utils.instance_scene_on_main(EnemyDeathEffect, global_position)
	queue_free()
