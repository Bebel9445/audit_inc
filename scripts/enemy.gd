extends Node

signal enemy_dead

func _ready():
	# Optionnel : initialise la vie au démarrage si personne n'appelle setHealthBar
	# setHealthBar(100) 
	pass

func setHealthBar(pv: int):
	$HealthBar.max_value = pv
	$HealthBar.min_value = 0
	$HealthBar.value = pv

func take_damage(damage: int):
	print("Dégâts reçus : ", damage)
	
	# On applique les dégâts VISUELLEMENT tout de suite
	$HealthBar.value -= damage
	
	# Ensuite on vérifie si c'est mortel
	if $HealthBar.value <= 0:
		$HealthBar.value = 0 # Pour être sûr qu'elle soit vide visuellement
		enemy_dead.emit()
