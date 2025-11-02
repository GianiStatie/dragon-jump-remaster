extends Node2D

enum CELL {TERRAIN, STATIC, OBJECT}

# TODO: make a datatype for these
const symbol_to_tile_info: Dictionary = {
	"W": { # wall
		"type": CELL.TERRAIN,
		"autotile": true,
		"source": 0,
		"coords": null,
		"callable": null,
		"debug_alt": null,
		"scene": null
	},
	"V": { # disolve wall
		"type": CELL.OBJECT,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 2),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/secenes/level/tiles/disolve_block.tscn")
	}
}
# These get populated at runtime
var static_atlas_coords_to_symbol: Dictionary = {}
var object_atlas_coords_to_symbol: Dictionary = {}

@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var static_layer : TileMapLayer = $StaticLayer
@onready var objects_layer: TileMapLayer = $ObjectsLayer


func _ready() -> void:
	_init_atlas_symbol_mapping()
	_populate_objects()


func _init_atlas_symbol_mapping() -> void:
	for symbol in symbol_to_tile_info:
		var atlas_coords = str(symbol_to_tile_info[symbol]["coords"])
		var cell_type = symbol_to_tile_info[symbol]["type"]
		if cell_type == CELL.STATIC:
			static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif cell_type == CELL.OBJECT:
			object_atlas_coords_to_symbol[atlas_coords] = symbol


func _populate_objects() -> void:
	for cell_coords in objects_layer.get_used_cells():
		var symbol = _get_cell_symbol(cell_coords, CELL.OBJECT)
		var object_scene = symbol_to_tile_info[symbol]["scene"]
		var object = object_scene.instantiate()
		var object_position = objects_layer.to_global(objects_layer.map_to_local(cell_coords))
		
		objects_layer.call_deferred("add_child", object)
		object.global_position = object_position
		objects_layer.erase_cell(cell_coords)


func _get_cell_symbol(cell_coords: Vector2i, cell_type: CELL) -> String:
	if cell_type == CELL.TERRAIN:
		return "W"
	elif cell_type == CELL.STATIC:
		var atlas_coords = static_layer.get_cell_atlas_coords(cell_coords)
		return static_atlas_coords_to_symbol[str(atlas_coords)]
	elif cell_type == CELL.OBJECT:
		var atlas_coords = objects_layer.get_cell_atlas_coords(cell_coords)
		return object_atlas_coords_to_symbol[str(atlas_coords)]
	return "E"
