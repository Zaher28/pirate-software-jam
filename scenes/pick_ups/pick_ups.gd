extends Node3D

signal get_pickup

var rotation_speed = .05

func _ready():
	$Hitbox.body_entered.connect(give_pickup) #Connect signal to give_pickup

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Give it rotating effect
	rotate_y(rotation_speed + delta)
	
#Called when player runs over pickup, which then calls get_pickup on the player's side
func give_pickup(body: Node3D):
	if body.name == "Player":
		body.get_pickup()
		queue_free()
	
