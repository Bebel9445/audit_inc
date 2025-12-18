extends Control

signal on_close(Array)

@onready var cards_vbox := $Panel/VBoxContainer/ScrollContainer/CardsContainer
@onready var close_button := $Panel/VBoxContainer/TitleAndClose/Close
@onready var title := $Panel/VBoxContainer/TitleAndClose/Title

# --- POLICE PIXEL ART ---
const FONT_PIXEL = preload("res://assets/fonts/ByteBounce.ttf")

func _ready():
	# La popup est cachée par défaut
	hide()
	
	title.add_theme_font_override("font", FONT_PIXEL)
	title.add_theme_font_size_override("font_size", 60)
	title.modulate = Color(1, 0.8, 0.2)
	close_button.add_theme_font_override("font", FONT_PIXEL)
	close_button.add_theme_font_size_override("font_size", 60)
	
	# Empêche les clics de passer à travers
	mouse_filter = Control.MOUSE_FILTER_STOP
	make_style()

func make_style():
	var style := StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.border_color = Color.WHITE
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_width_left = 4
	style.border_width_right = 4
	$Panel.add_theme_stylebox_override("panel", style)

func open(cards: Array[object_skill_card]):
	show()

	# Nettoyage complet
	for child in cards_vbox.get_children():
		child.queue_free()

	var current_hbox: HBoxContainer = null
	var count := 0

	for card in cards:
		# Toutes les 5 cartes, on crée une nouvelle ligne
		if count % 5 == 0:
			current_hbox = HBoxContainer.new()
			current_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			current_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cards_vbox.add_child(current_hbox)
		
		if card.get_parent(): card.get_parent().remove_child(card)
		card.custom_minimum_size = Vector2(180, 310)
		current_hbox.add_child(card)
		card.position = Vector2.ZERO
		count += 1

func close():
	hide()
	var skill_cards: Array[object_skill_card]
	for hbox in cards_vbox.get_children():
		if hbox is not HBoxContainer:
			continue
		for card in hbox.get_children():
			if card is object_skill_card:
				skill_cards.append(card)
				print("\n\n\n\n\n\n\n\n\nAAAAAAAAAAAAAAAAAAAAAAAAA\n\n\n\n\n\n\n\n\n")
	on_close.emit(skill_cards)

func _on_close_button_pressed():
	close()
