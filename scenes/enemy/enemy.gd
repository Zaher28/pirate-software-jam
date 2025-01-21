extends CharacterBody3D
class_name Enemy

@export var target: Node3D
@export var health: int
@export var speed: float
@export var damage: int # Damage dealt to the tower
@export var ignore_player: bool # Enemy will not avoid player

var target_velocity = Vector3.ZERO

func _ready() -> void:
	damage = 1
	ignore_player = false
	speed = 0.2
	health = 10
	$Area3D.body_entered.connect(is_in_on_sight)

func _physics_process(delta: float) -> void:
	if !is_instance_valid(self): return
	if !target: return
	
	var direction = target.position - position
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	velocity = target_velocity
	move_and_slide()

func is_in_on_sight(body: Node3D) -> void:
	if ignore_player: return
	if body.name == "player":
		var player_position = body.position - global_position
		
	

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
