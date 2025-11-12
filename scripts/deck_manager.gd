extends Node
class_name DeckManager

# --- Types de piles ---
var draw_pile: Array[FightCards] = []
var discard_pile: Array[FightCards] = []

# --- Initialisation ---
func _init():
	reset_deck()

# --- Création du deck initial ---
func reset_deck():
	draw_pile.clear()
	discard_pile.clear()

	# Création des FightCards avec leurs infos de base
	# Tu peux évidemment étendre ou charger ces données depuis un JSON ou autre
	var img1 = load("res://icon.svg")
	var img2 = load("res://icon.svg")
	var img3 = load("res://icon.svg")

	var card1_obj = FightCardsObject.new("Vérification", 1, "Vérifie les systèmes critiques", 5, img1)
	var card2_obj = FightCardsObject.new("Observation", 1, "Observe les conditions de travail", 3, img2)
	var card3_obj = FightCardsObject.new("Entretien", 1, "Effectue un entretien préventif", 4, img3)

	var card1 = FightCards.new(card1_obj, 2, 1, 5)
	var card2 = FightCards.new(card2_obj, 1, 1, 3)
	var card3 = FightCards.new(card3_obj, 3, 1, 4)

	draw_pile = [card1, card2, card3]
	shuffle()

# --- Mélanger le deck ---
func shuffle():
	draw_pile.shuffle()

# --- Tirer une carte ---
func draw() -> FightCards:
	if draw_pile.is_empty():
		reshuffle_discard()
	if draw_pile.is_empty():
		print("Deck vide !")
		return null
	return draw_pile.pop_back()

# --- Défausser une carte ---
func discard(card: FightCards) -> void:
	if card != null:
		discard_pile.append(card)
	else:
		push_warning("Tentative de défausser une carte nulle")

# --- Remettre la défausse dans la pioche ---
func reshuffle_discard():
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

# --- Obtenir les infos d’une carte par son nom ---
func get_card_by_name(name: String) -> FightCards:
	for card in draw_pile + discard_pile:
		if card._carte.name == name:
			return card
	return null
