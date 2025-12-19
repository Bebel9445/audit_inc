extends Control
# Cette scène représente une popup d'affichage de cartes

# Signal émis à la fermeture de la popup
# Il renvoie la liste des cartes présentes dans la popup
signal on_close(Array)

# Références vers les noeuds de l'interface
@onready var cards_vbox := $Panel/VBoxContainer/ScrollContainer/CardsContainer
# Conteneur vertical qui contiendra plusieurs HBox (lignes de cartes)

@onready var close_button := $Panel/VBoxContainer/TitleAndClose/Close
# Bouton "croix" pour fermer la popup

@onready var title := $Panel/VBoxContainer/TitleAndClose/Title
# Label du titre de la popup

# --- POLICE PIXEL ART ---
# Police utilisée pour le titre et le bouton de fermeture
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")

func _ready():
	# La popup est cachée par défaut au lancement
	hide()
	
	# Style du titre
	title.add_theme_font_override("font", FONT_PIXEL)
	title.add_theme_font_size_override("font_size", 60)
	title.modulate = Color(1, 0.8, 0.2) # Couleur dorée
	
	# Style du bouton de fermeture
	close_button.add_theme_font_override("font", FONT_PIXEL)
	close_button.add_theme_font_size_override("font_size", 60)
	
	# Empêche les clics de passer à travers la popup
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Applique le style visuel du panel (fond + bordure)
	make_style()

func make_style():
	# Création du style du panel principal
	var style := StyleBoxFlat.new()
	style.bg_color = Color.BLACK          # Fond noir
	style.border_color = Color.WHITE      # Bordure blanche
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_width_left = 4
	style.border_width_right = 4
	
	# Application du style au Panel
	$Panel.add_theme_stylebox_override("panel", style)

func open(cards: Array[object_skill_card]):
	# Affiche la popup
	show()

	# Supprime toutes les lignes de cartes précédentes
	for child in cards_vbox.get_children():
		child.queue_free()

	var current_hbox: HBoxContainer = null
	var count := 0 # Compteur de cartes

	for card in cards:
		# Toutes les 5 cartes, on crée une nouvelle ligne (HBox)
		if count % 5 == 0:
			current_hbox = HBoxContainer.new()
			current_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			current_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cards_vbox.add_child(current_hbox)
		
		# Retire la carte de son parent précédent si nécessaire
		if card.get_parent():
			card.get_parent().remove_child(card)
		
		# Taille minimale pour uniformiser les cartes
		card.custom_minimum_size = Vector2(180, 310)
		
		# Ajoute la carte à la ligne courante
		current_hbox.add_child(card)
		
		# Réinitialise sa position locale
		card.position = Vector2.ZERO
		
		count += 1

func close():
	# Cache la popup
	hide()
	
	# Récupère toutes les cartes actuellement affichées
	var skill_cards: Array[object_skill_card]
	
	for hbox in cards_vbox.get_children():
		if hbox is not HBoxContainer:
			continue
		
		for card in hbox.get_children():
			if card is object_skill_card:
				skill_cards.append(card)
	
	# Émet le signal avec la liste des cartes
	on_close.emit(skill_cards)

func _on_close_button_pressed():
	# Appelé lorsque l'utilisateur clique sur la croix
	close()
