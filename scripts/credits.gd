extends Control

@onready var scroll := $ScrollContainer
@onready var vbox := $ScrollContainer/VBoxContainer

@export var scroll_speed := 40.0   # pixels / seconde

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

func _ready() -> void:
	#Le contenu
	$CreditsMusic.play()
	text_print()

func _process(delta):
	scroll.scroll_vertical += scroll_speed * delta
	
	#Quand on est à la fin des crédits on arrêtes de scroll
	var max_scroll = scroll.get_v_scroll_bar().max_value
	scroll.scroll_vertical = min(
		scroll.scroll_vertical + scroll_speed * delta,
		max_scroll
	)

#En gros c'est juste 1 milliards de labels et d'images qui vont défiler
func text_print():
	var labelDev := Label.new()
	labelDev.text = "Equipe de développeurs"
	labelDev.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labelDev.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# STYLE PIXEL
	labelDev.add_theme_font_override("font", FONT_PIXEL)
	labelDev.add_theme_font_size_override("font_size", 24) # Assez gros pour être lisible
	vbox.add_child(labelDev)
