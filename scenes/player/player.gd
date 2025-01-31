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
@export var min_turning_speed = 20
# The maximum drifting turn rate in degrees per second.
@export var max_drift_radius = 90
# How fast the turning radius increases while drifting in degrees per second.
@export var drift_efficiency = 2
# How much the drift boosts you when you finish (multiplier).
@export var drift_boost = 1.3
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
# What percentage of momentum the player keeps when bouncing off a wall
@export var wall_bounce_factor = 0.8

var has_pickup = false
var using_pickup = false
var pickup: Pickups
var pickup_time = 10
var turning_direction = 1
var course_correcting = false
var recovery_direction = 0
var recovery_camera = 1
var do_friction = true
var can_flip_camera = true
var bouncing = false

signal enemy_killed

func _ready():
	$PickupTimer.timeout.connect(_on_pickup_finished)

func _physics_process(delta: float) -> void:
	
	do_friction = true
	can_flip_camera = true
	
	# find the direction to the camera
	var dir_to_cam = global_position.direction_to($CameraPivot/Camera3D.global_position)
	# we only want the direction on the xz plane
	dir_to_cam.y = 0
	
	# move forward -> accelerate away from camera
	if Input.is_action_pressed("move_forward") and not Input.is_action_pressed("brake_drift"):
		velocity -= dir_to_cam * accel * delta
	# move backward -> accelerate toward camera
	if Input.is_action_pressed("move_back") and not Input.is_action_pressed("brake_drift"):
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
	if Input.is_action_pressed("brake_drift"):
		real_turning_speed += drift_efficiency * delta
		if real_turning_speed > max_drift_radius:
			real_turning_speed = max_drift_radius
	
	# ok so we need the drift to go in the direction we're pressing, so we'll do it here
	# instead of rotating the player, we'll rotate the velocity (this will totally work)
	# ^ this guy has no clue if it will work
	# turn left -> rotate left about y axis (or drift left)
	if Input.is_action_pressed("turn_left"):
		turning_direction = -1
		if Input.is_action_pressed("brake_drift"):
			do_friction = false
			can_flip_camera = false
			velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(real_turning_speed * delta))
			$Pivot.rotation_degrees.y += real_turning_speed * 0.5 * delta
			$CameraPivot.rotation_degrees.y += real_turning_speed * 0.15 * delta
			if abs($Pivot.rotation_degrees.x) < 20:
				$Pivot.rotation_degrees.x += real_turning_speed * 0.1 * delta * sign($CameraPivot/Camera3D.position.x)
		else:
			rotation_degrees.y += real_turning_speed * delta
			velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(real_turning_speed * delta))
	# turn right -> rotate right about y axis (or drift right)
	if Input.is_action_pressed("turn_right"):
		turning_direction = 1
		if Input.is_action_pressed("brake_drift"):
			do_friction = false
			can_flip_camera = false
			velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(-1 * real_turning_speed * delta))
			$Pivot.rotation_degrees.y -= real_turning_speed * 0.5 * delta
			$CameraPivot.rotation_degrees.y -= real_turning_speed * 0.15 * delta
			if abs($Pivot.rotation_degrees.x) < 20:
				$Pivot.rotation_degrees.x -= real_turning_speed * 0.1 * delta * sign($CameraPivot/Camera3D.position.x)
		else:
			rotation_degrees.y -= real_turning_speed * delta
			velocity = velocity.rotated(Vector3(0, 1, 0), deg_to_rad(-1 * real_turning_speed * delta))
	
	#ensure the collision box follows the pivot
	$CollisionShape3D.rotation_degrees.y = $Pivot.rotation_degrees.y
	
	if do_friction:
		var friction = 0.15 + 0.85 * (max_speed - velocity.length()) / max_speed
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)
	# otherwise, do the decreased drift friction
	else:
		var friction = 0.15
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)
	
	if Input.is_action_just_released("brake_drift"):
		if abs($CameraPivot.rotation_degrees.y - $Pivot.rotation_degrees.y) < abs($Pivot.rotation_degrees.y - $CameraPivot.rotation_degrees.y):
			recovery_direction = sign($CameraPivot.rotation_degrees.y - $Pivot.rotation_degrees.y)
		else:
			recovery_direction = sign($Pivot.rotation_degrees.y - $CameraPivot.rotation_degrees.y)
		recovery_camera = sign($CameraPivot/Camera3D.position.x)
		course_correcting = true
		# Apply drift boost if you drifted for long enough
		if abs($Pivot.rotation_degrees.x) > 3:
			velocity *= drift_boost
	
	# pivot back to the correct direction after drifting
	if course_correcting:
		if abs($CameraPivot.rotation_degrees.y - $Pivot.rotation_degrees.y) > 0.5:
			$CameraPivot.rotation_degrees.y += recovery_direction * abs($CameraPivot.rotation_degrees.y - $Pivot.rotation_degrees.y) * delta
			$Pivot.rotation_degrees.x -= recovery_direction * abs($Pivot.rotation_degrees.x) * delta * recovery_camera
		else:
			$CameraPivot.rotation_degrees.y = $Pivot.rotation_degrees.y
			$Pivot.rotation_degrees.x = 0
			course_correcting = false
	
	# pivot back to the correct direction after bouncing
	if bouncing:
		pass
	
	# show the wheel rotating in the direction of the velocity
	if velocity != Vector3.ZERO and not Input.is_action_pressed("brake_drift"):
		if sign(velocity.normalized().x) == sign(dir_to_cam.normalized().x) and sign(velocity.normalized().z) == sign(dir_to_cam.normalized().z):
			$Pivot.rotation_degrees.z -= velocity.length()
		elif velocity.x != 0 or velocity.z != 0:
			$Pivot.rotation_degrees.z += velocity.length()
	
	# manipulate the hitbox based on magnitude/direction of velocity
	#if dir_to_cam.angle_to(velocity.normalized()) > 3: # if moving away, angle will be close to pi radians, otherwise close to 0
		#if sign($Hitbox/CollisionShape3D.position.x) == sign($Camera3D.position.x):
			#$Hitbox/CollisionShape3D.position.x = -1 * sign($Camera3D.position.x)
	#else:
		#if sign($Hitbox/CollisionShape3D.position.x) != sign($Camera3D.position.x):
			#$Hitbox/CollisionShape3D.position.x = sign($Camera3D.position.x)
			
	# ok now completely redo all that but better (and in one line!)
	$Hitbox.rotation_degrees.y = rad_to_deg(turning_direction * dir_to_cam.angle_to(velocity.normalized()) - PI) + $CameraPivot.rotation_degrees.y
	
	$Hitbox/CollisionShape3D.shape.size.x = (base_hitbox_width + (hitbox_scale_value * velocity.length())) / scale.x
	
	# button to switch side of camera
	if Input.is_action_just_pressed("switch_camera") and can_flip_camera:
		$CameraPivot/Camera3D.position.x *= -1
		$Hitbox/CollisionShape3D.position.x *= -1
		$CameraPivot/Camera3D.rotation_degrees.y *= -1
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
	print(body)
	if velocity.length() > danger_speed and body.is_in_group("enemy"):
		if body.health > damage_mult * velocity.length():
			body.velocity = velocity * knockback_factor
			velocity *= -1 * knockback_factor
		else:
			enemy_killed.emit()
		body.hurt(damage_mult * velocity.length())
	elif body.is_in_group("wall"):
		velocity *= -1 * wall_bounce_factor
		bouncing = true

#When pickup time passes or when pickup uses depleted
func _on_pickup_finished():
	using_pickup = false
	pickup.revert()
	pickup.queue_free()
