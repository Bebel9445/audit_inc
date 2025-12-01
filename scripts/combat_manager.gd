extends Node
class_name CombatManager

@onready var card_zone2 = $CardZone2
@onready var slot_zone = $SlotZone/SlotHBox
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox

@onready var deck_manager = preload("res://scripts/deck_manager.gd").new()
@onready var player = preload("res://scripts/player.gd").new()
#@onready var slot = preload("res://scripts/slot.gd")

var turn := 1

# --- Démarrage ---
func _ready():
	start_combat()

# --- Initialisation du combat ---
func start_combat():
	player.reset()
	deck_manager.shuffle() # Mélange les actions
	
	# 1. Piocher les cartes d'action
	draw_cards(3)
	
	# 2. Afficher les compétences
	display_skills() 
	
	display_slots()

	if not dialogue_box.is_connected("dialogue_finished", Callable(self, "_on_dialogue_finished")):
		dialogue_box.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

	var intro_dialogue = load("res://data/dialogues/combat_intro.tres")
	dialogue_box.load_dialogue_resource(intro_dialogue)

func _on_dialogue_finished():
	dialogue_box.show_text("À toi de jouer !")

func display_slots():
	var container = slot_zone
	if container == null:
		push_error("Erreur : Impossible de trouver le conteneur 'SlotHBox' dans SlotZone")
		return
	
	# On nettoie le conteneur au cas où
	for child in container.get_children():
		child.queue_free()
	
	# on créer 2 slots
	for i in range(2):
		var slot = Slot.new()
		slot.custom_minimum_size = Vector2(140, 180)
		container.add_child(slot)
		slot.position = Vector2.ZERO

# --- NOUVELLE FONCTION : Affiche les compétences dans CardZone2 ---
func display_skills():
	# On récupère le tableau des compétences depuis le DeckManager
	var skills: Array[skill_card] = deck_manager.get_all_skills()
	
	# Adapte le chemin ici si ton arborescence est différente (ex: "ScrollContainer/SkillsBox")
	var container = card_zone2.get_node("SkillsBox") 
	
	if container == null:
		push_error("Erreur : Impossible de trouver le conteneur 'SkillsBox' dans CardZone2")
		return

	# On nettoie le conteneur au cas où
	for child in container.get_children():
		child.queue_free()

	# On ajoute chaque carte
	for skill_data in skills:
		var visual_card = skill_data._carte
		
		# Sécurité : Si la carte a déjà un parent ailleurs, on la détache
		if visual_card.get_parent():
			visual_card.get_parent().remove_child(visual_card)
		
		# --- REDIMENSIONNEMENT ---
		# C'est ici qu'on force la taille plus petite !
		# Par exemple : 140x180 (au lieu de la taille standard qui est souvent plus grande)
		visual_card.custom_minimum_size = Vector2(140, 180)
		
		# Si tu veux aussi réduire la police, c'est plus complexe, 
		# mais réduire la taille du conteneur suffit souvent.
		# On peut aussi utiliser scale, mais dans un Container c'est déconseillé.
		
		# On l'ajoute au conteneur
		container.add_child(visual_card)
		
		# Reset de position standard
		visual_card.position = Vector2.ZERO


# --- Pioche de cartes (Actions) ---
func draw_cards(amount: int):
	for i in range(amount):
		var card_info: FightCards = deck_manager.draw()
		if card_info:
			print("Carte piochée :", card_info.getName())
			add_card_to_zone(card_info)
		else:
			print("Aucune carte à piocher.")

# --- Ajoute une carte dans la zone de jeu (Actions) ---
func add_card_to_zone(card_info: FightCards):
	var carte_visuelle: FightCardsObject = card_info._carte
	if not carte_visuelle:
		push_warning("Carte invalide : aucun visuel associé.")
		return

	# On remet la taille par défaut pour les cartes d'action (au cas où elle aurait été réduite)
	carte_visuelle.custom_minimum_size = Vector2(200, 250) # Taille normale

	# Connecte le clic sur la carte à la fonction de jeu
	if not carte_visuelle.is_connected("gui_input", Callable(self, "_on_card_clicked")):
		carte_visuelle.connect("gui_input", Callable(self, "_on_card_clicked").bind(card_info))

	$MainHand.add_card(carte_visuelle)

# --- Quand une carte est cliquée ---
func _on_card_clicked(event: InputEvent, carte_info: FightCards):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_card_played(carte_info)

# --- Quand une carte est jouée ---
func _on_card_played(carte_info: FightCards):
	var card_cost := carte_info.getCout()

	if player.energy < card_cost:
		dialogue_box.show_text("Pas assez d’énergie !")
		return

	player.energy -= card_cost
	print("Carte jouée :", carte_info.getName(), "| Coût :", card_cost)

	apply_card_effect(carte_info)
	
	# On retire le visuel de l'écran avant de défausser
	if carte_info._carte.get_parent():
		carte_info._carte.get_parent().remove_child(carte_info._carte)
	
	deck_manager.discard(carte_info)

# --- Application de l’effet d’une carte ---
func apply_card_effect(carte_info: FightCards):
	if carte_info.effect_script != "":
		var effect_class = load(carte_info.effect_script)
		if effect_class:
			var effect_instance = effect_class.new()
			add_child(effect_instance)
			effect_instance.apply(service_display, player)
		else:
			push_warning("Impossible de charger l’effet : " + str(carte_info.effect_script))
	else:
		print("Aucun effet défini pour :", carte_info.getName())

func apply_bonus_from_slot():# Mieux de mettre les classes en paramètres 
	var card = object_skill_card

	for slot in slot_zone.get_children():
		if slot is Slot:
			if slot.carte_occupee != null:
				card = slot.carte_occupee
				apply_bonus(card.type, card.bonus)# IL FAUT ABSOLUMENT LE CHANGER 

func apply_bonus(type: String, bonus: int):
	for fight_card in $MainHand.get_children():
		if not fight_card is FightCardsObject:
			return
		if fight_card.type == type:
			fight_card.damage += bonus
			fight_card.labelState.text = "Dégats : " + str(fight_card.damage)
