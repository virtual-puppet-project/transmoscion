extends CanvasLayer

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _ready() -> void:
	$NextScreenTimer.timeout.connect(func():
		get_tree().change_scene_to_file("res://screens/main.tscn")
	)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	get_tree().change_scene_to_file("res://screens/main.tscn")

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#
