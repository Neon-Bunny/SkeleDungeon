extends Node2D

const MapNode = preload("res://Scenes/map_node.tscn")

var rows = 4
var columns = 7
var spacing_x = 150
var spacing_y = 75

var MapNodes = []

func _ready():
	generate_nodes()

func generate_nodes():
	for y in range(rows):
		var RowNodes = []
		for x in range (columns):
			var node = MapNode.instantiate()
			$Nodes.add_child(node)
			node.position = Vector2(
				x * spacing_x + 100,
				y * spacing_y + 200
			)
			
			RowNodes.append(node)
			
		MapNodes.append(RowNodes)
