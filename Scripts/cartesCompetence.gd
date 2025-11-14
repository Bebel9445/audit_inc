extends MarginContainer
class_name ObjetCarteCompetence

@export var nom_competence: String
@export var _niveau: int = -1 # Au cas où à -1 pour éviter des erreurs (qui ne devraient pas arriver)
var panel: Panel
var labelNiveau: Label

var is_dragging := false # Servira pour les drags and drops
var preview = null

# StyleBoxes pour le contour
var style_defaut = StyleBoxFlat.new()
var surlignement_possible = StyleBoxFlat.new()
var surlignement_impossible = StyleBoxFlat.new()

func _ready():
	# En gros y'aura un contour gris quand la carte ne peux pas être fusionné et jaune sinon lors d'un drag and drop
	style_defaut.border_width_bottom = 4
	style_defaut.border_width_left = 4
	style_defaut.border_width_right = 4
	style_defaut.border_width_top = 4
	style_defaut.border_color = Color.TRANSPARENT
	
	surlignement_possible.border_width_bottom = 4
	surlignement_possible.border_width_left = 4
	surlignement_possible.border_width_right = 4
	surlignement_possible.border_width_top = 4
	surlignement_possible.border_color = Color.YELLOW
	
	surlignement_impossible.border_width_bottom = 4
	surlignement_impossible.border_width_left = 4
	surlignement_impossible.border_width_right = 4
	surlignement_impossible.border_width_top = 4
	surlignement_impossible.border_color = Color.GRAY
	
	panel.add_theme_stylebox_override("panel", style_defaut)


# ===========================
#  TOUTES LES FONCTIONS POUR DRAG
# ===========================

func _get_drag_data(position):
	is_dragging = true
	panel.add_theme_stylebox_override("panel", style_defaut)
	
	# donnée envoyée : un dictionnaire
	var donnee = {
		"carte": self,
		"competence": nom_competence,
		"niveau": _niveau
	}

	# création d'une petite preview
	# en gros la preview elle permet d'avoir un visuel "fantome" de la carte sur la souris quand tu drag
	preview = duplicate()
	preview.modulate.a = 0.5
	set_drag_preview(preview)

	return donnee


func _can_drop_data(position, donnee):
	if not donnee.has("competence"):
		return false
	
	if donnee["carte"] == self:
		return false

	# Même compétence ? -> surlignage jaune
	if donnee["competence"] == nom_competence && donnee["niveau"] == _niveau:
		panel.add_theme_stylebox_override("panel", surlignement_possible)
	else:
		panel.add_theme_stylebox_override("panel", surlignement_impossible)

	return true


func _drop_data(position, donnee):
	is_dragging = false

	if donnee["competence"] == nom_competence && donnee["niveau"] == _niveau:
		_fusionner(donnee["carte"])
	else:
		# pas la même carte → contour gris
		panel.add_theme_stylebox_override("panel", surlignement_impossible)

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
	labelNiveau.text = "lvl. " + str(_niveau)

	# Supprime l'autre carte
	autre_carte.queue_free()


# ===========================
#  CARTE
# ===========================

 # Pour créer une carte sur l'écran
func _init(nom: String, niveau: int, image: Texture2D, position_x: int, position_y: int):
	name = nom
	nom_competence = nom
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_top", 10)
	add_theme_constant_override("margin_right", 10)
	add_theme_constant_override("margin_bottom", 10)
	position.x = position_x
	position.y = position_y
	
	panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)
	
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_FILL
	vbox.add_child(hbox)
	
	# --- Labels affichés en haut ---
	
	var vbox_gauche := VBoxContainer.new()
	vbox_gauche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox_gauche)
	
	var labelNom := Label.new()
	labelNom.text = "Compétence de " + nom
	labelNom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNom.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	labelNom.add_theme_font_size_override("font_size", 22)
	vbox_gauche.add_child(labelNom)
	
	labelNiveau = Label.new()
	_niveau = niveau
	labelNiveau.text = "lvl. " + str(_niveau)
	labelNiveau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNiveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	labelNiveau.add_theme_font_size_override("font_size", 18)
	vbox_gauche.add_child(labelNiveau)
	
	# Faut trouver une image compatible (une étoile)
	#var etoile := TextureRect.new()
	#var img = load("res://Cartes/images/Etoile.png")
	#etoile.texture = img
	#etoile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#hbox.add_child(etoile)

	var texture_rect := TextureRect.new()
	texture_rect.texture = image
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(texture_rect)
