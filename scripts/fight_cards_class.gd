class_name FightCards
extends RefCounted

# Type de la carte
enum CardType {
	ECONOMY,
	LEGAL,
	COMMUNICATION
} 

# --- Attributs ---
var _carte: FightCardsObject
var _lvl: int
var _cout: int
var _damage: int
var _have_bonus: bool = false
var _damage_with_bonus: int
var _type: CardType
var effect_script: String

# --- Constructeur ---
func _init(carte_instance: FightCardsObject, lvl: int,  cout_valeur: int, damage: int, effect_path: String, type: CardType):
	_carte = carte_instance
	_carte.assigned_class = self
	_lvl = lvl
	_cout = cout_valeur
	_damage = damage
	effect_script = effect_path
	_type = type
	_damage_with_bonus = damage # Valeur par défaut

# --- Méthodes ---
func getLvl() -> int: return _lvl
func getCout() -> int: return _cout
func getDamage() -> int: return _damage
func getDamageWithBonus() -> int: return _damage_with_bonus
func getName() -> String: return _carte.name
func getType() -> CardType: return _type
func getImage() -> Texture2D: return _carte.getImage()
func getDescription() -> String: return _carte.texte
func haveBonus() -> bool: return _have_bonus
func setHaveBonus(have_bonus: bool): _have_bonus = have_bonus

func calculate_efficiency(equipped_skills: Array[skill_card]):
	var requirement_met = false
	
	for skill in equipped_skills:
		if skill.getType() == _type and skill.getNiveau() >= _lvl:
			requirement_met = true
			break
	
	if requirement_met:
		_damage_with_bonus = _damage
		_have_bonus = true
	else:
		_damage_with_bonus = 3 
		_have_bonus = false

	update_visual_text()

func update_visual_text():
	if _carte and _carte.labelState:
		if _have_bonus:
			_carte.labelState.text = "Dégâts : " + str(_damage_with_bonus) + " (OK)"
			_carte.labelState.modulate = Color.GREEN
		else:
			_carte.labelState.text = "Dégâts : " + str(_damage_with_bonus) + " (Nul)"
			_carte.labelState.modulate = Color.RED
