extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reload_scene():
	get_tree().reload_current_scene()

func toggle_help(turn_on):
	if turn_on:
		$HelpPanel.visible = true
		$HelpDimmer.visible = true
		get_tree().paused = true
	else:
		$HelpPanel.visible = false
		$HelpDimmer.visible = false
		get_tree().paused = false
