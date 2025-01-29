extends Node

var time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta

func enemy_credit_float() -> float:
	if time == 0.0:
		return 0
	return 1.5 * (sqrt(time)-log(time))
	
func enemy_credit_int() -> int:
	if time == 0.0:
		return 0
	return int(1.5 * (sqrt(time)-log(time)))
	
func enemy_stat_scalar_float() -> float:
	if time <= 10:
		return 1.0
	if time <= 30:
		return 1 + (time - 10) * (.25 / 20)
	return 1.25 + (time - 30) * (.75 / 20)
	
func enemy_stat_scalar_fin_int(initial: int) -> int:
	if time <= 10:
		return initial
	if time <= 30:
		return int((1 + (time - 10) * (.25 / 20)) * initial)
	return int((1.25 + (time - 30) * (.75 / 20)) * initial)

#func enemy_stat_scalar_float() -> float:
	#if time <= 90:
		#return 1.0
	#if time <= 150:
		#return 1 + (time - 90) * (.25 / 60)
	#return 1.25 + (time - 150) * (.75 / 60)
	#
#func enemy_stat_scalar_fin_int(initial: int) -> int:
	#if time <= 90:
		#return initial
	#if time <= 150:
		#return int((1 + (time - 90) * (.25 / 60)) * initial)
	#return int((1.25 + (time - 150) * (.75 / 60)) * initial)
