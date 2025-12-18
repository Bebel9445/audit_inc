extends Control
class_name DialogueBox

# --- SIGNAUX ---

## Signal émis quand le joueur a fini de lire le texte ou a cliqué pour fermer.
signal dialogue_finished

# --- RÉFÉRENCES ---
@onready var dialogue_text = $Panel/DialogueText
@onready var next_button = $Panel/NextButton

# --- VARIABLES ---

## Liste des phrases à afficher successivement.
var lines: Array = [] 

## Index de la phrase actuelle.
var current_index := 0

## Indique si l'animation de texte est en cours.
var is_typing := false

## Vitesse d'apparition des caractères (en secondes par caractère).
var typing_speed := 0.03

## Référence au Tween d'animation (pour pouvoir l'interrompre).
var tween: Tween

## Chemin vers le fichier de données.
const JSON_PATH = "res://data/dialogue.json" 

## Dictionnaire contenant toutes les données chargées du JSON.
var dialogue_data = {}

func _ready():
	hide()
	# Connexion du bouton (Zone transparente qui couvre tout l'écran souvent)
	next_button.connect("pressed", Callable(self, "_on_next_pressed"))
	_load_json_dialogues()
	
# --- GESTION DES DONNÉES ---

## Charge le fichier JSON contenant les dialogues au démarrage.
func _load_json_dialogues():
	if not FileAccess.file_exists(JSON_PATH):
		push_error("DialogueBox: Fichier JSON introuvable à " + JSON_PATH)
		return
		
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)

	if error == OK:
		dialogue_data = json.data
	else:
		push_error("DialogueBox: Erreur de parsing JSON.")

# --- API PUBLIQUE (Appelée par CombatScene) ---

## Lance une séquence de dialogue complète basée sur l'ID du type de service.
func start_dialogue_by_type(type_id: int):
	# Conversion int -> string car les clés JSON sont des strings
	var key = str(type_id)

	if dialogue_data.has(key):
		# dialogue_data[key] est supposé être un Array de Strings
		start_dialogue(dialogue_data[key])
	else:
		show_text("Erreur: Dialogue type " + key + " introuvable.")
		

## Pioche une phrase d'intro aléatoire pour le début du combat.
func play_random_intro_by_type(type_id: int):
	var key = str(type_id) 

	if dialogue_data.has(key):
		var possible_lines = dialogue_data[key]
		
		if possible_lines.size() > 0:
			var random_line = possible_lines.pick_random() 
			show_text(random_line) 
		else:
			show_text("...") 
	else:
		push_warning("DialogueBox: Type " + key + " introuvable dans le JSON.")
		show_text("Préparez-vous au combat !")

## Lance l'affichage d'une liste de phrases.
func start_dialogue(new_lines: Array[String]):
	lines = new_lines
	current_index = 0
	show_line()

## Affiche une seule phrase unique (raccourci).
func show_text(text: String):
	is_typing = false
	lines = [text] # On crée un tableau d'une seule case
	current_index = 0
	show_line()

# --- LOGIQUE INTERNE ---

## Affiche la ligne correspondant à current_index ou ferme le dialogue si fini.
func show_line():
	if current_index < lines.size():
		show()
		type_text(lines[current_index])
	else:
		hide()
		emit_signal("dialogue_finished")

## Anime le texte caractère par caractère (Effet Machine à écrire).
func type_text(text: String):
	is_typing = true

	# 1. On assigne tout le texte (pour que le layout calcule la taille)
	dialogue_text.text = text 

	# 2. On masque tout (0 caractères visibles)
	dialogue_text.visible_characters = 0 

	# 3. Calcul de la durée
	var total_time = text.length() * typing_speed

	# 4. Animation via Tween
	if tween: tween.kill() 
	tween = create_tween()
	tween.tween_property(dialogue_text, "visible_characters", text.length(), total_time)

	# 5. Attente fin
	await tween.finished
	is_typing = false

## Gestion du clic sur le bouton "Suivant".
## Si le texte s'écrit encore -> On affiche tout instantanément (Skip).
## Si le texte est fini -> On passe à la phrase suivante ou on ferme.
func _on_next_pressed():
	if is_typing:
		# SKIP : On force l'affichage complet
		if tween: tween.kill() 
		dialogue_text.visible_characters = -1 # -1 = Tout afficher
		is_typing = false
		
		# Ici, on ferme directement après le skip car c'est souvent ce qu'on veut
		# pour des messages courts. Si tu veux attendre un 2ème clic, retire les 2 lignes suivantes :
		hide()
		emit_signal("dialogue_finished")
		return    
		
	# NEXT : Phrase suivante
	current_index += 1
	show_line()
