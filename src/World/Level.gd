extends Node

var Debug = preload("res://src/DebugOverlay.tscn")

onready var currentLevel := $Level00 as Node

func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)

	var debug = Debug.instance()

	debug.add_stats("Player position", $Player, "position", false)
	debug.add_stats("Player motion", $Player, "motion", false)

	get_parent().call_deferred("add_child", debug)
