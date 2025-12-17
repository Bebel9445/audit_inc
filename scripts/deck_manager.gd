extends Node
class_name DeckManager

# --- IMAGES ---
# C'EST ICI QUE TU METS TON IMAGE UNIQUE POUR LES CARTES DE COMBAT
const FRAME_FIGHT_CARD = preload("res://assets/cards/images/defaultfightcards.png") 

# Frames pour les SKILLS (si tu veux garder la distinction de rareté pour les skills)
const FRAME_COMMON = preload("res://assets/cards/SkillCardsCommon.png")
const FRAME_RARE   = preload("res://assets/cards/SkillCardsRare.png")
const FRAME_EPIC   = preload("res://assets/cards/SkillCardsEpic.png")
const FRAME_MYTHIC = preload("res://assets/cards/SkillCardsMythic.png")

# Icones Types
const ICON_ECO   = preload("res://assets/cards/eco.png")
const ICON_LEGAL = preload("res://assets/cards/hammer.png") 
const ICON_COMM  = preload("res://assets/cards/comm.png")   

const FALLBACK_IMAGE = "res://icon.svg"

# --- PATHS ---
const COMBAT_JSON_PATH = "res://Data/combat.json"
const SKILL_JSON_PATH = "res://Data/competence.json"
const GENERIC_ATTACK_SCRIPT = "res://scripts/effects/generic_attack.gd"
const GENERIC_SKILL_SCRIPT = "res://scripts/skills/generic_skill.gd"

# --- PILES ---
var master_deck: Array[FightCards] = [] 
var draw_pile: Array[FightCards] = []   
var discard_pile: Array[FightCards] = []
var skill_pile: Array[skill_card] = [] 

# --- DATA ---
var all_cards_data = []   
var all_skills_data = []  

func _init():
	_load_raw_data()
	reset_campaign()

func _load_raw_data():
	if FileAccess.file_exists(COMBAT_JSON_PATH):
		var file = FileAccess.open(COMBAT_JSON_PATH, FileAccess.READ)
		all_cards_data = JSON.parse_string(file.get_as_text())
		
	if FileAccess.file_exists(SKILL_JSON_PATH):
		var file = FileAccess.open(SKILL_JSON_PATH, FileAccess.READ)
		all_skills_data = JSON.parse_string(file.get_as_text())

func reset_campaign():
	master_deck.clear()
	skill_pile.clear()
	
	# Starter Deck : 5 cartes
	for i in range(5):
		add_reward_card(1)
		
	# Starter Skills : 2 Compétences
	for i in range(2):
		add_skill_reward()

# --- RECOMPENSES (ACTIONS) ---
func add_reward_card(max_lvl_filter: int = 10):
	if all_cards_data.is_empty(): return
	var data = all_cards_data.pick_random() 
	var new_card = _create_card_from_data(data)
	if new_card:
		master_deck.append(new_card)
		print("RECOMPENSE ACTION : ", new_card.getName())

# --- RECOMPENSES (SKILLS) ---
func add_skill_reward():
	if all_skills_data.is_empty(): return
	
	var data = all_skills_data.pick_random()
	var type_int = int(data.get("type", 0))
	var card_type = _get_card_type(type_int)
	
	# Note : Je garde la logique de rareté pour les skills car tu n'as précisé que pour les FightCards
	var frame_img = _get_frame_texture_for_skills(1) 
	var icon_img = _get_icon_texture(type_int)
	
	var visual_skill = object_skill_card.new(
		data.get("nom", "Skill"), 
		1, 
		type_int, 
		frame_img, 
		icon_img, 
		0, 0
	)
	
	var new_skill = skill_card.new(
		visual_skill, 1, data.get("nom", ""), 1, card_type, GENERIC_SKILL_SCRIPT
	)
	
	skill_pile.append(new_skill)
	print("RECOMPENSE SKILL : ", new_skill.getCompetence())


# --- HELPER ACTIONS ---
func _create_card_from_data(data) -> FightCards:
	var card_type = _get_card_type(int(data.get("type", 0)))
	var char_img = _load_image_safe(data.get("image", ""))
	var atk_data = data.get("attaque", {})
	var desc = atk_data.get("descritpion", atk_data.get("description", "")) 
	
	var niveau = int(data.get("niveau", 1))
	
	# Calcul Dégâts
	var damage_calcule = 8 + (niveau * 4)
	var json_damage = int(atk_data.get("degats", 0))
	if json_damage > 0:
		damage_calcule = (damage_calcule + json_damage) / 2
	
	var cout = 1 
	
	# ICI : On utilise la constante unique FRAME_FIGHT_CARD pour le fond
	var card_obj = FightCardsObject.new(
		data.get("nom", "Carte"), 
		niveau, 
		desc, 
		damage_calcule, 
		char_img,
		FRAME_FIGHT_CARD 
	)
	
	return FightCards.new(
		card_obj, 
		niveau, 
		cout, 
		damage_calcule, 
		GENERIC_ATTACK_SCRIPT, 
		card_type
	)

# --- HELPER UTILS ---
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

# --- Gestion Deck Combat (inchangé) ---
func prepare_combat_deck():
	draw_pile = master_deck.duplicate()
	discard_pile.clear()
	shuffle()

func shuffle(): draw_pile.shuffle()

func draw() -> FightCards:
	if draw_pile.is_empty(): reshuffle_discard()
	if draw_pile.is_empty(): return null
	return draw_pile.pop_back()

func discard(card: FightCards):
	if card: discard_pile.append(card)

func reshuffle_discard():
	if discard_pile.is_empty(): return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

func get_all_skills() -> Array[skill_card]:
	return skill_pile
