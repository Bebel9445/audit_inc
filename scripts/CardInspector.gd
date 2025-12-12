extends PanelContainer
class_name CardInspector

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

var title_label: Label
var desc_label: Label
var stats_label: Label
var texture_rect: TextureRect

func _init():
	# Configuration UI 
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(250, 400) 
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	sb.border_color = Color(1, 1, 1, 0.5)
	sb.border_width_bottom = 2
	sb.border_width_top = 2
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	# Désactive l'anti-aliasing pour pixel art
	sb.anti_aliasing = false 
	add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	margin.add_child(vbox)
	
	# Titre
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2)) 
	# STYLE PIXEL
	title_label.add_theme_font_override("font", FONT_PIXEL)
	title_label.add_theme_font_size_override("font_size", 48) # Très gros titre
	vbox.add_child(title_label)
	
	# Image
	texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(0, 150)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(texture_rect)
	
	# Stats
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# STYLE PIXEL
	stats_label.add_theme_font_override("font", FONT_PIXEL)
	stats_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(stats_label)
	
	# Description
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# STYLE PIXEL
	desc_label.add_theme_font_override("font", FONT_PIXEL)
	desc_label.add_theme_font_size_override("font_size", 32) # Très lisible
	vbox.add_child(desc_label)
	
	hide()

func show_card(card_data: FightCards):
	if card_data == null: 
		hide()
		return
		
	show()
	title_label.text = card_data.getName()
	
	if card_data.getImage():
		texture_rect.texture = card_data.getImage()
		texture_rect.show()
	else:
		texture_rect.hide()
		
	var dmg_text = "Degats : " + str(card_data.getDamageWithBonus())
	if card_data.haveBonus():
		stats_label.modulate = Color.GREEN
		dmg_text += " (OK !)"
	else:
		stats_label.modulate = Color(1, 0.4, 0.4) 
		dmg_text += " (Malus)"
		
	stats_label.text = dmg_text
	desc_label.text = card_data.getDescription()
