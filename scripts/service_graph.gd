extends Node2D

@export var service_scene : PackedScene = preload("res://scenes/ui/service_node.tscn")
var services := [] # array classique

signal initiate_combat(service: ServiceNode) # 

func _ready():
	create_graph()
	
	#oui bon c pour tester qu'on peut changer l'état + influence 


func create_graph():
	randomize() # pour avoir des valeurs différentes à chaque lancement

	var total_services = 5
	for i in range(total_services):
		var s_instance = service_scene.instantiate()
		var s : ServiceNode = s_instance as ServiceNode
		if s == null:
			print("Erreur : L'instance n'est pas un ServiceNode")
			continue

		s.name = "Service %d" % i
		s.nameService = "Service %d" % i
		s.state = get_random_state()
		
		# la taille sera définis dans nos données plus tard
		s.size = randi_range(1, 3) 
		
		s.position = get_circular_position(i, total_services, 200, Vector2(400,300))
		s.connect("combat_requested", Callable(self, "_on_service_clicked"))
		add_child(s)
		services.append(s)
		
		# Appelé APRES avoir défini state et size
		s.update_visual() 
	
	# réation des liens pour avoir un graphe a tester
	for i in range(total_services):
		services[i].add_link(services[(i+1) % total_services])
	
	update_links_visual()

#gestion d'un tour surtout pour gérer la propagation
func execute_turn():
	print("Système : Propagation de l'influence...")
	
	# Dictionnaire pour stocker les états futurs
	var next_states = {}

	# Chaque nœud calcule son futur état basé sur l'état ACTUEL des voisins
	for s in services:
		var service_node : ServiceNode = s as ServiceNode
		if service_node:
			# On demande au nœud de calculer son prochain état
			next_states[service_node] = service_node.calculate_next_state()
	
	# On applique les états calculés (tout en même temps)
	var state_changed = false
	for s in services:
		var service_node : ServiceNode = s as ServiceNode
		if service_node and service_node.state != next_states[service_node]:
			service_node.state = next_states[service_node]
			service_node.update_visual() # Mettre à jour la couleur/apparence
			state_changed = true
	
	if state_changed:
		print("Des états ont changé.")
	else:
		print("Le système est stable.")
	
	# Optionnel : Mettre à jour les lignes si leur couleur dépend de l'état
	# update_links_visual() 


func update_links_visual():
	# Supprimer les anciennes lignes
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	
	# Dessiner les lignes sans doublons
	var drawn_links = {}
	for s in services:
		var service_node: ServiceNode = s as ServiceNode # Typage pour plus de clarté
		if not service_node: continue
		
		for l_untyped in service_node.links:
			var l: ServiceNode = l_untyped as ServiceNode 
			if l == null:
				continue
				
			# Clé unique pour éviter doublons
			var key = str(min(s.get_instance_id(), l.get_instance_id())) + "_" + str(max(s.get_instance_id(), l.get_instance_id()))
			if drawn_links.has(key):
				continue
			drawn_links[key] = true

			var line = Line2D.new()
			line.width = 2
			line.default_color = Color(1,0,0) # rouge visible
			
		
			line.points = [s.get_edge_position(l.get_center_position()), l.get_edge_position(s.get_center_position())]
			add_child(line)

			
func get_random_state() -> String:
	var states = ["green","orange","red"]
	return states[randi() % states.size()]


func get_circular_position(index:int, total:int, radius:float = 200.0, center:Vector2 = Vector2(400,300)) -> Vector2:
	var angle = (TAU / total) * index
	return center + Vector2(cos(angle), sin(angle)) * radius

func _on_service_clicked(service: ServiceNode):
	# On transmet le signal au parent (qui sera le CombatManager)
	emit_signal("initiate_combat", service)
