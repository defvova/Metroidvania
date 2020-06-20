extends "res://src/Enemies/Enemy.gd"

enum DIRECTION {
	LEFT = -1,
	RIGHT = 1
}

export (DIRECTION) var WALKING_DIRECTION = DIRECTION.RIGHT

onready var floorCast := $FloorCast as RayCast2D
onready var wallCast := $WallCast as RayCast2D

func _ready() -> void:
	wallCast.cast_to.x *= WALKING_DIRECTION
	
func _physics_process(delta: float) -> void:
	if wallCast.is_colliding():
		global_position = wallCast.get_collision_point()
		rotation = get_enemy_rotation(wallCast)
	else:
		floorCast.rotation_degrees = -MAX_SPEED * 10 * WALKING_DIRECTION * delta

		if floorCast.is_colliding():
			global_position = floorCast.get_collision_point()
			rotation = get_enemy_rotation(floorCast)
		else:
			rotation_degrees += 20 * WALKING_DIRECTION

func get_enemy_rotation(ray_cast: RayCast2D) -> float:
	var normal: Vector2 = ray_cast.get_collision_normal()
	return normal.rotated(deg2rad(90)).angle()
