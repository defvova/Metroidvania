extends Node

export (Array, AudioStream) var music_list = []

var music_list_index: int = 0

onready var musicPlayer := $AudioStreamPlayer as AudioStreamPlayer

#func _ready() -> void:
#	music_list.shuffle()

func list_play() -> void:
	assert(music_list.size() > 0)
	musicPlayer.stream = music_list[music_list_index]
	musicPlayer.play()
	music_list_index += 1

	if music_list_index == music_list.size():
		music_list_index = 0

func list_stop() -> void:
	musicPlayer.stop()

func _on_AudioStreamPlayer_finished() -> void:
	list_play()
