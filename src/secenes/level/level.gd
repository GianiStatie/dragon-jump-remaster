@tool
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
	"X": { # spikes
		"type": CELL.STATIC,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 2),
		"callable": "_get_4sides_alt_tile",
		"debug_alt": null,
		"scene": null
	},
	"D": { # disolve wall
		"type": CELL.OBJECT,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/secenes/level/tiles/disolve_block.tscn")
	},
	"P": { # powerup
		"type": CELL.OBJECT,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(1, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/secenes/powerups/powerup.tscn")
	},
	#"q": { # blending wall
		#"type": CELL.STATIC,
		#"autotile": false,
		#"source": 0,
		#"coords": Vector2i(2, 0),
		#"callable": null,
		#"debug_alt": null,
		#"scene": null
	#}
}

# These get populated at runtime
var static_atlas_coords_to_symbol: Dictionary = {}
var object_atlas_coords_to_symbol: Dictionary = {}

@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var static_layer : TileMapLayer = $StaticLayer
@onready var objects_layer: TileMapLayer = $ObjectsLayer
@onready var secrets_layer: TileMapLayer = $SecretsLayer

@onready var secrets_visual_layer: TileMapLayer = $SecretsLayer/VisualLayer

# These are used to debug in editor
var is_initialized = false
var terrain_layer_uesed_cells = []
var emplased_time = 0
var update_interval = 1


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_process(true)


func _exit_tree() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and is_initialized:
		return
	
	emplased_time += delta
	if emplased_time >= update_interval:
		_init_terrain_layer()
		emplased_time = 0


func _ready() -> void:
	_init_atlas_symbol_mapping()
	_init_terrain_layer()
	#_update_static_alt_tiles()
	
	if not Engine.is_editor_hint():
		_populate_objects()
		_init_hidden_areas()
	
	is_initialized = true


func _init_atlas_symbol_mapping() -> void:
	for symbol in symbol_to_tile_info:
		var atlas_coords = str(symbol_to_tile_info[symbol]["coords"])
		var cell_type = symbol_to_tile_info[symbol]["type"]
		if cell_type == CELL.STATIC:
			static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif cell_type == CELL.OBJECT:
			object_atlas_coords_to_symbol[atlas_coords] = symbol


func _init_terrain_layer() -> void:
	var used_cells = terrain_layer.get_used_cells()
	if terrain_layer_uesed_cells == used_cells:
		return
	
	terrain_layer.clear_visual_tiles()
	for cell_coords in used_cells:
		terrain_layer.update_visual_tiles(cell_coords)
	
	terrain_layer_uesed_cells = used_cells


func _update_static_alt_tiles() -> void:
	for cell_coords in static_layer.get_used_cells():
		var symbol = _get_cell_symbol(cell_coords, CELL.STATIC)
		var alt_tile_callable = symbol_to_tile_info[symbol]["callable"]
		if alt_tile_callable:
			var tile_source = symbol_to_tile_info[symbol]["source"]
			var tile_coords = symbol_to_tile_info[symbol]["coords"]
			var callable = Callable(self, alt_tile_callable)
			var alt_tile = callable.call(cell_coords)
			static_layer.set_cell(cell_coords, tile_source, tile_coords, alt_tile)


func _populate_objects() -> void:
	for cell_coords in objects_layer.get_used_cells():
		var symbol = _get_cell_symbol(cell_coords, CELL.OBJECT)
		var object_scene = symbol_to_tile_info[symbol]["scene"]
		var object = object_scene.instantiate()
		var object_position = objects_layer.to_global(objects_layer.map_to_local(cell_coords))
		
		object.global_position = object_position
		objects_layer.call_deferred("add_child", object)
		objects_layer.erase_cell(cell_coords)


func _init_hidden_areas() -> void:
	secrets_layer._init_secrets()


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


func _get_4sides_alt_tile(cell: Vector2i) -> int:
	return _get_alt_tile(cell, [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT])


func _get_alt_tile(cell: Vector2i, directions: Array[Vector2i]) -> int:
	for i in range(directions.size()):
		if terrain_layer.get_cell_tile_data(cell + directions[i]) != null:
			return i
	return 0
