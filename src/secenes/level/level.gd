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
	"D": { # disolve wall
		"type": CELL.OBJECT,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 2),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/secenes/level/tiles/disolve_block.tscn")
	},
	"X": { # spikes
		"type": CELL.STATIC,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 1),
		"callable": "_get_4sides_alt_tile",
		"debug_alt": null,
		"scene": null
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
	"q": { # blending wall
		"type": CELL.STATIC,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(2, 0),
		"callable": null,
		"debug_alt": null,
		"scene": null
	}
}
const hidden_area_atlas_coors = Vector2i(1, 0)

# These get populated at runtime
var static_atlas_coords_to_symbol: Dictionary = {}
var object_atlas_coords_to_symbol: Dictionary = {}

@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var static_layer : TileMapLayer = $StaticLayer
@onready var objects_layer: TileMapLayer = $ObjectsLayer
@onready var secrets_layer: TileMapLayer = $SecretsLayer
@onready var terrain_visual_layer: TileMapLayer = $TerrainLayer/VisualLayer


func _ready() -> void:
	_init_atlas_symbol_mapping()
	_init_terrain_layer()
	_update_static_alt_tiles()
	_populate_objects()
	#_init_hidden_areas()


func _init_atlas_symbol_mapping() -> void:
	for symbol in symbol_to_tile_info:
		var atlas_coords = str(symbol_to_tile_info[symbol]["coords"])
		var cell_type = symbol_to_tile_info[symbol]["type"]
		if cell_type == CELL.STATIC:
			static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif cell_type == CELL.OBJECT:
			object_atlas_coords_to_symbol[atlas_coords] = symbol


func _init_terrain_layer() -> void:
	for cell_coords in terrain_layer.get_used_cells():
		terrain_layer.update_visual_tiles(cell_coords)


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
	var islands = _get_islands(secrets_layer)
	for i in range(len(islands)):
		var island = islands[i]
		_generate_area_for_island(secrets_layer, island, i)
		_replace_secret_cells(island)


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


func _get_islands(tilemap: TileMapLayer) -> Array:
	var used = tilemap.get_used_cells()
	var visited := {}
	var islands := []

	for cell in used:
		if cell in visited:
			continue
		
		var island := []
		var stack := [cell]
		
		while stack:
			var current = stack.pop_back()
			if current in visited:
				continue
			visited[current] = true
			island.append(current)

			# Check 4-way or 8-way neighbors depending on your definition
			for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
				var neighbor = current + dir
				if neighbor in used and not neighbor in visited:
					stack.append(neighbor)
		
		islands.append(island)
	
	return islands


func _generate_area_for_island(tilemap: TileMapLayer, island: Array, island_index: int) -> void: 
	# Create Area2D for this island
	var area := Area2D.new()
	tilemap.add_child(area)
	area.name = "Island_%d" % island_index
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(5, true)
	area.area_entered.connect(_on_secret_area_entered)
	area.area_exited.connect(_on_secret_area_exited)
	
	# Add CollisionPolygon2D for the whole island
	var polygon := CollisionPolygon2D.new()
	area.add_child(polygon)

	# Convert cell coords → local positions
	var points := []
	var cell_size = tilemap.tile_set.tile_size
	for cell in island:
		var pos = tilemap.map_to_local(cell)
		# You can approximate shape as tile-sized boxes
		points.append_array([
			pos + Vector2(-cell_size.x/2, -cell_size.y/2),
			pos + Vector2(cell_size.x/2, -cell_size.y/2),
			pos + Vector2(cell_size.x/2, cell_size.y/2),
			pos + Vector2(-cell_size.x/2, cell_size.y/2),
		])
	
	# Convex hull: creates a simple outer contour from all tile corners
	points = Geometry2D.convex_hull(points)
	polygon.polygon = points


func _replace_secret_cells(cell_array: Array) -> void:
	for cell_coords in cell_array:
		var atlas_coords = terrain_layer.get_visual_tile_atlas_coords(cell_coords)
		secrets_layer.set_cell(cell_coords, 0, atlas_coords)
		
	# TODO: fix this
	cell_array.reverse()
	for cell_coords in cell_array:
		terrain_layer.erase_cell(cell_coords)
		terrain_layer.update_visual_tiles(cell_coords)


func _get_4sides_alt_tile(cell: Vector2i) -> int:
	return _get_alt_tile(cell, [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT])


func _get_alt_tile(cell: Vector2i, directions: Array[Vector2i]) -> int:
	for i in range(directions.size()):
		if terrain_layer.get_cell_tile_data(cell + directions[i]) != null:
			return i
	return 0


func _on_secret_area_entered(_area: Area2D):
	var tween = create_tween()
	tween.tween_property(secrets_layer, "modulate:a", 0.5, 0.2) # fade out over 0.5s


func _on_secret_area_exited(_area: Area2D):
	secrets_layer.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(secrets_layer, "modulate:a", 1.0, 0.5)
