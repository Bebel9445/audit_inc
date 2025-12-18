extends Node
class_name DeckManager

# --- RESSOURCES GRAPHIQUES ---
const FRAME_FIGHT_CARD = preload("res://assets/cards/images/defaultfightcards.png") 

const FRAME_COMMON = preload("res://assets/cards/SkillCardsCommon.png")
const FRAME_RARE   = preload("res://assets/cards/SkillCardsRare.png")
const FRAME_EPIC   = preload("res://assets/cards/SkillCardsEpic.png")
const FRAME_MYTHIC = preload("res://assets/cards/SkillCardsMythic.png")

const ICON_ECO    = preload("res://assets/cards/eco.png")
const ICON_LEGAL  = preload("res://assets/cards/hammer.png") 
const ICON_COMM   = preload("res://assets/cards/comm.png")    

const FALLBACK_IMAGE = "res://icon.svg"

# --- CHEMINS DE DONNÉES ---
const COMBAT_JSON_PATH = "res://Data/combat.json"
const SKILL_JSON_PATH = "res://Data/competence.json"
## Script attaché aux cartes d'attaque générées.
const GENERIC_ATTACK_SCRIPT = "res://scripts/effects/generic_attack.gd"
## Script attaché aux compétences générées.
const GENERIC_SKILL_SCRIPT = "res://scripts/skills/generic_skill.gd"

# --- PILES DE CARTES ---

## Deck principal (Collection du joueur). Contient toutes les cartes obtenues.
var master_deck: Array[FightCards] = [] 

## Pioche actuelle pour le combat (vide hors combat).
var draw_pile: Array[FightCards] = []   

## Défausse actuelle pour le combat.
var discard_pile: Array[FightCards] = []

## Inventaire des compétences passives acquises.
var skill_pile: Array[skill_card] = [] 

# --- DONNÉES BRUTES (JSON) ---
var all_cards_data = []    
var all_skills_data = []  

func _init():
	_load_raw_data()
	# On initialise une campagne au démarrage
	reset_campaign()

## Charge les fichiers JSON en mémoire au lancement.
func _load_raw_data():
	if FileAccess.file_exists(COMBAT_JSON_PATH):
		var file = FileAccess.open(COMBAT_JSON_PATH, FileAccess.READ)
		all_cards_data = JSON.parse_string(file.get_as_text())
		
	if FileAccess.file_exists(SKILL_JSON_PATH):
		var file = FileAccess.open(SKILL_JSON_PATH, FileAccess.READ)
		all_skills_data = JSON.parse_string(file.get_as_text())

## Réinitialise la progression du joueur (Nouveau Deck).
func reset_campaign():
	master_deck.clear()
	skill_pile.clear()
	
	print("--- INITIALISATION DU DECK ---")
	
	# 1. Starter Deck ACTION : 5 cartes aléatoires (Full Random)
	for i in range(5):
		add_reward_card()
		
	# 2. Starter SKILLS : On garantit 1 compétence de chaque type (Eco, Juridique, Com)
	# Cela évite que le joueur soit bloqué sans bonus dès le début.
	_add_specific_starter_skill(0) # Type Eco
	_add_specific_starter_skill(1) # Type Juridique
	_add_specific_starter_skill(2) # Type Com
	
	print("------------------------------")

## Ajoute une compétence spécifique de niveau 1 au deck (utilisé pour le starter).
func _add_specific_starter_skill(target_type: int):
	var candidates = []
	# Filtrage dans le JSON
	for s in all_skills_data:
		if int(s.get("type")) == target_type and int(s.get("niveau", 1)) == 1:
			candidates.append(s)
	
	# Fallback si pas de niveau 1 trouvé
	if candidates.is_empty():
		for s in all_skills_data:
			if int(s.get("type")) == target_type:
				candidates.append(s)
	
	if not candidates.is_empty():
		var data = candidates.pick_random()
		_create_and_add_skill(data)

# --- GÉNÉRATION DE RÉCOMPENSES ---

## Pioche une carte d'action aléatoire dans le JSON et l'ajoute au Master Deck.
## @param max_lvl_filter: (Obsolète) Le système est maintenant full random.
func add_reward_card(_max_lvl_filter: int = 10) -> FightCards:
	if not all_cards_data or all_cards_data.is_empty(): return null
	
	var data = all_cards_data.pick_random() 
	var new_card = _create_card_from_data(data)
	
	if new_card:
		master_deck.append(new_card)
		print("✅ CARTE ACTION GAGNÉE : ", new_card.getName(), " (Niv.", new_card.getLvl(), ")")
		return new_card 
	return null

## Pioche une compétence aléatoire et l'ajoute à l'inventaire.
func add_skill_reward() -> skill_card:
	if not all_skills_data or all_skills_data.is_empty(): return null
	
	var data = all_skills_data.pick_random()
	return _create_and_add_skill(data)

# --- FACTORIES (CRÉATION D'OBJETS) ---

## Instancie une compétence (Logique + Visuel) depuis les données JSON.
func _create_and_add_skill(data) -> skill_card:
	var type_int = int(data.get("type", 0))
	var card_type = _get_card_type(type_int)
	var frame_img = _get_frame_texture_for_skills(1) 
	var icon_img = _get_icon_texture(type_int)
	
	# Création du visuel
	var visual_skill = object_skill_card.new(
		data.get("nom", "Skill"), 
		1, 
		type_int, 
		frame_img, 
		icon_img, 
		0, 0
	)
	
	# Création de la logique
	var new_skill = skill_card.new(
		visual_skill, 1, data.get("nom", ""), 1, card_type, GENERIC_SKILL_SCRIPT
	)
	
	skill_pile.append(new_skill)
	print("✅ SKILL GAGNÉ : ", new_skill.getCompetence())
	return new_skill

## Instancie une carte de combat (Logique + Visuel) depuis les données JSON.
func _create_card_from_data(data) -> FightCards:
	var card_type = _get_card_type(int(data.get("type", 0)))
	var char_img = _load_image_safe(data.get("image", ""))
	var atk_data = data.get("attaque", {})
	var desc = atk_data.get("descritpion", atk_data.get("description", "")) 
	
	var niveau = int(data.get("niveau", 1))
	
	# Formule de Dégâts : (Base + JSON) / 2 pour lisser les valeurs
	var damage_calcule = 8 + (niveau * 4)
	var json_damage = int(atk_data.get("degats", 0))
	if json_damage > 0:
		damage_calcule = (damage_calcule + json_damage) / 2
	
	var cout = 1 
	
	# 1. Objet VISUEL
	var card_obj = FightCardsObject.new(
		data.get("nom", "Carte"), 
		niveau, 
		desc, 
		damage_calcule, 
		char_img,
		FRAME_FIGHT_CARD 
	)
	
	# 2. Objet LOGIQUE
	var fight_card_logic = FightCards.new(
		card_obj, 
		niveau, 
		cout, 
		damage_calcule, 
		GENERIC_ATTACK_SCRIPT, 
		card_type
	)
	
	# Liaison finale
	card_obj.setup_card(fight_card_logic)
	
	return fight_card_logic

# --- UTILITAIRES ---

func _get_frame_texture_for_skills(level: int) -> Texture2D:
	match level:
		1: return FRAME_COMMON
		2: return FRAME_RARE
		3: return FRAME_EPIC
		4: return FRAME_MYTHIC
	return FRAME_COMMON

func _get_icon_texture(type_int: int) -> Texture2D:
	match type_int:
		0: return ICON_ECO
		1: return ICON_LEGAL
		2: return ICON_COMM
	return ICON_ECO

func _get_card_type(val: int) -> FightCards.CardType:
	match val:
		0: return FightCards.CardType.ECONOMY
		1: return FightCards.CardType.LEGAL
		2: return FightCards.CardType.COMMUNICATION
	return FightCards.CardType.ECONOMY

func _load_image_safe(path: String) -> Texture:
	if path != "" and ResourceLoader.exists(path): return load(path)
	return load(FALLBACK_IMAGE)

# --- GESTION DU DECK DE COMBAT ---

## Prépare la pioche pour un nouveau combat (copie du Master Deck + mélange).
func prepare_combat_deck():
	draw_pile = master_deck.duplicate()
	discard_pile.clear()
	shuffle()

## Mélange la pioche.
func shuffle(): 
	draw_pile.shuffle()

## Tire une carte de la pioche. Gère le mélange de la défausse si vide.
func draw() -> FightCards:
	if draw_pile.is_empty(): reshuffle_discard()
	if draw_pile.is_empty(): return null
	return draw_pile.pop_back()

## Ajoute une carte à la défausse.
func discard(card: FightCards):
	if card: discard_pile.append(card)

## Recycle la défausse dans la pioche.
func reshuffle_discard():
	if discard_pile.is_empty(): return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

func get_all_skills() -> Array[skill_card]:
	return skill_pile
