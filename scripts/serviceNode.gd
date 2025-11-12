extends Node2D
class_name ServiceNode

@export var nameService: String
@export var size: int = 1 # 1 = petit, 2 = moyen, 3 = grand
@export var state: String = "green" # green / orange / red
var links := [] # array classique

@onready var color_rect = $ColorRect
@onready var label = $Label

func _ready():
	update_visual()

func add_link(service):
	if service == null:
		return
	if not links.has(service):
		links.append(service)
		if service.has_method("add_link") and not service.links.has(self):
			service.links.append(self) # lien bidirectionnel


func update_state():
	var red_count = 0
	for s in links:
		if s.state == "red":
			red_count += 1
	if red_count >= 2:
		state = "red"
	elif red_count == 1:
		state = "orange"
	else:
		state = "green"
	update_visual()

func update_visual():
	match state:
		"green":
			color_rect.color = Color(0,1,0)
		"orange":
			color_rect.color = Color(1,0.5,0)
		"red":
			color_rect.color = Color(1,0,0)
	
func get_center_position() -> Vector2:
	# centre exact du ColorRect, en tenant compte de la taille et de l'échelle
	return global_position + color_rect.size * 0.5
	
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
