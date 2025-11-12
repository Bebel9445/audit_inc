extends Node

@onready var card_zone = $CardZone
@onready var service_display = $ServiceDisplay
@onready var dialogue_box = $DialogueBox

@onready var deck_manager = preload("res://scripts/deck_manager.gd").new()
@onready var player = preload("res://scripts/player.gd").new()

var turn = 1

func _ready():
	start_combat()

func start_combat():
	player.reset()
	deck_manager.shuffle()
	draw_cards(3)
	dialogue_box.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))
	
	# Charger le dialogue depuis le .tres
	var intro_dialogue = load("res://data/dialogues/combat_intro.tres")
	dialogue_box.load_dialogue_resource(intro_dialogue)


func _on_dialogue_finished():
	dialogue_box.show_text("À toi de jouer !")

func draw_cards(amount: int):
	for i in range(amount):
		var card = deck_manager.draw()
		if card:
			print("Draw card:", card.name)
			add_card_to_zone(card)
		else:
			print("No card to draw")


func add_card_to_zone(card):
	var card_scene = preload("res://scenes/ui/card.tscn").instantiate()
	card_scene.setup(card)
	card_scene.connect("card_played", Callable(self, "_on_card_played"))
	
	var container = card_zone.get_node("CardsVBox")
	container.add_child(card_scene)


func _on_card_played(card):
	if player.energy < card.cost:
		dialogue_box.show_text("Pas assez d'énergie !")
		return
	player.energy -= card.cost
	apply_card_effect(card)
	deck_manager.discard(card)

func apply_card_effect(card):
	# Charger le script de l'effet
	var effect_class = load(card.effect_script)
	if effect_class:
		var effect_instance = effect_class.new()  # <- pour un GDScript
		add_child(effect_instance)
		effect_instance.apply(service_display, player)
	else:
		print("Impossible de charger l'effet :", card.effect_script)
