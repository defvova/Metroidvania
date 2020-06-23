extends CenterContainer

func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_LoadButton_pressed() -> void:
	SoundFx.play("Click", 1, -10)
	SaveAndLoader.is_loading = true
	Music.list_stop()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/World/Level.tscn")
