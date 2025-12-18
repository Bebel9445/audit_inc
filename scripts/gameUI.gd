extends CanvasLayer
class_name GameUI

# --- SIGNAUX ---

## Signal émis quand le joueur clique sur "Commencer".
signal start_game_requested

## Signal émis quand le joueur clique sur "Nouvelle Mission" à la fin.
signal restart_game_requested

## Signal pour afficher les crédits.
signal credits_requested

# --- RESSOURCES ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

# --- COMPOSANTS UI ---
var main_menu: Control
var end_screen: Control
var score_label: Label
var result_label: Label

func _ready():
	_create_main_menu()
	_create_end_screen()
	show_main_menu()

## Affiche le menu principal et cache l'écran de fin.
func show_main_menu():
	main_menu.show()
	end_screen.hide()

## Affiche l'écran de fin de partie avec le bilan comptable.
## Calcule la différence entre le score initial et final pour déterminer la victoire.
func show_end_screen(initial_score: int, final_score: int):
	main_menu.hide()
	end_screen.show()
	
	var diff = final_score - initial_score
	var texte_resultat = ""
	var color_resultat = Color.WHITE
	
	# Logique de victoire basée sur l'évolution du score
	if diff > 0:
		texte_resultat = "VICTOIRE !\nL'organisation se porte mieux."
		color_resultat = Color.GREEN
	elif diff == 0:
		texte_resultat = "MATCH NUL.\nL'organisation a stagné."
		color_resultat = Color.YELLOW
	else:
		texte_resultat = "ECHEC.\nLa situation s'est dégradée."
		color_resultat = Color(1, 0.4, 0.4) 
		
	result_label.text = texte_resultat
	result_label.modulate = color_resultat
	
	# Affichage détaillé avec le formatage "+X pts"
	score_label.text = "Score Initial : %d\nScore Final : %d\nEvolution : %+d pts" % [initial_score, final_score, diff]

# --- GÉNÉRATION D'INTERFACE (CODE) ---

## Construit le Menu Principal programmatiquement.
func _create_main_menu():
	main_menu = Control.new()
	main_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_menu)
	
	# Fond sombre
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu.add_child(bg)
	
	# Conteneur centré
	var center_cont = CenterContainer.new()
	center_cont.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu.add_child(center_cont)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20) 
	center_cont.add_child(vbox)
	
	# TITRE DU JEU
	var title = Label.new()
	title.text = "AUDIT INC."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT_PIXEL)
	title.add_theme_font_size_override("font_size", 128) 
	title.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	vbox.add_child(title)
	
	# TEXTE D'INTRO
	var intro = Label.new()
	intro.text = "Vous etes un auditeur junior.\n\nVotre mission : Acquérir de l'experience et\nassainir cette organisation en auditant différents poles,	 en 16 semaines.\n\nAttention : Chaque semaine compte."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.add_theme_font_override("font", FONT_PIXEL)
	intro.add_theme_font_size_override("font_size", 32) 
	intro.modulate = Color(0.9, 0.9, 0.9)
	vbox.add_child(intro)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	vbox.add_child(spacer)
	
	# BOUTON JOUER
	var btn = Button.new()
	btn.text = "  COMMENCER L'AUDIT  "
	btn.add_theme_font_override("font", FONT_PIXEL)
	btn.add_theme_font_size_override("font_size", 48)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.custom_minimum_size.y = 80
	btn.pressed.connect(func(): emit_signal("start_game_requested"))
	vbox.add_child(btn)
	
	# BOUTON CREDITS
	var btnCredits = Button.new()
	btnCredits.text = "  CREDITS  "
	btnCredits.add_theme_font_override("font", FONT_PIXEL)
	btnCredits.add_theme_font_size_override("font_size", 48)
	btnCredits.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btnCredits.custom_minimum_size.y = 80
	btnCredits.pressed.connect(func(): emit_signal("credits_requested"))
	vbox.add_child(btnCredits)

## Construit l'Écran de Fin programmatiquement.
func _create_end_screen():
	end_screen = Control.new()
	end_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_screen.hide()
	add_child(end_screen)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_screen.add_child(bg)
	
	var center_cont = CenterContainer.new()
	center_cont.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_screen.add_child(center_cont)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center_cont.add_child(vbox)
	
	# LABEL RESULTAT (VICTOIRE/DEFAITE)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_override("font", FONT_PIXEL)
	result_label.add_theme_font_size_override("font_size", 96)
	vbox.add_child(result_label)
	
	# LABEL DÉTAILS SCORE
	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_override("font", FONT_PIXEL)
	score_label.add_theme_font_size_override("font_size", 48)
	vbox.add_child(score_label)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 40
	vbox.add_child(spacer)
	
	# BOUTON RESTART
	var btn = Button.new()
	btn.text = "  NOUVELLE MISSION  "
	btn.add_theme_font_override("font", FONT_PIXEL)
	btn.add_theme_font_size_override("font_size", 48)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.custom_minimum_size.y = 80
	btn.pressed.connect(func(): emit_signal("restart_game_requested"))
	vbox.add_child(btn)
