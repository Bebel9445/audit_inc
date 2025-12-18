extends MarginContainer
class_name object_skill_card

# --- CONSTANTES & RESSOURCES ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")
const BASE_SIZE = Vector2(75, 128) # Taille de référence interne pour l'art

# --- VARIABLES ---

## Lien vers la logique (Données)
var assigned_class: skill_card

@export var nom_competence: String
var _niveau: int = 1
var _type_id: int = 0 

# Composants UI générés dynamiquement
var panel: Panel
var art_board: Control 
var labelType: Label 
var texture_frame: TextureRect
var texture_icon: TextureRect

# --- GESTION DRAG & DROP ---
var is_dragging := false 
var preview = null
signal quit_slot(slot)
var slot_actuel = null
var drag_source

# Styles pour le feedback visuel (surlignement lors du survol)
var style_defaut = StyleBoxFlat.new()
var surlignement_possible = StyleBoxFlat.new()
var surlignement_impossible = StyleBoxFlat.new()

# --- INITIALISATION ---

## Constructeur visuel : Génère toute l'UI par code (Panel, Labels, Textures).
func _init(nom: String, niveau: int, type_id: int, frame_image: Texture2D, icon_image: Texture2D, position_x: int, position_y: int):
	name = nom
	nom_competence = nom
	_niveau = niveau
	_type_id = type_id 
	
	custom_minimum_size = Vector2(180, 310)
	position.x = position_x
	position.y = position_y
	
	# Création du fond
	panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_PASS 
	add_child(panel)

	# Création du conteneur artistique (pour le scaling)
	art_board = Control.new()
	art_board.size = BASE_SIZE 
	art_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_board.pivot_offset = Vector2(0, 0)
	panel.add_child(art_board)

	# Le cadre de rareté
	texture_frame = TextureRect.new()
	texture_frame.texture = frame_image
	texture_frame.size = BASE_SIZE
	texture_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_board.add_child(texture_frame)

	# L'icône du type
	texture_icon = TextureRect.new()
	texture_icon.texture = icon_image
	texture_icon.position = Vector2(6, 18) 
	texture_icon.size = Vector2(63, 85)
	texture_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art_board.add_child(texture_icon)

	# Label du Type (Economie, etc.)
	labelType = Label.new()
	var type_str = ""
	match _type_id:
		0: type_str = "ECONOMIE"
		1: type_str = "JURIDIQUE"
		2: type_str = "COMM."
		
	labelType.text = type_str
	labelType.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelType.add_theme_font_override("font", FONT_PIXEL)
	labelType.add_theme_font_size_override("font_size", 16)
	labelType.add_theme_color_override("font_outline_color", Color.BLACK)
	labelType.add_theme_constant_override("outline_size", 4)
	labelType.size = Vector2(75, 20)
	labelType.position = Vector2(0, 5) 
	art_board.add_child(labelType)

	# Connexion pour gérer le redimensionnement responsive
	resized.connect(_on_resized)
	call_deferred("_on_resized")

## Adapte l'échelle du contenu artistique à la taille du conteneur.
func _on_resized():
	if not art_board: return
	var scale_x = size.x / BASE_SIZE.x
	var scale_y = size.y / BASE_SIZE.y
	var ratio = min(scale_x, scale_y)
	art_board.scale = Vector2(ratio, ratio)
	art_board.position = (size - (BASE_SIZE * ratio)) / 2

## Met à jour l'apparence de la carte (notamment le cadre) quand elle change de niveau.
func update_visuals(new_level: int):
	_niveau = new_level
	var new_frame_path = "res://assets/cards/SkillCardsCommon.png"
	
	if _niveau == 2: new_frame_path = "res://assets/cards/SkillCardsRare.png"
	elif _niveau == 3: new_frame_path = "res://assets/cards/SkillCardsEpic.png"
	elif _niveau == 4: new_frame_path = "res://assets/cards/SkillCardsMythic.png"
	
	if ResourceLoader.exists(new_frame_path):
		texture_frame.texture = load(new_frame_path)

func _ready():
	_setup_styles()
	panel.add_theme_stylebox_override("panel", style_defaut)

# Configuration des StyleBox pour le feedback visuel
func _setup_styles():
	var w = 2
	style_defaut.border_width_bottom = w
	style_defaut.border_width_left = w
	style_defaut.border_width_right = w
	style_defaut.border_width_top = w
	style_defaut.border_color = Color.TRANSPARENT
	
	surlignement_possible.border_width_bottom = w
	surlignement_possible.border_width_left = w
	surlignement_possible.border_width_right = w
	surlignement_possible.border_width_top = w
	surlignement_possible.border_color = Color.YELLOW
	
	surlignement_impossible.border_width_bottom = w
	surlignement_impossible.border_width_left = w
	surlignement_impossible.border_width_right = w
	surlignement_impossible.border_width_top = w
	surlignement_impossible.border_color = Color.GRAY

# --- LOGIQUE DRAG & DROP (FUSION) ---

## Nettoyage après un drag.
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		panel.add_theme_stylebox_override("panel", style_defaut)
		drag_source = null

## Début du glisser-déposer.
func _get_drag_data(_position):
	is_dragging = true
	drag_source = self
	
	# On signale au slot actuel qu'on part
	if slot_actuel:
		emit_signal("quit_slot", slot_actuel)
		slot_actuel = null
		
	panel.add_theme_stylebox_override("panel", style_defaut)
	
	# Création de l'aperçu fantôme
	preview = duplicate()
	preview.modulate.a = 0.5
	set_drag_preview(preview)
	
	return self

## Vérifie si une autre carte peut être déposée sur celle-ci (Fusion).
## Possible uniquement si même nom et même niveau.
func _can_drop_data(_position, donnee):
	if donnee == null or donnee == self: return false
	
	if donnee.nom_competence == nom_competence && donnee._niveau == _niveau && _niveau != 4:
		panel.add_theme_stylebox_override("panel", surlignement_possible)
		return true
	else:
		panel.add_theme_stylebox_override("panel", surlignement_impossible)
		return false # On autorise le survol pour montrer l'erreur, mais le drop échouera

## Effectue la fusion si les conditions sont réunies.
func _drop_data(_position, donnee):
	is_dragging = false
	if donnee.nom_competence == nom_competence && donnee._niveau == _niveau:
		_fusionner(donnee)
	
	await get_tree().process_frame
	panel.add_theme_stylebox_override("panel", style_defaut)

func _drag_end(_success):
	is_dragging = false
	panel.add_theme_stylebox_override("panel", style_defaut)

## Logique de fusion : Augmente le niveau de CETTE carte et supprime l'AUTRE.
func _fusionner(autre_carte):
	var nouveau_niveau = _niveau + 1
	if nouveau_niveau > 4: nouveau_niveau = 4
	
	# Mise à jour des données logiques et visuelles
	assigned_class.setNiveau(nouveau_niveau)
	update_visuals(nouveau_niveau)
	
	# Destruction de la carte sacrifiée
	autre_carte.queue_free()
