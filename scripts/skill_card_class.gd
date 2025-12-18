class_name skill_card
extends RefCounted

# --- ATTRIBUTS ---

## Référence vers l'objet visuel (le noeud Godot) associé à cette donnée.
var _carte: object_skill_card

## Niveau actuel de la compétence (impacte le bonus).
var _niveau_carte: int

## Nom de la compétence affiché.
var _competence: String

## Chemin vers le script GDScript qui contient l'effet unique de la carte.
var effect_script: String 

## Valeur de base du bonus au niveau 1.
var _bonus_initial: int

## Valeur actuelle du bonus (Calculé : base * niveau).
var _bonus: int         

## Type de la carte (Economie, Juridique, etc.) pour les synergies.
var _type: FightCards.CardType 

# --- CONSTRUCTEUR ---

## Initialise une nouvelle carte de compétence logique et la lie à son visuel.
func _init(carte_instance: object_skill_card, niveau: int, competence: String, bonus: int, type: FightCards.CardType, effect_path: String = ""):
	_carte = carte_instance
	_carte.assigned_class = self # Lien bidirectionnel
	_competence = competence
	_niveau_carte = niveau
	_type = type
	effect_script = effect_path
	_bonus_initial = bonus
	updateBonus()

# --- MÉTHODES PUBLIQUES ---

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

## Met à jour le niveau de la carte (utilisé lors de la fusion).
## Recalcule automatiquement le bonus.
func setNiveau(nouveau_niveau: int):
	_niveau_carte = nouveau_niveau
	updateBonus()

## Recalcule le bonus effectif basé sur le niveau actuel.
func updateBonus():
	_bonus = _bonus_initial * _niveau_carte
