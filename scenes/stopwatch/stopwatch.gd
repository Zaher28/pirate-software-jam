extends Node

@export var pickup: PackedScene
var time_alive: float = 0.0
var we_lost = false
var time_to_spawn_pickup = 30
#check for pickup spawn
var pickup_check = 0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(delta):
	#If we are still alive, increase stopwatch
	if !we_lost:
		time_alive += delta
	#Spawn a pickup every time_to_spawn_pickup seconds
	if int(time_alive) / time_to_spawn_pickup > pickup_check:
		pickup_check+=1
		spawn_pickup()

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
	get_tree().get_first_node_in_group("lose_screen").lose(time_alive)

func spawn_pickup():
	
	var power = pickup.instantiate()
	
	var random_spawn = Vector2(randf_range(-50.0, 50.0), randf_range(-50.0, 50.0))
	
	#dont spawn pickups inside the tower
	if abs(random_spawn.x) < 5.0:
		random_spawn.x = sign(random_spawn.x) * 5.0
	if abs(random_spawn.y) < 5.0:
		random_spawn.y = sign(random_spawn.y) * 5.0
	
	get_tree().current_scene.add_child(power)
	print(power.gun)
	power.global_position = Vector3(random_spawn.x, .5, random_spawn.y)
	
