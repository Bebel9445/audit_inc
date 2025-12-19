extends Node2D
class_name ServiceGraph

# --- SIGNAUX ---

## Signal émis lorsqu'un joueur clique sur un noeud pour lancer un combat.
signal initiate_combat(service: ServiceNode)

## Signal émis lorsque tous les noeuds sont sécurisés (Bleu).
signal all_nodes_secured 

# --- CONFIGURATION (Export) ---

@export_category("Configuration Graphique")
@export var service_scene : PackedScene = preload("res://scenes/ui/service_node.tscn")
@export var background_texture : Texture2D = preload("res://assets/background.png")

## Police utilisée pour les labels des noeuds.
@export var font_bytebounce : FontFile = preload("res://assets/fonts/ByteBounce.ttf") 

@export_group("Ajustement du Graphe")
## Décalage du centre du graphe par rapport au centre de l'écran.
@export var graph_center_offset : Vector2 = Vector2(0,40) 
@export_range(0.1, 2.0) var graph_scale : float = 0.7

## Liste de toutes les instances de ServiceNode actives.
var services := [] 

func _ready():
	# On differe la création pour s'assurer que le viewport est prêt
	call_deferred("create_graph")

# --- GÉNÉRATION PROCÉDURALE ---

## Génère le graphe complet : Noeuds, Couleurs, Positions et Liens.
func create_graph():
	randomize()
	
	# Nettoyage
	for child in get_children():
		child.queue_free()
	services.clear()

	create_background()

	# Nombre aléatoire de noeuds
	var total_services = randi_range(6,8)
	
	# --- LOGIQUE DU SAC (BAG SYSTEM) ---
	# Garantit une distribution équilibrée de la difficulté.
	var color_bag: Array[String] = []
	
	# Règle 1 : Minimum 3 Verts (Facile) pour le farm
	for i in range(3):
		color_bag.append("green")
		
	# Règle 2 : Maximum 1 Rouge (Boss)
	color_bag.append("red")
	
	# Règle 3 : Le reste en Orange (Normal)
	while color_bag.size() < total_services:
		color_bag.append("orange")
	
	# Sécurité (Si la configuration change)
	if color_bag.size() > total_services:
		color_bag.resize(total_services)
		
	# Mélange pour répartir les difficultés
	color_bag.shuffle()
	# -----------------------------------

	# Calcul de la géométrie (Cercle)
	var viewport_size = get_viewport_rect().size
	var center_screen = (viewport_size / 2) + graph_center_offset
	var radius_x = (viewport_size.x * 0.42) * graph_scale
	var radius_y = (viewport_size.y * 0.35) * graph_scale
	
	# Instanciation des noeuds
	for i in range(total_services):
		var s_instance = service_scene.instantiate()
		var s : ServiceNode = s_instance as ServiceNode
		
		if s == null: continue

		s.name = "Service %d" % i
		
		# Application de la couleur piochée
		s.state = color_bag[i] 
		
		s.size = randi_range(1, 3) 
		s.type = randi() % 4 
		
		# Positionnement en cercle avec légère variation aléatoire
		var angle_step = TAU / total_services
		var base_angle = (angle_step * i) - (PI / 2)
		var random_angle = base_angle + randf_range(-0.15, 0.15)
		var dist_mod = randf_range(0.9, 1.05)
		
		var x_pos = cos(random_angle) * radius_x * dist_mod
		var y_pos = sin(random_angle) * radius_y * dist_mod
		s.position = center_screen + Vector2(x_pos, y_pos)
		
		# Connexion des signaux
		s.connect("combat_requested", Callable(self, "_on_service_clicked"))
		
		# Gestion curseur souris
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
		
		if s.label and font_bytebounce:
			s.label.add_theme_font_override("font", font_bytebounce)
		
		s.update_visual() 
	
	# Création des liens (Arêtes du graphe)
	for i in range(total_services):
		# Lien vers le suivant (Cercle fermé)
		services[i].add_link(services[(i+1) % total_services])
		
		# Lien aléatoire supplémentaire (Croisement) -> 25% de chance
		if randf() < 0.25:
			var target_index = (i + 2) % total_services
			if not services[target_index] in services[i].links:
				services[i].add_link(services[target_index])
	
	update_links_visual()

## Crée ou met à jour le fond d'écran.
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

## Dessine les lignes (Line2D) entre les noeuds connectés.
func update_links_visual():
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	
	var drawn_links = {}
	
	for s in services:
		var node_a = s as ServiceNode
		for neighbor in node_a.links:
			var node_b = neighbor as ServiceNode
			
			# Astuce pour ne pas dessiner deux fois la même ligne (A->B et B->A)
			var id_1 = node_a.get_instance_id()
			var id_2 = node_b.get_instance_id()
			var key = str(min(id_1, id_2)) + "_" + str(max(id_1, id_2))
			
			if drawn_links.has(key): continue
			drawn_links[key] = true
			
			var line = Line2D.new()
			line.width = 2.0
			line.default_color = Color(0.5, 0.5, 0.5, 0.5)
			line.z_index = -1 
			
			# Calcul des points d'attache sur le bord du cercle
			var p1 = node_a.get_edge_position(node_b.position)
			var p2 = node_b.get_edge_position(node_a.position)
			
			line.points = [p1, p2]
			add_child(line)

# --- LOGIQUE DE JEU ---

## Applique la réussite d'un noeud (passage au Bleu) et propage l'effet.
func mark_node_as_secured(service_node: ServiceNode):
	service_node.set_completed()

	# Réduction de difficulté sur les voisins
	for neighbor in service_node.links:
		if neighbor.has_method("reduce_difficulty"):
			neighbor.reduce_difficulty()
		
	update_links_visual()
	_check_victory_condition()

## Vérifie si tous les noeuds sont Bleus.
func _check_victory_condition():
	for s in services:
		if s.state != "blue":
			return
	emit_signal("all_nodes_secured")

## Calcule le score actuel basé sur l'état des noeuds.
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

# --- CALLBACKS UI ---

func _on_service_clicked(service: ServiceNode):
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	emit_signal("initiate_combat", service)

func _on_service_hover_enter():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_service_hover_exit():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
