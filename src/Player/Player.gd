extends KinematicBody2D

const DustEffect = preload("res://src/Effects/DustEffect.tscn")
const PlayerBullet = preload("res://src/Player/PlayerBullet.tscn")

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 64
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 200
export (int) var JUMP_FORCE = 128
export (int) var MAX_SLOPE_ANGLE = 46
export (int) var BULLET_SPEED = 250

var motion := Vector2.ZERO
var snap_vector := Vector2.ZERO
var just_jumped := false

onready var sprite := $Sprite as Sprite
onready var spriteAnimator := $SpriteAnimator as AnimationPlayer
onready var coyoteJumpTimer := $CoyoteJumpTimer as Timer
onready var fireBulletTimer := $FireBulletTimer as Timer
onready var gun := $Sprite/PlayerGun as Node2D
onready var muzzle := $Sprite/PlayerGun/PlayerGun/Muzzle as Position2D

func _physics_process(delta: float) -> void:
	just_jumped = false
	var input_vector: Vector2 = get_input_vector()

	apply_horizontal_force(input_vector, delta)
	apply_gravity(delta)
	jump_check()
	update_animation(input_vector)
	move()

	if Input.is_action_pressed("fire") && fireBulletTimer.time_left == 0:
		fire_bullet()

func fire_bullet() -> void:
	var bullet: Object = Utils.instance_scene_on_main(PlayerBullet, muzzle.global_position)
	bullet.velocity = Vector2.RIGHT.rotated(gun.rotation) * BULLET_SPEED
	bullet.velocity.x *= sprite.scale.x
	bullet.rotation = bullet.velocity.angle()
	fireBulletTimer.start()

func create_dust_effect() -> void:
	var dust_position: Vector2 = global_position
	dust_position.x += rand_range(-4, 4)
# warning-ignore:return_value_discarded
	Utils.instance_scene_on_main(DustEffect, dust_position)

func get_input_vector() -> Vector2:
	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	return input_vector

func apply_horizontal_force(input_vector: Vector2, delta: float) -> void:
	if input_vector.x == 0:
		apply_friction()
	else:
		motion.x += input_vector.x * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)

func apply_friction() -> void:
	if is_on_floor():
		motion.x = lerp(motion.x, 0, FRICTION)

func jump_check() -> void:
	if is_on_floor() || coyoteJumpTimer.time_left > 0:
		snap_vector = Vector2.DOWN

		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
			just_jumped = true
			snap_vector = Vector2.ZERO

	if Input.is_action_just_released("ui_up") && motion.y < -JUMP_FORCE/2:
		motion.y = -JUMP_FORCE/2

func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)

func update_animation(input_vector: Vector2) -> void:
	sprite.scale.x = sign(get_local_mouse_position().x)
	if input_vector.x == 0:
		spriteAnimator.play("Idle")
	else:
		#sprite.scale.x = sign(input_vector.x)
		var playback_speed: float = input_vector.x * sprite.scale.x
		var is_playback: bool = playback_speed < 0

		spriteAnimator.play("Run", 0, playback_speed, is_playback)

	if !is_on_floor():
		spriteAnimator.play("Jump")

func move() -> void:
	var was_in_air: bool = !is_on_floor()
	var was_on_floor: bool = is_on_floor()
	var last_position: Vector2 = position
	var last_motion: Vector2 = motion

	motion = move_and_slide_with_snap(motion, snap_vector * 4, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))

	# Landing
	if was_in_air && is_on_floor():
		motion.x = last_motion.x

	var is_in_air: bool = !is_on_floor()
	var was_not_jumped: bool = !just_jumped
	# Just left ground
	if was_on_floor && is_in_air && was_not_jumped:
		motion.y = 0
		position.y = last_position.y
		coyoteJumpTimer.start()

	# Prevent sliding (hack)
	if is_on_floor() && get_floor_velocity().length() == 0 && abs(motion.x) < 1:
		position.x = last_position.x
