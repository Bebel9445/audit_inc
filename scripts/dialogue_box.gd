extends Control

signal dialogue_finished

@onready var dialogue_text = $Panel/DialogueText
@onready var next_button = $Panel/NextButton

var lines: Array = [] 
var current_index := 0
var is_typing := false
var typing_speed := 0.03
var tween: Tween

const JSON_PATH = "res://Data/dialogue.json" 
var dialogue_data = {}

func _ready():
	hide()
	next_button.connect("pressed", Callable(self, "_on_next_pressed"))
	_load_json_dialogues()
	
# Charger le fichier JSON en mémoire
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


func start_dialogue_by_type(type_id: int):
	# Les clés du JSON sont des strings ("0", "1"), on convertit l'int
	var key = str(type_id)

	if dialogue_data.has(key):
		start_dialogue(dialogue_data[key])
	else:
		# Fallback si l'ID n'existe pas
		show_text("Erreur: Dialogue type " + key + " introuvable.")

# Charger une ressource DialogueResource
func load_dialogue_resource(dialogue_res):
	if dialogue_res and dialogue_res is DialogueResource:
		start_dialogue(dialogue_res.lines)
		

func play_random_intro_by_type(type_id: int):
	var key = str(type_id) # Convertit l'enum (0, 1, 2) en string pour le JSON ("0", "1")

	if dialogue_data.has(key):
		var possible_lines = dialogue_data[key]
		
		# Vérifie que la liste n'est pas vide
		if possible_lines.size() > 0:
			var random_line = possible_lines.pick_random() # Pioche une ligne au hasard
			show_text(random_line) # Affiche uniquement cette ligne
		else:
			show_text("...") # Fallback si la liste est vide
	else:
		# Fallback si le type n'existe pas dans le JSON (ex: type RH manquant)
		push_warning("DialogueBox: Type " + key + " introuvable dans le JSON.")
		show_text("Préparez-vous au combat !")

func start_dialogue(new_lines: Array[String]):
	lines = new_lines
	current_index = 0
	show_line()

func show_text(text: String):
	is_typing = false
	lines = [text]
	current_index = 0
	show_line()

func show_line():
	if current_index < lines.size():
		show()
		type_text(lines[current_index])
	else:
		hide()
		emit_signal("dialogue_finished")

func type_text(text: String):
	is_typing = true

	# On met tout le texte d'un coup (la mise en page est figée)
	dialogue_text.text = text 

	# On cache tout le texte (0 caractère visible)
	dialogue_text.visible_characters = 0 

	# On calcule le temps total de l'animation
	var total_time = text.length() * typing_speed

	# On utilise un Tween (animation fluide) pour augmenter le nombre de caractères
	if tween: tween.kill() # Nettoyage de l'ancien tween si existant
	tween = create_tween()

	# On anime la propriété "visible_characters" de 0 jusqu'à la fin
	tween.tween_property(dialogue_text, "visible_characters", text.length(), total_time)

	# On attend que le Tween finisse
	await tween.finished

	is_typing = false

func _on_next_pressed():
	# Si c'est en train d'écrire, on "Skip" l'animation
	if is_typing:
		if tween: tween.kill() # On arrête l'animation en cours
		dialogue_text.visible_characters = -1 # -1 veut dire "tout afficher"
		is_typing = false
		hide()
		emit_signal("dialogue_finished")
		return	
		
	# Sinon, on passe à la phrase suivante
	current_index += 1
	show_line()
