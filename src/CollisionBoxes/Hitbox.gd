extends Area2D

export (int) var damage: int = 1

func _on_Hitbox_area_entered(hurtbox: Area2D) -> void:
	hurtbox.emit_signal("hit", damage)
