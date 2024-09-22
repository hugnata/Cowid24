extends Node2D

@onready var terrain: TileMapLayer = $Terrain
@onready var cow_pen: Area2D = $"Cow Pen"

func is_viable_drop_location(pos: Vector2) -> bool :
	var tile_coord : Vector2i = terrain.local_to_map(terrain.to_local(pos))
	var tile_data = terrain.get_cell_tile_data(tile_coord)
	if tile_data == null:
		return false
	if tile_data.get_custom_data("valid_drop_off") != true:
		return false
	return true

func get_spawn_area() -> CollisionShape2D:
	return cow_pen.get_child(0)
