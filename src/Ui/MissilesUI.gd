extends HBoxContainer

var PlayerStats = ResourceLoader.PlayerStats

onready var label := $Label as Label

func _ready() -> void:
	PlayerStats.connect("player_missiles_changed", self, "_on_player_missiles_changed")

func _on_player_missiles_changed(amount: int) -> void:
	label.text = str(amount)
