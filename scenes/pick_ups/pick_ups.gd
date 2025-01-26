extends Node3D
class_name Pickups

signal get_pickup

var pickup: Pickups
var player: Node


var rotation_speed = .05
#For RNG
var rng = RandomNumberGenerator.new()

class GrowPickUp:
	extends Pickups
	
	var passive = true
	var grow_multiplier = Vector3(4,2,4)
	var grow_danger_speed = 5
	
	func _init(player: Node):
		self.player = player
	
	#When pickup is used
	func use():
		player.find_child("Animation").play("Grow")
		player.danger_speed = grow_danger_speed

	#When pickup time passes (I think only for passives?)
	func revert():
		player.find_child("Animation").play_backwards()
		player.danger_speed = 7

func _ready():
	rng.randomize()
	$Hitbox.body_entered.connect(give_pickup) #Connect signal to give_pickup
	player = get_tree().get_first_node_in_group("player")
	pickup = GrowPickUp.new(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Give it rotating effect
	rotate_y(rotation_speed + delta)
	
#Called when player runs over pickup, which then calls get_pickup on the player's side
func give_pickup(body: Node3D):
	if body.name == "Player":
		body.get_pickup(pickup)
		queue_free()
	
