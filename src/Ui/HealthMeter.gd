extends Control

const HEALTH_PIXEL_SIZE: int = 5
const HEALTH_PIXEL_BORDER_SIZE: int = 1

var PlayerStats = ResourceLoader.PlayerStats

onready var full = $Full as TextureRect

func _ready() -> void:
	PlayerStats.connect("player_health_changed", self, "_on_player_health_changed")

func _on_player_health_changed(value: int) -> void:
	full.rect_size.x = value * HEALTH_PIXEL_SIZE + HEALTH_PIXEL_BORDER_SIZE
