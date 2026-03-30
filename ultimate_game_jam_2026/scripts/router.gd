extends Area2D

@export var next_scene: String = "res://scenes/Levels/level_1.tscn"

func _on_body_entered(body):
	print("something entered: ", body.name)
	if body.is_in_group("Player"):
		print("player entered, changing scene to: ", next_scene)
		get_tree().change_scene_to_file(next_scene)
