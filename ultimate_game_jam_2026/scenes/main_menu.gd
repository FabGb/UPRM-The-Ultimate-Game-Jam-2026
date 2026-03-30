extends Control

const levelScene = "res://scenes/Levels/Tutorial.tscn"
var change_scene = preload(levelScene)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(change_scene)
	pass # Replace with function body.
