extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var statistics_label = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel/Control/StatisticsBlock/StatisticsLabel")

var current_size = Vector2()
var vortex = [Vector2(0, 1)]
var current_distance = 0
var total_cells = 1
var cells_left = 1

func update_entropy(distance, new_cells_found):
	current_distance = distance
	if new_cells_found > 0:
		cells_left -= new_cells_found
		var current_entropy = log(cells_left) / log(total_cells)
		vortex.append(Vector2(distance, vortex[-1].y))
		vortex.append(Vector2(distance, current_entropy))
		
		statistics_label.entropy = current_entropy
		statistics_label.update()
	update()


func reset():
	cells_left = total_cells
	vortex = [Vector2(0, 1)]
	current_distance = 0


func adjust_size():
	var parent_size = get_parent().rect_size
	current_size = parent_size
	update()

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	adjust_size()


func _draw():
	draw_rect(Rect2(Vector2.ZERO, current_size), Color(0.8, 0.8, 0.8), true)
	draw_chart()
	
func draw_chart():
	var color = Color.red
	var max_distance = vortex[-1].x
	var add_tail = false

	if current_distance != max_distance:
		max_distance = current_distance
		add_tail = true

	if max_distance == 0: # ???
		max_distance = 1
	
	var chart_scale = Vector2(
		current_size.x / max(1, current_distance),
		current_size.y
	)
	
	for i in range(len(vortex) - 1):
		draw_line(
			Vector2(
				vortex[i].x,
				1 - vortex[i].y
			) * chart_scale,
			Vector2(
				vortex[i + 1].x,
				1 - vortex[i + 1].y
			) * chart_scale,
			color,
			2.0
		)

	if add_tail:
		draw_line(
			Vector2(
				vortex[len(vortex) - 1].x,
				1 - vortex[len(vortex) - 1].y
			) * chart_scale,
			Vector2(
				current_distance,
				1 - vortex[len(vortex) - 1].y
			) * chart_scale,
			color,
			2.0
		)
#		line_points.append(Vector2(
#			1.0 * current_distance / max_distance * current_size.x,
#			line_points[-1].y
#		))
#	$Line2D.points = line_points
#		var color = Color(0.8, 0.2, 0.2)
#	for i in range(len(trace_points) - 1):
#		if rainbow_trace:
#			color = rainbow_colors[(len(trace_points) - i - 1) % 6]
#		draw_line(
#			Vector2(trace_points[i]),
#			Vector2(trace_points[i + 1]),
#			color,
#			2.0
#		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
