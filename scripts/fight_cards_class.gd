class_name FightCards
extends RefCounted

# Type de la carte
enum CardType{
	ECONOMY,
	LEGAL,
	COMMUNICATION
} 


# --- Attributs ---
var _carte: FightCardsObject
var _cout: int
var _damage: int
var _have_bonus: bool
var _damage_with_bonus: int

# Nouveaux attributs
var effect_script: String  # Chemin vers le script d'effet
var _type: CardType    # Type de la carte (ACTION ou COMPETENCE)

# --- Constructeur ---
func _init(carte_instance: FightCardsObject, cout_valeur: int, damage: int, effect_path: String, type: CardType):
	
	_carte = carte_instance
	_carte.assigned_class = self
	_cout = cout_valeur
	_damage = damage
	effect_script = effect_path
	_type = type
	_have_bonus = false
	_damage_with_bonus = damage

# --- Méthodes ---
func getCout() -> int:
	return _cout

func getDamage() -> int:
	return _damage

func getDamageWithBonus() -> int:
	return _damage_with_bonus
	
func getName() -> String:
	return _carte.name

func getType() -> CardType:
	return _type
	
func getImage() -> Texture2D:
	return _carte.getImage()

func getDescription() -> String:
	return _carte.texte

func haveBonus() -> bool:
	return _have_bonus

func setHaveBonus(have_bonus: bool):
	_have_bonus = have_bonus

func updateDamageWithBonus(bonus: int):
	_damage_with_bonus = _damage + bonus
