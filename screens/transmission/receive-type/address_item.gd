extends HBoxContainer

@onready
var ip := $IP as LineEdit
@onready
var port := $Port as LineEdit
@onready
var delete := $Delete as Button

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _ready() -> void:
	delete.pressed.connect(func() -> void:
		queue_free()
	)

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#

func get_ip() -> String:
	return ip.text

func get_port() -> int:
	return port.text.to_int() if port.text.is_valid_int() else -1
