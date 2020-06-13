extends KinematicBody2D

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 64
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 200
export (int) var JUMP_FORCE = 128
export (int) var MAX_SLOPE_ANGLE = 46

var motion := Vector2.ZERO

onready var sprite := $Sprite as Sprite
onready var spriteAnimator := $SpriteAnimator as AnimationPlayer

func _physics_process(delta: float) -> void:
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

func move() -> void:
	motion = move_and_slide(motion, Vector2.UP)

func jump_check() -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE

	if Input.is_action_just_released("ui_up") && motion.y < -JUMP_FORCE/2:
		motion.y = -JUMP_FORCE/2

func apply_gravity(delta: float) -> void:
	#if not is_on_floor():
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
