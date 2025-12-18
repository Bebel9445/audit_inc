extends Control
# Ce script est attaché à un noeud Control (interface utilisateur)

signal end_credit
# Signal émis lorsque les crédits sont terminés ou sautés

@onready var scroll := $ScrollContainer
# Référence au ScrollContainer qui gère le défilement vertical

@onready var vbox := $ScrollContainer/VBoxContainer
# VBoxContainer qui contient tous les éléments des crédits (textes, images, etc.)

@export var scroll_speed := 1.0
# Vitesse de défilement des crédits (en pixels par frame)

# --- POLICE PIXEL ART ---
# Police pixel art utilisée pour tous les textes des crédits
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")

func _ready() -> void:
	# Fonction appelée lorsque la scène est prête
	
	# Application de la police et de la taille aux boutons
	$SkipButton.add_theme_font_override("font", FONT_PIXEL)
	$SkipButton.add_theme_font_size_override("font_size", 45)
	
	$AccelerationButton.add_theme_font_override("font", FONT_PIXEL)
	$AccelerationButton.add_theme_font_size_override("font_size", 45)
	
	$AccelerationReset.add_theme_font_override("font", FONT_PIXEL)
	$AccelerationReset.add_theme_font_size_override("font_size", 45)
	
	# Génération de tout le contenu des crédits
	text_print()
	
	# Empêche le joueur de scroller manuellement avec la souris
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	# Fait défiler automatiquement les crédits à chaque frame
	scroll.scroll_vertical += scroll_speed

func start_credit():
	# Démarre les crédits depuis le début
	$CreditsMusic.play()       # Lance la musique
	scroll.scroll_vertical = 0 # Remet le scroll en haut

func skip_credits():
	# Permet de quitter les crédits immédiatement
	$CreditsMusic.stop()  # Arrête la musique
	end_credit.emit()     # Informe les autres scènes que les crédits sont terminés

func scroll_acceleration():
	# Augmente la vitesse de défilement
	scroll_speed += 3

func acceleration_reset():
	# Réinitialise la vitesse de défilement
	scroll_speed = 1

# =====================================================
# === FONCTIONS UTILITAIRES POUR LE CONTENU DES CREDITS
# =====================================================

func make_space(size: int):
	# Crée un espace vertical entre deux éléments
	var space := Control.new()
	space.custom_minimum_size.y = size
	vbox.add_child(space)

func make_label(text: String, size: int, color: Color):
	# Crée un label centré avec une police pixel
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Applique une couleur si elle est fournie
	if color != null:
		label.modulate = color
	
	# Applique la police pixel et la taille
	label.add_theme_font_override("font", FONT_PIXEL)
	label.add_theme_font_size_override("font_size", size)
	
	vbox.add_child(label)

func make_rich_label(size: int, text: String):
	# Crée un RichTextLabel pour utiliser le BBCode (couleurs, centrage, etc.)
	var richLabel := RichTextLabel.new()
	richLabel.bbcode_enabled = true  # Active les balises BBCode
	richLabel.fit_content = true     # Ajuste la hauteur au contenu
	richLabel.text = text
	
	# Police pixel pour le RichTextLabel
	richLabel.add_theme_font_override("normal_font", FONT_PIXEL)
	richLabel.add_theme_font_size_override("normal_font_size", size)
	
	vbox.add_child(richLabel)

func make_image(image: String):
	# Ajoute une image centrée dans les crédits
	var TextureImage := TextureRect.new()
	TextureImage.texture = load(image)
	
	# Conserve le ratio de l'image et la centre
	TextureImage.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	TextureImage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Taille minimale de l'image
	TextureImage.custom_minimum_size = Vector2(300, 300)
	
	vbox.add_child(TextureImage)

func make_ScaryZ():
	# Crée une animation à partir de plusieurs images (frames)
	var anim_tex := AnimatedTexture.new()
	anim_tex.frames = 166           # Nombre total de frames
	anim_tex.set_speed_scale(8)     # Vitesse de lecture de l'animation
	
	# Chargement de chaque frame
	for i in range(anim_tex.frames):
		anim_tex.set_frame_texture(
			i,
			load("res://assets/icons/frame/_a_frm" + str(i) + ",100.png")
		)
	
	# Affichage de l'animation dans un TextureRect
	var rect := TextureRect.new()
	rect.texture = anim_tex
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	vbox.add_child(rect)

# =====================================================
# === CREATION DE TOUT LE CONTENU DES CREDITS
# =====================================================

func text_print():
	# Couleurs utilisées dans les crédits
	var default_color = Color.WHITE
	var title_color = Color(1, 0.8, 0.2)
	
	# Grand espace au début
	make_space(800)
	
	# Titre équipe
	make_label("Equipe de développeurs", 60, title_color)
	
	# Liste des développeurs
	for i in range(3):
		var text: String
		match i: # équivalent d'un switch / case
			0: text = "GIESE Jean"
			1: text = "ADJEI Wilson"
			2: text = "GOMES Abel"
			_: text = "Anonyme"
		make_label(text, 45, default_color)
	
	make_space(40)
	
	# Logiciels utilisés
	make_label("Inventaire des logiciels", 60, title_color)
	make_rich_label(45, """[center][color=green]Godot :[/color] moteur de jeu pour développer le jeu
[color=green]Aseprite :[/color] pour faire du pixel art
[color=green]Lottiefiles :[/color] pour faire des animations
[color=green]SQLite :[/color] pour stocker des données[/center]""")
	
	make_space(40)
	
	# Rôles du projet
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
	
	# Références fun
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
	
	# Clash Royale
	make_label("Compte Clash royale de Jean", 60, title_color)
	make_image("res://assets/icons/CR1.jpg")
	make_image("res://assets/icons/CR2.jpg")
	make_image("res://assets/icons/CR3.jpg")
	
	make_space(40)
	make_label(
		"Lien pour ajouter Jean en ami sur Clash royale :",
		45,
		default_color
	)
	make_label(
		"https://link.clashroyale.com/invite/friend/fr?tag=RYRR090PR&token=6hk6ye8g&platform=android",
		45,
		Color.SKY_BLUE
	)
	
	make_space(80)
	
	# Message de fin
	make_rich_label(
		45,
		"[center]Grosse pensée à [color=yellow]la rivière de pisse[/color] qui nous à accompagner durant tout le projet[/center]"
	)
	make_image("res://assets/cards/RiverOfPiss.png")
	
	make_space(100)
	make_label("Merci!", 100, Color.SPRING_GREEN)
	
	make_space(1000)
	make_label("Grau Caka", 100, Color.BROWN)
