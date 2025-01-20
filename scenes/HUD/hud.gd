extends Control
#This node is where we (probably) put the spinning wheel too
@export var stopwatch_label: Label
@export var highscore_label: Label

var stopwatch : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	stopwatch = get_tree().get_first_node_in_group("stopwatch")
	highscore_label.text = stopwatch.time_to_string(get_parent().load_highscore())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_stopwatch()
	
# Time to String to Label
func update_stopwatch():
	stopwatch_label.text = stopwatch.time_to_string(stopwatch.time_alive)
