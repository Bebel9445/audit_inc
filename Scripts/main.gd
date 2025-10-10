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
	var carte_instance = carte_scene.instantiate()
	add_child(carte_instance)
	carte_instance.choixGauche.connect(choix)
	carte_instance.choixDroite.connect(choix)
	choixPoles_instance.hide()
	
	print(nomPole)
	if (nomPole == "RH") :
		var img = load("res://icon.svg")
		carte_instance.set_card(img, "Voici le pole RH !", "Choix de gauche", "choix de droite (la droiiiiite hein)")
	elif (nomPole == "Economie") :
		pass
	elif (nomPole == "Fournitures") :
		pass
	else :
		pass

func choix(nomChoix):
	if (nomChoix == "Gauche"):
		print("Gauche")
	else:
		print("Droite")
