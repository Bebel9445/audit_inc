extends Control

signal end_credit
@onready var scroll := $ScrollContainer
@onready var vbox := $ScrollContainer/VBoxContainer

@export var scroll_speed := 1.0   # pixels / seconde

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

func _ready() -> void:
	#Le contenu
	$SkipButton.add_theme_font_override("font", FONT_PIXEL)
	$SkipButton.add_theme_font_size_override("font_size", 45) # Assez gros pour être lisible
	$AccelerationButton.add_theme_font_override("font", FONT_PIXEL)
	$AccelerationButton.add_theme_font_size_override("font_size", 45) # Assez gros pour être lisible
	$AccelerationReset.add_theme_font_override("font", FONT_PIXEL)
	$AccelerationReset.add_theme_font_size_override("font_size", 45) # Assez gros pour être lisible
	text_print()
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE # Pour pas que le joueur puisse scroll

func _process(delta):
	scroll.scroll_vertical += scroll_speed

func start_credit():
	$CreditsMusic.play()
	scroll.scroll_vertical = 0

func skip_credits():
	$CreditsMusic.stop()
	end_credit.emit()

func scroll_acceleration():
	scroll_speed += 3

func acceleration_reset():
	scroll_speed = 1

# === POUR TOUT CE QUI EST TEXTE ET CONTENU ===

# Méthode de terrorsiste pour faire un espace
func make_space(size: int):
	var space := Control.new()
	space.custom_minimum_size.y = size
	vbox.add_child(space)

func make_label(text: String, size: int, color: Color):
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if color != null:
		label.modulate = color
	# STYLE PIXEL
	label.add_theme_font_override("font", FONT_PIXEL)
	label.add_theme_font_size_override("font_size", size) # Assez gros pour être lisible
	vbox.add_child(label)

func make_rich_label(size: int, text: String):
	var richLabel = RichTextLabel.new()
	richLabel.bbcode_enabled = true	# Pour mettre des balises de couleurs dans le .text
	richLabel.fit_content = true
	richLabel.text = text
	richLabel.add_theme_font_override("normal_font", FONT_PIXEL)
	richLabel.add_theme_font_size_override("normal_font_size", size) # Assez gros pour être lisible
	vbox.add_child(richLabel)

func make_image(image: String):
	var TextureImage := TextureRect.new()
	TextureImage.texture = load(image)
	TextureImage.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	TextureImage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	TextureImage.custom_minimum_size = Vector2(300, 300)
	vbox.add_child(TextureImage)

func make_ScaryZ():
	var anim_tex := AnimatedTexture.new()
	anim_tex.frames = 166

	anim_tex.set_speed_scale(8) # Les fps en gros

	for i in range(anim_tex.frames):
		anim_tex.set_frame_texture(i, load("res://assets/icons/frame/_a_frm" + str(i) + ",100.png"))

	var rect := TextureRect.new()
	rect.texture = anim_tex
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	vbox.add_child(rect)

#En gros c'est juste 1 milliards de labels et d'images qui vont défiler
func text_print():
	var default_color = Color.WHITE
	var title_color = Color(1, 0.8, 0.2)
	# Ajouter de l'espace d'une taille mis en paramètre
	make_space(800)
	
	make_label("Equipe de développeurs", 60, title_color)
	for i in range(3):
		var text: String
		match i:	#L'équivalent d'un switch case en Godot
			0:	text = "GIESE Jean"
			1:	text = "ADJEI Wilson"
			2:	text = "GOMES Abel"
			_:	text = "Anonyme" # valeur par défaut du switch case
		make_label(text, 45, default_color)
	
	make_space(40)
	
	make_label("Inventaire des logiciels", 60, title_color)
	make_rich_label(45, """[center][color=green]Godot :[/color] moteur de jeu pour développer le jeu
	[color=green]Aseprite :[/color] pour faire du pixel art
	[color=green]Lottiefiles :[/color] pour faire des animations
	[color=green]SQLite :[/color] pour stocker des données[/center]""")
	
	make_space(40)
	
	make_label("Client", 60, title_color)
	make_label("M.Gossa", 45, default_color)
	make_space(20)
	make_label("Chef de Projet", 60, title_color)
	make_label("ADJEI Wilson", 45, default_color)
	make_space(20)
	make_label("Développeurs / Testeurs", 60, title_color)
	make_label("GIESE Jean", 45, default_color)
	make_label("GOMES Jean", 45, default_color)
	make_space(20)
	make_label("Utilisateurs", 60, title_color)
	make_label("Toi", 45, default_color)
	make_image("res://assets/icons/PointingAFinger.jpg")
	
	make_space(40)
	
	make_label("Bonnes ref à avoir", 60, title_color)
	make_label("Cell forme parfaite", 45, default_color)
	make_image("res://assets/icons/PerfectCell.webp")
	make_space(40)
	make_label("le path ou le paf?", 45, default_color)
	make_image("res://assets/icons/PathOrPaf.png")
	make_space(40)
	make_label("Z en mode terrifiant", 45, default_color)
	make_ScaryZ()
	
	make_space(60)
	make_label("Compte Clash royale de Jean", 60, title_color)
	make_image("res://assets/icons/CR1.jpg")
	make_image("res://assets/icons/CR2.jpg")
	make_image("res://assets/icons/CR3.jpg")
	make_space(40)
	make_label("Lien pour ajouter Jean en ami sur Clash royale :", 45, default_color)
	make_label("https://link.clashroyale.com/invite/friend/fr?tag=RYRR090PR&token=6hk6ye8g&platform=android", 45, Color.SKY_BLUE)
	
	make_rich_label(45, "[center]Grosse pensée à [color=yellow]la rivière de pisse[/color] qui nous à accompagner durant tout le projet[/center]")
	make_image("res://assets/cards/RiverOfPiss.png")
	
	make_space(1000)
	make_label("Grau Caka", 100, Color.BROWN)
