extends AudioStreamPlayer2D

@onready var music_player = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	music_player.stream = preload("res://assets/Sounds/coolkid - double.mp3")
	music_player.stream.loop = true
	music_player.play()
