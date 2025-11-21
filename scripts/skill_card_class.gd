class_name skill_card
extends RefCounted

# --- Attributs ---
var _carte: object_skill_card
var _niveau_carte: int
var _competence: String
var effect_script: String # Chemin vers le script d'effet passif

# --- Constructeur ---
func _init(carte_instance: object_skill_card, niveau: int, competence: String, effect_path: String = ""):
	_carte = carte_instance
	_competence = competence
	_niveau_carte = niveau
	effect_script = effect_path

# --- Méthodes ---
func getCompetence() -> String:
	return _competence

func getNiveau() -> int:
	return _niveau_carte

func getEffectScript() -> String:
	return effect_script

# --- AJOUT POUR LA FUSION ---
# Appelle cette fonction quand deux cartes fusionnent visuellement
# pour mettre à jour la donnée réelle.
func setNiveau(nouveau_niveau: int):
	_niveau_carte = nouveau_niveau
