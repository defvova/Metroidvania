extends Node

var sounds_path: String = "res://assets/Music and Sounds/"

var sounds: Dictionary = {
	"Bullet": 	 load(sounds_path + "Bullet.wav"),
	"Click": 	 load(sounds_path + "Click.wav"),
	"EnemyDie":  load(sounds_path + "EnemyDie.wav"),
	"Explosion": load(sounds_path + "Explosion.wav"),
	"Hurt": 	 load(sounds_path + "Hurt.wav"),
	"Jump": 	 load(sounds_path + "Jump.wav"),
	"Pause": 	 load(sounds_path + "Pause.wav"),
	"Powerup": 	 load(sounds_path + "Powerup.wav"),
	"Step": 	 load(sounds_path + "Step.wav"),
	"Unpause": 	 load(sounds_path + "Unpause.wav")
}

onready var sound_players: Array = get_children()

func play(sound_name: String, pitch_scale: float = 1, volume_db: int = 0) -> void:
	for soundPlayer in sound_players:
		if !soundPlayer.playing:
			soundPlayer.pitch_scale = pitch_scale
			soundPlayer.volume_db = volume_db
			soundPlayer.stream = sounds[sound_name]
			soundPlayer.play()
			return
	print("Too many sounds playing at once")
