extends Node

var time_alive: float = 0.0
var we_lost = false

func _process(delta):
	#If we are still alive, increase stopwatch
	if !we_lost:
		time_alive += delta

func time_to_string(time: float) -> String:
	#Split the time into its components (seconds, miliseconds)
	var time_vector = Vector2(time, fmod(time, 1) * 1000)
	#format time into string
	var fstring = "%02d.%03d"
	var time_string = fstring % [time_vector.x, time_vector.y]
	return time_string
	
func _on_tower_death():
	#we lost
	we_lost = true
	#save highscore if its actually a highscore
	if get_parent().load_highscore() < time_alive:
		get_parent().save_highscore(time_alive)
		print("New Highscore: %.3f seconds" % [time_alive])
	else:
		print("Current Run: %.3f seconds" % [time_alive])
		print("Previous Highscore: %.3f seconds" % [get_parent().load_highscore()])
