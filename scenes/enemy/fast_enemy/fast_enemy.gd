extends Enemy

func _ready() -> void:
	controller = get_tree().get_first_node_in_group("game_controller")
	damage = controller.enemy_stat_scalar_fin_int(1)
	ignore_player = false
	speed = 3.0 * controller.enemy_stat_scalar_float()
	health = controller.enemy_stat_scalar_fin_int(8)
	$"Cone of Vision".body_entered.connect(is_in_on_sight)
