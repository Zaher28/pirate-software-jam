extends Enemy

func _ready() -> void:
	controller = get_tree().get_first_node_in_group("game_controller")
	damage = controller.enemy_stat_scalar_fin_int(10)
	ignore_player = true
	speed = 0.25 * controller.enemy_stat_scalar_float()
	health = controller.enemy_stat_scalar_fin_int(20)
	$"Cone of Vision".body_entered.connect(is_in_on_sight) # Connects signal to
