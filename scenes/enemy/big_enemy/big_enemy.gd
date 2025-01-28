extends Enemy

func _ready() -> void:
	damage = 10
	ignore_player = true
	speed = 0.25
	health = 20
	$"Cone of Vision".body_entered.connect(is_in_on_sight) # Connects signal to
