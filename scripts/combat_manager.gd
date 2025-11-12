extends Node
class_name CombatManager

@onready var card_zone = $CardZone
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox

@onready var deck_manager = preload("res://scripts/deck_manager.gd").new()
@onready var player = preload("res://scripts/player.gd").new()

var turn := 1

# --- Démarrage ---
func _ready():
	start_combat()

# --- Initialisation du combat ---
func start_combat():
	player.reset()
	deck_manager.shuffle()
	draw_cards(3)

	if not dialogue_box.is_connected("dialogue_finished", Callable(self, "_on_dialogue_finished")):
		dialogue_box.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

	var intro_dialogue = load("res://data/dialogues/combat_intro.tres")
	dialogue_box.load_dialogue_resource(intro_dialogue)

func _on_dialogue_finished():
	dialogue_box.show_text("À toi de jouer !")

# --- Pioche de cartes ---
func draw_cards(amount: int):
	for i in range(amount):
		var card_info: FightCards = deck_manager.draw()
		if card_info:
			print("Carte piochée :", card_info.getName())
			add_card_to_zone(card_info)
		else:
			print("Aucune carte à piocher.")

# --- Ajoute une carte dans la zone de jeu ---
func add_card_to_zone(card_info: FightCards):
	var carte_visuelle: FightCardsObject = card_info._carte
	if not carte_visuelle:
		push_warning("Carte invalide : aucun visuel associé.")
		return

	# Connecte le clic sur la carte à la fonction de jeu
	if not carte_visuelle.is_connected("gui_input", Callable(self, "_on_card_clicked")):
		carte_visuelle.connect("gui_input", Callable(self, "_on_card_clicked").bind(card_info))

	var container = card_zone.get_node("CardsVBox")
	container.add_child(carte_visuelle)


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
	deck_manager.discard(carte_info)

# --- Application de l’effet d’une carte ---
func apply_card_effect(carte_info: FightCards):
	# Optionnel : si tu veux retrouver une data liée à cette carte
	var card_data = deck_manager.get_card_by_name(carte_info.getName())

	if card_data and "effect_script" in card_data:
		if card_data.effect_script != "":
			var effect_class = load(card_data.effect_script)
			if effect_class:
				var effect_instance = effect_class.new()
				add_child(effect_instance)
				effect_instance.apply(service_display, player)
			else:
				push_warning("Impossible de charger l’effet : " + str(card_data.effect_script))
		else:
			print("Aucun effet défini pour :", carte_info.getName())
	else:
		print("Aucune donnée d’effet trouvée pour :", carte_info.getName())
