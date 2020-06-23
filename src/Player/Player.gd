extends KinematicBody2D

const DustEffect = preload("res://src/Effects/DustEffect.tscn")
const JumpEffect = preload("res://src/Effects/JumpEffect.tscn")
const PlayerBullet = preload("res://src/Player/PlayerBullet.tscn")
const WallDustEffect = preload("res://src/Effects/WallDustEffect.tscn")
const PlayerMissile = preload("res://src/Player/PlayerMissile.tscn")

var PlayerStats = ResourceLoader.PlayerStats
var MainInstances = ResourceLoader.MainInstances

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 64
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 200
export (int) var WALL_SLIDE_SPEED = 48
export (int) var MAX_WALL_SLIDE_SPEED = 128
export (int) var JUMP_FORCE = 128
export (int) var MAX_SLOPE_ANGLE = 46
export (int) var BULLET_SPEED = 250
export (int) var MISSILE_BULLET_SPEED = 150

enum {
	MOVE,
	WALL_SLIDE
}

var state = MOVE
var invincible: bool = false setget set_invincible
var motion: Vector2 = Vector2.ZERO
var snap_vector: Vector2 = Vector2.ZERO
var just_jumped: bool = false
var double_jump: bool = true

onready var cameraFollow := $CameraFollow as RemoteTransform2D
onready var sprite := $Sprite as Sprite
onready var spriteAnimator := $SpriteAnimator as AnimationPlayer
onready var blinkAnimator := $BlinkAnimator as AnimationPlayer
onready var coyoteJumpTimer := $CoyoteJumpTimer as Timer
onready var fireBulletTimer := $FireBulletTimer as Timer
onready var gun := $Sprite/PlayerGun as Node2D
onready var muzzle := $Sprite/PlayerGun/PlayerGun/Muzzle as Position2D
onready var powerupDetector := $PowerupDetector as Area2D

# warning-ignore:unused_signal
signal hit_door(door)

func set_invincible(value: bool) -> void:
	invincible = value

func _ready() -> void:
	PlayerStats.connect("player_died", self, "_on_died")
	PlayerStats.missiles_unlocked = SaveAndLoader.custom_data.missiles_unlocked
	MainInstances.Player = self
	call_deferred("asign_camera_follow")

func queue_free() -> void:
	MainInstances.Player = null
	.queue_free()

func _physics_process(delta: float) -> void:
	just_jumped = false

	match state:
		MOVE:
			var input_vector: Vector2 = get_input_vector()

			apply_horizontal_force(input_vector, delta)
			apply_gravity(delta)
			jump_check()
			update_animation(input_vector)
			move()
			wall_slide_check()
		WALL_SLIDE:
			spriteAnimator.play("Wall Slide")

			var wall_axis = get_wall_axis()
			if wall_axis != 0:
				sprite.scale.x = wall_axis

			wall_slide_jump_check(wall_axis)
			wall_slide_drop(delta)
			move()
			wall_detach(delta, wall_axis)

	if Input.is_action_pressed("fire") && fireBulletTimer.time_left == 0:
		fire_bullet()

	if Input.is_action_pressed("fire_missile") && fireBulletTimer.time_left == 0:
		if PlayerStats.missiles > 0 && PlayerStats.missiles_unlocked:
			fire_missile()
			PlayerStats.missiles -= 1

func asign_camera_follow() -> void:
	cameraFollow.remote_path = MainInstances.WorldCamera.get_path()

func save() -> Dictionary:
	var save_dictionary = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}

	return save_dictionary

func fire_bullet() -> void:
	var bullet: Object = Utils.instance_scene_on_main(PlayerBullet, muzzle.global_position)
	bullet.velocity = Vector2.RIGHT.rotated(gun.rotation) * BULLET_SPEED
	bullet.velocity.x *= sprite.scale.x
	bullet.rotation = bullet.velocity.angle()
	fireBulletTimer.start()

func fire_missile() -> void:
	var missile: Object = Utils.instance_scene_on_main(PlayerMissile, muzzle.global_position)
	missile.velocity = Vector2.RIGHT.rotated(gun.rotation) * MISSILE_BULLET_SPEED
	missile.velocity.x *= sprite.scale.x
	motion -= missile.velocity * 0.25
	missile.rotation = missile.velocity.angle()
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
			jump(JUMP_FORCE)
			just_jumped = true
	else:
		if Input.is_action_just_released("ui_up") && motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2

		if Input.is_action_just_pressed("ui_up") && double_jump:
			jump(JUMP_FORCE * .75)
			double_jump = false


func jump(force: int) -> void:
	# warning-ignore:return_value_discarded
	Utils.instance_scene_on_main(JumpEffect, global_position)
	motion.y = -force
	snap_vector = Vector2.ZERO

func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)

func update_animation(input_vector: Vector2) -> void:
	var facing: float = sign(get_local_mouse_position().x)

	if facing != 0:
		sprite.scale.x = facing

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
# warning-ignore:return_value_discarded
		Utils.instance_scene_on_main(JumpEffect, global_position)
		double_jump = true

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

func wall_slide_check() -> void:
	if !is_on_floor() && is_on_wall():
		state = WALL_SLIDE
		double_jump = true
		create_dust_effect()

func get_wall_axis() -> int:
	var is_right_wall = test_move(transform, Vector2.RIGHT)
	var is_left_wall = test_move(transform, Vector2.LEFT)

	return int(is_left_wall) - int(is_right_wall)

func wall_slide_jump_check(wall_axis) -> void:
	if Input.is_action_just_pressed("ui_up"):
		motion.x = wall_axis * MAX_SPEED
		motion.y = -JUMP_FORCE/1.25
		state = MOVE
		var dust_position: Vector2 = global_position + Vector2(wall_axis * 4, 0)
		var dust = Utils.instance_scene_on_main(WallDustEffect, dust_position)
		dust.scale.x = wall_axis

func wall_slide_drop(delta: float) -> void:
	var max_slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed("ui_down"):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GRAVITY * delta, max_slide_speed)

func wall_detach(delta: float, wall_axis: int) -> void:
	if Input.is_action_just_pressed("ui_right"):
		motion.x = ACCELERATION * delta
		state = MOVE

	if Input.is_action_just_pressed("ui_left"):
		motion.x = -ACCELERATION * delta
		state = MOVE

	if wall_axis == 0 || is_on_floor():
		state = MOVE

func _on_Hurtbox_hit(damage: int) -> void:
	if !invincible:
		PlayerStats.health -= damage
		blinkAnimator.play("Blink")

func _on_died() -> void:
	queue_free()

func _on_PowerupDetector_area_entered(area: Area2D) -> void:
	if area is Powerup:
		area._pickup()
