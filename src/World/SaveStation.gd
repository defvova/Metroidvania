extends StaticBody2D

onready var animationPlayer := $AnimationPlayer as AnimationPlayer

func _on_SaveArea_body_entered(_body: Node) -> void:
	animationPlayer.play("Save")
	SaveAndLoader.is_loading = false
	SaveAndLoader.save_game()
