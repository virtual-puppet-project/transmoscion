class_name OSCData
extends RefCounted

## https://opensoundcontrol.stanford.edu/spec-1_0.html

class Address extends OSCData:
	const ADDRESS_IDENTIFIER := "/"
	
	func _parse(stream: StreamPeerBuffer) -> void:
		pass

class Bundle extends OSCData:
	const BUNDLE_IDENTIFIER := "#bundle"
	
	func _parse(stream: StreamPeerBuffer) -> void:
		pass

var data := {}

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _init(stream: StreamPeerBuffer) -> void:
	_parse(stream)

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

func _parse(stream: StreamPeerBuffer) -> void:
	self.data["invalid"] = "invalid"
	self.data["raw"] = stream.data_array

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#

static func from_bytes(bytes: PackedByteArray) -> OSCData:
	var stream := StreamPeerBuffer.new()
	stream.data_array = bytes
	
	var stream_size: int = stream.get_size()
	if stream_size < 4 or stream_size % 4 != 0:
		return OSCData.new(stream)
	
	var first_char: String = char(stream.get_u8())
	stream.seek(0)
	
	match first_char:
		"/":
			return Address.new(stream)
		"#":
			return Bundle.new(stream)
		_:
			return OSCData.new(stream)

static func from_string(text: String) -> OSCData:
	var stream := StreamPeerBuffer.new()
	stream.data_array = text.to_utf8_buffer()
	
	if text.begins_with(Address.ADDRESS_IDENTIFIER):
		return Address.new(stream)
	elif text.begins_with(Bundle.BUNDLE_IDENTIFIER):
		return Bundle.new(stream)
	else:
		return OSCData.new(stream)
