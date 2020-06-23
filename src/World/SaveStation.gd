extends StaticBody2D

onready var animationPlayer := $AnimationPlayer as AnimationPlayer

var PlayerStats: Resource = ResourceLoader.PlayerStats

func _on_SaveArea_body_entered(_body: Node) -> void:
	SoundFx.play("Powerup", 0.6, -10)
	animationPlayer.play("Save")
	SaveAndLoader.save_game()
	PlayerStats.refill_stats()
