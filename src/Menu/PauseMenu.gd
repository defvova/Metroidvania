extends ColorRect

var paused: bool = false setget set_paused

func set_paused(value: bool) -> void:
	paused = value
	get_tree().paused = paused
	visible = paused

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		self.paused = !paused

func _on_ResumeButton_pressed() -> void:
	self.paused = false

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
