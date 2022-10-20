class_name BinaryDataLoadResult
extends RefCounted

var result: BinaryData
var error := OK
var error_description := "n/a"

static func ok(data: BinaryData) -> BinaryDataLoadResult:
	var r := BinaryDataLoadResult.new()
	r.result = data
	
	return r

static func err(p_error_code: int, p_error_description: String) -> BinaryDataLoadResult:
	var r := BinaryDataLoadResult.new()
	r.error = p_error_code
	r.error_description = p_error_description
	
	return r

func unwrap() -> BinaryData:
	if result == null:
		printerr("Invalid data")
		assert(false)
		return null
	
	return result
