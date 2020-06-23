extends Node

var Debug = preload("res://src/DebugOverlay.tscn")

onready var currentLevel := $Level00 as Node

var MainInstances = ResourceLoader.MainInstances

func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)
	Music.list_play()

	if SaveAndLoader.is_loading:
		SaveAndLoader.load_game()
		SaveAndLoader.is_loading = false

	MainInstances.Player.connect("hit_door", self, "_on_Player_hit_door")

#	var debug = Debug.instance()
#
#	debug.add_stats("Player position", $Player, "position", false)
#	debug.add_stats("Player motion", $Player, "motion", false)
#
#	get_parent().call_deferred("add_child", debug)

func change_level(door: Area2D) -> void:
	var offset: Vector2 = currentLevel.position
	currentLevel.queue_free()

	var NewLevel: Resource = load(door.new_level_path)
	var newLevel: Node2D = NewLevel.instance()

	add_child(newLevel)
	var newDoor: Area2D = get_door_with_connection(door, door.connection)

	var exit_position: Vector2 = newDoor.position - offset
	newLevel.position = door.position - exit_position

func get_door_with_connection(notDoor: Area2D, connection: Resource) -> Area2D:
	var doors: Array = get_tree().get_nodes_in_group("Door")

	for door in doors:
		if door.connection == connection && door != notDoor:
			return door

	return null

func _on_Player_hit_door(door: Area2D) -> void:
	call_deferred("change_level", door)

func _on_Player_player_died() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().change_scene("res://src/Menu/GameOverMenu.tscn")
