extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()
func on_click():
	parent.on_click()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
