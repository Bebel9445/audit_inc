extends Node2D
class_name ServiceNode

# Signal émis quand on clique sur ce nœud
signal combat_requested(service: ServiceNode)

# Définition des types
enum ServiceType { ECONOMY, WELLBEING, FINANCE, RH }
@export var type: ServiceType = ServiceType.ECONOMY

# --- TEXTURES ---
# Icônes (Blanches)
const ICON_ECO = preload("res://assets/icons/icon_eco.png")
const ICON_WELLBEING = preload("res://assets/icons/icon_wellbeing.png")
const ICON_FINANCE = preload("res://assets/icons/icon_finance.png")
const ICON_RH = preload("res://assets/icons/icon_hr.png")

# --- POLICE (FONT) ---
# IMPORTANT : Assurez-vous que le fichier .ttf est bien à cet endroit !
const FONT_PIXEL = preload("res://assets/icons/ByteBounce.ttf")

@export var nameService: String
@export var size: int = 1 
@export var state: String = "green" 
var links := [] 

# --- RÉFÉRENCES ---
@onready var frame = $FrameSprite      # Le Cadre (Z-Index 0)
@onready var sprite = $ServiceSprite   # L'Icône (Z-Index 1)
@onready var highlight_border = $HighlightBorder 
@onready var label = $Label
@onready var area_2d = $Area2D 

var is_highlighted: bool = false
const BORDER_PADDING = 4.0 

func _ready():
	# Configuration souris
	if highlight_border:
		highlight_border.mouse_filter = Control.MOUSE_FILTER_PASS
	
	if area_2d:
		area_2d.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		area_2d.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		area_2d.connect("input_event", Callable(self, "_on_area_2d_input_event"))
	
	# Configuration du Label (Police & Alignement)
	if label:
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER # Centrer le texte
		
		# Appliquer la police Pixel Art
		if FONT_PIXEL:
			label.add_theme_font_override("font", FONT_PIXEL)
			label.add_theme_font_size_override("font_size", 16) # Ajustez la taille (ex: 16, 24)
	
	
	# Mise à jour initiale
	update_icon()
	update_visual()
	
	call_deferred("_keep_inside_screen")

func _keep_inside_screen():
	var screen_rect = get_viewport_rect()
	var margin = 70.0 
	position.x = clamp(position.x, margin, screen_rect.size.x - margin)
	position.y = clamp(position.y, margin, screen_rect.size.y - margin)

# --- LIENS & PROPAGATION ---
func add_link(service: ServiceNode):
	if service == null: return
	if not links.has(service):
		links.append(service)
		if not service.links.has(self):
			service.links.append(self)

func calculate_next_state() -> String:
	var red_count = 0
	for s_untyped in links:
		var s: ServiceNode = s_untyped as ServiceNode
		if s.state == "red": red_count += 1
			
	if red_count >= 2: return "red"
	elif red_count == 1: return "orange"
	else: return "green"

# --- VISUEL ---
func update_icon():
	if not sprite: return
	
	match type:
		ServiceType.ECONOMY:   sprite.texture = ICON_ECO
		ServiceType.WELLBEING: sprite.texture = ICON_WELLBEING
		ServiceType.FINANCE:   sprite.texture = ICON_FINANCE
		ServiceType.RH:        sprite.texture = ICON_RH
			
func update_visual():
	# 1. Définir la taille CIBLE en pixels
	var target_size_px = Vector2(64, 64) # Taille standard (Size 1)
	
	match size:
		2: target_size_px = Vector2(96, 96)   # Moyen (Size 2)
		3: target_size_px = Vector2(128, 128) # Gros (Size 3)
	
	# 2. Mettre à l'échelle le CADRE
	if frame and frame.texture != null:
		var tex_size = frame.texture.get_size()
		var scale_x = target_size_px.x / tex_size.x
		var scale_y = target_size_px.y / tex_size.y
		var final_scale = min(scale_x, scale_y)
		
		frame.scale = Vector2(final_scale, final_scale)
		
		# 3. Mettre à l'échelle l'ICÔNE
		if sprite:
			sprite.scale = frame.scale * 0.6
	
	# 4. Adapter la bordure
	if highlight_border:
		var border_dim = target_size_px + Vector2(BORDER_PADDING, BORDER_PADDING) * 2
		highlight_border.size = border_dim
		highlight_border.position = -border_dim * 0.5
	
	# 5. Adapter la Hitbox
	if has_node("Area2D/CollisionShape2D"):
		var shape = $Area2D/CollisionShape2D
		if shape.shape is RectangleShape2D:
			shape.shape.size = target_size_px
			shape.position = Vector2.ZERO 
	
	# 6. Couleur
	if sprite:
		match state:
			"green":  sprite.modulate = Color(0.2, 1.0, 0.2) 
			"orange": sprite.modulate = Color(1.0, 0.7, 0.0) 
			"red":    sprite.modulate = Color(1.0, 0.2, 0.2) 
	
	# 7. Texte et Positionnement
	if label:
		label.text = "%s\n(Taille %d)" % [nameService, size]
		
		# On place le texte SOUS le sprite
		# Le sprite va de -hauteur/2 à +hauteur/2.
		# Donc le bas du sprite est à target_size_px.y / 2
		var bottom_of_sprite = target_size_px.y / 2
		label.position.y = bottom_of_sprite + 5 # Ajoute 5px de marge
		
		# On centre le label horizontalement
		# Astuce : on force une largeur et on décale de la moitié vers la gauche
		label.custom_minimum_size.x = 120
		label.position.x = -60 

# --- SOURIS ---
func toggle_highlight():
	is_highlighted = not is_highlighted
	if highlight_border:
		highlight_border.visible = is_highlighted
	if not is_highlighted:
		update_visual() 

func _on_mouse_entered():
	if not is_highlighted: 
		scale = Vector2(1.1, 1.1) 
		z_index = 10 

func _on_mouse_exited():
	if not is_highlighted:
		scale = Vector2(1, 1)
		z_index = 0 

func _on_area_2d_input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Graph: Clic sur ", nameService)
		toggle_highlight()
		emit_signal("combat_requested", self)

# --- UTILITAIRES ---
func get_center_position() -> Vector2:
	return position

func get_edge_position(towards: Vector2) -> Vector2:
	var center = get_center_position()
	var dir = (towards - center).normalized()
	
	var current_radius = 32.0 
	if frame and frame.texture:
		current_radius = (frame.texture.get_size().x * frame.scale.x) * 0.5
	
	return center + dir * (current_radius * 0.9)
