extends Control

@onready var scroll := $ScrollContainer
@onready var vbox := $ScrollContainer/VBoxContainer

@export var scroll_speed := 1.0   # pixels / seconde

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

func _ready() -> void:
	#Le contenu
	$CreditsMusic.play()
	text_print()
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE # Pour pas que le joueur puisse scroll

func _process(delta):
	scroll.scroll_vertical += scroll_speed

# Méthode de terrorsiste pour faire un espace
func make_space(size: int):
	var space := Control.new()
	space.custom_minimum_size.y = size
	vbox.add_child(space)

#En gros c'est juste 1 milliards de labels et d'images qui vont défiler
func text_print():
	# Ajouter de l'espace d'une taille mis en paramètre
	make_space(800)
	
	var labelDev := Label.new()
	labelDev.text = "Equipe de développeurs"
	labelDev.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelDev.modulate = Color(1, 0.8, 0.2)
	# STYLE PIXEL
	labelDev.add_theme_font_override("font", FONT_PIXEL)
	labelDev.add_theme_font_size_override("font_size", 60) # Assez gros pour être lisible
	vbox.add_child(labelDev)
	
	for i in range(3):
		var labelDevName := Label.new()
		match i:	#L'équivalent d'un switch case en Godot
			0:	labelDevName.text = "GIESE Jean"
			1:	labelDevName.text = "ADJEI Wilson"
			2:	labelDevName.text = "GOMES Abel"
			_:	labelDevName.text = "Anonyme" # valeur par défaut du switch case
		labelDevName.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# STYLE PIXEL
		labelDevName.add_theme_font_override("font", FONT_PIXEL)
		labelDevName.add_theme_font_size_override("font_size", 45) # Assez gros pour être lisible
		vbox.add_child(labelDevName)
	
	make_space(40)
	
	var labelSoftware := Label.new()
	labelSoftware.text = "Inventaire des logiciels"
	labelSoftware.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	labelSoftware.modulate = Color(1, 0.8, 0.2)
	labelSoftware.add_theme_font_override("font", FONT_PIXEL)
	labelSoftware.add_theme_font_size_override("font_size", 60) # Assez gros pour être lisible
	vbox.add_child(labelSoftware)

	var labelSoftwareName = RichTextLabel.new()
	labelSoftwareName.bbcode_enabled = true	# Pour mettre des balises de couleurs dans le .text
	labelSoftwareName.fit_content = true
	labelSoftwareName.text = """[center][color=green]Godot :[/color] moteur de jeu pour développer le jeu
	[color=green]Aseprite :[/color] pour faire du pixel art
	[color=green]Lottiefiles :[/color] pour faire des animations
	[color=green]SQLite :[/color] pour stocker des données[/center]"""
	labelSoftwareName.add_theme_font_override("normal_font", FONT_PIXEL)
	labelSoftwareName.add_theme_font_size_override("normal_font_size", 45) # Assez gros pour être lisible
	vbox.add_child(labelSoftwareName)
	
	make_space(40)
	
	var labelhonor = RichTextLabel.new()
	labelhonor.bbcode_enabled = true	# Pour mettre des balises de couleurs dans le .text
	labelhonor.fit_content = true
	labelhonor.text = "[center]Grosse pensé à [color=yellow]la rivière de pisse[/color] qui nous à accompagner durant tout le projet[/center]"
	labelhonor.add_theme_font_override("normal_font", FONT_PIXEL)
	labelhonor.add_theme_font_size_override("normal_font_size", 45) # Assez gros pour être lisible
	vbox.add_child(labelhonor)
	
	var RiverOfPissImage := TextureRect.new()
	RiverOfPissImage.texture = load("res://assets/cards/RiverOfPiss.png")
	RiverOfPissImage.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	RiverOfPissImage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	RiverOfPissImage.custom_minimum_size = Vector2(300, 300)
	vbox.add_child(RiverOfPissImage)
	
	make_space(1000)
