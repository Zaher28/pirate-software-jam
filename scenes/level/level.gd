extends Node3D

var time_alive: float = 0.0
var we_lost = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Increments time_alive by delta time if we're still alive
	if !we_lost:
		time_alive += delta

## Function that takes in a [param highscore] and saves it to a local file 
func save_highscore(highscore: float) -> void:
	# create a file to save the high score to
	var savefile := FileAccess.open("user://savefile.dat", FileAccess.WRITE)
	#save highscore
	if savefile:
		savefile.store_float(highscore)
	#If it can't open the file, show error string
	else:
		var err := FileAccess.get_open_error()
		push_warning("could not open file: ", error_string(err))
		
## Function that loads highscore, or 0 if no highscore found
func load_highscore(default: float = 0.0) -> float:
	# read from file that has high score
	var savefile := FileAccess.open("user://savefile.dat", FileAccess.READ)
	#return highscore
	if savefile:
		return savefile.get_float()
	else:
		return default

func _on_tower_death():
	#we lost
	we_lost = true
	#save highscore if its actually a highscore
	if load_highscore() < time_alive:
		save_highscore(time_alive)
		print("New Highscore: %.3f seconds" % [time_alive])
	else:
		print("Current Run: %.3f seconds" % [time_alive])
		print("Previous Highscore: %.3f seconds" % [load_highscore()])
	
