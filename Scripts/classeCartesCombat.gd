class_name CarteDeCombat
extends RefCounted # permet de créer des objets “légers” non liés à une scène (Node).
# En gros c'est pour pas avoir à mettre de extend (je crois)

# --- Attributs ---
var _carte: ObjetCarteCombat
var _cout: int	# ça coûte x semaines à jouer la catre comme Abel à proposé
var _niveau_carte: int
var _degat: int

# --- Constructeur ---
func _init(carte_instance: ObjetCarteCombat, cout_valeur: int, niveau: int, degat: int):
	_carte = carte_instance
	_cout = cout_valeur
	_niveau_carte = niveau
	_degat = degat
	self.augmenter_degat(_niveau_carte)

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
	_carte.labelNiveau.text = str(_niveau_carte)

func augmenter_degat(multiplicateur: int):
	_degat *= multiplicateur
	_carte.labelState.text = "Dégats : " + str(_degat)
