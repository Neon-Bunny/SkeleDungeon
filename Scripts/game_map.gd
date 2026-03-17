extends Node2D

const map_node = preload("res://Scenes/map_node.tscn")

var rows = 4
var columns = 7

var spacing_x = 150
var spacing_y = 75

func _ready():
	if GameState.map_nodes.is_empty():
		generate_nodes()
		assign_start_and_boss()
		generate_paths()
		cleanup_nodes()

func assign_start_and_boss():

	var middle_row = rows / 2

	var start = GameState.map_nodes[middle_row][0]
	var boss = GameState.map_nodes[middle_row][columns - 1]

	start.node_type = "Start"
	boss.node_type = "Boss"

	start.connected = true
	start.unlock()
	boss.connected = true
	
	for i in range(0, rows - 1):
		var node = GameState.map_nodes[i][columns - 1]
		if node.node_type != "Boss":
			node.queue_free()

func generate_nodes():
	for y in range(rows):
		var row_nodes = []
		for x in range (columns):
			var node = map_node.instantiate()
			$Nodes.add_child(node)
			node.position = Vector2(
				x * spacing_x + 100,
				y * spacing_y + 200
			)
			
			row_nodes.append(node)
			
		GameState.map_nodes.append(row_nodes)

func generate_paths():
	var path_count = 4
	var middle_row = rows / 2
	
	for i in range(path_count):
		var y = middle_row
		for x in range(columns - 2):
			var current = GameState.map_nodes[y][x]
			var shift = randi_range(-1, 1)
			var next_y = clamp(y + shift, 0, rows - 1)
			var next = GameState.map_nodes[next_y][x + 1]
			connect_nodes(current, next)
			y = next_y
		
		var boss = GameState.map_nodes[middle_row][columns - 1]
		for j in range(rows):
			var node_a = GameState.map_nodes[j][columns - 2]
			if node_a.connected == true:
				connect_nodes(node_a, boss)

func connect_nodes(a, b):
	a.connected = true
	b.connected = true
	a.next_nodes.append(b)
	
	var line = Line2D.new()
	line.width = 4
	line.add_point(a.position)
	line.add_point(b.position)
	$Connections.add_child(line)

func cleanup_nodes():
	for row in GameState.map_nodes:
		for node in row:
			if !node.connected:
				node.hide()
#
########
#const map_node = preload("res://Scenes/map_node.tscn")
#
#var rows = 4
#var columns = 7
#
#var spacing_x = 150
#var spacing_y = 75
#
#func _ready():
#	if len(GameState.map_nodes) == 0:
#		generate_nodes()
#		assign_start_and_boss()
#		generate_paths()
#		cleanup_nodes()
#
#func assign_start_and_boss():
#
#	var middle_row = rows / 2
#
#	var start = GameState.map_nodes[middle_row][0]
#	var boss = GameState.map_nodes[middle_row][columns - 1]
#
#	start.node_type = "Start"
#	boss.node_type = "Boss"
#
#	start.connected = true
#	start.unlock()
#	boss.connected = true
#	
#	for i in range(0, rows - 1):
#		var node = GameState.map_nodes[i][columns - 1]
#		if node.node_type != "Boss":
#			node.queue_free()
#
#func generate_nodes():
#	for y in range(rows):
#		var row_nodes = []
#		for x in range (columns):
#			var node = map_node.instantiate()
#			$Nodes.add_child(node)
#			node.position = Vector2(
#				x * spacing_x + 100,
#				y * spacing_y + 200
#			)
#			
#			row_nodes.append(node)
#			
#		GameState.map_nodes.append(row_nodes)
#
#func generate_paths():
#	var path_count = 4
#	var middle_row = rows / 2
#	
#	for i in range(path_count):
#		var y = middle_row
#		for x in range(columns - 2):
#			var current = GameState.map_nodes[y][x]
#			var shift = randi_range(-1, 1)
#			var next_y = clamp(y + shift, 0, rows - 1)
#			var next = GameState.map_nodes[next_y][x + 1]
#			connect_nodes(current, next)
#			y = next_y
#		
#		var boss = GameState.map_nodes[middle_row][columns - 1]
#		for j in range(rows):
#			var node_a = GameState.map_nodes[j][columns - 2]
#			if node_a.connected == true:
#				connect_nodes(node_a, boss)
#
#func connect_nodes(a, b):
#	a.connected = true
#	b.connected = true
#	a.next_nodes.append(b)
#	
#	var line = Line2D.new()
#	line.width = 4
#	line.add_point(a.position)
#	line.add_point(b.position)
#	$Connections.add_child(line)
#
#func cleanup_nodes():
#	for row in GameState.map_nodes:
#		for node in row:
#			if !node.connected:
#				node.hide()
#The fundamental problem is that you are storing Node instances in your GameState. When you change scenes, Godot marks those nodes as "orphaned" or destroyed because they were part of the previous scene's tree. Even if they stay in your array, they lose their visual representation and their next_nodes references might break.
#To fix this while keeping your current logic, you should store data objects (Dictionaries or Resources) instead of the scene instances.
#Here is the refactored script. I’ve updated it to generate a "Blueprint" first, then draw it:
#gdscript
#extends Node2D
#
#const map_node_scene = preload("res://Scenes/map_node.tscn")
#
#var rows = 4
#var columns = 7
#var spacing_x = 150
#var spacing_y = 75
#
#func _ready():
#	# If map_data is empty, generate the "blueprint" first
#	if GameState.map_data.is_empty():
#		generate_map_blueprint()
#		assign_logic()
#		generate_paths_logic()
#	
#	# Every time we enter the scene, we draw based on that blueprint
#	render_map()
#
## 1. CREATE DATA (Run once)
#func generate_map_blueprint():
#	for y in range(rows):
#		var row_data = []
#		for x in range(columns):
#			row_data.append({
#				"pos": Vector2(x * spacing_x + 100, y * spacing_y + 200),
#				"type": "Normal",
#				"connected": false,
#				"unlocked": false,
#				"next_coords": [] # Stores Vector2i(row, col)
#			})
#		GameState.map_data.append(row_data)
#
## 2. ASSIGN TYPES (Run once)
#func assign_logic():
#	var middle = rows / 2
#	var start = GameState.map_data[middle][0]
#	var boss = GameState.map_data[middle][columns - 1]
#	
#	start.type = "Start"
#	start.connected = true
#	start.unlocked = true
#	boss.type = "Boss"
#	boss.connected = true
#
## 3. CALCULATE PATHS (Run once - Logic only)
#func generate_paths_logic():
#	var path_count = 4
#	var middle_row = rows / 2
#	
#	for i in range(path_count):
#		var y = middle_row
#		for x in range(columns - 2):
#			var shift = randi_range(-1, 1)
#			var next_y = clamp(y + shift, 0, rows - 1)
#			
#			connect_data_nodes(y, x, next_y, x + 1)
#			y = next_y
#		
#		# Connect to boss
#		for j in range(rows):
#			if GameState.map_data[j][columns - 2].connected:
#				connect_data_nodes(j, columns - 2, middle_row, columns - 1)
#
#func connect_data_nodes(y1, x1, y2, x2):
#	var a = GameState.map_data[y1][x1]
#	var b = GameState.map_data[y2][x2]
#	a.connected = true
#	b.connected = true
#	# Store the coordinate so we can find it again later
#	var target_coord = Vector2i(y2, x2)
#	if not target_coord in a.next_coords:
#		a.next_coords.append(target_coord)
#
## 4. DRAW EVERYTHING (Run every time you return to map)
#func render_map():
#	# Draw Lines first
#	for y in range(rows):
#		for x in range(columns):
#			var data = GameState.map_data[y][x]
#			for coord in data.next_coords:
#				var target = GameState.map_data[coord.x][coord.y]
#				create_line(data.pos, target.pos)
#				
#	# Draw Nodes
#	for y in range(rows):
#		for x in range(columns):
#			var data = GameState.map_data[y][x]
#			if not data.connected: continue
#			
#			var node = map_node_scene.instantiate()
#			$Nodes.add_child(node)
#			node.position = data.pos
#			# Give the node its data (so it knows if it's a boss, etc.)
#			if node.has_method("setup"):
#				node.setup(data)
#
#func create_line(pos_a, pos_b):
#	var line = Line2D.new()
#	line.width = 4
#	line.add_point(pos_a)
#	line.add_point(pos_b)
#	line.z_index = -1 # Keep lines behind nodes
#	$Connections.add_child(line)
#Use code with caution.
#
#Why this works for you:
#Persistence: Your GameState.map_data is now just a bunch of numbers and strings. Godot won't delete these when you switch scenes.
#Next Levels: When a player finishes a level, you can set GameState.map_data[y][x].unlocked = true. When they return to the map, render_map() runs, sees that value, and colors the node appropriately.
#Cleanliness: Your logic (random path generation) is separated from your visuals (instantiating scenes).
#Note on GameState: Change var map_nodes = [] to var map_data = [] in your Autoload script to match this logic!
