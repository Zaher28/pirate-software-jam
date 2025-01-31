extends CanvasLayer
#This node is where we (probably) put the spinning wheel too
@export var stopwatch_label: Label
@export var highscore_label: Label
@export var speed_label: Label
@export var upgrade_label: Label
@export var ammo_label: Label
@export var minimap: ColorRect

@export var upgrade_text_display_length: float

var stopwatch : Node
var player: Node

var upgrade_text_timer = 0.0
var displaying_upgrade = false

var mini_player_tex = load("res://assets/minimap/player.png")
var mini_enemy_tex = load("res://assets/minimap/enemy.png")
var mini_pickup_tex = load("res://assets/minimap/pickup.png")

var spinach_icon = load("res://assets/Spinach.png")
var extra_large_icon = load("res://assets/Extra Large.png")
var shotgun_icon = load("res://assets/Shotgun.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.position.x = 1031
	$Sprite2D.position.y = 527
	$Sprite2D.scale.x = 0.5
	$Sprite2D.scale.y = 0.5
	stopwatch = get_tree().get_first_node_in_group("stopwatch")
	player = get_tree().get_first_node_in_group("player")
	highscore_label.text = "HS: %s" % stopwatch.time_to_string(get_parent().load_highscore())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_stopwatch()
	update_speed()
	update_minimap()
	update_pickup()
	
	if displaying_upgrade:
		upgrade_text_timer += delta
		if upgrade_text_timer >= upgrade_text_display_length:
			upgrade_label.text = ""
			upgrade_text_timer = 0.0
			displaying_upgrade = false

# Time to String to Label
func update_stopwatch():
	stopwatch_label.text = stopwatch.time_to_string(stopwatch.time_alive)

# Display the player's speed
func update_speed():
	speed_label.text = "%.2f mps" % player.velocity.length()

# Draw the minimap
func update_minimap():
	# clear the minimap of everything except tower
	for minimap_item in minimap.get_children():
		if not minimap_item.is_in_group("minimap_item_locked"):
			minimap_item.free()
	# draw player
	draw_mini_element(mini_player_tex, Vector2(0.1, 0.1), player.global_position.x, player.global_position.z)
	# draw other entities
	for enemy in get_tree().get_nodes_in_group("enemy"):
		draw_mini_element(mini_enemy_tex, Vector2(0.05, 0.05), enemy.global_position.x, enemy.global_position.z)
	for pickup in get_tree().get_nodes_in_group("pickup"):
		draw_mini_element(mini_pickup_tex, Vector2(0.05, 0.05), pickup.global_position.x, pickup.global_position.z)

# Draw a minimap element
func draw_mini_element(texture, mini_scale, x, z):
	var mini_element = Sprite2D.new()
	mini_element.texture = texture
	mini_element.scale = mini_scale
	minimap.add_child(mini_element)
	mini_element.position.x += 75 + x
	mini_element.position.y += 75 + z

func display_upgrade(text):
	upgrade_label.text = text
	displaying_upgrade = true
	
func update_pickup():
	ammo_label.text = ""
	if is_instance_valid(player.pickup):
		if is_instance_of(player.pickup, Pickups.ShotgunPickUp):
			$Sprite2D.texture = shotgun_icon
			ammo_label.text = "Uses - %d" % player.pickup.uses
		elif is_instance_of(player.pickup, Pickups.GrowPickUp):
			$Sprite2D.texture = extra_large_icon
		elif is_instance_of(player.pickup, Pickups.InstakillPickUp):
			$Sprite2D.texture = spinach_icon
	else:
		$Sprite2D.texture = null
