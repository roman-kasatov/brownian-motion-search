extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const BASE_SIZE = Vector2(600.0, 400.0)
var current_size = BASE_SIZE

# settings
var rainbow_trace = false

# defaults
var trace_length = 10
var cell_num = Vector2(60, 40)
var simulation_active = false
var particle_direction = Vector2.RIGHT
var particle_speed = 200

var rainbow_colors = [
	Color(0.95, 0.05, 0.35),
	Color(1.00, 0.61, 0.00),
	Color(0.96, 0.84, 0.01),
	Color(0.01, 0.78, 0.01),
	Color(0.00, 0.55, 0.80),
	Color(0.46, 0.16, 0.88)
]


# variables
var cell_array = null
var trace_points = []
var total_distance = 0

# other nodes
onready var uncertainty_block = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel/Control/UncertaintyBlock")
onready var statistics_label = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel/Control/StatisticsBlock/StatisticsLabel")
onready var side_bar = get_node("/root/Main/VBoxContainer/HBoxContainer/SideBar")
onready var settings = get_node("/root/Main/SettingsPanel")

onready var particle = $Particle

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	randomize()
	load_settings()
	adjust_size()
	reset()

func load_settings():
	rainbow_trace = settings.get("rainbow_trace")

func reset():
	simulation_active = false
	side_bar.set_mode('prepare')
	trace_points = []

	distance_went = 0
	total_distance = 0
	cell_array = []
	for i in range(cell_num.x):
		cell_array.append([])
		for _j in range(cell_num.y):
			cell_array[i].append(0)
	
	uncertainty_block.total_cells = cell_num.x * cell_num.y
	uncertainty_block.reset()

	statistics_label.distance = total_distance
	statistics_label.update()

	update()

func adjust_size():
	var parent_size = get_parent().rect_size
	current_size = BASE_SIZE
	var base_ratio = BASE_SIZE.x / BASE_SIZE.y
	if parent_size.x / parent_size.y > base_ratio:
		current_size.y = parent_size.y
		current_size.x = current_size.y * base_ratio
	else:
		current_size.x = parent_size.x
		current_size.y = current_size.x / base_ratio

	self.scale = Vector2.ONE * current_size.x / BASE_SIZE.x
	self.position = (parent_size - current_size) / 2

func draw_cells():
	draw_rect(Rect2(Vector2.ZERO, BASE_SIZE), Color(0.5, 0.5, 0.5), true)
	for i in range(cell_num.x):
		for j in range(cell_num.y):
			if cell_array[i][j]:
				draw_rect(
					Rect2(
						Vector2(
							i * (BASE_SIZE.x / cell_num.x),
							j * (BASE_SIZE.y / cell_num.y)
						), 
						Vector2(
							BASE_SIZE.x / cell_num.x,
							BASE_SIZE.y / cell_num.y
						)
					),
					Color(0.8, 0.8, 0.8),
					true
				)

	# vertical lines
	for i in range(cell_num.x + 1):
		draw_line(
			Vector2(i * BASE_SIZE.x / cell_num.x, 0),
			Vector2(i * BASE_SIZE.x / cell_num.x, BASE_SIZE.y),
			Color(0.8, 0.8, 0.8),
			1.0
		)
	# horizontal lines
	for i in range(cell_num.y + 1):
		draw_line(
			Vector2(0, i * BASE_SIZE.y / cell_num.y),
			Vector2(BASE_SIZE.x, i * BASE_SIZE.y / cell_num.y),
			Color(0.8, 0.8, 0.8),
			1.0
		)
	# frame
	#draw_rect(Rect2(Vector2.ZERO, BASE_SIZE), Color(0.0, 0.0, 0.0), false, 4.0)

func draw_trace():
	if len(trace_points) == 0:
		return
	var color = Color(0.8, 0.2, 0.2)
	for i in range(len(trace_points) - 1):
		if rainbow_trace:
			color = rainbow_colors[(len(trace_points) - i - 1) % 6]
		draw_line(
			Vector2(trace_points[i]),
			Vector2(trace_points[i + 1]),
			color,
			2.0
		)
	if rainbow_trace:
		color = rainbow_colors[0]
	draw_line(
			Vector2(trace_points[len(trace_points) - 1]),
			Vector2(particle.position),
			color,
			2.0
		)

func _draw():
	draw_cells()
	draw_trace()

func start_simulation():
	if len(trace_points) == 0:
		trace_points = [particle.position]
	side_bar.set_mode('simulation')
	if distance_went == 0:
		generate_speed()
	self.simulation_active = true


func generate_speed():
	var angle = randf() * 2 * PI
	particle_direction = Vector2(cos(angle), sin(angle))
	
	if randf() < 0.00:
		jump_distance = 100
	else:
		jump_distance = 200

func stop_simulation():
	if trace_length > 0 and simulation_active:
		trace_points.append(particle.position)
	self.simulation_active = false


var distance_went = 0
var jump_distance = 0

func _process(delta):
	if simulation_active:
		move_particle(particle_speed * delta)

func move_particle(step_length):
		# set direction
	if distance_went >= jump_distance:
		distance_went = 0
		generate_speed()
		
		if trace_length > 0 and simulation_active:
			trace_points.append(particle.position)
			
			while trace_length < len(trace_points):
				trace_points.remove(0)

	# make step
	var step = particle_direction * step_length
	particle.position += step
	distance_went += step.length()
	total_distance += step.length()

	var bounce_flag = false
	if particle.position.x < 0:
		bounce_flag = true
		particle.position.x = 0.0001
		particle_direction.x = -particle_direction.x
	if particle.position.x > BASE_SIZE.x:
		bounce_flag = true
		particle.position.x = BASE_SIZE.x - 0.0001
		particle_direction.x = -particle_direction.x
	if particle.position.y < 0:
		bounce_flag = true
		particle.position.y = 0.0001
		particle_direction.y = - particle_direction.y
	if particle.position.y > BASE_SIZE.y:
		bounce_flag = true
		particle.position.y = BASE_SIZE.y - 0.0001
		particle_direction.y = - particle_direction.y
	
	if bounce_flag:
		if trace_length > 0 and simulation_active:
			trace_points.append(particle.position)
			
			while trace_length < len(trace_points):
				trace_points.remove(0)

	# mark visited cells

	var start_point = particle.position - step
	var end_point = particle.position
	var cell_size = (0.0 + BASE_SIZE.x) / cell_num.x

	if start_point.x > end_point.x:
		var tmp = start_point
		start_point = end_point
		end_point = tmp

	var new_cells_found = 0.0
	var min_cell_x = ceil(start_point.x / cell_size)
	var max_cell_x = ceil(end_point.x / cell_size)
	for cell_x in range(min_cell_x, max_cell_x):
		var x = cell_x * cell_size
		var cell_y = floor(lerp(start_point.y, end_point.y, (x - start_point.x) / (end_point.x - start_point.x)) / cell_size)
		if cell_array[cell_x][cell_y] == 0:
			cell_array[cell_x][cell_y] = 1
			new_cells_found += 1
		if cell_array[cell_x - 1][cell_y] == 0:
			cell_array[cell_x - 1][cell_y] = 1
			new_cells_found += 1

	if start_point.y > end_point.y:
		var tmp = start_point
		start_point = end_point
		end_point = tmp

	var min_cell_y = ceil(start_point.y / cell_size)
	var max_cell_y = ceil(end_point.y / cell_size)
	for cell_y in range(min_cell_y, max_cell_y):
		var y = cell_y * cell_size
		var cell_x = floor(lerp(start_point.x, end_point.x, (y - start_point.y) / (end_point.y - start_point.y)) / cell_size)
		if cell_array[cell_x][cell_y] == 0:
			cell_array[cell_x][cell_y] = 1
			new_cells_found += 1
		if cell_array[cell_x][cell_y - 1] == 0:
			cell_array[cell_x][cell_y - 1] = 1
			new_cells_found += 1

	uncertainty_block.update_entropy(total_distance, new_cells_found)

	statistics_label.distance = total_distance
	statistics_label.update()
			
	update()


var dragging_particle = false
var last_mouse_pos = 0
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if $Particle/Area2D/CollisionShape2D.shape.radius * particle.scale.x > \
					get_local_mouse_position().distance_to(particle.position):
				dragging_particle = true
				last_mouse_pos = get_local_mouse_position()
		else:
			dragging_particle = false
	elif event is InputEventMouseMotion and dragging_particle:
		var new_mouse_pos = get_local_mouse_position()
		particle.position += (new_mouse_pos - last_mouse_pos)
	
		if particle.position.x < 0:
			particle.position.x = 0
			dragging_particle = false
		if particle.position.x > BASE_SIZE.x:
			particle.position.x = BASE_SIZE.x - 0.0001
			dragging_particle = false
		if particle.position.y < 0:
			particle.position.y = 0
			dragging_particle = false
		if particle.position.y > BASE_SIZE.y:
			particle.position.y = BASE_SIZE.y - 0.0001
			dragging_particle = false
	
		last_mouse_pos = new_mouse_pos


func set_speed(value):
	particle_speed = value

func set_trace_length(value):
	trace_length = value

func set_cell_size(value):
	if value == 'S':
		cell_num = Vector2(120, 80)
	elif value == 'M':
		cell_num = Vector2(60, 40)
	elif value == 'L':
		cell_num = Vector2(30, 20) # 30 20
	reset()
