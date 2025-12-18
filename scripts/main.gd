extends Node
class_name Main

# ==============================================================================
# CLASSE PRINCIPALE DU JEU (Main)
# ==============================================================================
# Rôle : Chef d'orchestre global.
# - Gère le cycle de vie du jeu (Début, Semaines, Fin).
# - Connecte tous les systèmes entre eux (Combat, Graphe, UI, Deck).
# - Gère la musique et les transitions d'écran.
# ==============================================================================

# --- GESTION DU TEMPS ---
var current_week: int = 1
const MAX_WEEKS: int = 16

# --- SCORING ---
var initial_score: int = 0
var game_started: bool = false

# --- RÉFÉRENCES ---
@onready var deck_manager = DeckManager.new() 
@onready var combat_scene = $CombatScene 
@onready var service_graph = $ServiceGraph
@onready var enemy = $Enemy 
@onready var hud_label = $HUD/TimeLabel 

var game_ui: GameUI
var current_service_node: ServiceNode = null
var is_combat_resolved: bool = false

func _ready():
	add_child(deck_manager)
	game_ui = GameUI.new()
	add_child(game_ui) 
	game_ui.start_game_requested.connect(_on_start_game)
	game_ui.restart_game_requested.connect(_on_restart_game)
	game_ui.credits_requested.connect(_print_credits)

	
	$Credits.end_credit.connect(_end_credit)
	
	# --- ETAPE CRUCIALE : CONNECTION ---

	combat_scene.enemy_ref = enemy 
	
	service_graph.initiate_combat.connect(on_initiate_combat)
	combat_scene.card_played.connect(on_card_effect_applied)
	enemy.enemy_dead.connect(on_enemy_victory)
	combat_scene.combat_turn_ended.connect(on_combat_defeat)
	combat_scene.give_up.connect(on_combat_give_up)
	service_graph.all_nodes_secured.connect(finish_game)
	
	$HUD.hide()
	service_graph.hide()
	combat_scene.hide()
	enemy.get_node("HealthBar").hide()

func _print_credits():
	game_ui.main_menu.hide()
	$Credits.show()
	$Credits.start_credit()

func _end_credit():
	$Credits.hide()
	game_ui.main_menu.show()

func _on_start_game():
	$Music.play()
	game_ui.main_menu.hide()
	$HUD.show()
	service_graph.show()
	await get_tree().process_frame
	initial_score = service_graph.get_organization_score()
	game_started = true
	update_time_display()

func _on_restart_game():
	get_tree().reload_current_scene()

func on_initiate_combat(service: ServiceNode):
	if not game_started: return
	$Music.stop()
	$MusicCombat.play()
	is_combat_resolved = false
	current_service_node = service
	
	if current_week > MAX_WEEKS:
		finish_game()
		return

	service_graph.hide()
	combat_scene.show()
	enemy.show() 
	enemy.get_node("HealthBar").show()
	
	# --- EQUILIBRAGE DOUX ---
	var base_difficulty = 70 
	var weekly_scaling = (current_week - 1) * 40  
	var size_scaling = service.size * 40    
	var total_hp = base_difficulty + weekly_scaling + size_scaling
	
	var multiplier: float = 1.0
	match service.state:
		"red":    multiplier = 1.85
		"orange": multiplier = 1.45
		"green":  multiplier = 0.65 
	
	var final_hp = int(total_hp * multiplier) + randi_range(-5, 5)

	var max_hp_cap = 750
	if final_hp > max_hp_cap:
		final_hp = max_hp_cap
		
	if final_hp < 50: final_hp = 50
	
	# IMMERSION : On parle de "Charge de travail"
	print("--- MISSION D'AUDIT ---")
	print("Semaine : ", current_week, " | Complexité : ", service.state)
	print("Charge de travail estimée (PV) : ", final_hp)
	print("-----------------------")
	
	enemy.setHealthBar(final_hp)
	
	combat_scene.setup_preparation_phase(service.dialogue_combat_type, deck_manager)

func on_card_effect_applied(card: FightCards):
	var final_damage = card.getDamageWithBonus()
	if not card.haveBonus():
		final_damage = int(final_damage * 0.5)
	enemy.take_damage(final_damage)

# --- VICTOIRE (MISSION RÉUSSIE) ---
func on_enemy_victory():
	if is_combat_resolved: return
	is_combat_resolved = true
	
	if current_service_node:
		service_graph.mark_node_as_secured(current_service_node)
	
	var new_card = deck_manager.add_reward_card()
	var skills_gagnes = []
	for i in range(3):
		var s = deck_manager.add_skill_reward()
		if s: skills_gagnes.append(s)
	
	# IMMERSION : Vocabulaire de validation
	combat_scene.dialogue_box.show_text("Audit clôturé sans réserve. Le dossier est classé.")
	await combat_scene.dialogue_box.dialogue_finished
	
	if new_card:
		# IMMERSION : On recrute du staff
		combat_scene.dialogue_box.show_text("Nouvelle carte d'auditeur obtenu : '" + new_card.getName())
		await combat_scene.dialogue_box.dialogue_finished
	
	if skills_gagnes.size() > 0:
		# IMMERSION : REX (Retour d'Expérience)
		combat_scene.dialogue_box.show_text("Retour d'Expérience, : " + str(skills_gagnes.size()) + " méthodes validées.")
		await combat_scene.dialogue_box.dialogue_finished
		for s in skills_gagnes:
			combat_scene.dialogue_box.show_text("- Compétence acquise : " + s.getCompetence())
			await combat_scene.dialogue_box.dialogue_finished
	

	if game_started: end_week_sequence(1)

# --- DEFAITE (ÉCHÉANCE DÉPASSÉE) ---
func on_combat_defeat():
	if is_combat_resolved: return
	is_combat_resolved = true
	
	var skills_gagnes = []
	for i in range(2):
		var s = deck_manager.add_skill_reward()
		if s: skills_gagnes.append(s)
	
	# IMMERSION : On a manqué de temps
	combat_scene.dialogue_box.show_text("Échéance dépassée. Le rapport n'est pas prêt à temps.")
	await combat_scene.dialogue_box.dialogue_finished

	if skills_gagnes.size() > 0:
		# IMMERSION : Formation corrective
		combat_scene.dialogue_box.show_text("Formation corrective imposée, de nouvelles compétences ont été acquéries : " + str(skills_gagnes.size()) + " mises à niveau.")
		await combat_scene.dialogue_box.dialogue_finished
		for s in skills_gagnes:
			combat_scene.dialogue_box.show_text("- Méthode révisée : " + s.getCompetence())
			await combat_scene.dialogue_box.dialogue_finished
	
	if game_started: end_week_sequence(1) 

# --- ABANDON (REPORT DE MISSION) ---
func on_combat_give_up():
	if is_combat_resolved: return
	is_combat_resolved = true
	
	var skills_gagnes = []
	for i in range(2):
		var s = deck_manager.add_skill_reward()
		if s: skills_gagnes.append(s)
	
	# IMMERSION : Le joueur décide d'arrêter
	combat_scene.dialogue_box.show_text("Mission reportée. Pénalités de retard appliquées (2 semaines).")
	await combat_scene.dialogue_box.dialogue_finished
	
	if skills_gagnes.size() > 0:
		combat_scene.dialogue_box.show_text("Analyse de l'échec : " + str(skills_gagnes.size()) + " points d'amélioration identifiés.")
		await combat_scene.dialogue_box.dialogue_finished
		for s in skills_gagnes:
			combat_scene.dialogue_box.show_text("- Compétence théorique obtenu : " + s.getCompetence())
			await combat_scene.dialogue_box.dialogue_finished
	
	if game_started: end_week_sequence(2)

func end_week_sequence(weeks_to_add: int = 1):
	# 1. On coupe la musique de combat
	$MusicCombat.stop()

	# 2. On relance la musique du bureau (Graphe)
	if not $Music.playing:
		$Music.play()
	
	var main_hand_node = combat_scene.get_node("MainHand")
	

	main_hand_node.clear_hand()
	# -----------------------------
		
	combat_scene.hide()
	enemy.hide() 
	current_week += weeks_to_add
	
	if current_week > MAX_WEEKS:
		finish_game()
	else:
		service_graph.show()
		update_time_display()

func finish_game():
	print("Fin de l'exercice comptable !")
	game_started = false 
	$HUD.hide()
	service_graph.hide()
	combat_scene.hide()
	enemy.hide()
	var final_score = service_graph.get_organization_score()
	game_ui.show_end_screen(initial_score, final_score)

func update_time_display():
	if hud_label:
		hud_label.text = "Semaine : %d / %d" % [current_week, MAX_WEEKS]
		if current_week >= MAX_WEEKS - 4:
			hud_label.modulate = Color(1, 0.2, 0.2) 
		else:
			hud_label.modulate = Color.WHITE
