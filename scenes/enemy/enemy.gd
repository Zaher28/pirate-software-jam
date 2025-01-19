extends RigidBody3D

@export var target: Node3D
@export var speed: float = 10

func _process(delta: float) -> void:
	if target:
		var next_position = position.move_toward(target.position, speed)
		position.x = next_position.x
		position.z = next_position.z
