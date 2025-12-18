extends Node
class_name CombatManager

# --- SIGNAUX ---
signal combat_start
signal card_played(FightCards)
signal combat_turn_ended
signal give_up

const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")
const JSON_PATH = "res://data/pnj.json"

@onready var card_zone2 = $CardZone2
@onready var slot_zone = $SlotZone/SlotHBox
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox
@onready var start_button = $StartCombat
@onready var give_up_button = $GiveUp
@onready var main_hand = $MainHand
@onready var confirm_popup = $ConfirmationAttack 

# --- BOUTONS ---
@onready var btn_prev = $MainHand/PrevButton
@onready var btn_next = $MainHand/NextButton

var enemy_ref: Enemy = null 
var pnj_data: Dictionary = {} 
var is_in_fight = false
var current_deck_ref: DeckManager
var card_inspector: CardInspector

func _ready():
	_load_json_data()
	if start_button:
		if not start_button.is_connected("pressed", Callable(self, "_on_start_combat_pressed")):
			start_button.connect("pressed", Callable(self, "_on_start_combat_pressed"))
			
	# --- CONNEXION CLIC CARTE ---
	if main_hand:
		if not main_hand.is_connected("card_clicked", Callable(self, "_on_card_clicked_signal")):
			main_hand.connect("card_clicked", Callable(self, "_on_card_clicked_signal"))

	# --- ASSIGNATION DES BOUTONS ---
	# IMPORTANT : On donne les références à MainHand pour qu'il ne les supprime pas !
	if btn_prev and btn_next:
		main_hand.btn_prev = btn_prev
		main_hand.btn_next = btn_next
		
		# Connexion Pagination
		if btn_prev.is_connected("pressed", Callable(main_hand, "change_page")):
			btn_prev.disconnect("pressed", Callable(main_hand, "change_page"))
		if btn_next.is_connected("pressed", Callable(main_hand, "change_page")):
			btn_next.disconnect("pressed", Callable(main_hand, "change_page"))
			
		btn_prev.pressed.connect(main_hand.change_page.bind(-1))
		btn_next.pressed.connect(main_hand.change_page.bind(1))
	else:
		push_warning("CombatManager: Boutons Prev/Next introuvables !")

	_setup_layout()

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
	
	card_inspector = CardInspector.new()
	add_child(card_inspector)
	card_inspector.z_index = 100 
	var inspector_x = reserve_start_x + 200 
	var inspector_y = margin_top + slot_h + 20 
	card_inspector.global_position = Vector2(inspector_x, inspector_y)
	
	if not main_hand.is_connected("card_hovered", Callable(card_inspector, "show_card")):
		main_hand.connect("card_hovered", Callable(card_inspector, "show_card"))

func _load_json_data():
	if not FileAccess.file_exists(JSON_PATH): return
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK: pnj_data = json.data

func set_random_enemy_visual(type_id: int):
	if enemy_ref == null or pnj_data.is_empty() or not pnj_data.has("pnj"): return
	var type_str = str(type_id)
	var possible_paths: Array = []
	var specific = pnj_data["pnj"].get(type_str, {})
	if specific: possible_paths.append_array(specific.values())
	var common = pnj_data["pnj"].get("all", {})
	if common: possible_paths.append_array(common.values())
	if not possible_paths.is_empty():
		enemy_ref.change_visual(possible_paths.pick_random())

func setup_preparation_phase(type_id: int, deck_manager_ref: DeckManager):
	current_deck_ref = deck_manager_ref
	is_in_fight = false
	set_random_enemy_visual(type_id)
	
	start_button.show()
	card_zone2.show()
	slot_zone.get_parent().show()

	for slot in slot_zone.get_children():
		if slot is Slot and slot.carte_occupee != null:
			slot.remove_child(slot.carte_occupee) 
			
	deck_manager_ref.prepare_combat_deck() 
	
	# Chargement propre
	main_hand.load_full_deck(deck_manager_ref.master_deck) 
	
	display_slots()
	display_skills()
	
	dialogue_box.play_random_intro_by_type(type_id)

func _on_start_combat_pressed():
	if is_in_fight: return
	is_in_fight = true
	start_button.hide()
	card_zone2.hide()
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
	
	for card_visual in main_hand.visible_cards_objects:
		if card_visual is FightCardsObject:
			var card_data = card_visual.assigned_class
			if card_data:
				card_data.calculate_efficiency(active_skills)
				if card_visual.has_method("update_visual_state"):
					card_visual.update_visual_state()

func _on_slots_changed():
	update_hand_efficiency()

# --- CLIC & CONFIRMATION ---
func _on_card_clicked_signal(carte_info: FightCards):
	if not is_in_fight: return 
	
	var dmg = carte_info.getDamageWithBonus()
	var message = ""
	
	if not carte_info.haveBonus():
		dmg = int(dmg * 0.5) 
		message = "\n(PENALITE : Incompatible -50%)"
	
	var text_confirm = "Jouer " + carte_info.getName() + " ?\nDegats : " + str(dmg) + message
	$ConfirmationAttack.dialog_text = text_confirm
	
	if $ConfirmationAttack.is_connected("confirmed", Callable(self, "_on_confirm_play")):
		$ConfirmationAttack.disconnect("confirmed", Callable(self, "_on_confirm_play"))
	$ConfirmationAttack.connect("confirmed", Callable(self, "_on_confirm_play").bind(carte_info))
	
	$ConfirmationAttack.show()

func _on_confirm_play(carte_info):
	var music = AudioStreamPlayer.new() 
	music.stream = preload("res://music/rot.wav")
	add_child(music)
	music.play()
	
	apply_card_effect(carte_info) 
	card_played.emit(carte_info)
	current_deck_ref.discard(carte_info)
	
	# On retire la carte jouée
	main_hand.remove_card_logic(carte_info)
	
	update_hand_efficiency()
	
	if main_hand.all_cards_logic.is_empty():
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
		if not is_instance_valid(visual): continue
		if visual.get_parent() == container: continue
		if visual.get_parent(): visual.get_parent().remove_child(visual)
		visual.custom_minimum_size = Vector2(180, 310)
		container.add_child(visual)
		visual.position = Vector2.ZERO
