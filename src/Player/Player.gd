extends KinematicBody2D

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 64
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 200
export (int) var JUMP_FORCE = 128
export (int) var MAX_SLOPE_ANGLE = 46

var motion := Vector2.ZERO
var snap_vector := Vector2.ZERO
var just_jumped := false

onready var sprite := $Sprite as Sprite
onready var spriteAnimator := $SpriteAnimator as AnimationPlayer

func _physics_process(delta: float) -> void:
	just_jumped = false
	var input_vector: Vector2 = get_input_vector()

	apply_horizontal_force(input_vector, delta)
	apply_gravity(delta)
	jump_check()
	update_animation(input_vector)
	move()

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
	if is_on_floor():
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
	if input_vector.x == 0:
		spriteAnimator.play("Idle")
	else:
		sprite.scale.x = sign(input_vector.x)
		spriteAnimator.play("Run")

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

	# Prevent sliding (hack)
	if is_on_floor() && get_floor_velocity().length() == 0 && abs(motion.x) < 1:
		position.x = last_position.x
