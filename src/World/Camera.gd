extends Camera2D

var shake: float = 0

onready var timer = $Timer as Timer

func _ready() -> void:
# warning-ignore:return_value_discarded
	Events.connect("add_screenshake", self, "_on_Events_add_screenshake")

func _process(_delta: float) -> void:
	offset_h = rand_range(-shake, shake)
	offset_v = rand_range(-shake, shake)

func screenshake(amount: float, duration: float) -> void:
	shake = amount
	timer.wait_time = duration
	timer.start()

func _on_Timer_timeout() -> void:
	shake = 0

func _on_Events_add_screenshake(amount: float, duration: float) -> void:
	screenshake(amount, duration)
