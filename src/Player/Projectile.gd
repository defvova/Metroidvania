extends Node2D

var ExplosionEffect = preload("res://src/Effects/ExplosionEffect.tscn")

var velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	position += velocity * delta

func _on_VisibilityNotifier2D_viewport_exited(_viewport: Viewport) -> void:
	queue_free()

func _on_Hitbox_body_entered(_body: Node) -> void:
# warning-ignore:return_value_discarded
	Utils.instance_scene_on_main(ExplosionEffect, global_position)
	queue_free()

func _on_Hitbox_area_entered(_area: Area2D) -> void:
# warning-ignore:return_value_discarded
	Utils.instance_scene_on_main(ExplosionEffect, global_position)
	queue_free()
