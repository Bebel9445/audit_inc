extends Node

signal enemy_dead

func _ready():
	pass

func setHealthBar(pv: int):
	$HealthBar.max_value = pv
	$HealthBar.min_value = 0
	$HealthBar.value = pv

func takeDamage(damage: int):
	if damage > $HealthBar.value:
		enemy_dead.emit()
		return
	$HealthBar.value -= damage
