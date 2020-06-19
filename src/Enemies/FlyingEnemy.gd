extends "res://src/Enemies/Enemy.gd"

export (int) var ACCELERATION = 100

var MainInstances = ResourceLoader.MainInstances

onready var sprite := $Sprite as Sprite

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	var player: KinematicBody2D = MainInstances.Player
	if player:
		chase_player(player, delta)
		
func chase_player(player: KinematicBody2D, delta: float) -> void:
	var direction = (player.global_position - global_position).normalized()
	motion += direction * ACCELERATION * delta
	motion = motion.clamped(MAX_SPEED)
	sprite.flip_h = global_position < player.global_position
	motion = move_and_slide(motion)

func _on_VisibilityNotifier2D_screen_entered() -> void:
	set_physics_process(true)
