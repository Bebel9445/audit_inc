extends Node
class_name CombatManager

# --- SIGNAUX ---

## Émis lorsque le joueur clique sur "Lancer le combat" (fin de phase de prépa).
signal combat_start

## Émis lorsqu'une carte a été validée et jouée.
signal card_played(FightCards)

## Émis quand le joueur n'a plus de cartes en main (Fin du tour).
signal combat_turn_ended

## Émis lorsque le joueur clique sur le bouton d'abandon.
signal give_up

# --- RESSOURCES ---
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")
const JSON_PATH = "res://data/pnj.json"

# --- RÉFÉRENCES SCÈNE (UI & LOGIQUE) ---
@onready var card_zone2 = $CardZone2
@onready var slot_zone = $SlotZone/SlotHBox
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox
@onready var start_button = $StartCombat
@onready var give_up_button = $GiveUp
@onready var main_hand = $MainHand
@onready var confirm_popup = $ConfirmationAttack 

# --- VARIABLES D'ÉTAT ---
var enemy_ref: Enemy = null 
var pnj_data: Dictionary = {} 

## Verrou pour empêcher les interactions pendant les animations ou hors combat.
var is_in_fight = false

## Lien vers le DeckManager (pour piocher/défausser).
var current_deck_ref: DeckManager

## Fenêtre flottante affichant les détails des cartes.
var card_inspector: CardInspector

func _ready():
	_load_json_data()
	
	# Connexion sécurisée du bouton start
	if start_button:
		if not start_button.is_connected("pressed", Callable(self, "_on_start_combat_pressed")):
			start_button.connect("pressed", Callable(self, "_on_start_combat_pressed"))
			
	# Génération procédurale du placement des éléments
	_setup_layout()

# --- INITIALISATION UI & DATA ---

## Place les zones de jeu (Slots, Réserve, Inspecteur) via le code.
## Permet d'adapter l'interface à la taille de l'écran dynamiquement.
func _setup_layout():
	var screen_size = get_viewport().size
	var margin_top = 20
	var margin_right = 20
	var slot_w = 200
	var slot_h = 330
	var reserve_w = 400 
	var gap = 40 
	
	# Positionnement de la zone des Slots (En haut à droite)
	var slots_total_width = (slot_w * 2) + 50 
	var slots_start_x = screen_size.x - slots_total_width - margin_right
	
	slot_zone.get_parent().global_position = Vector2(slots_start_x, margin_top)
	slot_zone.get_parent().custom_minimum_size = Vector2(slots_total_width, slot_h)
	
	# Positionnement de la réserve de Skills (À gauche des slots)
	var reserve_start_x = slots_start_x - reserve_w - gap
	card_zone2.global_position = Vector2(reserve_start_x, margin_top)
	card_zone2.custom_minimum_size = Vector2(reserve_w, slot_h)
	card_zone2.size = Vector2(reserve_w, slot_h)
	
	# Création et placement de l'Inspecteur de Carte
	card_inspector = CardInspector.new()
	add_child(card_inspector)
	card_inspector.z_index = 100 
	var inspector_x = reserve_start_x + 200 
	var inspector_y = margin_top + slot_h + 20 
	card_inspector.global_position = Vector2(inspector_x, inspector_y)
	
	# Connexion : Survoler une carte de la main met à jour l'inspecteur
	main_hand.connect("card_hovered", Callable(card_inspector, "show_card"))

## Charge les chemins des images des ennemis (PNJ) depuis le JSON.
func _load_json_data():
	if not FileAccess.file_exists(JSON_PATH):
		push_error("CombatManager : JSON introuvable à " + JSON_PATH)
		return
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		pnj_data = json.data
	else:
		push_error("Erreur JSON : " + json.get_error_message())

## Applique une apparence aléatoire à l'ennemi selon le type de service (Eco, RH, etc.).
func set_random_enemy_visual(type_id: int):
	if enemy_ref == null or pnj_data.is_empty() or not pnj_data.has("pnj"): return
	var type_str = str(type_id)
	var possible_paths: Array = []
	
	# Récupère les skins spécifiques au type + les skins génériques ("all")
	var specific = pnj_data["pnj"].get(type_str, {})
	if specific: possible_paths.append_array(specific.values())
	var common = pnj_data["pnj"].get("all", {})
	if common: possible_paths.append_array(common.values())
	
	if not possible_paths.is_empty():
		var random_path = possible_paths.pick_random()
		if enemy_ref.has_method("change_visual"):
			enemy_ref.change_visual(random_path)

# --- FLUX DE COMBAT : PRÉPARATION ---

## Initialise le plateau pour un nouveau combat.
## Reset la main, la pioche, l'ennemi et affiche l'interface de "Loadout".
func setup_preparation_phase(type_id: int, deck_manager_ref: DeckManager):
	current_deck_ref = deck_manager_ref
	is_in_fight = false
	
	# Setup Visuel Ennemi
	set_random_enemy_visual(type_id)
	
	# Affichage UI Préparation
	start_button.show()
	card_zone2.show()
	slot_zone.get_parent().show()

	# Nettoyage des slots (si des cartes y étaient restées)
	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			slot.remove_child(slot.carte_occupee) 
			
	# Préparation du Deck de combat
	main_hand.clear_hand()
	deck_manager_ref.prepare_combat_deck() 
	
	# Affichage des éléments interactifs
	display_slots()   # Création des 2 slots vides
	display_skills()  # Affichage de l'inventaire de skills
	draw_cards(5)     # Pioche de la main de départ
	
	# Phrase d'intro du boss/service
	dialogue_box.play_random_intro_by_type(type_id)

## Callback bouton "Lancer le combat".
## Verrouille l'équipement et active le calcul des bonus.
func _on_start_combat_pressed():
	if is_in_fight: return
	is_in_fight = true
	
	start_button.hide()
	card_zone2.hide() # On cache la réserve de skills
	
	# On calcule une dernière fois l'efficacité avant de laisser le joueur jouer
	update_hand_efficiency()
	combat_start.emit()

func _on_give_up_pressed():
	give_up.emit()

# --- CŒUR DU GAMEPLAY : SYNERGIES ---

## Vérifie les synergies entre les Skills équipés (Slots) et les Cartes Action (Main).
## Met à jour visuellement les cartes (Vert = Bonus, Rouge = Malus).
func update_hand_efficiency():
	# 1. Récupérer la liste des compétences actives dans les slots
	var active_skills: Array[skill_card] = []
	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			if slot.carte_occupee.assigned_class:
				active_skills.append(slot.carte_occupee.assigned_class)
	
	# 2. Parcourir la main du joueur
	for card_visual in $MainHand.get_children():
		if card_visual is FightCardsObject:
			var card_data = card_visual.assigned_class
			if card_data:
				# 3. Calcul Logique (Dégâts finaux)
				card_data.calculate_efficiency(active_skills)
				
				# 4. Mise à jour Visuelle (Texte & Couleur)
				if card_visual.has_method("update_visual_state"):
					card_visual.update_visual_state()

## Appelé quand on drag & drop une compétence dans un slot.
func _on_slots_changed():
	update_hand_efficiency()

# --- GESTION DES CARTES (PIOCHE / JEU) ---

## Pioche X cartes depuis le DeckManager et les ajoute à la scène.
func draw_cards(amount: int):
	if not current_deck_ref: return
	for i in range(amount):
		var card_info = current_deck_ref.draw()
		if card_info:
			add_card_to_zone(card_info)
	# À chaque pioche, on vérifie si les nouvelles cartes ont des bonus
	update_hand_efficiency()

## Crée le visuel d'une carte et l'ajoute à la Main (MainHand).
func add_card_to_zone(card_info: FightCards):
	var carte_visuelle = card_info._carte
	if not carte_visuelle: return
	
	# Connexion du clic (pour jouer la carte)
	if not carte_visuelle.is_connected("gui_input", Callable(self, "_on_card_clicked")):
		carte_visuelle.connect("gui_input", Callable(self, "_on_card_clicked").bind(card_info))
	
	# Gestion parenté (au cas où elle vient d'ailleurs)
	if carte_visuelle.get_parent():
		carte_visuelle.get_parent().remove_child(carte_visuelle)
		
	$MainHand.add_card(carte_visuelle)

## Gestion du Clic sur une carte en main.
## Affiche une popup de confirmation avec les dégâts réels.
func _on_card_clicked(event: InputEvent, carte_info: FightCards):
	if not is_in_fight: return 
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var dmg = carte_info.getDamageWithBonus()
		var message = ""
		
		# Feedback si malus appliqué
		if not carte_info.haveBonus():
			dmg = int(dmg * 0.5) 
			message = "\n(PENALITE : Incompatible -50%)"
		
		var text_confirm = "Jouer " + carte_info.getName() + " ?\nDegats : " + str(dmg) + message
		$ConfirmationAttack.dialog_text = text_confirm
		
		# Connexion propre du signal "confirmed" (avoid duplicates)
		if $ConfirmationAttack.is_connected("confirmed", Callable(self, "_on_confirm_play")):
			$ConfirmationAttack.disconnect("confirmed", Callable(self, "_on_confirm_play"))
		$ConfirmationAttack.connect("confirmed", Callable(self, "_on_confirm_play").bind(carte_info))
		
		$ConfirmationAttack.show()

## Exécute l'action de jouer la carte après confirmation.
func _on_confirm_play(carte_info):
	# SFX
	var music = AudioStreamPlayer.new() 
	music.stream = preload("res://music/rot.wav")
	add_child(music)
	music.play()
	
	# Effet Visuel / Logique spécifique
	apply_card_effect(carte_info) 
	
	# Signaux globaux
	card_played.emit(carte_info)
	
	# Gestion des piles
	current_deck_ref.discard(carte_info)
	$MainHand.remove_card(carte_info._carte)
	
	# Vérification fin de tour (Main vide)
	if $MainHand.cartes.is_empty():
		await get_tree().create_timer(0.5).timeout
		combat_turn_ended.emit()

## Charge et instancie dynamiquement le script d'effet de la carte.
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

# --- AFFICHAGE SLOTS & SKILLS ---

## Initialise les 2 slots vides pour poser les compétences.
func display_slots():
	var container = slot_zone
	for child in container.get_children(): child.queue_free()
	
	for i in range(2):
		var slot = Slot.new()
		# Si on change une carte dans le slot, on met à jour les dégâts
		slot.connect("slot_updated", Callable(self, "_on_slots_changed"))
		container.add_child(slot)

## Affiche toutes les compétences disponibles dans la réserve (CardZone2).
func display_skills():
	if not current_deck_ref: return
	
	var skills = current_deck_ref.get_all_skills()
	var container = card_zone2.get_node("SkillsBox") 
	
	for skill_data in skills:
		var visual = skill_data._carte
		if not is_instance_valid(visual): continue
		
		# Si le skill est déjà affiché, on ignore
		if visual.get_parent() == container: continue
		
		# On le déplace vers le container de réserve
		if visual.get_parent(): visual.get_parent().remove_child(visual)
		visual.custom_minimum_size = Vector2(180, 310)
		container.add_child(visual)
		visual.position = Vector2.ZERO
