extends CharacterBody3D
class_name Enemy

@export var target: Node3D
@export var health: int
@export var speed: float
@export var damage: int # Damage dealt to the tower
@export var ignore_player: bool # Enemy will not avoid player

enum STATE {
	NEUTRAL, # Move towards center, not in danger
	FLEEING # Sees player character, flee for 2 seconds
}

var flee_from_target: Node3D = null
var target_velocity = Vector3.ZERO
var curr_state = STATE.NEUTRAL

func _ready() -> void:
	damage = 1
	ignore_player = false
	speed = 2
	health = 10
	$"Cone of Vision".body_entered.connect(is_in_on_sight) # Connects signal to
	$"Cone of Vision".body_exited.connect(is_out_of_sight) # Connects signal to 

func _physics_process(delta: float) -> void:
	if !is_instance_valid(self): return
	if !target: return
	
	if position.distance_to(target.position) < 5.5:  # Adjust threshold if needed
		print(target.has_method("take_damage"))
		print(target)
		if target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()  # Destroy the enemy after dealing damage
	
	if curr_state == STATE.NEUTRAL:
		var direction = (target.position - position).normalized() * speed
		target_velocity.x = direction.x
		target_velocity.z = direction.z
		velocity = target_velocity
	elif curr_state == STATE.FLEEING:
		var desired_velocity = flee_from_target.global_position.direction_to(global_position).normalized() * speed
		#var desired_velocity = (position - flee_from_target.position).normalized() * max_velocity
		var steering_velocity = (desired_velocity - velocity).limit_length(3)
		target_velocity.x = steering_velocity.x
		target_velocity.z = steering_velocity.z
		velocity = target_velocity
	move_and_slide()

func is_in_on_sight(body: Node3D) -> void:
	if ignore_player: return
	if body.name == "Player":
		curr_state = STATE.FLEEING
		flee_from_target = body
		
func is_out_of_sight(body: Node3D) -> void:
	if body.name == "Player":
		curr_state = STATE.NEUTRAL
		flee_from_target = null

#@export var target: Node3D
#@export var speed: float = 1
#@export var damage: int = 5  # Damage dealt to the tower
#
#var target_velocity = Vector3.ZERO
#
#func _physics_process(delta: float) -> void:
	#if !is_instance_valid(self): return
	#if !target: return
#
	#var direction = target.position - position
	#target_velocity.x = direction.x * speed
	#target_velocity.z = direction.z * speed
	#
	#velocity = target_velocity
	#move_and_slide()
#
	## Check if close enough to deal damage
	#if position.distance_to(target.position) < 5.5:  # Adjust threshold if needed
		#print(target.has_method("take_damage"))
		#print(target)
		#if target.has_method("take_damage"):
			#target.take_damage(damage)
		#queue_free()  # Destroy the enemy after dealing damage
