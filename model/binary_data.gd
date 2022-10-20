class_name BinaryData
extends RefCounted

## Handles saving and loading binary data.

## Data class that stores a timestamp and binary data.
class DataPoint extends Object:
	## The time since recording in msecs.
	var timestamp: float = -1.0
	## The binary data received as bytes.
	var data := PackedByteArray()
	
	func _init(p_timestamp: float, p_data: PackedByteArray) -> void:
		timestamp = p_timestamp
		data.append_array(p_data)
	
	func _to_string() -> String:
		return "%.4f %s" % [timestamp, data.get_string_from_utf8()]
	
	## Gets the timestamp (rounded to four decimal places) and the data converted to a String.
	func as_string() -> String:
		return _to_string()
## All data received. Automatically timestamped.
var _data_points: Array[DataPoint] = []

## Whether or not recording data has started. Only useful as a flag.
var _is_recording := false
const DEFAULT_STARTING_TICKS: float = -1.0
## Changed to the engine ticks in msec when recording starts.
var _starting_ticks: float = DEFAULT_STARTING_TICKS

const MAGIC_HEADER := "vpptosc"
const VERSION_MAJOR: int = 0
const VERSION_MINOR: int = 1
const VERSION_PATCH: int = 0

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

func _parse_bytes(file: FileAccess) -> int:
	var timestamp: float = -1.0
	var size: int = 0
	var data: PackedByteArray
	
	var counter: int = -1
	while not file.eof_reached():
		counter += 1
		match counter:
			0:
				timestamp = file.get_double()
				if timestamp < 0.0:
					printerr("Bad timestamp: %.4f" % timestamp)
					return ERR_INVALID_DATA
			1:
				size = file.get_32()
				if (file.get_position() + size) > file.get_length():
					printerr("Bad data size: %d" % size)
					return ERR_INVALID_DATA
			2:
				_data_points.append(DataPoint.new(timestamp, file.get_buffer(size)))
				counter = -1
	
	return OK

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#

## Takes an absolute path to a file
static func load_file(path: String) -> BinaryDataLoadResult:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return BinaryDataLoadResult.err(FileAccess.get_open_error(), "Unable to open file at %s" % path)
	
	var binary_data := BinaryData.new()
	var err: int = binary_data.parse_bytes(file)
	if err != OK:
		return BinaryDataLoadResult.err(err, "Error occurred while loading data. Check the logs.")
	
	return BinaryDataLoadResult.ok(binary_data)

func save_file(path: String) -> int:
	if _is_recording:
		printerr("Declining to save while recording is active. This could cause an infinite loop.")
		return ERR_BUSY
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ERR_CANT_OPEN
	
	file.store_buffer(MAGIC_HEADER.to_utf8_buffer())
	file.store_16(VERSION_MAJOR)
	file.store_16(VERSION_MINOR)
	file.store_16(VERSION_PATCH)
	
	for data_point in _data_points:
		file.store_double(data_point.timestamp)
		file.store_32(data_point.data.size())
		file.store_buffer(data_point.data)
	
	return OK

## Loads in data from a file.
##
## The file magic + semver must be present. An incorrect patch version does not stop processing.
func parse_bytes(file: FileAccess) -> int:
	var magic_header_size: int = MAGIC_HEADER.to_utf8_buffer().size()
	if file.get_length() < magic_header_size + 2 + 2 + 2: # Header + major + minor + patch
		printerr("File size too small")
		return ERR_INVALID_DATA
	var file_magic: String = file.get_buffer(MAGIC_HEADER.to_utf8_buffer().size()).get_string_from_utf8()
	if file_magic != MAGIC_HEADER:
		printerr("Invalid magic header: %s" % file_magic)
		return ERR_INVALID_DATA
	var major_version: int = file.get_16()
	if major_version != VERSION_MAJOR:
		printerr("Unsupported major version: %d" % major_version)
		return ERR_INVALID_DATA
	var minor_version: int = file.get_16()
	if minor_version != VERSION_MINOR:
		printerr("Unsupported minor version: %d" % minor_version)
		return ERR_INVALID_DATA
	var patch_version: int = file.get_16()
	if patch_version != VERSION_PATCH:
		printerr("Patch version does not match, things might be broken")
	
	return _parse_bytes(file)

func start_recording() -> void:
	_is_recording = true
	_starting_ticks = Time.get_ticks_msec()

func stop_recording() -> void:
	_is_recording = false
	_starting_ticks = DEFAULT_STARTING_TICKS

func add_data(data: PackedByteArray) -> void:
	_data_points.append(DataPoint.new(Time.get_ticks_msec() - _starting_ticks, data))

## Frees all data points and clears the containing array.
func clear_data() -> void:
	for data_point in _data_points:
		data_point.free()
	_data_points.clear()
