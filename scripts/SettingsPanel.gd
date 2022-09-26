extends Panel
var settings_loaded = false

onready var particle_block = get_node("/root/Main/VBoxContainer/HBoxContainer/VBoxContainer/Panel2/Control/ParticleBlock")

var default_settings = {
	'rainbow_trace': false
}

var settings = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()

func load_settings():
	settings_loaded = true
	for key in default_settings:
		settings[key] = default_settings[key]
	
	$VBoxContainer/VBoxContainer/HBoxContainer/CheckBox.pressed = settings['rainbow_trace']
	print(settings['rainbow_trace'])

func get(key):
	if not settings_loaded:
		load_settings()
	return settings[key]

func set(value, key):
	settings[key] = value
	particle_block.load_settings()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

