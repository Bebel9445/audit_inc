class_name FightCards
extends RefCounted

# Enumération des types de services/cartes
enum CardType {
	ECONOMY,
	LEGAL,
	COMMUNICATION
} 

# --- ATTRIBUTS ---

## Référence vers l'objet visuel (Noeud UI) associé.
var _carte: FightCardsObject

## Niveau requis de la carte.
var _lvl: int

## Coût en points d'action (pas utilisé actuellement mais prévu).
var _cout: int

## Dégâts de base (affichés sur la carte).
var _damage: int

## Indique si la carte bénéficie du bonus de compétence active.
var _have_bonus: bool = false

## Dégâts réels calculés (Base + Bonus compétence).
var _damage_with_bonus: int

## Type de la carte (Doit correspondre au type de compétence pour activer le bonus).
var _type: CardType

## Chemin du script d'effet (ex: generic_attack.gd).
var effect_script: String

# --- CONSTRUCTEUR ---

func _init(carte_instance: FightCardsObject, lvl: int,  cout_valeur: int, damage: int, effect_path: String, type: CardType):
	_carte = carte_instance
	_carte.assigned_class = self # Lien bidirectionnel
	_lvl = lvl
	_cout = cout_valeur
	_damage = damage
	effect_script = effect_path
	_type = type
	_damage_with_bonus = _damage # Valeur par défaut avant calcul

# --- ACCESSEURS (GETTERS) ---
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

# --- LOGIQUE MÉTIER ---

## Vérifie si le joueur possède les compétences requises pour utiliser cette carte à plein potentiel.
## Parcourt la liste des compétences équipées (Skill Slots).
## Si une compétence match (Type + Niveau), le bonus est activé.
func calculate_efficiency(equipped_skills: Array[skill_card]):
	var requirement_met = false
	
	for skill in equipped_skills:
		# Condition : Même Type ET Niveau Compétence >= Niveau Carte
		if skill.getType() == _type and skill.getNiveau() >= _lvl:
			requirement_met = true
			# Le bonus de la compétence s'ajoute aux dégâts de base
			_damage_with_bonus = _damage + skill.getBonus()
			break
	
	if requirement_met:
		# BONUS ACTIF : La carte fait ses dégâts max + bonus
		_have_bonus = true
	else:
		# MALUS : Condition non remplie.
		# La réduction de dégâts (x0.5) est gérée au moment de l'attaque ou visuellement
		_damage_with_bonus = _damage
		_have_bonus = false
	
	# Met à jour l'affichage de la carte (Texte vert ou rouge)
	update_visual_text()

## Synchronise l'état logique avec l'objet visuel.
func update_visual_text():
	if _carte and _carte.labelState:
		if _have_bonus:
			_carte.labelState.text = "Dégâts : " + str(_damage_with_bonus) + " (OK)"
			_carte.labelState.modulate = Color.GREEN
		else:
			# Note : Le visuel affichera les dégâts de base, mais en ROUGE pour signaler le problème.
			_carte.labelState.text = "Dégâts : " + str(_damage_with_bonus)
			_carte.labelState.modulate = Color.RED
