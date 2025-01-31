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
	return (sqrt(0.2 * time))
	
func enemy_credit_int() -> int:
	if time == 0.0:
		return 0
	return int((sqrt(0.2 * time)))
	
func enemy_stat_scalar_float() -> float:
	return 30#2 - exp(-time / 433)
	
func enemy_stat_scalar_fin_int(initial: int) -> int:
	return int(initial * (2 - exp(-time / 433)))
	
func enemy_stat_scalar_fin_int_offset(initial: int, offset: float) -> int:
	return int(initial * (2 - exp(-(time - offset) / 433)))
	
func enemy_spawntime_float() -> float:
	if time == 0.0:
		return 0
	return (sqrt(0.2 * time))
	
func enemy_spawntime_int() -> int:
	if time == 0.0:
		return 0
	return int((sqrt(0.2 * time)))

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
