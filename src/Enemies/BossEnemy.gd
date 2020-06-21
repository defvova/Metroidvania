extends "res://src/Enemies/Enemy.gd"

var MainInstances: Resource = ResourceLoader.MainInstances

const Bullet: Resource = preload("res://src/Enemies/EnemyBullet.tscn")

export (int) var ACCELERATION = 70

onready var rightWallCheck := $RightWallCheck as RayCast2D
onready var leftWallCheck := $LeftWallCheck as RayCast2D

signal died

func _process(delta: float) -> void:
	chase_player(delta)

func chase_player(delta: float) -> void:
	var player: KinematicBody2D = MainInstances.Player

	if player:
		var direction_to_move: float = sign(player.global_position.x - global_position.x)
		motion.x += ACCELERATION * delta * direction_to_move
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		global_position.x += motion.x * delta
		rotation_degrees = lerp(rotation_degrees, (motion.x / MAX_SPEED) * 10, 0.3)

		if ((rightWallCheck.is_colliding() && motion.x > 0) ||
			(leftWallCheck.is_colliding() && motion.x < 0)):
			motion.x *= -0.5

func fire_bullet() -> void:
	var bullet = Utils.instance_scene_on_main(Bullet, global_position)
	var velocity: Vector2 = Vector2.DOWN * 50

	velocity = velocity.rotated(deg2rad(rand_range(-30, 30)))
	bullet.velocity = velocity

func _on_Timer_timeout() -> void:
	fire_bullet()
