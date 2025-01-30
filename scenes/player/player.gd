extends CharacterBody3D

# How fast the player accelerates in meters per second squared.
@export var accel = 12
# The maximum speed the player can be traveling in meters per second.
@export var max_speed = 30
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# The base turning speed in degrees per second.
@export var turning_speed = 80
# The minimum turning speed in degrees per second.
@export var min_turning_speed = 6
# The minimum speed the wheel must be moving to deal damage.
@export var danger_speed = 7
# The amount of damage done per m/s of speed.
@export var damage_mult = 1
# Base hitbox width.
@export var base_hitbox_width = 1.25
# How much to scale the hitbox with speed, to ensure damage check occurs before collision.
@export var hitbox_scale_value = 0.1
# How much to knock back the player and enemy when they collide and the enemy doesn't die (percentage of speed).
@export var knockback_factor = 1.2

var has_pickup = false
var using_pickup = false
var pickup: Pickups
var pickup_time = 10

func _ready():
	$PickupTimer.timeout.connect(_on_pickup_finished)

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
	
	# max speed check
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	# determine turning speed based on velocity
	var real_turning_speed = turning_speed
	if velocity != Vector3.ZERO:
		real_turning_speed *= (max_speed - abs(velocity.length())) / max_speed
	if real_turning_speed < min_turning_speed:
		real_turning_speed = min_turning_speed
	
	# turn left -> rotate left about y axis
	if Input.is_action_pressed("turn_left"):
		rotation_degrees.y += real_turning_speed * delta
		velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(real_turning_speed * delta))
	# turn right -> rotate right about y axis
	if Input.is_action_pressed("turn_right"):
		rotation_degrees.y -= real_turning_speed * delta
		velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(-1 * real_turning_speed * delta))
	
	var friction = 0.15 + 0.85 * (max_speed - velocity.length()) / max_speed
	
	velocity = velocity.lerp(Vector3.ZERO, friction * delta)
	
	# show the wheel rotating in the direction of the velocity
	if velocity != Vector3.ZERO:
		if sign(velocity.normalized().x) == sign(dir_to_cam.normalized().x) and sign(velocity.normalized().z) == sign(dir_to_cam.normalized().z):
			$Pivot.rotation_degrees.z -= velocity.length()
		elif velocity.x != 0 or velocity.z != 0:
			$Pivot.rotation_degrees.z += velocity.length()
	
	# manipulate the hitbox based on magnitude/direction of velocity
	if dir_to_cam.angle_to(velocity.normalized()) > 3: # if moving away, angle will be close to pi radians, otherwise close to 0
		if sign($Hitbox/CollisionShape3D.position.x) == sign($Camera3D.position.x):
			$Hitbox/CollisionShape3D.position.x = -1 * sign($Camera3D.position.x)
	else:
		if sign($Hitbox/CollisionShape3D.position.x) != sign($Camera3D.position.x):
			$Hitbox/CollisionShape3D.position.x = sign($Camera3D.position.x)
	$Hitbox/CollisionShape3D.shape.size.x = (base_hitbox_width + (hitbox_scale_value * velocity.length())) / scale.x
	
	# button to switch side of camera
	if Input.is_action_just_pressed("switch_camera"):
		$Camera3D.position.x *= -1
		$Camera3D.rotation_degrees.y *= -1
		if get_tree().get_first_node_in_group("shotgun_cone"):
			get_tree().get_first_node_in_group("shotgun_cone").rotation_degrees.y += 180
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor
		velocity.y = velocity.y - (fall_acceleration * delta)
	
	# button to use pickup
	if Input.is_action_just_pressed("use_pickup"):
		if has_pickup:
			use_pickup()
	
	move_and_slide()

#Logic for giving player a pickup (random weighted number?)
func get_pickup(pickup: Pickups):
	if !has_pickup:
		print("Got a pickup!")
		has_pickup = true
		self.pickup = pickup
	else:
		pass

#Logic for using pickup
func use_pickup():
	#If a pickup isnt currently happening, use pickup
	if !using_pickup:
		pickup.use()
		#If the pickup is a passive one, start pickup timer (default 10s rn)
		if pickup.passive == true:
			using_pickup = true
			$PickupTimer.start(pickup_time)
			has_pickup = false
			print("Used a pickup!")
		else:
			pickup.uses -= 1
			if pickup.uses <= 0:
				_on_pickup_finished()
				has_pickup = false
	else:
		print("Currently using a pickup!")
		pass

# Logic for damaging enemies
func _on_hitbox_body_entered(body):
	if velocity.length() > danger_speed and body.is_in_group("enemy"):
		if body.health > damage_mult * velocity.length():
			body.velocity = velocity * knockback_factor
			velocity *= -1 * knockback_factor
		body.hurt(damage_mult * velocity.length())
		print(damage_mult * velocity.length())

#When pickup time passes or when pickup uses depleted
func _on_pickup_finished():
	using_pickup = false
	pickup.revert()
	pickup.queue_free()
