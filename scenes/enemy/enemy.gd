extends CharacterBody3D

@export var target: Node3D
@export var speed: float = 1

var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if target:
		var direction = target.position - position
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
		
		velocity = target_velocity
		move_and_slide()
