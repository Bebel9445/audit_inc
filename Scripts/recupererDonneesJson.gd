extends Node

func _ready():
	#Ouverture du fichier json + vérification qu'il est bien ouvert	
	var file = FileAccess.open("res://RessourcesHumaines.json", FileAccess.READ)
	if not file:
		push_error("Impossible d'ouvrir le fichier JSON")
		return
	
	var content = file.get_as_text()
	var parsed = JSON.parse_string(content) #Récupérer le contenu sous forme de dictionnaire
	
	#Récupérer les données dans des variables
	if typeof(parsed) == TYPE_DICTIONARY:
		var card = parsed["1"] #1 pour l'id 
		var nomPerso = card["nomPerso"]
		var text = card["text"] #Récupère le diaguole du perso 
		
		var choixGauche = card["choix"]["gauche"]["text"] #Le dialogue du choix de gauche (dialogue du joueur)
		var statsGauche = card["choix"]["gauche"]["stats"] #le tableau des 4 stats 
		
		var choixDroite  = card["choix"]["droite"]["text"]
		var statsDroite = card["choix"]["droite"]["stats"]
		print("Texte :", card["text"])
	else:
		push_error("Erreur de parsing JSON")
