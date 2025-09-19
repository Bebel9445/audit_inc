extends MarginContainer

@onready var card_image: TextureRect = $VBoxContainer/TextureRect
@onready var card_text: Label = $VBoxContainer/Label

func _ready():
	pass

func set_card(image: Texture2D, text: String):
	card_image.texture = image
	card_text.text = text

#var img = load("res://pngtree-gold-coins-stack-icon-flat-illustration-of-golden-vector-for-web-png-image_12528911.png")
#func _process(delta):
	#if Input.is_action_just_pressed("click_mouse"):
		#set_card(img, "Voici une pile de pièce !")
