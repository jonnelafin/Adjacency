extends Node2D

var debug_neighbour_reports = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var data = {}
var tiles = []
var tile_size = 32*2
var w = 10
var h = 6
var gap = 32

const tile_prefab = preload("res://Assets/Tiles/TileBasic.tscn");

onready var fps_label = $FPSLabel

func rand():
	if randi() % 2:
		return false
	return true
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(w):
		for i2 in range(h):
			var x = i*(tile_size+gap)+tile_size/2
			var y = i2*(tile_size+gap)+tile_size/2
			if rand():
				data[[x, y]] = [x, y, [i, i2]]
func find(i, i2, tils):
	for x in tils:
		if x is tileBasic:
			if x.x == i and x.y == i2:
				return x
	return ""
func find_a(i, i2, tils):
	for x in tils:
		if x is tileBasic:
			if x.a_x == i and x.a_y == i2:
				return x
	return ""
func reverseFind(tile):
	if data.has([tile.x, tile.y]):
		return true
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	fps_label.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("ui_reload"):
		for i in get_children():
			if i != fps_label:
				i.queue_free()
		data = {}
		tiles = []
		_ready()
	if Input.is_action_just_pressed("ui_debug"):
		print("Data: ")
		print(data)
		print("Find on 3, 2:")
		var fnd = find_a(3, 2, tiles)
		print(fnd)
		if is_instance_valid(fnd) and fnd is tileBasic:
			print(fnd.report())
			print("Neighbors: ")
			print(fnd.get_neighbours())
			if debug_neighbour_reports:
				print("Neighbor reports:")
				var reports = fnd.get_neighbours()
				for z in reports[0]:
					print("  " + z.report())
				print("log: ")
				print(reports[1])
		else:
			print("It seems as if that tile is not valid...")
		var is_empty_string = (str(fnd) == "")
		var is_valid_godot = is_instance_valid(fnd)
		var is_tile = (fnd is tileBasic)
		print("Checks: is_empty_string" + str(is_empty_string) + ", is_valid_godot" + str(is_valid_godot) + ", is_tile" + str(is_tile))
	for i in tiles:
		if not reverseFind(i):
			tiles.remove(i)
			i.queue_free()
	for i in data.values():
		var x = i[0]
		var y = i[1]
		var actuals = i[2]
		var tile = find(x, y, tiles)
		if str(tile) == "":
			var tileisnt = tile_prefab.instance()
			tileisnt.setSize(tile_size)
			tileisnt.x = x
			tileisnt.y = y
			tileisnt.a_x = actuals[0]
			tileisnt.a_y = actuals[1]
			tileisnt.parent = self
			self.add_child(tileisnt)
			tiles.append(tileisnt)
			tileisnt.genConnectors()