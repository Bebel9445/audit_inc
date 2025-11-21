extends MarginContainer
class_name object_skill_card

@export var nom_competence: String
var _niveau: int = -1 # Au cas où à -1 pour éviter des erreurs (qui ne devraient pas arriver)

var panel: Panel
var labelNiveau: Label

var is_dragging := false 
var preview = null

# StyleBoxes
var style_defaut = StyleBoxFlat.new()
var surlignement_possible = StyleBoxFlat.new()
var surlignement_impossible = StyleBoxFlat.new()
var drag_source

func _ready():
	# MODIF : Bordures plus fines (2px au lieu de 4px) pour faire plus propre en petit
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
	
	panel.add_theme_stylebox_override("panel", style_defaut)


# ===========================
#  DRAG & DROP
# ===========================

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		panel.add_theme_stylebox_override("panel", style_defaut)
		drag_source = null

func _get_drag_data(position):
	is_dragging = true
	drag_source = self
	panel.add_theme_stylebox_override("panel", style_defaut)
	preview = duplicate()
	preview.modulate.a = 0.5
	set_drag_preview(preview)
	return self

func _can_drop_data(position, donnee):
	if donnee == null or donnee == self: return false

	if donnee.nom_competence == nom_competence && donnee._niveau == _niveau:
		panel.add_theme_stylebox_override("panel", surlignement_possible)
	else:
		panel.add_theme_stylebox_override("panel", surlignement_impossible)
	return true

func _drop_data(position, donnee):
	is_dragging = false
	if donnee.nom_competence == nom_competence && donnee._niveau == _niveau:
		_fusionner(donnee)

	await get_tree().process_frame
	panel.add_theme_stylebox_override("panel", style_defaut)

func _drag_end(success):
	is_dragging = false
	panel.add_theme_stylebox_override("panel", style_defaut)

# ===========================
#  FUSION
# ===========================

func _fusionner(autre_carte):
	_niveau += 1
	labelNiveau.text = "Lv." + str(_niveau) # "Lv." prend moins de place
	autre_carte.queue_free()


# ===========================
#  INIT (VERSION MINIATURE)
# ===========================

func _init(nom: String, niveau: int, image: Texture2D, position_x: int, position_y: int):
	name = nom
	nom_competence = nom
	
	# MODIF : On force une taille fixe et petite (110x140)
	custom_minimum_size = Vector2(110, 140)
	
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# MODIF : Marges réduites à 2px (au lieu de 10)
	add_theme_constant_override("margin_left", 2)
	add_theme_constant_override("margin_top", 2)
	add_theme_constant_override("margin_right", 2)
	add_theme_constant_override("margin_bottom", 2)
	
	position.x = position_x
	position.y = position_y
	
	panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_PASS 
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Réduit l'espace entre le texte et l'image
	vbox.add_theme_constant_override("separation", 1) 
	add_child(vbox)
	
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN # Prend le moins de place possible en hauteur
	vbox.add_child(hbox)
	
	# --- Labels ---
	
	var vbox_gauche := VBoxContainer.new()
	vbox_gauche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox_gauche)
	
	var labelNom := Label.new()
	# MODIF : J'ai enlevé "Compétence de" car c'est trop long pour une petite carte
	labelNom.text = nom 
	labelNom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNom.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# MODIF : Police réduite (22 -> 11)
	labelNom.add_theme_font_size_override("font_size", 11)
	# Coupe le texte avec "..." s'il est trop long
	labelNom.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS 
	vbox_gauche.add_child(labelNom)
	
	labelNiveau = Label.new()
	_niveau = niveau
	labelNiveau.text = "Lv." + str(_niveau)
	labelNiveau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNiveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# MODIF : Police réduite (18 -> 10)
	labelNiveau.add_theme_font_size_override("font_size", 10)
	vbox_gauche.add_child(labelNiveau)
	
	# --- Image ---
	
	var texture_rect := TextureRect.new()
	texture_rect.texture = image
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# MODIF CRUCIALE : Permet à l'image de rétrécir pour tenir dans la petite carte
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE 
	
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(texture_rect)
