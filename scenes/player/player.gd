extends CharacterBody3D

# I copied this scripts code from 
# https://docs.godotengine.org/en/stable/getting_started/first_3d_game/03.player_movement_code.html#
# for reference

# How fast the player accelerates in meters per second squared.
@export var accel = 10
# The maximum speed the player can be traveling in meters per second.
@export var max_speed = 30
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# The base turning speed in degrees per second.
@export var turning_speed = 60

func _physics_process(delta: float) -> void:
	
	# find the direction to the camera
	var dir_to_cam = global_position.direction_to($Camera3D.global_position)
	# we only want the direction on the xz plane
	dir_to_cam.y = 0
	
	# move forward -> accelerate away from camera
	if Input.is_action_pressed("move_forward"):
		velocity -= dir_to_cam * accel * delta
	# move backward -> accelerate toward camera
	if Input.is_action_pressed("move_back"):
		velocity += dir_to_cam * accel * delta
	
	# check which way the player is moving relative to the camera
	var direction = 0
	if velocity != Vector3.ZERO:
		if (velocity.normalized() - dir_to_cam).length() < 1:
			direction = -1 # the player is moving toward the camera
		else:
			direction = 1 # the player is moving away from the camera
	
	# turn left -> rotate left about y axis
	if Input.is_action_pressed("turn_left"):
		rotation_degrees.y += turning_speed * delta
		velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(turning_speed * delta))
	# turn right -> rotate right about y axis
	if Input.is_action_pressed("turn_right"):
		rotation_degrees.y -= turning_speed * delta
		velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(-1 * turning_speed * delta))
	
	# button to switch side of camera
	
	## Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor
		velocity.y = velocity.y - (fall_acceleration * delta)
	
	move_and_slide()
