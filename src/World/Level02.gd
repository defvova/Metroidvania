extends "res://src/World/BaseLevel.gd"

const PLAYER_BIT: int = 0

onready var bossEnemy := $BossEnemy as KinematicBody2D
onready var blockDoor := $BlockDoor as TileMap

func set_block_door(active: bool) -> void:
	blockDoor.visible = active
	blockDoor.set_collision_mask_bit(PLAYER_BIT, active)

func _on_Trigger_area_triggered() -> void:
	set_block_door(true)

func _on_BossEnemy_died() -> void:
	set_block_door(false)
