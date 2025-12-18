extends Control
class_name MainHand

# --- SIGNAUX ---
signal card_hovered(card_data)
signal card_clicked(card_data)

# --- LOGIQUE ---
var all_cards_logic: Array[FightCards] = []
var current_page_index: int = 0
const CARDS_PER_PAGE: int = 5

# --- VISUEL ---
var visible_cards_objects: Array[FightCardsObject] = []
var spacing := 100        
var arc_height := 25     
var hover_raise := 40    
var hover_scale := 1.2 
var hover_spread := 30  
var animation_speed := 0.15
var hovered_card: FightCardsObject = null

# --- BOUTONS (Référence directe) ---
@onready var btn_prev: BaseButton = $PrevButton
@onready var btn_next: BaseButton = $NextButton

# --- INITIALISATION ---

func _ready():
	# 1. Connexion des signaux
	if btn_prev:
		btn_prev.pressed.connect(func(): change_page(-1))
		btn_prev.z_index = 200 
	else:
		push_error("MainHand: 'PrevButton' introuvable !")

	if btn_next:
		btn_next.pressed.connect(func(): change_page(1))
		btn_next.z_index = 200
	else:
		push_error("MainHand: 'NextButton' introuvable !")

# --- GESTION DU DECK ---

## Fonction clé pour vider la main sans tuer les boutons
func clear_hand():
	# 1. On vide les listes logiques et visuelles
	visible_cards_objects.clear()
	all_cards_logic.clear()
	
	# 2. On supprime les noeuds enfants SAUF les boutons
	for child in get_children():
		if child == btn_prev or child == btn_next:
			continue
		
		remove_child(child)
		child.queue_free()
	
	# 3. Reset pagination
	current_page_index = 0
	_update_buttons_state()

func load_full_deck(deck: Array[FightCards]):
	# On utilise notre fonction sécurisée d'abord
	clear_hand()
	
	# Ensuite on charge
	all_cards_logic = deck.duplicate() 
	current_page_index = 0
	_refresh_display()

func remove_card_logic(card_logic: FightCards):
	if all_cards_logic.has(card_logic):
		all_cards_logic.erase(card_logic)
		# Gestion des pages vides
		if current_page_index > 0:
			var total_pages = ceil(float(all_cards_logic.size()) / float(CARDS_PER_PAGE))
			if current_page_index >= total_pages:
				current_page_index = max(0, int(total_pages) - 1)
		_refresh_display()

func change_page(direction: int):
	var new_index = current_page_index + direction
	var max_page = 0
	if all_cards_logic.size() > 0:
		max_page = ceil(float(all_cards_logic.size()) / float(CARDS_PER_PAGE)) - 1
	
	if new_index < 0: return
	if new_index > max_page: return
	
	current_page_index = new_index
	_refresh_display()

# --- AFFICHAGE ---

func _refresh_display():
	# On retire visuellement les cartes actuelles
	for c in visible_cards_objects:
		if c and c.get_parent() == self: 
			remove_child(c)
	
	visible_cards_objects.clear()
	
	if all_cards_logic.is_empty():
		_update_buttons_state()
		return

	var start_idx = current_page_index * CARDS_PER_PAGE
	var end_idx = min(start_idx + CARDS_PER_PAGE, all_cards_logic.size())
	
	# Instanciation
	for i in range(start_idx, end_idx):
		var logic = all_cards_logic[i]
		_instantiate_visual_card(logic)
	
	_update_buttons_state()
	_update_positions(true) 

func _instantiate_visual_card(logic: FightCards):
	var visual = logic._carte
	if not visual: return
	
	# --- TAILLE FIXE ---
	var fixed_size = Vector2(220, 340)
	visual.custom_minimum_size = fixed_size
	visual.size = fixed_size
	visual.set_anchors_preset(Control.PRESET_TOP_LEFT)
	
	# --- NOM ---
	if logic.getName() != "":
		visual.name = logic.getName().validate_node_name()
	
	# --- GESTION PARENTÉ ---
	if visual.get_parent(): visual.get_parent().remove_child(visual)
	
	add_child(visual)
	visible_cards_objects.append(visual)
	
	# --- CONNEXIONS ---
	if visual.is_connected("mouse_entered", Callable(self, "_on_card_mouse_enter")):
		visual.disconnect("mouse_entered", Callable(self, "_on_card_mouse_enter"))
	if visual.is_connected("mouse_exited", Callable(self, "_on_card_mouse_exit")):
		visual.disconnect("mouse_exited", Callable(self, "_on_card_mouse_exit"))
	if visual.is_connected("gui_input", Callable(self, "_on_card_gui_input")):
		visual.disconnect("gui_input", Callable(self, "_on_card_gui_input"))
		
	visual.mouse_entered.connect(_on_card_mouse_enter.bind(visual))
	visual.mouse_exited.connect(_on_card_mouse_exit.bind(visual))
	visual.gui_input.connect(_on_card_gui_input.bind(logic))

func _update_buttons_state():
	if btn_prev:
		btn_prev.disabled = (current_page_index == 0)
		btn_prev.modulate.a = 0.5 if btn_prev.disabled else 1.0
		
	if btn_next:
		var max_page = 0
		if all_cards_logic.size() > 0:
			max_page = ceil(float(all_cards_logic.size()) / float(CARDS_PER_PAGE)) - 1
		btn_next.disabled = (current_page_index >= max_page)
		btn_next.modulate.a = 0.5 if btn_next.disabled else 1.0

# --- EVENTS SOURIS ---

func _on_card_gui_input(event: InputEvent, card_logic: FightCards):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("card_clicked", card_logic)

func _on_card_mouse_enter(carte):
	hovered_card = carte
	_update_positions()
	if carte.assigned_class:
		emit_signal("card_hovered", carte.assigned_class)

func _on_card_mouse_exit(carte):
	if hovered_card == carte:
		hovered_card = null
		emit_signal("card_hovered", null)
	_update_positions()

func _update_positions(instantly := false):
	if visible_cards_objects.is_empty(): return
	
	var count := visible_cards_objects.size()
	var center_x := size.x / 2
	var start_x := center_x - ((count - 1) * spacing) / 2

	for i in range(count):
		var card := visible_cards_objects[i]
		if not is_instance_valid(card): continue
		
		var t := (i - (count - 1) / 2.0)
		
		# Position X
		var target_x := start_x + i * spacing - (card.size.x / 2)
		
		# Position Y (Arc de cercle)
		var target_y = -abs(t) * abs(t) * 2 + arc_height + 40
		
		var target_rot = deg_to_rad(t * 5)
		var target_scale := 1.0

		# Gestion du survol
		if card == hovered_card:
			target_y -= hover_raise
			target_scale = hover_scale
			target_rot = 0 
			card.z_index = 100 
		elif hovered_card != null:
			card.z_index = i 
			var hover_index := visible_cards_objects.find(hovered_card)
			var distance = abs(i - hover_index)
			if distance == 1:
				if (i < hover_index): target_x -= hover_spread 
				else: target_x += hover_spread 
		else:
			card.z_index = i

		# Application
		if instantly:
			card.position = Vector2(target_x, target_y)
			card.rotation = target_rot
			card.scale = Vector2.ONE * target_scale
		else:
			card.position = card.position.lerp(Vector2(target_x, target_y), animation_speed)
			card.rotation = lerp_angle(card.rotation, target_rot, animation_speed)
			card.scale = card.scale.lerp(Vector2.ONE * target_scale, animation_speed)
