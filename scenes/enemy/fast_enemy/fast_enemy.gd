extends Enemy

func _ready() -> void:
	damage = 1
	ignore_player = false
	speed = 3
	health = 8
	$"Cone of Vision".body_entered.connect(is_in_on_sight)

func _physics_process(delta: float) -> void:
	if !is_instance_valid(self): return
	if !target: return
	
	if position.distance_to(target.position) < 5.5:  # Adjust threshold if needed
		# print(target.has_method("take_damage"))
		# print(target)
		if target.has_method("take_damage"):
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
	look_at(velocity) # Have enemy face towards their velocity (which would be towards the tower)
	move_and_slide()
