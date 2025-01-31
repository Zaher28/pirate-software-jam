extends Node3D

@export var spawner_scene: PackedScene # Drag and drop the enemy spawner scene here
@export var tower_position: Vector3 # Position of the tower
@export var ring_radii: Array[float] = [24.0, 36.0, 52.0] # Radii of the rings (inner to outer)
@export var spawners_per_ring: Array[int] = [4, 8, 12] # Number of spawners per ring (inner to outer)
@export var ring_thickness: float = 12.0 # Thickness of the ring zones
@export var spawn_duration: float = 120.0 # Total duration to add all spawners
@export var initial_delay: float = 4.0 # Starting delay between spawns
@export var exponential_decay_rate: float = 0.01 # Controls delay reduction over time

# Internal variables
var spawner_queue: Array = [] # Queue to store all spawner positions
var elapsed_time: float = 0.0 # Tracks time passed
var next_spawn_time: float = 3.0 # When the next spawner should spawn

## Ready function to prepare spawners at the start
func _ready() -> void:
	prepare_spawners()
	
## Function to gradually spawn spawners
func _process(delta: float) -> void:
	elapsed_time += delta
	if spawner_queue.size() == 0:
		prepare_spawners()

	# Calculate normalized time (0 to 1)
	var normalized_time = clamp(elapsed_time / spawn_duration, 0.0, 1.0)
	var curve_value = difficulty_curve(normalized_time)

	# Calculate spawn delay using exponential decay
	var current_delay = 4 + initial_delay * exp(-exponential_decay_rate * elapsed_time)

	# Check if it's time to spawn the next spawner
	if elapsed_time >= next_spawn_time:
		if spawner_queue.size() > 0:
			var position = spawner_queue.pop_front()
			spawn_spawner(position)

		# Update next spawn time based on current delay
		next_spawn_time = elapsed_time + current_delay

## Function to prepare all spawner positions in advance
func prepare_spawners() -> void:
	for ring_index in range(ring_radii.size()):
		var base_radius = ring_radii[ring_index] # Base radius for the current ring
		var spawner_count = spawners_per_ring[ring_index] # Number of spawners for the ring

		for i in range(spawner_count):
			# Randomize the angle
			var angle = randf() * 2.0 * PI
			# Randomize the distance within the ring's thickness
			var random_radius = base_radius + randf_range(-ring_thickness / 2.0, ring_thickness / 2.0)
			
			# Compute the position
			var x = random_radius * cos(angle)
			var z = random_radius * sin(angle)
			var position = tower_position + Vector3(x, 0, z)
			
			# Add position to the queue
			spawner_queue.append(position)

## Function to spawn a single spawner
func spawn_spawner(position: Vector3) -> void:
	var spawner = spawner_scene.instantiate()
	add_child(spawner)
	spawner.global_transform.origin = position
	
## Function to calculate the difficulty curve
func difficulty_curve(t: float) -> float:
	# Ease-in-out curve (normalized t from 0 to 1)
	return 3 * t * t - 2 * t * t * t
	
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
