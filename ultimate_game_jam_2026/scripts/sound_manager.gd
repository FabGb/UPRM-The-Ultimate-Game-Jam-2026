extends Node


func play_sound_global(stream: AudioStream, position: Vector2):
	var player = AudioStreamPlayer2D.new()
	player.stream = stream
	
	get_tree().current_scene.add_child(player)
	player.global_position = position
	
	player.play()
	player.finished.connect(player.queue_free)