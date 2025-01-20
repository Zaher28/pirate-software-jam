extends Node3D

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


	
