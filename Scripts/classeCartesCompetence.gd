class_name CarteDeCompetence
extends RefCounted # permet de créer des objets “légers” non liés à une scène (Node).
# En gros c'est pour pas avoir à mettre de extend (je crois)

# --- Attributs ---
var _carte: ObjetCarteCompetence
var _niveau_carte: int
var _competence: String

# --- Constructeur ---
func _init(carte_instance: ObjetCarteCompetence, comptence: String):
	_carte = carte_instance
	_competence = comptence
	_niveau_carte = _carte._niveau

# --- Méthodes ---
func getCompetence() -> String:
	return _competence

func getNiveau() -> int:
	return _niveau_carte
