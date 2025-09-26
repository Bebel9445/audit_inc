extends Node
@export var choixPoles_scene : PackedScene
@export var carte_scene : PackedScene

var choixPoles_instance
var current_difficulte : int

func _ready():
	pass
	

func new_game(difficulte : int):
	print(difficulte)
	current_difficulte = difficulte
	$Menu.queue_free()
	choixPoles_instance = choixPoles_scene.instantiate()
	add_child(choixPoles_instance)	
	choixPoles_instance.poleRH.connect(lancer_audit) #Mettre "RH" en paramètre ( = lancer_audit("RH"))
	choixPoles_instance.poleEconomie.connect(lancer_audit)
	choixPoles_instance.poleFournitures.connect(lancer_audit)
	choixPoles_instance.poleBienEtre.connect(lancer_audit)
	
	#Initialiser les states en fonction de la difficulté choisi	

func lancer_audit(nomPole):
	print(nomPole)
	if (nomPole == "RH") :
		pass
	elif (nomPole == "Economie") :
		pass
	elif (nomPole == "Fournitures") :
		pass
	else :
		pass
	
	var carte_instance = carte_scene.instantiate()
	add_child(carte_instance)
	#carte_instance.set_card(TextureRect e, "ldn,dkkd")
	choixPoles_instance.hide()
