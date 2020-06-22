extends Control

func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)

func _on_StartButton_pressed() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/World/Level.tscn")

func _on_LoadButton_pressed() -> void:
	SaveAndLoader.is_loading = true
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/World/Level.tscn")

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
