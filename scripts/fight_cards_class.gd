class_name FightCards
extends RefCounted

# --- DEFINITION DU TYPE ---
enum CardType { 
	ACTION,      # Carte jouable en combat (Main)
	COMPETENCE   # Carte passive (Slot)
}

# --- Attributs ---
var _carte: FightCardsObject
var _cout: int
var _niveau_carte: int
var _degat: int

# Nouveaux attributs
var effect_script: String  # Chemin vers le script d'effet
var card_type: CardType    # Type de la carte (ACTION ou COMPETENCE)

# --- Constructeur ---
func _init(carte_instance: FightCardsObject, cout_valeur: int, niveau: int, degat: int, 
		   effect_path: String, type_de_carte: CardType):
	
	_carte = carte_instance
	_cout = cout_valeur
	_degat = degat
	effect_script = effect_path
	card_type = type_de_carte
	
	setNiveau(niveau)

# --- Méthodes ---
func getCout() -> int:
	return _cout

func getNiveau() -> int:
	return _niveau_carte

func getDegat() -> int:
	return _degat

func setNiveau(niveau: int):
	_niveau_carte = niveau
	self.augmenter_degat(_niveau_carte)
	# Vérification de sécurité si l'objet visuel a bien le label
	if _carte and "labelNiveau" in _carte:
		_carte.labelNiveau.text = "lvl. " + str(_niveau_carte)
	
func getName() -> String:
	return _carte.name
	
func getImage() -> Texture2D:
	return _carte.getImage()

func getDescription() -> String:
	return _carte.texte
	
func augmenter_degat(multiplicateur: int):
	_degat *= multiplicateur
	if _carte and "labelState" in _carte:
		_carte.labelState.text = "Dégats : " + str(_degat)
