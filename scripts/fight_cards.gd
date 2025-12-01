extends MarginContainer
class_name FightCardsObject

var labelNiveau: Label
var labelState: Label
var texte: String
var damage: int

 # Pour créer une carte sur l'écran
func _init(nom: String, niveau: int, texte: String, degats: int, image: Texture2D):
	name = nom
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_top", 10)
	add_theme_constant_override("margin_right", 10)
	add_theme_constant_override("margin_bottom", 10)
	
	var panel := Panel.new()
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
	
	var labelNom := Label.new()
	labelNom.text = nom
	labelNom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNom.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hbox.add_child(labelNom)
	
	labelNiveau = Label.new()
	labelNiveau.text = "lvl. " + str(niveau)
	labelNiveau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNiveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(labelNiveau)

	var texture_rect := TextureRect.new()
	texture_rect.texture = image
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(texture_rect)

	var label := Label.new()
	label.text = texte
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	labelState = Label.new()
	labelState.text = "Dégats : " + str(degats)
	damage = degats
	var font = load("res://Fonts/Figerona-VF.ttf")	# Pour mettre en gras
	labelState.add_theme_font_override("font", font)
	labelState.autowrap_mode = TextServer.AUTOWRAP_WORD
	labelState.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelState.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(labelState)
	
func getImage() -> Texture2D:
	for child in get_children():
		if child is TextureRect:
			return child.texture
	return null
