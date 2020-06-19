extends Node2D

func _on_DustEffect10_tree_exited() -> void:
	queue_free()
