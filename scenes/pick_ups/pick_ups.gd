extends Node3D
class_name Pickups

@export var gun: PackedScene

var pickup: Pickups
var player: Node

var rotation_speed = .05
#For RNG
var rng = RandomNumberGenerator.new()

class ShotgunPickUp:
	extends Pickups
	
	var _name = "Shotgun"
	
	var passive = false
	var uses = 10
	var enemies_in_area := {} 
	var shotgun_damage = 25
	var gun_cone
	
	func _init(player: Node, gun: PackedScene):
		self.player = player
		self.gun = gun
		
	func setup():
		gun_cone = gun.instantiate()
		gun_cone.body_entered.connect(_on_shotgun_cone_entered)
		gun_cone.body_exited.connect(_on_shotgun_cone_exited)
		# SORRY! but the player won't see this stupid ugly code so it's ok
		if sign(self.player.get_node("CameraPivot").get_node("Camera3D").position.x) < 0:
			gun_cone.rotation_degrees.y += 180
		self.player.get_node("CameraPivot").add_child(gun_cone)
		
	func use():
		print("Shoot!")
		for enemy in enemies_in_area:
			enemy.hurt(shotgun_damage)
			
	func _on_shotgun_cone_entered(body: Node3D):
		if body.is_in_group("enemy"):
			enemies_in_area[body] = null

	func _on_shotgun_cone_exited(body: Node3D):
		if body.is_in_group("enemy"):
			enemies_in_area.erase(body)
	
	func revert():
		print("Gun no more")
		self.player.remove_child(gun_cone)
		gun_cone.queue_free()
			
#Pickup that kills enemy on contact
class InstakillPickUp:
	extends Pickups
	
	var _name = "Instakill"
	
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
	
	var _name = "Grow"
	
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
	
	var random_number = rng.randi_range(0, 2)
	
	if random_number == 0:
		pickup = GrowPickUp.new(player)
	elif random_number == 1:
		pickup = ShotgunPickUp.new(player, gun)
	elif random_number == 2:
		pickup = InstakillPickUp.new(player)
		
func setup():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Give it rotating effect
	rotate_y(rotation_speed + delta)
	
#Called when player runs over pickup, which then calls get_pickup on the player's side
func give_pickup(body: Node3D):
	if body.name == "Player":
		if body.has_pickup == false and body.using_pickup == false:
			pickup.setup()
			body.get_pickup(pickup)
			print("Obtained %s" % [pickup._name])
			queue_free()
	
