class_name FightCardsObject
extends MarginContainer

# --- RESSOURCES ---
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")

# --- VARIABLES ---

## Référence vers la logique métier de la carte.
var assigned_class: FightCards 

## Label affichant les dégâts (change de couleur selon le bonus).
var labelState: Label

var texte: String
var damage: int

# --- INITIALISATION UI ---

## Constructeur : Crée toute la hiérarchie de nœuds par code (VBox, HBox, Labels...).
func _init(nom: String, level: int, texte_desc: String, degats: int, _char_image: Texture2D, bg_texture: Texture2D):
	name = nom
	texte = texte_desc
	damage = degats 
	
	# Configuration de base
	custom_minimum_size = Vector2(200, 280) 
	size = Vector2(300, 380)
	pivot_offset = Vector2(100, 140) # Pour que la rotation se fasse au centre

	# Marges internes pour ne pas coller au bord
	add_theme_constant_override("margin_left", 12)
	add_theme_constant_override("margin_top", 12)
	add_theme_constant_override("margin_right", 12)
	add_theme_constant_override("margin_bottom", 12)
	
	# 1. LE FOND (Background)
	var bg_rect := TextureRect.new()
	bg_rect.texture = bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_SCALE 
	bg_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	add_child(bg_rect)

	# 2. CONTENEUR VERTICAL PRINCIPAL
	var main_vbox := VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_theme_constant_override("separation", 10) 
	add_child(main_vbox) 
	
	# A. EN-TÊTE (Nom + Niveau)
	var hbox_header := HBoxContainer.new()
	hbox_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_vbox.add_child(hbox_header)
	
	var labelNom := Label.new()
	labelNom.text = nom
	labelNom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNom.add_theme_font_override("font", FONT_PIXEL)
	labelNom.add_theme_font_size_override("font_size", 25) 
	labelNom.add_theme_color_override("font_outline_color", Color.BLACK)
	labelNom.add_theme_constant_override("outline_size", 4)
	hbox_header.add_child(labelNom)
	
	var labelLvl := Label.new()
	labelLvl.text = "lv." + str(level)
	labelLvl.add_theme_font_override("font", FONT_PIXEL)
	labelLvl.add_theme_font_size_override("font_size", 25)
	labelLvl.add_theme_color_override("font_outline_color", Color.BLACK)
	labelLvl.add_theme_constant_override("outline_size", 4)
	hbox_header.add_child(labelLvl)

	# B. CORPS (Dégâts + Description)
	var center_vbox := VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER      
	center_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(center_vbox)

	# Label Dégâts Dynamique
	labelState = Label.new()
	labelState.text = "Degats : " + str(degats)
	labelState.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelState.add_theme_font_override("font", FONT_PIXEL)
	labelState.add_theme_font_size_override("font_size", 32)
	labelState.add_theme_color_override("font_outline_color", Color.BLACK)
	labelState.add_theme_constant_override("outline_size", 8)
	center_vbox.add_child(labelState)

	# Label Description
	var labelDesc := Label.new()
	labelDesc.text = "" # Le texte est géré dynamiquement ou via l'inspecteur
	labelDesc.custom_minimum_size = Vector2(180, 0) 
	labelDesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labelDesc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelDesc.add_theme_font_override("font", FONT_PIXEL)
	labelDesc.add_theme_font_size_override("font_size", 20)
	labelDesc.add_theme_color_override("font_outline_color", Color.BLACK)
	labelDesc.add_theme_constant_override("outline_size", 4)
	labelDesc.add_theme_color_override("font_color", Color.WHITE) 
	center_vbox.add_child(labelDesc)

# --- GESTION DE L'ÉTAT VISUEL ---

## Initialise le lien avec la classe logique.
func setup_card(data: FightCards):
	assigned_class = data
	update_visual_state()

## Met à jour la couleur et le texte des dégâts selon si le bonus est actif ou non.
func update_visual_state():
	if not assigned_class: return
	
	var final_damage = assigned_class.getDamageWithBonus()
	var has_bonus = assigned_class.haveBonus()
	
	if not has_bonus:
		# MALUS VISUEL : On affiche la valeur réduite et en ROUGE
		final_damage = int(final_damage * 0.5)
		labelState.modulate = Color(1.0, 0.4, 0.4) 
	else:
		# BONUS VISUEL : On affiche la valeur boostée et en VERT
		labelState.modulate = Color(0.2, 1.0, 0.2) 
		
	labelState.text = "Degats : " + str(final_damage)

## Utilitaire pour récupérer l'image de la carte (pour l'inspecteur).
func getImage() -> Texture2D:
	for child in get_children():
		if child is VBoxContainer:
			for sub in child.get_children():
				if sub is TextureRect:
					return sub.texture
	return null
