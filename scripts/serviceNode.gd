extends Node2D
class_name ServiceNode

signal combat_requested(service: ServiceNode)

@export var nameService: String
@export var size: int = 1 # 1 = petit, 2 = moyen, 3 = grand
@export var state: String = "green" # green / orange / red
var links := [] # array classique

@onready var color_rect = $ColorRect
@onready var label = $Label
@onready var area_2d = $Area2D 

@onready var highlight_border = $HighlightBorder 

var is_highlighted: bool = false # État de surbrillance

const BORDER_PADDING = 8.0 

func _ready():
	update_visual()

	area_2d.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area_2d.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	area_2d.connect("input_event", Callable(self, "_on_area_2d_input_event"))

	color_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	highlight_border.mouse_filter = Control.MOUSE_FILTER_PASS
		

#Survol d'un noeud
func _on_mouse_entered():
	# On ne fait rien si le nœud est déjà sélectionné (bleu)
	if not is_highlighted:
		# On augmente la luminosité ET la taille
		modulate = Color(1.7, 1.7, 1.7) # 40% plus lumineux
		scale = Vector2(1.1, 1.1)      # 10% plus grand

func _on_mouse_exited():
	if not is_highlighted:
		# On réinitialise les deux
		modulate = Color(1, 1, 1)
		scale = Vector2(1, 1)

func _on_area_2d_input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Combat demandé pour : ", name)
		
		toggle_highlight() # Active la surbrillance
		
		emit_signal("combat_requested", self)

func add_link(service: ServiceNode):
	if service == null:
		return
	if not links.has(service):
		links.append(service)
		if not service.links.has(self):
			service.links.append(self)

func calculate_next_state() -> String:
	var red_count = 0
	for s_untyped in links:
		var s: ServiceNode = s_untyped as ServiceNode
		if s.state == "red":
			red_count += 1
			
	if red_count >= 2:
		return "red"
	elif red_count == 1:
		return "orange"
	else:
		return "green"

func update_visual():
	# 1. Appliquer la taille au carré principal
	var base_size = 50.0 
	var new_dimension = base_size * (1 + (size - 1) * 0.5) 
	color_rect.size = Vector2(new_dimension, new_dimension)
	color_rect.position = -color_rect.size * 0.5
	
	# 2. Mettre à jour la bordure pour qu'elle soit plus grande
	var border_size = color_rect.size + Vector2(BORDER_PADDING, BORDER_PADDING)
	highlight_border.size = border_size
	highlight_border.position = -border_size * 0.5 # Centrer la bordure
	
	# 3. Mettre à jour la CollisionShape
	if has_node("Area2D/CollisionShape2D"):
		var collision_shape = $Area2D/CollisionShape2D
		if collision_shape.shape is RectangleShape2D:
			# La hitbox doit correspondre à la bordure (plus grande)
			collision_shape.shape.size = border_size
			collision_shape.position = Vector2.ZERO
	
	# 4. Appliquer la couleur de l'etat
	match state:
		"green":
			color_rect.color = Color(0,0.7,0)
		"orange":
			color_rect.color = Color(1,0.5,0)
		"red":
			color_rect.color = Color(0.7,0,0)
	
	# 5. Mettre à jour le label
	label.text = "%s (Size: %d)" % [nameService, size]

func toggle_highlight():
	is_highlighted = not is_highlighted
	
	# On MONTRE ou CACHE la bordure
	highlight_border.visible = is_highlighted
	
	# Gère le modulate/scale (au cas où on clique pendant un survol)
	if is_highlighted:
		# Si on sélectionne, on annule l'effet de survol
		modulate = Color(1,1,1)
		scale = Vector2(1,1)
	else:
		# Si on désélectionne, on vérifie si la souris est toujours dessus
		var mouse_pos = get_local_mouse_position()
		var rect = Rect2(highlight_border.position, highlight_border.size)
		if rect.has_point(mouse_pos):
			# La souris est toujours dessus, on réactive l'effet de survol
			modulate = Color(1.4, 1.4, 1.4)
			scale = Vector2(1.1, 1.1)
		else:
			# La souris est partie, on réinitialise tout
			modulate = Color(1, 1, 1)
			scale = Vector2(1, 1)

func get_center_position() -> Vector2:
	return position
	
func get_edge_position(towards: Vector2) -> Vector2:
	var center = get_center_position() 
	var dir = (towards - center).normalized()
	var half_size = color_rect.size * 0.5 

	var scale_x = INF
	var scale_y = INF
	if dir.x != 0:
		scale_x = half_size.x / abs(dir.x)
	if dir.y != 0:
		scale_y = half_size.y / abs(dir.y)

	var t = min(scale_x, scale_y)
	return center + dir * t
