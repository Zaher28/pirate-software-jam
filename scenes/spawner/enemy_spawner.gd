extends Node3D

# Variables for spawning
@export var enemy_scene: PackedScene
@export var num_time_interval: Vector2 = Vector2(2.0, 5.0) # Min and max interval for spawning
@export var spawn_radius: float = 5.0
@export var greedy_algorithm: bool = false
@export var health: int

const _BIG_CRED: int = 5
const _FAST_CRED: int = 3
const _NORM_CRED: int = 1

# Internal variables
var timer: Timer
var tower

func _ready():
	# Create and configure a timer for spawning
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = randf_range(num_time_interval.x, num_time_interval.y)
	timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(timer)
	timer.start()
	tower = get_tree().get_first_node_in_group("tower")

func _on_spawn_timer_timeout():
	var enemy_credit = int(randi_range(1, 12))
	var num_big = 0
	var num_fast = 0
	var num_norm = 0
	
	# If greedy_algorithm is set, spawner will create more than 1 big enemies if the credits allow for it.
	if greedy_algorithm:
		num_big = enemy_credit / _BIG_CRED
		enemy_credit = enemy_credit % _BIG_CRED
	else:
		if enemy_credit > _BIG_CRED:
			num_big = 1
			enemy_credit -= _BIG_CRED

	num_fast = enemy_credit / _FAST_CRED
	enemy_credit = enemy_credit % _BIG_CRED
	num_norm = enemy_credit / _NORM_CRED

	# Spawn the enemies
	if num_big > 0:
		for i in range(num_big):
			spawn_enemy(preload("res://scenes/enemy/big_enemy/big_enemy.tscn"))
	if num_fast > 0:
		for i in range(num_fast):
			spawn_enemy(preload("res://scenes/enemy/fast_enemy/fast_enemy.tscn"))
	if num_norm > 0:
		for i in range(num_norm):
			spawn_enemy(preload("res://scenes/enemy/enemy.tscn"))

	# Reset the timer with a new random interval
	timer.wait_time = randf_range(num_time_interval.x, num_time_interval.y)
	timer.start()

func spawn_enemy(scene: PackedScene):
	# Instance the enemy
	var enemy_instance = scene.instantiate()

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

func hurt(damage):
	health -= damage
	if health <= 0:
		queue_free()
