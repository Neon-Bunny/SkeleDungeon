extends Node2D

const map_node = preload("res://Scenes/map_node.tscn")

var rows = 4
var columns = 7

var spacing_x = 150
var spacing_y = 75

var map_nodes = []

func _ready():
	generate_nodes()
	assign_start_and_boss()
	generate_paths()
	cleanup_nodes()

func assign_start_and_boss():

	var middle = rows / 2

	var start = map_nodes[middle][0]
	var boss = map_nodes[middle][columns - 1]

	start.node_type = "Start"
	boss.node_type = "Boss"

	start.connected = true
	start.unlock()
	boss.connected = true

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
			
		map_nodes.append(row_nodes)

func generate_paths():
	var path_count = 4
	var start_row = rows / 2
	
	for i in range(path_count):
		var y = start_row
		for x in range(columns - 1):
			var current = map_nodes[y][x]
			var shift = randi_range(-1, 1)
			var next_y = clamp(y + shift, 0, rows - 1)
			var next = map_nodes[next_y][x + 1]
			connect_nodes(current, next)
			y = next_y

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
	for row in map_nodes:
		for node in row:
			if !node.connected:
				node.hide()
