extends Enemy

func _ready() -> void:
	damage = 50
	ignore_player = true
	speed = 0.5
	health = 20
	$"Cone of Vision".body_entered.connect(is_in_on_sight) # Connects signal to

func hurt(damage):
	health -= damage
	if health <= 0:
		queue_free()
