extends Node
class_name CombatManager

# ==============================================================================
# GESTIONNAIRE DE COMBAT (CombatManager)
# ==============================================================================
# Rôle : Contrôle toute la scène de combat (Audit).
# - Gère l'interface (Slots, Compétences, Main, Ennemi).
# - Applique les règles de jeu (jouer une carte, calculer l'efficacité).
# - Affiche les pop-ups de confirmation.
# ==============================================================================

# --- SIGNAUX ---
signal combat_start
signal card_played(FightCards)
signal combat_turn_ended
signal give_up

# --- CONSTANTES & RESSOURCES ---
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")
const JSON_PATH = "res://data/pnj.json"

# --- REFERENCES SCENE (Noeuds UI) ---
@onready var card_zone2 = $CardZone2
@onready var slot_zone = $SlotZone/SlotHBox
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox
@onready var start_button = $StartCombat
@onready var give_up_button = $GiveUp
@onready var main_hand = $MainHand
@onready var confirm_popup = $ConfirmationAttack
@onready var popup_skill_cards_scene = preload("res://scenes/skill_cards_popup.tscn").instantiate()

# --- BOUTONS PAGINATION ---
@onready var btn_prev = $MainHand/PrevButton
@onready var btn_next = $MainHand/NextButton

# --- VARIABLES ETAT ---
var enemy_ref: Enemy = null 
var pnj_data: Dictionary = {} 
var is_in_fight = false
var current_deck_ref: DeckManager
var card_inspector: CardInspector # Fenêtre d'info au survol
var hit_sound: AudioStreamPlayer

func _ready():
	hit_sound = AudioStreamPlayer.new()
	hit_sound.stream = preload("res://music/video-game-hit-noise-001-135821.mp3")
	add_child(hit_sound)
	
	_load_json_data()
	
	add_child(popup_skill_cards_scene)
	popup_skill_cards_scene.on_close.connect(close_popup_skill_cards)
	
	# Connexion sécurisée du bouton start
	if start_button:
		if not start_button.is_connected("pressed", Callable(self, "_on_start_combat_pressed")):
			start_button.connect("pressed", Callable(self, "_on_start_combat_pressed"))
			
	# Connexion Clic Carte (depuis la main)
	if main_hand:
		if not main_hand.is_connected("card_clicked", Callable(self, "_on_card_clicked_signal")):
			main_hand.connect("card_clicked", Callable(self, "_on_card_clicked_signal"))

	# Initialisation et Connexion des Boutons de Pagination
	if btn_prev and btn_next:
		# On donne les références à MainHand pour qu'il les gère
		main_hand.btn_prev = btn_prev
		main_hand.btn_next = btn_next
		
		# Nettoyage des anciennes connexions pour éviter les doublons
		if btn_prev.is_connected("pressed", Callable(main_hand, "change_page")):
			btn_prev.disconnect("pressed", Callable(main_hand, "change_page"))
		if btn_next.is_connected("pressed", Callable(main_hand, "change_page")):
			btn_next.disconnect("pressed", Callable(main_hand, "change_page"))
			
		# Connexion : -1 (Gauche) et 1 (Droite)
		btn_prev.pressed.connect(main_hand.change_page.bind(-1))
		btn_next.pressed.connect(main_hand.change_page.bind(1))
	else:
		push_warning("CombatManager: Boutons Prev/Next introuvables !")

	_setup_layout()

## Configure la position et la taille des éléments UI au démarrage.
func _setup_layout():
	var screen_size = get_viewport().size
	var margin_top = 20
	var margin_right = 20
	var slot_w = 200
	var slot_h = 330
	var reserve_w = 400 
	var gap = 40 
	
	# Placement de la zone de Slots (à droite)
	var slots_total_width = (slot_w * 2) + 50 
	var slots_start_x = screen_size.x - slots_total_width - margin_right
	slot_zone.get_parent().global_position = Vector2(slots_start_x, margin_top)
	slot_zone.get_parent().custom_minimum_size = Vector2(slots_total_width, slot_h)
	
	# Placement de la réserve de compétences (à gauche des slots)
	var reserve_start_x = slots_start_x - reserve_w - gap
	card_zone2.global_position = Vector2(reserve_start_x, margin_top)
	card_zone2.custom_minimum_size = Vector2(reserve_w, slot_h)
	card_zone2.size = Vector2(reserve_w, slot_h)
	
	# Création et placement de l'inspecteur de cartes (Tooltip géant)
	card_inspector = CardInspector.new()
	add_child(card_inspector)
	card_inspector.z_index = 100 
	var inspector_x = reserve_start_x + 200 
	var inspector_y = margin_top + slot_h + 20 
	card_inspector.global_position = Vector2(inspector_x, inspector_y)
	
	# Connexion du survol pour afficher les infos
	if not main_hand.is_connected("card_hovered", Callable(card_inspector, "show_card")):
		main_hand.connect("card_hovered", Callable(card_inspector, "show_card"))

## Charge les données des PNJ depuis le fichier JSON.
func _load_json_data():
	if not FileAccess.file_exists(JSON_PATH): return
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK: pnj_data = json.data

## Applique une apparence aléatoire à l'ennemi en fonction du type de pôle.
func set_random_enemy_visual(type_id: int):
	if enemy_ref == null or pnj_data.is_empty() or not pnj_data.has("pnj"): return
	var type_str = str(type_id)
	var possible_paths: Array = []
	
	# Chemins spécifiques au type + Chemins communs
	var specific = pnj_data["pnj"].get(type_str, {})
	if specific: possible_paths.append_array(specific.values())
	var common = pnj_data["pnj"].get("all", {})
	if common: possible_paths.append_array(common.values())
	
	if not possible_paths.is_empty():
		enemy_ref.change_visual(possible_paths.pick_random())

## Prépare l'écran de combat avant le début de l'affrontement.
func setup_preparation_phase(type_id: int, deck_manager_ref: DeckManager):
	current_deck_ref = deck_manager_ref
	is_in_fight = false
	set_random_enemy_visual(type_id)
	
	# Affichage de l'interface de préparation
	start_button.show()
	card_zone2.show()
	$PopupSkillCards.show()
	slot_zone.get_parent().show()

	# Nettoyage des slots (on retire les cartes précédentes)
	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			slot.remove_child(slot.carte_occupee) 
			
	deck_manager_ref.prepare_combat_deck() 
	
	# Chargement des cartes dans la main
	main_hand.load_full_deck(deck_manager_ref.master_deck) 
	
	display_slots()
	display_skills()
	
	dialogue_box.play_random_intro_by_type(type_id)

func _on_start_combat_pressed():
	if is_in_fight: return
	is_in_fight = true
	
	# On cache l'interface de prépa
	start_button.hide()
	card_zone2.hide() # On cache la réserve de skills
	$PopupSkillCards.hide()
	
	update_hand_efficiency() # Calcul initial des bonus
	combat_start.emit()

func _on_give_up_pressed():
	give_up.emit()

# Fonction qui va afficher l'inventaire des cartes de compétences
func popup_skill_cards():
	start_button.hide()
	var cards: Array[object_skill_card]
	var card_zone = card_zone2.get_node("SkillsBox")
	for card in card_zone.get_children():
		if card is object_skill_card:
			cards.append(card)
	popup_skill_cards_scene.open(cards)

# Fonction qui va fermer l'inventaire des cartes de compétences
func close_popup_skill_cards(cards: Array[object_skill_card]):
	start_button.show()
	var card_zone = card_zone2.get_node("SkillsBox")
	for card in cards:
		if card is not object_skill_card:
			continue
		if card.get_parent(): card.get_parent().remove_child(card)
		card.custom_minimum_size = Vector2(180, 310)
		card_zone.add_child(card)
		card.position = Vector2.ZERO

# --- CŒUR DU GAMEPLAY : SYNERGIES ---

## Vérifie les synergies entre les Skills équipés (Slots) et les Cartes Action (Main).
## Met à jour visuellement les cartes (Vert = Bonus, Rouge = Malus).
func update_hand_efficiency():
	var active_skills: Array[skill_card] = []
	
	# 1. On récupère les compétences actives dans les slots
	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			if slot.carte_occupee.assigned_class:
				active_skills.append(slot.carte_occupee.assigned_class)
	
	# 2. ON DÉLÈGUE TOUT À MAINHAND !
	main_hand.update_bonuses_from_skills(active_skills)

func _on_slots_changed():
	update_hand_efficiency()

# --- CLIC & CONFIRMATION ---

## Gestion du clic sur une carte : Affiche la pop-up de confirmation.
func _on_card_clicked_signal(carte_info: FightCards):
	if not is_in_fight: return 
	
	var dmg = carte_info.getDamageWithBonus()
	var message = ""
	
	# Affichage d'un avertissement si pas de bonus (malus 50%)
	if not carte_info.haveBonus():
		dmg = int(dmg * 0.5) 
		message = "\n(PENALITE : Incompatible -50%)"
	
	var text_confirm = "Jouer " + carte_info.getName() + " ?\nDegats : " + str(dmg) + message
	$ConfirmationAttack.dialog_text = text_confirm
	
	# Connexion propre du signal de confirmation
	if $ConfirmationAttack.is_connected("confirmed", Callable(self, "_on_confirm_play")):
		$ConfirmationAttack.disconnect("confirmed", Callable(self, "_on_confirm_play"))
	$ConfirmationAttack.connect("confirmed", Callable(self, "_on_confirm_play").bind(carte_info))
	
	$ConfirmationAttack.show()

## Joue la carte une fois confirmée.
func _on_confirm_play(carte_info):
	hit_sound.play()

	apply_card_effect(carte_info) 
	card_played.emit(carte_info)
	current_deck_ref.discard(carte_info) # Défausse logique
	
	# Retrait visuel de la main
	main_hand.remove_card_logic(carte_info)
	
	update_hand_efficiency()
	
	# Si la main est vide, fin du tour après un court délai
	if main_hand.all_cards_logic.is_empty():
		await get_tree().create_timer(0.5).timeout
		combat_turn_ended.emit()

## Applique l'effet spécial de la carte (si elle en a un).
func apply_card_effect(carte_info: FightCards):
	if carte_info.effect_script == "": return
	
	var effect_class = load(carte_info.effect_script)
	if effect_class:
		var instance = effect_class.new()
		add_child(instance)
		if instance.has_method("apply_effect"):
			instance.apply_effect(service_display, carte_info)
		
		await get_tree().create_timer(0.1).timeout
		instance.queue_free()

## Crée et affiche les slots vides.
func display_slots():
	var container = slot_zone
	for child in container.get_children(): child.queue_free()
	for i in range(2):
		var slot = Slot.new()
		slot.connect("slot_updated", Callable(self, "_on_slots_changed"))
		container.add_child(slot)

## Affiche les compétences disponibles dans la réserve.
func display_skills():
	if not current_deck_ref: return
	var skills = current_deck_ref.get_all_skills()
	var container = card_zone2.get_node("SkillsBox") 
	
	for skill_data in skills:
		var visual = skill_data._carte
		if not is_instance_valid(visual): continue
		if visual.get_parent() == container: continue
		
		if visual.get_parent(): visual.get_parent().remove_child(visual)
		
		visual.custom_minimum_size = Vector2(180, 310)
		container.add_child(visual)
		visual.position = Vector2.ZERO
