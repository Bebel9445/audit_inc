extends Node

func _ready():
	var service_instance = $ServiceGraph 
	service_instance.initiate_combat.connect(on_initiate_combat)
	
	var combat_instance = $CombatScene
	combat_instance.combat_start.connect(on_initiate_enemy)
	combat_instance.card_played.connect(on_card_played)
	
	var enemy_instance = $Enemy
	enemy_instance.enemy_dead.connect(on_enemy_dead)

func on_initiate_combat(service: ServiceNode):
	$ServiceGraph.hide()
	$CombatScene.show()

func on_initiate_enemy():
	$Enemy.setHealthBar(20) # C'est les pv de l'ennemi, on le modifira en fonction du graphe
	var pv_enemy = $Enemy.get_node("HealthBar")
	pv_enemy.show()

func on_card_played(card: FightCards):
	var damage
	if card.haveBonus():
		damage = card.getDamageWithBonus()
	else:
		damage = card.getDamage()
	
	$Enemy.takeDamage(damage)

func on_enemy_dead(): #Quand on bat un ennemi
	pass
