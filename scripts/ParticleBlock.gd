extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const BASE_SIZE = Vector2(600.0, 400.0)
var current_size = BASE_SIZE
var cell_num = Vector2(30, 20)

var simulation_active = false
var particle_direction = Vector2.RIGHT
var particle_speed = 200

var cell_array = null

var total_distance = 0
onready var uncertainty_block = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel/Control/UncertaintyBlock")
onready var statistics_label = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel/Control/StatisticsBlock/StatisticsLabel")
onready var particle = $Particle

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	randomize()
	adjust_size()
	reset()

func reset():
	uncertainty_block.reset()
	distance_went = 0
	total_distance = 0
	cell_array = []
	for i in range(cell_num.x):
		cell_array.append([])
		for j in range(cell_num.y):
			cell_array[i].append(0)

func adjust_size():
	var parent_size = get_parent().rect_size
	var current_size = BASE_SIZE
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
	draw_rect(Rect2(Vector2.ZERO, BASE_SIZE), Color(0.8, 0.8, 0.8), true)
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
					Color(0.5, 0.4, 0.4),
					true
				)

	# vertical lines
	for i in range(cell_num.x + 1):
		draw_line(
			Vector2(i * BASE_SIZE.x / cell_num.x, 0),
			Vector2(i * BASE_SIZE.x / cell_num.x, BASE_SIZE.y),
			Color(0.2, 0.2, 0.2),
			1.0
		)
	# horizontal lines
	for i in range(cell_num.y + 1):
		draw_line(
			Vector2(0, i * BASE_SIZE.y / cell_num.y),
			Vector2(BASE_SIZE.x, i * BASE_SIZE.y / cell_num.y),
			Color(0.2, 0.2, 0.2),
			1.0
		)
	# ftame
	draw_rect(Rect2(Vector2.ZERO, BASE_SIZE), Color(0.0, 0.0, 0.0), false, 4.0)

func _draw():
	draw_cells()

func start_simulation():
	if distance_went == 0:
		generate_speed()
	self.simulation_active = true


func generate_speed():
	var angle = randf() * 2 * PI
	particle_direction = Vector2(cos(angle), sin(angle))
	jump_distance = 100

func stop_simulation():
	self.simulation_active = false

var distance_went = 0
var jump_distance = 0
func _process(delta):
	if simulation_active:
		if distance_went >= jump_distance:
			distance_went = 0
			generate_speed()

		var step = particle_direction * particle_speed * delta
		particle.position += step
		distance_went += step.length()
		total_distance += step.length()

		if particle.position.x < 0:
			particle.position.x = 0
			particle_direction.x = -particle_direction.x
		if particle.position.x > BASE_SIZE.x:
			particle.position.x = BASE_SIZE.x - 0.0001
			particle_direction.x = -particle_direction.x
		if particle.position.y < 0:
			particle.position.y = 0
			particle_direction.y = - particle_direction.y
		if particle.position.y > BASE_SIZE.y:
			particle.position.y = BASE_SIZE.y - 0.0001
			particle_direction.y = - particle_direction.y
		
		var i = floor(particle.position.x / (BASE_SIZE.x / cell_num.x))
		var j = floor(particle.position.y / (BASE_SIZE.y / cell_num.y))
		
		print(particle.position)
		print(i, j)

		if cell_array[i][j] == 0:
			cell_array[i][j] = 1
			uncertainty_block.decrease_uncertainty(total_distance, 1.0 / cell_num.x / cell_num.y)
		else:
			uncertainty_block.update_distance(total_distance)

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
