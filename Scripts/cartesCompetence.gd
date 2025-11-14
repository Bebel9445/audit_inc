extends MarginContainer
class_name ObjetCarteCompetence

var labelNiveau: Label

 # Pour créer une carte sur l'écran
func _init(nom: String, niveau: int, image: Texture2D):
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
	labelNiveau.text = "lvl. " + str(niveau)
	labelNiveau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelNiveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	labelNiveau.add_theme_font_size_override("font_size", 18)
	vbox_gauche.add_child(labelNiveau)
	
	var label := Label.new()
	label.text = "Compétence"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(label)

	var texture_rect := TextureRect.new()
	texture_rect.texture = image
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(texture_rect)
