extends Node3D

# The HUD Node
@export var hud: CanvasLayer
# Number of enemies killed to unlock each upgrade
@export var update1: int
@export var update2: int
@export var update3: int
@export var update4: int
@export var update5: int
@export var update6: int
@export var update7: int
@export var update8: int

# no one needs to see this
@onready var player = get_parent()

var enemies_killed = 0

func _on_enemy_killed():
	enemies_killed += 1
	match enemies_killed:
		update1:
			player.damage_mult = 1.2
			hud.display_upgrade("Damage Up!")
		update2:
			player.accel = 15
			hud.display_upgrade("Acceleration Up!")
		update3:
			player.turning_speed = 100
			hud.display_upgrade("Better Steering!")
		update4:
			player.drift_boost = 1.45
			hud.display_upgrade("Better Drifts!")
		update5:
			player.damage_mult = 1.5
			hud.display_upgrade("Damage Up!")
		update6:
			player.turning_speed = 180
			hud.display_upgrade("Better Steering!")
		update7:
			player.accel = 17
			hud.display_upgrade("Acceleration Up!")
		update8:
			player.damage_mult = 1.9
			hud.display_upgrade("DAMAGE UP!")
