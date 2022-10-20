extends VBoxContainer

const AddressItem: PackedScene = preload("res://screens/transmission/receive-type/address_item.tscn")

@onready
var items := $Items as VBoxContainer
var item_mappings := {}

@onready
var addresses := $Items/Address/Addresses as VBoxContainer

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _ready() -> void:
	var menu_button := $MenuButton as MenuButton
	var menu_popup := menu_button.get_popup() as PopupMenu
	
	for child in items.get_children():
		menu_popup.add_item(child.name)
		item_mappings[child.name] = child
	
	menu_popup.index_pressed.connect(func(index: int) -> void:
		var item_name: String = menu_popup.get_item_text(index)
		
		menu_button.text = item_name
		
		for child in item_mappings.values():
			child.hide()
		
		item_mappings[item_name].show()
	)
	
	$Items/Address/AddAddress.pressed.connect(func() -> void:
		addresses.add_child(AddressItem.instantiate())
	)

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#

