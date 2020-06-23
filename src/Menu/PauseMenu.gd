extends ColorRect

var paused: bool = false setget set_paused

func set_paused(value: bool) -> void:
	paused = value
	get_tree().paused = paused
	visible = paused
	if paused:
		SoundFx.play("Pause", 1, -10)
	else:
		SoundFx.play("Unpause", 1, -10)

func _process(_delta: float) -> void:
	var is_Player_alive = get_tree().get_nodes_in_group("Player").size() > 0
	if Input.is_action_just_pressed("Pause"):
		self.paused = !paused

func _on_ResumeButton_pressed() -> void:
	SoundFx.play("Click", 1, -10)
	self.paused = false

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
