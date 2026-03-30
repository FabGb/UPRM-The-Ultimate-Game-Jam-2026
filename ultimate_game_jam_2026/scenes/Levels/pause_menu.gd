extends Node

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
