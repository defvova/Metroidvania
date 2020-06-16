extends "res://src/Enemies/Enemy.gd"

enum DIRECTION { LEFT = -1, RIGHT = 1 }

export (DIRECTION) var WALKING_DIRECTION

var state

onready var sprite := $Sprite as Sprite
onready var floorLeft := $FloorLeft as RayCast2D
onready var floorRight := $FloorRight as RayCast2D
onready var wallLeft := $WallLeft as RayCast2D
onready var wallRight := $WallRight as RayCast2D

func _ready() -> void:
	state = WALKING_DIRECTION

func _physics_process(_delta: float) -> void:
	match state:
		DIRECTION.RIGHT:
			motion.x = MAX_SPEED

			if !floorRight.is_colliding() || wallRight.is_colliding():
				state = DIRECTION.LEFT

		DIRECTION.LEFT:
			motion.x = -MAX_SPEED
			if !floorLeft.is_colliding() || wallLeft.is_colliding():
				state = DIRECTION.RIGHT

	sprite.scale.x = sign(motion.x)

	motion = move_and_slide_with_snap(motion, Vector2.DOWN * 4, Vector2.UP, true, 4, deg2rad(46))
