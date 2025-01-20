extends Node3D

@export var max_health: int = 100  # Maximum health of the tower
var current_health: int

#death signal
signal death

func _ready():
	# Initialize current health
	current_health = max_health

# Function to deal damage to the tower
func take_damage(damage: int):
	if current_health > 0:
		current_health -= damage
		print("Tower health: ", current_health)
	
	if current_health <= 0:
		on_tower_destroyed()

# Handle tower destruction
func on_tower_destroyed():
	print("Tower destroyed!")
	# Add destruction effects or logic here
	death.emit()
	queue_free()
