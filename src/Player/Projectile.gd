extends Node2D

var velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	position += velocity * delta

func _on_VisibilityNotifier2D_viewport_exited(_viewport: Viewport) -> void:
	queue_free()

func _on_Hitbox_body_entered(_body: Node) -> void:
	queue_free()

func _on_Hitbox_area_entered(_area: Area2D) -> void:
	queue_free()
