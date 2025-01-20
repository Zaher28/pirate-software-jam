extends Node3D

# Variables for spawning
@export var enemy_scene: PackedScene
@export var spawn_range: Vector2 = Vector2(1, 5) # A to B (min and max number of enemies)
@export var interval_range: Vector2 = Vector2(2.0, 5.0) # Min and max interval for spawning
@export var spawn_radius: float = 5.0

# Internal variables
var timer: Timer
var tower

func _ready():
	# Create and configure a timer for spawning
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = randf_range(interval_range.x, interval_range.y)
	timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(timer)
	timer.start()
	tower = get_tree().get_first_node_in_group("tower")

func _on_spawn_timer_timeout():
	# Determine how many enemies to spawn
	var num_enemies = int(randi_range(spawn_range.x, spawn_range.y))

	# Spawn the enemies
	for i in range(num_enemies):
		spawn_enemy()

	# Reset the timer with a new random interval
	timer.wait_time = randf_range(interval_range.x, interval_range.y)
	timer.start()

func spawn_enemy():
	if enemy_scene:
		# Instance the enemy
		var enemy_instance = enemy_scene.instantiate()

		# Spawn the enemy at a random offset
		var random_offset = Vector3(
			randf_range(-spawn_radius, spawn_radius),
			0,
			randf_range(-spawn_radius, spawn_radius)
		)
		
		# Instance the tower and assign it as the enemy's target
		enemy_instance.target = tower

		# Add the enemy and tower to the current scene
		get_tree().current_scene.add_child(enemy_instance) # Add the enemy to the scene
		enemy_instance.global_position = self.global_transform.origin + random_offset

# Helper function for random float range
func randf_range(min: float, max: float) -> float:
	return randf() * (max - min) + min

# Helper function for random integer range
func randi_range(min: int, max: int) -> int:
	return int(randf_range(float(min), float(max)) + 0.5)
