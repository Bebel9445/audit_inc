extends Node
class_name DeckManager

# --- PILES ---
# Pile pour les cartes d'action (Combat / Main)
var draw_pile: Array[FightCards] = []
var discard_pile: Array[FightCards] = []

# Pile pour les cartes de compétence (Slots / Passif)
# J'ai renommé 'draw_pile_skill' en 'skill_pile' car on ne les "pioche" pas de la même façon
var skill_pile: Array[skill_card] = [] 

# --- Initialisation ---
func _init():
	reset_deck()

# --- Création du deck initial ---
func reset_deck():
	draw_pile.clear()
	discard_pile.clear()
	skill_pile.clear()

	# Chargement des images (placeholders)
	var img1 = load("res://icon.svg")
	var img2 = load("res://icon.svg") # Tu pourras charger tes vrais assets ici

	# ==========================================
	# 1. CRÉATION DES CARTES D'ACTION (FightCards)
	# ==========================================
	# Rappel : FightCardsObject.new(Nom, Description, Dégats, Image)
	var card1_obj = FightCardsObject.new("Vérification", "Passe un service en 'green'", 5, img1)
	var card2_obj = FightCardsObject.new("Observation", "Observe les conditions", 3, img2)
	var card3_obj = FightCardsObject.new("Entretien", "Effectue un entretien préventif", 4, img1)

	# Rappel : FightCards.new(Visuel, Coût, Dégat, ScriptEffet, Type)
	# Assure-toi que ta classe FightCards a bien le constructeur mis à jour avec CardType
	var card1 = FightCards.new(card1_obj, 2, 5, "res://scripts/effects/repair_service_effect.gd", FightCards.CardType.LEGAL)
	var card2 = FightCards.new(card2_obj, 1, 3, "res://scripts/effects/observe_service_effect.gd", FightCards.CardType.ECONOMY)
	var card3 = FightCards.new(card3_obj, 3, 4, "res://scripts/effects/maintenance_effect.gd", FightCards.CardType.COMMUNICATION)

	draw_pile = [card1, card2, card3]
	
	# On mélange la pioche d'action
	shuffle()

	# ==========================================
	# 2. CRÉATION DES CARTES DE COMPÉTENCE (skill_card)
	# ==========================================
	
	# A. Création du Visuel (object_skill_card)
	# Constructeur : _init(nom, niveau, image, pos_x, pos_y)
	# On met pos_x et pos_y à 0 car c'est le Slot qui gérera la position finale.
	var skill_visuel_1 = object_skill_card.new("Isolation", 1, img1, 0, 0)
	var skill_visuel_2 = object_skill_card.new("Audit Flash", 1, img2, 0, 0)
	
	# B. Création de la Data (skill_card)
	# Constructeur : _init(carte_instance, niveau, competence, bonus, type, effect_path)
	var skill_data_1 = skill_card.new(
		skill_visuel_1, 
		1, 
		"Isolation", 
		2,
		FightCards.CardType.LEGAL,
		"res://scripts/skills/isolation_skill.gd" # Exemple de script passif
	)
	
	var skill_data_2 = skill_card.new(
		skill_visuel_2, 
		1, 
		"Audit Flash", 
		1,
		FightCards.CardType.ECONOMY,
		"res://scripts/skills/flash_audit.gd"
	)

	skill_pile = [skill_data_1, skill_data_2]


# --- GESTION ACTIONS (Combat) ---

func shuffle():
	draw_pile.shuffle()

func draw() -> FightCards:
	if draw_pile.is_empty():
		reshuffle_discard()
	if draw_pile.is_empty():
		print("Deck vide !")
		return null
	return draw_pile.pop_back()

func discard(card: FightCards) -> void:
	if card != null:
		discard_pile.append(card)
	else:
		push_warning("Tentative de défausser une carte nulle")

func reshuffle_discard():
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

# --- GESTION COMPÉTENCES (Inventaire) ---

# Récupère toutes les compétences (pour les afficher dans ton menu de choix ou ton inventaire)
func get_all_skills() -> Array[skill_card]:
	return skill_pile

# Recherche une carte par son nom (utile pour les effets)
func get_card_by_name(name: String):
	# Cherche dans les actions
	for card in draw_pile + discard_pile:
		if card._carte.name == name:
			return card
	
	# Cherche dans les compétences
	for skill in skill_pile:
		if skill.getCompetence() == name:
			return skill
			
	return null
