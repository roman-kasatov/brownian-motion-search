extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var statistics_label = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel/Control/StatisticsBlock/StatisticsLabel")

var current_size = Vector2()
var vortex = [Vector2(0, 1)]
var current_distance = 0

func decrease_uncertainty(distance, step):
	var current_uncertainty = vortex[-1].y - step
	vortex.append(Vector2(distance, vortex[-1].y))
	vortex.append(Vector2(distance, current_uncertainty))
	update()

	statistics_label.uncertainty = current_uncertainty
	statistics_label.update()

func reset():
	vortex = [Vector2(0, 1)]
	current_distance = 0

func update_distance(distance):
	current_distance = distance
	update()

func adjust_size():
	var parent_size = get_parent().rect_size
	print(parent_size)
	current_size = parent_size
	update()

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	print(get_path())
	adjust_size()


func _draw():
	draw_rect(Rect2(Vector2.ZERO, current_size), Color(0.8, 0.8, 0.8), true)
	var line_points = []
	var max_distance = vortex[-1].x
	var add_tail = false

	if current_distance != max_distance:
		max_distance = current_distance
		add_tail = true

	if max_distance == 0:
		max_distance = 1
	print(max_distance)
	var min_uncertainty = vortex[-1].y
	for v in vortex:
		line_points.append(Vector2(
			1.0 * v.x / max_distance * current_size.x,
			1.0 * (1 - v.y) * current_size.y
			)
		)
	if add_tail:
		line_points.append(Vector2(
			1.0 * current_distance / max_distance * current_size.x,
			line_points[-1].y
		))
	$Line2D.points = line_points


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
