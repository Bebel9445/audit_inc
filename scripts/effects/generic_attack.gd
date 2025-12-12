extends Node

# Ce script est appelé par CombatManager pour les cartes JSON

func apply_effect(target, card_data: FightCards):
	
	# On récupère les dégâts
	var damage = 0
	
	# On utilise les fonctions de FightCards (get genre)
	if card_data.haveBonus():
		damage = card_data.getDamageWithBonus()
	else:
		damage = card_data.getDamage() 
		
	print(">>> Attaque générique lancée ! Dégâts : ", damage)

	# 2. On applique les dégâts sur la cible
	if target.has_method("take_damage"):
		target.take_damage(damage)
