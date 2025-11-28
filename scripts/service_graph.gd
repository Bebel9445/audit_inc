extends Node2D

# Signal global vers le CombatManager
signal initiate_combat(service: ServiceNode)

@export var service_scene : PackedScene = preload("res://scenes/ui/service_node.tscn")
var services := [] 

func _ready():
	# On attend une frame pour être sûr que la taille de l'écran est correcte
	call_deferred("create_graph")

func create_graph():
	randomize()
	
	# Nettoyage
	for child in get_children():
		child.queue_free()
	services.clear()

	var total_services = 5
	
	# --- CENTRAGE AUTOMATIQUE ---
	# On récupère la taille visible de la fenêtre de jeu
	var viewport_size = get_viewport_rect().size
	
	# Le centre est la moitié de la taille
	var center_screen = viewport_size / 2
	
	# Le rayon s'adapte : on prend 35% de la plus petite dimension (hauteur ou largeur)
	# Cela laisse une marge confortable sur les bords
	var radius = min(viewport_size.x, viewport_size.y) * 0.35
	
	# 1. Création des Noeuds
	for i in range(total_services):
		var s_instance = service_scene.instantiate()
		var s : ServiceNode = s_instance as ServiceNode
		
		if s == null: continue

		s.name = "Service %d" % i
		s.nameService = "Pole %d" % (i + 1)
		
		# Stats aléatoires
		s.state = get_random_state()
		s.size = randi_range(1, 3) 
		# Type aléatoire
		s.type = randi() % 4
		
		# Positionnement en cercle autour du centre calculé
		s.position = get_circular_position(i, total_services, radius, center_screen)
		
		s.connect("combat_requested", Callable(self, "_on_service_clicked"))
		
		add_child(s)
		services.append(s)
		
		s.update_visual() 
	
	# 2. Création des Liens
	for i in range(total_services):
		services[i].add_link(services[(i+1) % total_services])
	
	# 3. Dessiner les lignes
	update_links_visual()

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
			line.width = 2.0 # Ligne plus fine car les noeuds sont plus petits
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

func get_random_state() -> String:
	var roll = randf()
	if roll < 0.5: return "green"
	elif roll < 0.8: return "orange"
	else: return "red"

func get_circular_position(index: int, total: int, radius: float, center: Vector2) -> Vector2:
	var angle = (TAU / total) * index - (PI / 2)
	return center + Vector2(cos(angle), sin(angle)) * radius

func _on_service_clicked(service: ServiceNode):
	emit_signal("initiate_combat", service)
