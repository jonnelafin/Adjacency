extends Node2D
class_name tileBasic

signal gen_ready
signal gen_ready_outer
var processing = false
var numop = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var x = 0
var y = 0
var a_x = 0
var a_y = 0
var state = -1
var parent
var disconnected_states = [-1]
var possible = []
var possible_log = ""
var future_size = ""

onready var hitbox = $Hitbox

onready var conn_up = $Connectors/Up
onready var conn_down = $Connectors/Down
onready var conn_left = $Connectors/Left
onready var conn_right = $Connectors/Right

var Sprites

var dirs = [
	[0, -1],
	[0, 1],
	[-1, 0],
	[1, 0]
]

var dirs_meaning = []

# Called when the node enters the scene tree for the first time.
func _ready():
	hitbox.parent = self
	dirs_meaning = [
		conn_up,
		conn_down,
		conn_left,
		conn_right
	]
	Sprites = [
		$Sprites/RD,
		$Sprites/RL,
		$Sprites/DL,
		$Sprites/LU,
		$Sprites/UR,
	]
	if is_instance_valid(parent):
		genConnectors()
	#setSize(500)

func toggleLook(ind):
	for i in Sprites:
		i.visible = false
	Sprites[ind].visible = true

func setSize(val):
	$Sprite.texture.width = val
	$Sprite.texture.height = val
	$Hitbox/CollisionShape2D.shape.extents.x = val/2
	$Hitbox/CollisionShape2D.shape.extents.y = val/2
	if len(Sprites) > 0: #is_instance_valid(Sprites) and 
		print(Sprites)
		for i in Sprites:
			print(i)
			var line = i.get_child(0)
			var points = line.points
			for ind in range(len(points)):
				var p = points[ind]
				print(p.x)
				if p.x > 0:
					p.x = val / 2
				if p.x < 0:
					p.x = -val / 2
				if p.y > 0:
					p.y = val / 2
				if p.y < 0:
					p.y = -val / 2
				points[ind] = p
			line.points = points
	else:
		print("Warning: tile has not yet been loaded, setting the size won't work!")
func on_click():
	match state:
		0:
			state = 1
		1:
			state = 0
	print("Click on " + str([a_x, a_y]) + " = " + str(state))
	var visited = []
	parent.last_tile = self
	gen_state(visited, state)
	yield(self, "gen_ready")
	#print(visited)
	print("(" + str([a_x, a_y]) + " = " + str(state) + ")")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if str(future_size) != "":
		print("Trying to set size to: " + str(future_size))
		setSize(int(future_size))
		future_size = ""
	self.global_position.x = x
	self.global_position.y = y
	if state == 3:
		self.modulate = Color(0, 1, 1, 1)
	if state == 2:
		self.modulate = Color(1, 0, 1, 1)
	if state == 1:
		self.modulate = Color(1, 1, 0, 1)
	if state == 0:
		self.modulate = Color(1, 1, 1, 1)
	if state == -1:
		self.modulate = Color(1, 1, 1, 0.15)
	if processing:
		self.modulate = Color(0, 1, 0, 1)
	toggleLook(self.state)
	#genConnectors()
func genConnectors():
	var i = 0
	for dir in dirs:
		var dx = dir[0]
		var dy = dir[1]
		var meaning = dirs_meaning[i]
		if is_instance_valid(meaning):
			var neighbour = parent.find_a(a_x+dx, a_y+dy, parent.tiles)
			if str(neighbour) != "" and is_instance_valid(neighbour) and (not (neighbour.state in disconnected_states)):
				meaning.modulate = Color(1, 1, 1, 1)
			else:
				meaning.modulate = Color(0, 0, 0, 0)
		i += 1
func report():
	return "Tile report: x" + str(a_x) + ", y" + str(a_y) + ", stat" + str(state) + ", pos" + str([x, y])
func get_neighbours():
	var out = []
	var out2 = []
	var logz = ""
	for dir in dirs:
		var dx = dir[0]
		var dy = dir[1]
		logz += "dx" + str(dx) + ", dy" + str(dy) + ", o" + str([a_x+dx, a_y+dy]) + "\n"
		var neighbour = parent.find_a(a_x+dx, a_y+dy, parent.tiles)
		if str(neighbour) != "" and is_instance_valid(neighbour): # and not (neighbour.state in disconnected_states)
			out.append(neighbour)
			out2.append(neighbour)
		else:
			out2.append("")
	return [out, logz, out2]


func gen_state(visited, _lastState = 0):
	processing = true
	numop += 1
	if self in visited:
#		self.state = visited[visited.size()-1].state
#		$Timer.stop()
#		$Timer.start()
#		yield($Timer, "timeout")
		emit_signal("gen_ready")
		numop -= 1
		if numop < 1:
			processing = false
		return
	visited.append(self)
	var neigh = self.get_neighbours()[0]
	var neighfill = self.get_neighbours()[2]
#	var sum = 0
#	for n in neigh:
#		sum += n.state
#	match sum:
#		-4:
#			state = 0
#		-3:
#			state = -1
#		-2:
#			state = 0
#		-1:
#			state = -1
#		0:
#			state = 1
#		1:
#			state = 0
#		2:
#			state = -1
#		3:
#			state = 2
#		4:
#			state = -1
#		5:
#			state = 0
#		6:
#			state = 0
	var last = visited[visited.size()-2]
	if last == self:
		last = visited[0]
	#self.state = lastState
	var poss = Ruleset.getAvailable(neighfill, [0, -1]) #0, 1
	self.possible_log = poss[1]
	self.possible = poss[0]
	if possible.size() > 0:
		self.state = possible[0]
	$Timer.stop()
	$Timer.start()
	yield($Timer, "timeout")
	for n in neigh:
		processing = false
		n.gen_state(visited, self.state)
		processing = true
	numop -= 1
	if numop < 1:
		processing = false
	emit_signal("gen_ready")
	emit_signal("gen_ready_outer")
	genConnectors()
