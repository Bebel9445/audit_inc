extends Node

# --- Gestion du Temps ---
var current_week: int = 1
const MAX_WEEKS: int = 16 

# --- Scoring ---
var initial_score: int = 0
var game_started: bool = false

# --- Références ---
@onready var deck_manager = DeckManager.new() 
@onready var combat_scene = $CombatScene
@onready var service_graph = $ServiceGraph
@onready var enemy = $Enemy
@onready var hud_label = $HUD/TimeLabel 

# Notre nouvelle UI
var game_ui: GameUI

var current_service_node: ServiceNode = null
var is_combat_resolved: bool = false

func _ready():
	add_child(deck_manager)
	
	# Instanciation de l'UI
	game_ui = GameUI.new()
	add_child(game_ui)
	game_ui.start_game_requested.connect(_on_start_game)
	game_ui.restart_game_requested.connect(_on_restart_game)
	game_ui.credits_requested.connect(_print_credits)
	
	# Connexions Jeu
	service_graph.initiate_combat.connect(on_initiate_combat)
	combat_scene.card_played.connect(on_card_effect_applied)
	enemy.enemy_dead.connect(on_enemy_victory)
	combat_scene.combat_turn_ended.connect(on_combat_defeat)
	
	# On cache le jeu au début, on laisse le menu
	$HUD.hide()
	service_graph.hide()
	combat_scene.hide()
	enemy.get_node("HealthBar").hide()
	
	combat_scene.give_up.connect(on_combat_give_up)

# --- CREDITS ---
func _print_credits():
	game_ui.main_menu.hide()
	$Cerdits.show()

# --- MENU & DÉMARRAGE ---
func _on_start_game():
	$Music.play()
	
	game_ui.main_menu.hide()
	$HUD.show()
	service_graph.show()
	
	# On attend une frame que le graphe soit bien généré pour calculer le score
	await get_tree().process_frame
	
	# Calcul du score de départ (État des lieux)
	initial_score = service_graph.get_organization_score()
	print("Score Initial de l'Organisation : ", initial_score)
	
	game_started = true
	update_time_display()

func _on_restart_game():
	get_tree().reload_current_scene()

# --- BOUCLE DE JEU ---

func on_initiate_combat(service: ServiceNode):
	if not game_started: return
	
	is_combat_resolved = false
	current_service_node = service
	
	if current_week > MAX_WEEKS:
		finish_game()
		return

	service_graph.hide()
	combat_scene.show()
	
	# Difficulté dynamique
	var base_hp = service.size * 50 
	var multiplier: float = 1.0
	match service.state:
		"red":    multiplier = 1.3 
		"orange": multiplier = 1.0
		"green":  multiplier = 0.8
	var final_hp = int(base_hp * multiplier) + randi_range(-5, 5)
	
	enemy.setHealthBar(final_hp)
	enemy.get_node("HealthBar").show()
	
	combat_scene.setup_preparation_phase(service.dialogue_combat_type, deck_manager)

func on_card_effect_applied(card: FightCards):
	enemy.take_damage(card.getDamageWithBonus())

# --- VICTOIRE ---
func on_enemy_victory():
	if is_combat_resolved: return
	is_combat_resolved = true
	
	# Conséquences
	current_service_node.set_completed() 
	for neighbor in current_service_node.links:
		if neighbor.has_method("reduce_difficulty"):
			neighbor.reduce_difficulty()
	
	# Récompenses
	deck_manager.add_reward_card()
	deck_manager.add_skill_reward()
	
	# Dialogue
	combat_scene.dialogue_box.show_text("Excellent travail. Dossier sécurisé.")
	
	await combat_scene.dialogue_box.dialogue_finished
	
	$Music.play()
	
	end_week_sequence()

# --- DEFAITE (TEMPS) ---
func on_combat_defeat():
	if is_combat_resolved: return
	is_combat_resolved = true
	
	# Pas de changement graphe, petite récompense
	deck_manager.add_reward_card() 
	
	combat_scene.dialogue_box.show_text("Temps écoulé. On fera mieux la prochaine fois.")
	
	# --- ATTENTE DU DIALOGUE ---
	await combat_scene.dialogue_box.dialogue_finished
	
	end_week_sequence()

func on_combat_give_up():
	if is_combat_resolved: return
	is_combat_resolved = true
	
	# Pas de changement graphe, petite récompense
	deck_manager.add_reward_card() 
	
	combat_scene.dialogue_box.show_text("Temps écoulé. On fera mieux la prochaine fois.")

	end_week_sequence()

func end_week_sequence():
	# Nettoyage main
	var main_hand = combat_scene.get_node("MainHand")
	for c in main_hand.get_children():
		main_hand.remove_child(c)
		
	combat_scene.hide()
	enemy.get_node("HealthBar").hide()
	
	current_week += 1
	
	if current_week > MAX_WEEKS:
		finish_game()
	else:
		service_graph.show()
		update_time_display()

func finish_game():
	print("Fin de partie !")
	$HUD.hide()
	service_graph.hide()
	combat_scene.hide()
	
	var final_score = service_graph.get_organization_score()
	print("Score Final : ", final_score)
	
	game_ui.show_end_screen(initial_score, final_score)

func update_time_display():
	if hud_label:
		hud_label.text = "Semaine : %d / %d" % [current_week, MAX_WEEKS]
		if current_week >= MAX_WEEKS - 4:
			hud_label.modulate = Color(1, 0.2, 0.2) 
		else:
			hud_label.modulate = Color.WHITE
