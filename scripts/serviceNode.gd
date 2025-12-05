extends Node2D
class_name ServiceNode

# Signal émis quand on clique sur ce nœud
signal combat_requested(service: ServiceNode)

enum ServiceType { ECONOMY, WELLBEING, FINANCE, RH }
@export var type: ServiceType = ServiceType.ECONOMY

# Textures
const ICON_ECO = preload("res://assets/icons/icon_eco.png")
const ICON_WELLBEING = preload("res://assets/icons/icon_wellbeing.png")
const ICON_FINANCE = preload("res://assets/icons/icon_finance.png")
const ICON_RH = preload("res://assets/icons/icon_hr.png")
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

@export var nameService: String
@export var size: int = 1 
@export var state: String = "green" 
var links := [] 

# References
@onready var frame = $FrameSprite       
@onready var sprite = $ServiceSprite    
@onready var highlight_border = $HighlightBorder 
@onready var label = $Label
@onready var area_2d = $Area2D 

const BORDER_PADDING = 4.0 

func _ready():
	if highlight_border:
		highlight_border.visible = false
		highlight_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if area_2d:
		area_2d.mouse_entered.connect(_on_mouse_entered)
		area_2d.mouse_exited.connect(_on_mouse_exited)
		area_2d.input_event.connect(_on_area_2d_input_event)
	
	if label:
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if FONT_PIXEL:
			label.add_theme_font_override("font", FONT_PIXEL)
			label.add_theme_font_size_override("font_size", 16)
	
	update_icon()
	update_visual()
	
	call_deferred("_keep_inside_screen")

func _keep_inside_screen():
	var screen_rect = get_viewport_rect()
	var margin = 70.0 
	position.x = clamp(position.x, margin, screen_rect.size.x - margin)
	position.y = clamp(position.y, margin, screen_rect.size.y - margin)

# Liens
func add_link(service: ServiceNode):
	if service == null: return
	if not links.has(service):
		links.append(service)
		if not service.links.has(self):
			service.links.append(self)

func calculate_next_state() -> String:
	# Si le nœud est terminé (bleu), il ne change plus d'état
	if state == "blue":
		return "blue"

	var red_count = 0
	for s_untyped in links:
		var s: ServiceNode = s_untyped as ServiceNode
		# On ignore les nœuds bleus dans le calcul de corruption (ou on peut dire qu'ils aident, fadura voir)
		if s.state == "red": red_count += 1
			
	if red_count >= 2: return "red"
	elif red_count == 1: return "orange"
	else: return "green"

# Visuel
func update_icon():
	if not sprite: return
	match type:
		ServiceType.ECONOMY:   sprite.texture = ICON_ECO
		ServiceType.WELLBEING: sprite.texture = ICON_WELLBEING
		ServiceType.FINANCE:   sprite.texture = ICON_FINANCE
		ServiceType.RH:        sprite.texture = ICON_RH
			
func update_visual():
	var target_size_px = Vector2(64, 64)
	match size:
		2: target_size_px = Vector2(96, 96)
		3: target_size_px = Vector2(128, 128)
	
	# Scale du Frame
	if frame and frame.texture != null:
		var tex_size = frame.texture.get_size()
		var scale_x = target_size_px.x / tex_size.x
		var scale_y = target_size_px.y / tex_size.y
		var final_scale = min(scale_x, scale_y)
		frame.scale = Vector2(final_scale, final_scale)
		
		if sprite:
			sprite.scale = frame.scale * 0.6
	
	# Mise à jour Highlight
	if highlight_border:
		var border_dim = target_size_px + Vector2(BORDER_PADDING, BORDER_PADDING) * 2
		highlight_border.size = border_dim
		highlight_border.position = -border_dim * 0.5
	
	# Hitbox
	if has_node("Area2D/CollisionShape2D"):
		var shape = $Area2D/CollisionShape2D
		if shape.shape is RectangleShape2D:
			shape.shape.size = target_size_px
			shape.position = Vector2.ZERO 
	
	# Couleur (État)
	if sprite:
		match state:
			"green":  sprite.modulate = Color(0.2, 1.0, 0.2) 
			"orange": sprite.modulate = Color(1.0, 0.7, 0.0) 
			"red":    sprite.modulate = Color(1.0, 0.2, 0.2)
			"blue":   sprite.modulate = Color(0.2, 0.6, 1.0) 
	
	# Label
	if label:
		# On peut changer le texte si c'est fini, sinon on garde la taille
		if state == "blue":
			label.text = "%s\n(OK)" % [nameService]
		else:
			label.text = "%s\n(Taille %d)" % [nameService, size]
			
		var bottom_of_sprite = target_size_px.y / 2
		label.position.y = bottom_of_sprite + 5
		label.custom_minimum_size.x = 120
		label.position.x = -60 

# gestion highlight
func set_highlight(enabled: bool):
	if highlight_border:
		highlight_border.visible = enabled

# event souris

func _on_mouse_entered():
	# Petit zoom au survol
	scale = Vector2(1.1, 1.1) 
	z_index = 10 

func _on_mouse_exited():
	scale = Vector2(1, 1)
	z_index = 0 

func _on_area_2d_input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Si le service est "bleu" (fini), on ne fait rien
		if state == "blue":
			print("Ce pôle est déjà sécurisé.")
			return

		print("Graph: Clic sur ", nameService)
		emit_signal("combat_requested", self)

# Utilitaires
func get_center_position() -> Vector2:
	return position

func get_edge_position(towards: Vector2) -> Vector2:
	var center = get_center_position()
	var dir = (towards - center).normalized()
	var current_radius = 32.0 
	if frame and frame.texture:
		current_radius = (frame.texture.get_size().x * frame.scale.x) * 0.5
	return center + dir * (current_radius * 0.9)
