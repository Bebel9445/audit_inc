class_name FightCardsObject
extends MarginContainer

# --- RESSOURCES ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

# --- VARIABLES ---
var assigned_class: FightCards
var labelState: Label
var texte: String
var damage: int

# On passe la texture de fond (bg_texture) directement dans le constructeur
func _init(nom: String, level: int, texte_desc: String, degats: int, char_image: Texture2D, bg_texture: Texture2D):
	name = nom
	texte = texte_desc
	
	# Dimensions (Ajustez selon vos besoins, ici celles de votre code précédent)
	custom_minimum_size = Vector2(200, 280) 
	size = Vector2(200, 280)
	pivot_offset = Vector2(100, 140) 

	# Marges pour que le texte ne touche pas les bords du cadre
	add_theme_constant_override("margin_left", 12)
	add_theme_constant_override("margin_top", 12)
	add_theme_constant_override("margin_right", 12)
	add_theme_constant_override("margin_bottom", 12)
	
	# --- 1. LE FOND (FRAME UNIQUE) ---
	var bg_rect := TextureRect.new()
	bg_rect.texture = bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_SCALE 
	bg_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	add_child(bg_rect) # Ajouté en premier = Arrière-plan

	# --- 2. LE CONTENEUR VERTICAL ---
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox) # Ajouté par dessus le fond
	
	# --- A. HEADER (Nom + Lvl) ---
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	vbox.add_child(hbox)
	
	var labelNom := Label.new()
	labelNom.text = nom
	labelNom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNom.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	labelNom.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS 
	labelNom.add_theme_font_override("font", FONT_PIXEL)
	labelNom.add_theme_font_size_override("font_size", 24) 
	hbox.add_child(labelNom)
	
	var labelLvl := Label.new()
	labelLvl.text = "lv." + str(level)
	labelLvl.size_flags_horizontal = Control.SIZE_SHRINK_END
	labelLvl.add_theme_font_override("font", FONT_PIXEL)
	labelLvl.add_theme_font_size_override("font_size", 24)
	hbox.add_child(labelLvl)

	# --- B. IMAGE DU PERSONNAGE ---
	var texture_char := TextureRect.new()
	texture_char.texture = null
	texture_char.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_char.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_char.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_char.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(texture_char)

	# --- C. DESCRIPTION ---
	var labelDesc := Label.new()
	labelDesc.text = "\n" # Espaceur par défaut
	labelDesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labelDesc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS 
	labelDesc.custom_minimum_size.y = 60 
	labelDesc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	labelDesc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelDesc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelDesc.add_theme_font_override("font", FONT_PIXEL)
	labelDesc.add_theme_font_size_override("font_size", 24)
	vbox.add_child(labelDesc)

	# --- D. DÉGÂTS ---
	labelState = Label.new()
	labelState.text = "Degats : " + str(degats)
	damage = degats
	labelState.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelState.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelState.add_theme_font_override("font", FONT_PIXEL)
	labelState.add_theme_font_size_override("font_size", 32)
	vbox.add_child(labelState)
	
func getImage() -> Texture2D:
	# On cherche l'image du perso (dans la VBox), pas le fond
	for child in get_children():
		if child is VBoxContainer:
			for sub in child.get_children():
				if sub is TextureRect:
					return sub.texture
	return null
