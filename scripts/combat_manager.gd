extends Node
class_name CombatManager

signal combat_start
signal card_played(FightCards)
signal combat_turn_ended
signal give_up

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

# --- REFERENCES INTERNES ---
@onready var card_zone2 = $CardZone2
@onready var slot_zone = $SlotZone/SlotHBox
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox
@onready var start_button = $StartCombat
@onready var give_up_button = $GiveUp
@onready var main_hand = $MainHand
@onready var confirm_popup = $ConfirmationAttack 
@onready var player = preload("res://scripts/player.gd").new()

# --- REFERENCE EXTERNE (Injectée par le Main) ---
var enemy_ref: Enemy = null 

# --- CONFIGURATION JSON ---
const JSON_PATH = "res://Data/pnj.json"
var pnj_data: Dictionary = {} 

var is_in_fight = false
var current_deck_ref: DeckManager
var card_inspector: CardInspector

func _ready():
	# 1. Charger les données d'images
	_load_json_data()
	

	# 2. Setup Bouton
	if start_button:
		if not start_button.is_connected("pressed", Callable(self, "_on_start_combat_pressed")):
			start_button.connect("pressed", Callable(self, "_on_start_combat_pressed"))
			
	# 3. Setup Layout (Mise en page)
	_setup_layout()

# --- LOGIQUE DE MISE EN PAGE ---
func _setup_layout():
	var screen_size = get_viewport().size
	var margin_top = 20
	var margin_right = 20
	var slot_w = 200
	var slot_h = 330
	var reserve_w = 400 
	var gap = 40 
	
	var slots_total_width = (slot_w * 2) + 50 
	var slots_start_x = screen_size.x - slots_total_width - margin_right
	
	slot_zone.get_parent().global_position = Vector2(slots_start_x, margin_top)
	slot_zone.get_parent().custom_minimum_size = Vector2(slots_total_width, slot_h)
	
	var reserve_start_x = slots_start_x - reserve_w - gap
	card_zone2.global_position = Vector2(reserve_start_x, margin_top)
	card_zone2.custom_minimum_size = Vector2(reserve_w, slot_h)
	card_zone2.size = Vector2(reserve_w, slot_h)
	
	# Inspecteur de carte
	card_inspector = CardInspector.new()
	add_child(card_inspector)
	card_inspector.z_index = 100 
	var inspector_x = reserve_start_x - 50 
	var inspector_y = margin_top + slot_h + 20 
	card_inspector.global_position = Vector2(inspector_x, inspector_y)
	
	main_hand.connect("card_hovered", Callable(card_inspector, "show_card"))

# --- LOGIQUE JSON & VISUEL ENNEMI ---
func _load_json_data():
	if not FileAccess.file_exists(JSON_PATH):
		push_error("CombatManager : JSON introuvable à " + JSON_PATH)
		return

	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		pnj_data = json.data
		print("CombatManager : Données ennemis chargées.")
	else:
		push_error("Erreur JSON : " + json.get_error_message())

func set_random_enemy_visual(type_id: int):
	# Sécurité 1 : A-t-on l'ennemi ?
	if enemy_ref == null:
		push_error("CombatManager : ERREUR CRITIQUE, enemy_ref est null !")
		return

	# Sécurité 2 : A-t-on les données ?
	if pnj_data.is_empty() or not pnj_data.has("pnj"):
		return

	var type_str = str(type_id)
	var possible_paths: Array = []
	
	# Récupérer chemins spécifiques
	var specific = pnj_data["pnj"].get(type_str, {})
	if specific: possible_paths.append_array(specific.values())

	# Récupérer chemins communs
	var common = pnj_data["pnj"].get("all", {})
	if common: possible_paths.append_array(common.values())
	
	print("Chemins trouvés : ", possible_paths)
	# Tirage au sort et application
	if not possible_paths.is_empty():
		var random_path = possible_paths.pick_random()
		print("CombatManager envoie l'image : ", random_path)
		if enemy_ref.has_method("change_visual"):
			enemy_ref.change_visual(random_path)
	else:
		push_warning("Aucune image trouvée pour le type " + type_str)

# --- DEROULEMENT DU JEU ---
func setup_preparation_phase(type_id: int, deck_manager_ref: DeckManager):
	current_deck_ref = deck_manager_ref
	is_in_fight = false
	
	# C'est ici qu'on met à jour l'ennemi
	set_random_enemy_visual(type_id)
	
	start_button.show()
	card_zone2.show()
	slot_zone.get_parent().show()

	# Nettoyage visuel slots
	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			slot.remove_child(slot.carte_occupee) 
			
	main_hand.clear_hand()
	deck_manager_ref.prepare_combat_deck() 
	
	display_slots()
	display_skills()
	draw_cards(5) 
	
	dialogue_box.play_random_intro_by_type(type_id)

func _on_start_combat_pressed():
	if is_in_fight: return
	is_in_fight = true
	start_button.hide()
	card_zone2.hide()
	player.reset()
	update_hand_efficiency()
	combat_start.emit()

func _on_give_up_pressed():
	give_up.emit()

func update_hand_efficiency():
	var active_skills: Array[skill_card] = []
	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			if slot.carte_occupee.assigned_class:
				active_skills.append(slot.carte_occupee.assigned_class)
	
	for card_visual in $MainHand.get_children():
		if card_visual is FightCardsObject:
			var card_data = card_visual.assigned_class
			if card_data:
				card_data.calculate_efficiency(active_skills)

func _on_slots_changed():
	update_hand_efficiency()

func draw_cards(amount: int):
	if not current_deck_ref: return
	for i in range(amount):
		var card_info = current_deck_ref.draw()
		if card_info:
			add_card_to_zone(card_info)
	update_hand_efficiency()

func add_card_to_zone(card_info: FightCards):
	var carte_visuelle = card_info._carte
	if not carte_visuelle: return

	if not carte_visuelle.is_connected("gui_input", Callable(self, "_on_card_clicked")):
		carte_visuelle.connect("gui_input", Callable(self, "_on_card_clicked").bind(card_info))
	
	if carte_visuelle.get_parent():
		carte_visuelle.get_parent().remove_child(carte_visuelle)
		
	$MainHand.add_card(carte_visuelle)

func _on_card_clicked(event: InputEvent, carte_info: FightCards):
	if not is_in_fight: return 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var dmg = carte_info.getDamageWithBonus()
		var text_confirm = "Jouer " + carte_info.getName() + " ?\nDegats : " + str(dmg)
		if not carte_info.haveBonus():
			text_confirm += "\n(Inadapte : Efficacite reduite)"
			
		$ConfirmationAttack.dialog_text = text_confirm
		
		if $ConfirmationAttack.is_connected("confirmed", Callable(self, "_on_confirm_play")):
			$ConfirmationAttack.disconnect("confirmed", Callable(self, "_on_confirm_play"))
			
		$ConfirmationAttack.connect("confirmed", Callable(self, "_on_confirm_play").bind(carte_info))
		$ConfirmationAttack.show()

func _on_confirm_play(carte_info):
	var music = AudioStreamPlayer.new() # un peu de musique ou quoi????
	music.stream = preload("res://music/rot.wav")
	music.play()
	
	apply_card_effect(carte_info) 
	card_played.emit(carte_info)
	current_deck_ref.discard(carte_info)
	$MainHand.remove_card(carte_info._carte)

	if $MainHand.cartes.is_empty():
		print("Main vide ! Fin du tour.")
		await get_tree().create_timer(0.5).timeout
		combat_turn_ended.emit()

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

func display_slots():
	var container = slot_zone
	for child in container.get_children(): child.queue_free()
	for i in range(2):
		var slot = Slot.new()
		slot.connect("slot_updated", Callable(self, "_on_slots_changed"))
		container.add_child(slot)

func display_skills():
	if not current_deck_ref: return
	
	var skills = current_deck_ref.get_all_skills()
	var container = card_zone2.get_node("SkillsBox") 
	
	for skill_data in skills:
		var visual = skill_data._carte
		
		# --- AJOUT DE LA SÉCURITÉ ICI ---
		# Si le visuel n'existe plus (car il a été fusionné/supprimé), on passe au suivant
		if not is_instance_valid(visual): 
			continue
		# --------------------------------
		
		# Maintenant on est sûr que 'visual' existe, on peut appeler get_parent()
		if visual.get_parent() == container: continue
		
		if visual.get_parent(): 
			visual.get_parent().remove_child(visual)
		
		visual.custom_minimum_size = Vector2(180, 310)
		container.add_child(visual)
		visual.position = Vector2.ZERO
