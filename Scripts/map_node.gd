extends Node2D

var node_type = ""
var connected = false
var unlocked = false
var next_nodes = []

func _ready():
	$Button.disabled = true

func unlock():
	unlocked = true
	$Button.disabled = false
