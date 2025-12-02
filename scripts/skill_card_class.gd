class_name skill_card
extends RefCounted

# --- Attributs ---
var _carte: object_skill_card
var _niveau_carte: int
var _competence: String
var effect_script: String # Chemin vers le script d'effet passif
var _bonus_initial: int
var _bonus: int	 	# Le bonus qu'on attriburea aux cartes de combat
var _type: FightCards.CardType 

# --- Constructeur ---
func _init(carte_instance: object_skill_card, niveau: int, competence: String, bonus: int, type: FightCards.CardType, effect_path: String = ""):
	_carte = carte_instance
	_carte.assigned_class = self
	_competence = competence
	_niveau_carte = niveau
	_type = type
	effect_script = effect_path
	_bonus_initial = bonus
	updateBonus()

# --- Méthodes ---
func getCompetence() -> String:
	return _competence

func getNiveau() -> int:
	return _niveau_carte

func getType() -> FightCards.CardType:
	return _type

func getEffectScript() -> String:
	return effect_script

func getBonus() -> int:
	return _bonus

# --- AJOUT POUR LA FUSION ---
# Appelle cette fonction quand deux cartes fusionnent visuellement
# pour mettre à jour la donnée réelle.
func setNiveau(nouveau_niveau: int):
	_niveau_carte = nouveau_niveau
	updateBonus()

func updateBonus():
	_bonus = _bonus_initial * _niveau_carte	
