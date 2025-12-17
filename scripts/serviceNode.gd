extends Node2D
class_name ServiceNode

signal combat_requested(service: ServiceNode)

enum ServiceType { ECONOMY, WELLBEING, FINANCE, RH }
@export var type: ServiceType = ServiceType.ECONOMY
@export var dialogue_combat_type: FightCards.CardType = FightCards.CardType.LEGAL

const ICON_ECO = preload("res://assets/icons/icon_eco.png")
const ICON_WELLBEING = preload("res://assets/icons/icon_wellbeing.png")
const ICON_FINANCE = preload("res://assets/icons/icon_finance.png")
const ICON_RH = preload("res://assets/icons/icon_hr.png")

@export var nameService: String
@export var size: int = 1 
@export var state: String = "green" 
var links := [] 

@onready var frame = $FrameSprite
@onready var sprite = $ServiceSprite
@onready var label = $Label
@onready var area_2d = $Area2D

func _ready():
	update_icon()
	update_visual()
	call_deferred("_keep_inside_screen")
	if area_2d:
		area_2d.input_event.connect(_on_area_2d_input_event)

func set_completed():
	state = "blue"
	update_visual()
	if area_2d: area_2d.input_pickable = false

func reduce_difficulty():
	if state == "blue": return
	if size > 1: size -= 1
	if state == "red": state = "orange"
	update_visual()

func update_icon():
	if not sprite: return
	match type:
		ServiceType.ECONOMY:   sprite.texture = ICON_ECO
		ServiceType.WELLBEING: sprite.texture = ICON_WELLBEING
		ServiceType.FINANCE:   sprite.texture = ICON_FINANCE
		ServiceType.RH:        sprite.texture = ICON_RH

func update_visual():
	# 1. Taille cible en PIXELS
	var target_size_px = Vector2(64, 64)
	match size:
		2: target_size_px = Vector2(96, 96)
		3: target_size_px = Vector2(128, 128)
	
	# 2. Scale du Sprite
	if frame and frame.texture != null:
		var tex_size = frame.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			var scale_x = target_size_px.x / tex_size.x
			var scale_y = target_size_px.y / tex_size.y
			var final_scale = min(scale_x, scale_y)
			frame.scale = Vector2(final_scale, final_scale)
			if sprite:
				sprite.scale = frame.scale * 0.6
	
	if has_node("Area2D/CollisionShape2D"):
		var shape_node = $Area2D/CollisionShape2D
		var shape_res = shape_node.shape
		
		if shape_res is RectangleShape2D:
			shape_res.size = target_size_px
			
		shape_node.position = Vector2.ZERO 
	
	if sprite:
		match state:
			"green":  sprite.modulate = Color(0.2, 1.0, 0.2) 
			"orange": sprite.modulate = Color(1.0, 0.7, 0.0) 
			"red":    sprite.modulate = Color(1.0, 0.2, 0.2)
			"blue":   sprite.modulate = Color(0.2, 0.6, 1.0) 

	if label:
		if state == "blue": label.text = nameService + "\n(OK)"
		else: label.text = nameService + "\n(Taille " + str(size) + ")"
		label.position.y = (target_size_px.y / 2) + 5
		label.position.x = -60

func add_link(service):
	if service and not links.has(service):
		links.append(service)
		if not service.links.has(self):
			service.links.append(self)

func _keep_inside_screen():
	var screen_rect = get_viewport_rect()
	var margin = 70.0 
	position.x = clamp(position.x, margin, screen_rect.size.x - margin)
	position.y = clamp(position.y, margin, screen_rect.size.y - margin)

func get_edge_position(towards: Vector2) -> Vector2:
	var current_radius = 32.0 
	if frame and frame.texture:
		current_radius = (frame.texture.get_size().x * frame.scale.x) * 0.5
	var dir = (towards - position).normalized()
	return position + dir * (current_radius * 0.9)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state != "blue":
			emit_signal("combat_requested", self)
