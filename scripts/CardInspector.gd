extends PanelContainer
class_name CardInspector

# ==============================================================================
# INSPECTEUR DE CARTE (Tooltip Géant)
# ==============================================================================
# Rôle : Affiche les détails complets d'une carte au survol de la souris.
# - Affiche Nom, Niveau, Image, Description.
# - Affiche les dégâts en temps réel (Vert/Rouge selon bonus).
# ==============================================================================

# --- RESSOURCES ---
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")

# --- COMPOSANTS UI ---
var title_label: Label
var level_label: Label
var desc_label: Label
var stats_label: Label
var texture_rect: TextureRect

func _init():
	# --- CONFIGURATION STYLE ---
	mouse_filter = Control.MOUSE_FILTER_IGNORE # Ne bloque pas les clics
	custom_minimum_size = Vector2(250, 450) 
	
	# Style du panneau (Fond sombre, bordures blanches)
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
	sb.anti_aliasing = false 
	add_theme_stylebox_override("panel", sb)
	
	# Structure Verticale
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Marges internes
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	margin.add_child(vbox)
	
	# --- CREATION DES ELEMENTS ---
	
	# 1. Titre (Jaune)
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2)) 
	title_label.add_theme_font_override("font", FONT_PIXEL)
	title_label.add_theme_font_size_override("font_size", 48) 
	vbox.add_child(title_label)
	
	# 2. Niveau (Gris)
	level_label = Label.new()
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7)) 
	level_label.add_theme_font_override("font", FONT_PIXEL)
	level_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(level_label)
	
	# 3. Image
	texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(0, 150)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(texture_rect)
	
	# 4. Stats / Dégâts (Vert ou Rouge)
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_override("font", FONT_PIXEL)
	stats_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(stats_label)
	
	# 5. Description (Blanc)
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_label.add_theme_font_override("font", FONT_PIXEL)
	desc_label.add_theme_font_size_override("font_size", 32) 
	vbox.add_child(desc_label)
	
	hide() # Caché par défaut

## Affiche les données de la carte survolée dans l'inspecteur.
## Met à jour les textes et la couleur des dégâts (Rouge/Vert).
func show_card(card_data: FightCards):
	if card_data == null: 
		hide()
		return
		
	show()
	
	# Textes de base
	title_label.text = card_data.getName()
	level_label.text = "Niveau " + str(card_data.getLvl()) 
	desc_label.text = card_data.getDescription() 
	
	# Image
	if card_data.getImage():
		texture_rect.texture = card_data.getImage()
		texture_rect.show()
	else:
		texture_rect.hide()
		
	# --- CALCUL ET AFFICHAGE DYNAMIQUE DES DÉGÂTS ---
	var final_damage = card_data.getDamageWithBonus()
	var dmg_text = ""
	
	if card_data.haveBonus():
		# BONUS ACTIF : Texte Vert
		stats_label.modulate = Color(0.2, 1.0, 0.2) 
		dmg_text = "Degats : " + str(final_damage) + "\n(Bonus Actif)"
	else:
		# MALUS : Texte Rouge + Division par 2 affichée
		final_damage = int(final_damage * 0.5)
		stats_label.modulate = Color(1.0, 0.4, 0.4) 
		dmg_text = "Degats : " + str(final_damage) + "\n(MALUS -50%)"
		
	stats_label.text = dmg_text
