extends MarginContainer

signal choixGauche
signal choixDroite

@onready var card_image: TextureRect = $VBoxContainer/TextureRect
@onready var card_text: Label = $VBoxContainer/Label
@onready var card_text_gauche: Button = $VBoxContainer/HBoxContainer/BoutonGauche
@onready var card_text_droite: Button = $VBoxContainer/HBoxContainer/BoutonDroite

func _ready():
	pass

func set_card(image: Texture2D, text: String, textGauche: String, textDroite: String):
	card_image.texture = image
	card_text.text = text
	card_text_gauche.text = textGauche
	card_text_droite.text = textDroite

func _on_bouton_gauche_pressed():
	choixGauche.emit("Gauche")

func _on_bouton_droite_pressed():
	choixDroite.emit("Droite")
