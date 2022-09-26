extends Label

var distance = 0
var entropy = 1
var precise = false

func _ready():
	update()

func update():
	var displayed_distance = distance
	if precise:
		text = "distance: %.1f, entropy: %.2f" % [displayed_distance, entropy]
	else:
		if distance > 1000:
			displayed_distance = floor(distance / 100) * 100
		elif distance > 100:
			displayed_distance = floor(distance / 10) * 10
		else:
			displayed_distance = distance
		text = "distance: %d, entropy: %.2f" % [displayed_distance, entropy]


func _on_precise_toggled(button_pressed):
	precise = button_pressed
	update()
