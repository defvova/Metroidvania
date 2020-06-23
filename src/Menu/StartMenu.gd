extends Control

func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)

func _on_StartButton_pressed() -> void:
	SoundFx.play("Click", 1, -10)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/World/Level.tscn")

func _on_LoadButton_pressed() -> void:
	SoundFx.play("Click", 1, -10)
	SaveAndLoader.is_loading = true
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/World/Level.tscn")

func _on_QuitButton_pressed() -> void:
	SoundFx.play("Click")
	get_tree().quit()
