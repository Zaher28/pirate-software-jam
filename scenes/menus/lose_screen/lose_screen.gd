extends CanvasLayer

@export var you_lose: Label
@export var current_highscore: Label
@export var time_survived: Label

func lose(time_alive: float):
	visible = true
	if get_parent().load_highscore() < time_alive:
		get_parent().save_highscore(time_alive)
		print("New Highscore: %.3f seconds" % [time_alive])
		current_highscore.text = "Current Highscore %.3f" % time_alive
		time_survived.text = "Time Survived %.3f" % time_alive
		$HighscoreAnimation.play("new_highscore")
	else:
		print("Current Run: %.3f seconds" % [time_alive])
		print("Previous Highscore: %.3f seconds" % [get_parent().load_highscore()])
		current_highscore.text = "Current Highscore %.3f" % get_parent().load_highscore()
		time_survived.text = "Time Survived %.3f" % time_alive
	$LoseAnimation.play("lose")

func _on_retry_pressed():
	get_tree().reload_current_scene()
