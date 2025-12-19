extends Node2D
class_name ServiceNode

# --- SIGNAUX ---
signal combat_requested(service: ServiceNode)

# --- PARAMÈTRES D'ANIMATION ---
const HOVER_SCALE_FACTOR := 1.2  # Grossissement de 20%
const ANIM_DURATION := 0.15      # Vitesse de l'animation (rapide)
var default_scale := Vector2(1, 1) # On garde en mémoire l'échelle de base

# --- ENUMS ---
enum ServiceType { ECONOMY, WELLBEING, FINANCE, RH }

# --- EXPORT VARIABLES ---

## Type de service (détermine l'icône et le nom).
@export var type: ServiceType = ServiceType.ECONOMY : set = set_service_type

## Type de combat associé (pour les dialogues/cartes).
@export var dialogue_combat_type: FightCards.CardType = FightCards.CardType.LEGAL

## Nom affiché du service.
@export var nameService: String

## Taille du service (1 à 3), impacte la difficulté.
@export var size: int = 1 

## État actuel (Couleur) : "green", "orange", "red", "blue".
@export var state: String = "green" 

## Liste des ServiceNode connectés à celui-ci.
var links := [] 

# Produire un son lorsque l'on passe la souris
var sound_effect: AudioStreamPlayer

# --- RESSOURCES ---
const ICON_ECO = preload("res://assets/icons/icon_eco.png")
const ICON_WELLBEING = preload("res://assets/icons/icon_wellbeing.png")
const ICON_FINANCE = preload("res://assets/icons/icon_finance.png")
const ICON_RH = preload("res://assets/icons/icon_hr.png")

# --- REFERENCES ---
@onready var frame = $FrameSprite
@onready var sprite = $ServiceSprite
@onready var label = $Label
@onready var area_2d = $Area2D

func _ready():
	sound_effect = AudioStreamPlayer.new()
	sound_effect.stream = preload("res://music/sound-effect.mp3")
	add_child(sound_effect)
	
	_configure_service()
	update_visual()
	call_deferred("_keep_inside_screen")
	if area_2d:
		area_2d.input_event.connect(_on_area_2d_input_event)
		# On connecte le survol pour l'animation
		area_2d.mouse_entered.connect(_on_hover_enter)
		area_2d.mouse_exited.connect(_on_hover_exit)

# --- CONFIGURATION ---

## Setter pour le type, déclenche la reconfiguration automatique.
func set_service_type(new_value):
	type = new_value
	if is_inside_tree():
		_configure_service()

## Configure l'apparence et le nom selon le type choisi.
func _configure_service():
	# 1. Mise à jour de l'icône
	if sprite:
		match type:
			ServiceType.ECONOMY:
				sprite.texture = ICON_ECO
			ServiceType.WELLBEING:
				sprite.texture = ICON_WELLBEING
			ServiceType.FINANCE:
				sprite.texture = ICON_FINANCE
			ServiceType.RH:
				sprite.texture = ICON_RH
	
	# 2. Génération du nom
	var suffix = ""
	match type:
		ServiceType.ECONOMY: suffix = "Economie"
		ServiceType.WELLBEING: suffix = "Bien etre"
		ServiceType.FINANCE: suffix = "Finance"
		ServiceType.RH: suffix = "Ressource Humaine"
	
	nameService = "Pole " + suffix
	
	update_visual()

# --- LOGIQUE D'ÉTAT ---

## Marque ce noeud comme terminé (Bleu).
func set_completed():
	state = "blue"
	update_visual()
	# Désactive le clic
	if area_2d: area_2d.input_pickable = false

## Réduit la difficulté du noeud (effet de propagation).
## Réduit la taille ou passe de Rouge à Orange.
func reduce_difficulty():
	if state == "blue": return
	
	if size > 1: size -= 1
	if state == "red": state = "orange"
	
	update_visual()

## Met à jour tous les éléments graphiques (couleur, taille, texte).
func update_visual():
	# 1. Calcul de la taille cible
	var target_size_px = Vector2(64, 64)
	match size:
		2: target_size_px = Vector2(96, 96)
		3: target_size_px = Vector2(128, 128)
	
	# 2. Scale du Sprite (Responsive)
	if frame and frame.texture != null:
		var tex_size = frame.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			var scale_x = target_size_px.x / tex_size.x
			var scale_y = target_size_px.y / tex_size.y
			var final_scale = min(scale_x, scale_y)
			frame.scale = Vector2(final_scale, final_scale)
			if sprite:
				sprite.scale = frame.scale * 0.6
	
	# 3. Adaptation de la zone de clic
	if has_node("Area2D/CollisionShape2D"):
		var shape_node = $Area2D/CollisionShape2D
		var shape_res = shape_node.shape
		if shape_res is RectangleShape2D:
			shape_res.size = target_size_px
		shape_node.position = Vector2.ZERO 
	
	# 4. Application de la couleur d'état
	if sprite:
		match state:
			"green":  sprite.modulate = Color(0.2, 1.0, 0.2) 
			"orange": sprite.modulate = Color(1.0, 0.7, 0.0) 
			"red":    sprite.modulate = Color(1.0, 0.2, 0.2)
			"blue":   sprite.modulate = Color(0.2, 0.6, 1.0) 

	# 5. Mise à jour du Label
	if label:
		if state == "blue": label.text = nameService + "\n(OK)"
		else: label.text = nameService + "\n(Taille " + str(size) + ")"
		
		label.position.y = (target_size_px.y / 2) + 5
		label.position.x = -60

## Ajoute une connexion bidirectionnelle vers un autre service.
func add_link(service):
	if service and not links.has(service):
		links.append(service)
		if not service.links.has(self):
			service.links.append(self)

## Contraint la position du noeud à l'intérieur de l'écran (avec marge).
func _keep_inside_screen():
	var screen_rect = get_viewport_rect()
	var margin = 70.0 
	position.x = clamp(position.x, margin, screen_rect.size.x - margin)
	position.y = clamp(position.y, margin, screen_rect.size.y - margin)

## Calcule le point d'intersection sur le bord du cercle pour dessiner les lignes proprement.
func get_edge_position(towards: Vector2) -> Vector2:
	var current_radius = 32.0 
	if frame and frame.texture:
		current_radius = (frame.texture.get_size().x * frame.scale.x) * 0.5
	var dir = (towards - position).normalized()
	return position + dir * (current_radius * 0.9)

# --- EVENTS ---

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state != "blue":
			emit_signal("combat_requested", self)

func _on_hover_enter():
	sound_effect.play()
	
	z_index = 10 
	
	# Animation d'agrandissement (celle que je t'ai donnée avant)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", default_scale * HOVER_SCALE_FACTOR, ANIM_DURATION)
	
	# --- AJOUT : TEXTE D'AIDE CONTEXTUEL ---
	if label and state != "blue":
		var hint = ""
		match state:
			"green":  hint = "\n(Formation)"
			"orange": hint = "\n(Audit Standard)"
			"red":    hint = "\n(DANGER)"
		
		# On ajoute le hint au texte existant temporairement
		label.text = nameService + "\n(Taille " + str(size) + ")" + hint
		# On peut mettre le hint en couleur si on veut (nécessite RichTextLabel, mais restons simples)

func _on_hover_exit():
	z_index = 0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", default_scale, ANIM_DURATION)
	
	# --- AJOUT : ON REMET LE TEXTE NORMAL ---
	update_visual() # Cette fonction remet le texte "propre" (Nom + Taille)
