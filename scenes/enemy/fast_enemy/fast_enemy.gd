extends Enemy

func _ready() -> void:
	damage = 1
	ignore_player = false
	speed = 3.0
	health = 8
	$"Cone of Vision".body_entered.connect(is_in_on_sight)
