extends MarginContainer
class_name FightCardsObject

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

var assigned_class: FightCards
var labelState: Label
var texte: String
var damage: int

func _init(nom: String, level: int, texte_desc: String, degats: int, image: Texture2D):
	name = nom
	texte = texte_desc
	
	custom_minimum_size = Vector2(200, 280) 
	size = Vector2(200, 280)
	pivot_offset = Vector2(100, 140) 

	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_top", 10)
	add_theme_constant_override("margin_right", 10)
	add_theme_constant_override("margin_bottom", 10)
	
	var panel := Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	
	# Header
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	vbox.add_child(hbox)
	
	var labelNom := Label.new()
	labelNom.text = nom
	labelNom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNom.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	labelNom.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS 
	# STYLE PIXEL
	labelNom.add_theme_font_override("font", FONT_PIXEL)
	labelNom.add_theme_font_size_override("font_size", 24) 
	hbox.add_child(labelNom)
	
	var labelLvl := Label.new()
	labelLvl.text = "lv." + str(level)
	labelLvl.size_flags_horizontal = Control.SIZE_SHRINK_END
	# STYLE PIXEL
	labelLvl.add_theme_font_override("font", FONT_PIXEL)
	labelLvl.add_theme_font_size_override("font_size", 24)
	hbox.add_child(labelLvl)

	# Image
	var texture_rect := TextureRect.new()
	texture_rect.texture = image
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(texture_rect)

	# Description
	var labelDesc := Label.new()
	labelDesc.text = texte_desc
	labelDesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labelDesc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS 
	labelDesc.custom_minimum_size.y = 60 
	labelDesc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	labelDesc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelDesc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# STYLE PIXEL
	labelDesc.add_theme_font_override("font", FONT_PIXEL)
	labelDesc.add_theme_font_size_override("font_size", 24) # Assez gros pour être lisible
	vbox.add_child(labelDesc)

	# Dégâts
	labelState = Label.new()
	labelState.text = "Degats : " + str(degats)
	damage = degats
	labelState.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelState.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# STYLE PIXEL
	labelState.add_theme_font_override("font", FONT_PIXEL)
	labelState.add_theme_font_size_override("font_size", 32) # Gros chiffres
	vbox.add_child(labelState)
	
func getImage() -> Texture2D:
	for child in get_children():
		if child is VBoxContainer:
			for sub in child.get_children():
				if sub is TextureRect:
					return sub.texture
	return null
