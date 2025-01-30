extends CharacterBody3D
class_name Enemy

@export var target: Node3D
@export var health: int
@export var speed: float
@export var damage: int # Damage dealt to the tower
@export var knockback_time: float # How long the enemy gets knocked back
@export var ignore_player: bool # Enemy will not avoid player

enum STATE {
	NEUTRAL, # Move towards center, not in danger
	FLEEING, # Sees player character, steer away from it
	KNOCKBACK, # Just got hit (and didn't die)
}

var flee_range = 20 # Higher values cause enemy flee steering force to increase, and vice versa
var flee_from_target: Node3D = null
var knockback_timer = 0.0
var curr_state = STATE.NEUTRAL
var controller

func _ready() -> void:
	controller = get_tree().get_first_node_in_group("game_controller")
	damage = controller.enemy_stat_scalar_fin_int(1)
	ignore_player = false
	speed = 1.0 * controller.enemy_stat_scalar_float()
	health = controller.enemy_stat_scalar_fin_int(9)
	$"Cone of Vision".body_entered.connect(is_in_on_sight) # Connects signal to

func _physics_process(delta: float) -> void:
	if !is_instance_valid(self): return
	if !target: return
	
	if position.distance_to(target.position) < 5.5:  # Adjust threshold if needed
		# print(target.has_method("take_damage"))
		# print(target)
		if target.has_method("take_damage"):
			print("Damage given: ", damage)
			target.take_damage(damage)
		queue_free()  # Destroy the enemy after dealing damage
	
	var seek_target_velocity = target.global_position - global_position # Calculate direction towards tower/necromancer
	seek_target_velocity.y = 0 # Eliminate Y factor from future calculations, theres probably a better way to do this
	
	if curr_state == STATE.NEUTRAL:
		var seek_target_steer = (seek_target_velocity - velocity) * 0.05 # Adjust scalar as needed
		seek_target_steer.y = 0
		
		velocity = (velocity + seek_target_steer).normalized() * speed
	elif curr_state == STATE.FLEEING:
		var distance_from_player = global_position.distance_to(flee_from_target.global_position) # Obtain distance between player and enemy
		
		var avoid_player_velocity = global_position - flee_from_target.global_position # Calculate vector pointing away from player
		avoid_player_velocity.y = 0
		if distance_from_player < flee_range:
			# The further the enemy is from the player, the more it will steer towards tower
			var seek_target_steer = (seek_target_velocity - velocity) * (distance_from_player / flee_range) 
			seek_target_steer.y = 0
			
			# The closer the enemy is to the player, the more it will steer away from player
			var avoid_player_steer = (velocity + avoid_player_velocity) * (1 - (distance_from_player / flee_range)) 
			avoid_player_steer.y = 0

			velocity = (velocity + avoid_player_steer + seek_target_steer).normalized() * speed
		else: # If player is now outside of the flee_range, revert back to normal behavior until end of Timer
			var seek_target_steer = (seek_target_velocity - velocity)
			seek_target_steer.y = 0
			velocity = (velocity + seek_target_steer).normalized() * speed
	elif curr_state == STATE.KNOCKBACK:
		knockback_timer += delta
		if knockback_timer >= knockback_time:
			knockback_timer = 0.0
			curr_state = STATE.NEUTRAL
	look_at(velocity) # Have enemy face towards their velocity (which would be towards the tower)
	move_and_slide()

func is_in_on_sight(body: Node3D) -> void:
	if ignore_player: return
	if body.name == "Player":
		curr_state = STATE.FLEEING
		flee_from_target = body
		$Timer.start()

func hurt(damage):
	health -= damage
	curr_state = STATE.KNOCKBACK
	if health <= 0:
		queue_free()

# After timer expires, set the current state back to neutral, and remove target from target tracking
func _on_timer_timeout() -> void:
	curr_state = STATE.NEUTRAL
	flee_from_target = null
