extends Node2D
class_name ServiceGraph # J'ai ajouté le class_name pour faciliter le typage si besoin

# Signal global vers le CombatManager
signal initiate_combat(service: ServiceNode)
# NOUVEAU SIGNAL : Victoire totale
signal all_nodes_secured 

@export_category("Configuration Graphique")
@export var service_scene : PackedScene = preload("res://scenes/ui/service_node.tscn")
@export var background_texture : Texture2D = preload("res://assets/background.png")

@export_group("Ajustement du Graphe")
@export var graph_center_offset : Vector2 = Vector2(0,40) 
@export_range(0.1, 2.0) var graph_scale : float = 0.7

var services := [] 

func _ready():
	call_deferred("create_graph")

func create_graph():
	randomize()
	
	for child in get_children():
		child.queue_free()
	services.clear()

	create_background()

	var total_services = randi_range(4, 6)
	var viewport_size = get_viewport_rect().size
	var center_screen = (viewport_size / 2) + graph_center_offset
	
	var radius_x = (viewport_size.x * 0.42) * graph_scale
	var radius_y = (viewport_size.y * 0.35) * graph_scale
	
	for i in range(total_services):
		var s_instance = service_scene.instantiate()
		var s : ServiceNode = s_instance as ServiceNode
		
		if s == null: continue

		s.name = "Service %d" % i
		s.nameService = "Pole %d" % (i + 1)
		
		s.state = get_random_state()
		s.size = randi_range(1, 3) 
		s.type = randi() % 4
		
		var angle_step = TAU / total_services
		var base_angle = (angle_step * i) - (PI / 2)
		
		var random_angle = base_angle + randf_range(-0.15, 0.15)
		var dist_mod = randf_range(0.9, 1.05)
		
		var x_pos = cos(random_angle) * radius_x * dist_mod
		var y_pos = sin(random_angle) * radius_y * dist_mod
		
		s.position = center_screen + Vector2(x_pos, y_pos)
		
		s.connect("combat_requested", Callable(self, "_on_service_clicked"))
		
		if s.has_signal("mouse_entered"):
			s.connect("mouse_entered", Callable(self, "_on_service_hover_enter"))
			s.connect("mouse_exited", Callable(self, "_on_service_hover_exit"))
		else:
			var area = s.get_node_or_null("Area2D")
			if area:
				area.connect("mouse_entered", Callable(self, "_on_service_hover_enter"))
				area.connect("mouse_exited", Callable(self, "_on_service_hover_exit"))
		
		add_child(s)
		services.append(s)
		s.update_visual() 
	
	for i in range(total_services):
		services[i].add_link(services[(i+1) % total_services])
		if randf() < 0.25:
			var target_index = (i + 2) % total_services
			if not services[target_index] in services[i].links:
				services[i].add_link(services[target_index])
	
	update_links_visual()

func create_background():
	var bg
	if background_texture:
		bg = TextureRect.new()
		bg.texture = background_texture
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_SCALE 
	else:
		bg = ColorRect.new()
		bg.color = Color(0.106, 0.247, 0.250, 0.8) 
	
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	bg.size = get_viewport_rect().size
	bg.position = Vector2.ZERO
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	bg.z_index = -100 
	add_child(bg)

func update_links_visual():
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	
	var drawn_links = {}
	
	for s in services:
		var node_a = s as ServiceNode
		for neighbor in node_a.links:
			var node_b = neighbor as ServiceNode
			
			var id_1 = node_a.get_instance_id()
			var id_2 = node_b.get_instance_id()
			var key = str(min(id_1, id_2)) + "_" + str(max(id_1, id_2))
			
			if drawn_links.has(key): continue
			drawn_links[key] = true
			
			var line = Line2D.new()
			line.width = 2.0
			line.default_color = Color(0.5, 0.5, 0.5, 0.5)
			line.z_index = -1 
			
			var p1 = node_a.get_edge_position(node_b.position)
			var p2 = node_b.get_edge_position(node_a.position)
			
			line.points = [p1, p2]
			add_child(line)

func execute_turn():
	var next_states = {}
	for s in services:
		next_states[s] = s.calculate_next_state()
	
	var state_changed = false
	for s in services:
		if s.state != next_states[s]:
			s.state = next_states[s]
			s.update_visual()
			state_changed = true
			
	if state_changed:
		print("Des états ont changé.")

# --- NOUVELLE LOGIQUE CENTRALISÉE ---
func mark_node_as_secured(service_node: ServiceNode):
	# 1. Le noeud devient bleu
	service_node.set_completed()

	# 2. Influence sur les voisins
	for neighbor in service_node.links:
		if neighbor.has_method("reduce_difficulty"):
			neighbor.reduce_difficulty()
		
	# 3. Met à jour les lignes visuelles
	update_links_visual()
	
	# 4. Vérification de la victoire
	_check_victory_condition()

func _check_victory_condition():
	for s in services:
		# Si un seul service n'est pas bleu, on n'a pas encore gagné
		if s.state != "blue":
			return
	
	# Si on arrive ici, tout est bleu !
	emit_signal("all_nodes_secured")
# ------------------------------------

func get_organization_score() -> int:
	var score = 0
	for s in services:
		if not is_instance_valid(s): continue
		match s.state:
			"red":    score -= 10
			"orange": score -= 5
			"green":  score += 0 
			"blue":   score += 10 
	return score

func get_random_state() -> String:
	var roll = randf()
	if roll < 0.5: return "green"
	elif roll < 0.8: return "orange"
	else: return "red"

func _on_service_clicked(service: ServiceNode):
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	emit_signal("initiate_combat", service)

func _on_service_hover_enter():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_service_hover_exit():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
