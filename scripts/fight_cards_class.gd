class_name FightCards
extends RefCounted # permet de créer des objets “légers” non liés à une scène (Node).
# En gros c'est pour pas avoir à mettre de extend (je crois)

# --- Attributs ---
var _carte: FightCardsObject
var _cout: int	# ça coûte x semaines à jouer la catre comme Abel à proposé
var _niveau_carte: int
var _degat: int

# --- Constructeur ---
func _init(carte_instance: FightCardsObject, cout_valeur: int, niveau: int, degat: int):
	_carte = carte_instance
	_cout = cout_valeur
	_degat = degat
	self.setNiveau(niveau)

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
	_carte.labelNiveau.text = "lvl. " + str(_niveau_carte)
	
func getName() -> String:
	return _carte.name
	
func getImage() -> Texture2D:
	return _carte.getImage()

func getDescription() -> String:
	return _carte.texte
	
func augmenter_degat(multiplicateur: int):
	_degat *= multiplicateur
	_carte.labelState.text = "Dégats : " + str(_degat)
