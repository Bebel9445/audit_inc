extends Node

class_name DeckManager

# Les piles
var draw_pile: Array[Resource] = []
var discard_pile: Array[Resource] = []

# --- Initialisation ---
func _init():
	# Remplir le deck au moment de la création
	draw_pile = [
		preload("res://assets/cards/verification.tres"),
		preload("res://assets/cards/observation.tres"),
		preload("res://assets/cards/entretien.tres")
	]
	discard_pile = []

# Mélanger le deck
func shuffle():
	draw_pile.shuffle()

# Tirer une carte
func draw() -> Resource:
	# Si le draw pile est vide, reshuffle la défausse
	if draw_pile.is_empty():
		reshuffle_discard()
	
	if draw_pile.is_empty():
		print("Deck is empty!")
		return null
	
	return draw_pile.pop_back()

# Mettre une carte dans la défausse
func discard(card: Resource) -> void:
	discard_pile.append(card)

# Remettre la défausse dans le draw pile
func reshuffle_discard() -> void:
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

# Méthode pratique pour réinitialiser le deck (par exemple au début d’un combat)
func reset_deck() -> void:
	# Recharge toutes les cartes originales
	draw_pile = [
		preload("res://assets/cards/verification.tres"),
		preload("res://assets/cards/observation.tres"),
		preload("res://assets/cards/entretien.tres")
	]
	discard_pile.clear()
	shuffle()
