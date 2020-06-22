extends Area2D

signal area_triggered

var enabled: bool = true

func _on_Trigger_body_entered(_body: Node) -> void:
	if enabled:
		emit_signal("area_triggered")
		enabled = false
