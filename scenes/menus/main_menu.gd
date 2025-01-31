extends Control

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/control_scheme/control_scheme.tscn")

func _on_play_mouse_entered():
	$Title/GPUParticles2D.emitting = true

func _on_play_mouse_exited():
	$Title/GPUParticles2D.emitting = false
