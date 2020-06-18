extends KinematicBody2D

const DustEffect = preload("res://src/Effects/DustEffect.tscn")
const JumpEffect = preload("res://src/Effects/JumpEffect.tscn")
const PlayerBullet = preload("res://src/Player/PlayerBullet.tscn")

var PlayerStats = ResourceLoader.PlayerStats

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 64
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 200
export (int) var WALL_SLIDE_SPEED = 48
export (int) var MAX_WALL_SLIDE_SPEED = 128
export (int) var JUMP_FORCE = 128
export (int) var MAX_SLOPE_ANGLE = 46
export (int) var BULLET_SPEED = 250

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

onready var sprite := $Sprite as Sprite
onready var spriteAnimator := $SpriteAnimator as AnimationPlayer
onready var blinkAnimator := $BlinkAnimator as AnimationPlayer
onready var coyoteJumpTimer := $CoyoteJumpTimer as Timer
onready var fireBulletTimer := $FireBulletTimer as Timer
onready var gun := $Sprite/PlayerGun as Node2D
onready var muzzle := $Sprite/PlayerGun/PlayerGun/Muzzle as Position2D

func set_invincible(value: bool) -> void:
	invincible = value
	
func _ready() -> void:
	PlayerStats.connect("player_died", self, "_on_died")

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
			wall_slide_drop_check(delta)
			wall_slide_fast_slide_check(delta)
			move()
			wall_detach_check(wall_axis)

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

func get_wall_axis() -> int:
	var is_right_wall = test_move(transform, Vector2.RIGHT)
	var is_left_wall = test_move(transform, Vector2.LEFT)
	
	return int(is_left_wall) - int(is_right_wall)

func wall_slide_jump_check(wall_axis) -> void:
	if Input.is_action_just_pressed("ui_up"):
		motion.x = wall_axis * MAX_SPEED
		motion.y = -JUMP_FORCE/1.25
		state = MOVE
		
func wall_slide_drop_check(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		motion.x = ACCELERATION * delta
		state = MOVE
		
	if Input.is_action_just_pressed("ui_left"):
		motion.x = -ACCELERATION * delta
		state = MOVE
		
func wall_slide_fast_slide_check(delta: float) -> void:
	var max_slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed("ui_down"):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GRAVITY * delta, max_slide_speed)
	
func wall_detach_check(wall_axis: int) -> void:
	if wall_axis == 0 || is_on_floor():
		state = MOVE

func _on_Hurtbox_hit(damage: int) -> void:
	if !invincible:
		PlayerStats.health -= damage
		blinkAnimator.play("Blink")

func _on_died() -> void:
	queue_free()
