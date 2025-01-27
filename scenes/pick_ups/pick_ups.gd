extends Node3D
class_name Pickups

signal get_pickup

var pickup: Pickups
var player: Node


var rotation_speed = .05
#For RNG
var rng = RandomNumberGenerator.new()

#Pickup that kills enemy on contact
class InstakillPickUp:
	extends Pickups
	
	var passive = true
	var instakill_danger_speed_change = 7
	var instakill_damage_multiplier = 999
	
	func _init(player: Node):
		self.player = player
	
	func use():
		player.danger_speed -= instakill_danger_speed_change
		player.damage_mult *= instakill_damage_multiplier
		
	func revert():
		player.danger_speed += instakill_danger_speed_change
		player.damage_mult /= instakill_damage_multiplier

#Pickup that makes you grow in size
class GrowPickUp:
	extends Pickups
	
	var passive = true
	
	func _init(player: Node):
		self.player = player
	
	#When pickup is used
	func use():
		player.find_child("Animation").play("Grow")

	#When pickup time passes (I think only for passives?)
	func revert():
		player.find_child("Animation").play_backwards("Grow")

func _ready():
	rng.randomize()
	$Hitbox.body_entered.connect(give_pickup) #Connect signal to give_pickup
	player = get_tree().get_first_node_in_group("player")
	var random_number = rng.randi_range(0, 1)
	
	if random_number == 0:
		pickup = GrowPickUp.new(player)
	else:
		pickup = InstakillPickUp.new(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Give it rotating effect
	rotate_y(rotation_speed + delta)
	
#Called when player runs over pickup, which then calls get_pickup on the player's side
func give_pickup(body: Node3D):
	if body.name == "Player":
		if body.has_pickup == false and body.using_pickup == false:
			body.get_pickup(pickup)
			print("Obtained %s" % [pickup.get_name()])
			queue_free()
	
