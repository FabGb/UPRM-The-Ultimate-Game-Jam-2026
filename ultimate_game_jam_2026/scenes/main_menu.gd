extends Control

@export_file('*.tscn') var change_scene

func _on_quit_btn_pressed() -> void:
	get_tree().quit()


func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file(change_scene)
