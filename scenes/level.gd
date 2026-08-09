extends Node2D

class_name CatLevel

@onready var tilemap_layer: TileMapLayer = $TileMapLayer

const CAT_CHARACTER_SCENE = preload("res://scenes/cat_character.tscn")
const SPAWN_NODE_SCENE = preload("res://scenes/spawn_node.tscn")

var player: CatCharacter = null
var spawn: SpawnNode = null


func player_respawn() -> void:
	print("player respawn")
	print(player)
	
	if player == null:
		player = CAT_CHARACTER_SCENE.instantiate()
		player.tilemap_layer = tilemap_layer
		add_child(player)
	
	player.global_position = spawn.spawn_point.global_position
	player.velocity = Vector2(0, 0)


func activate_spawn(new_spawn: SpawnNode) -> void:
	spawn.deactivate()
	spawn = new_spawn
	spawn.activate()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for cell_coords in tilemap_layer.get_used_cells():
		var tile_data = tilemap_layer.get_cell_tile_data(cell_coords)
		
		if tile_data and tile_data.get_custom_data("is_spawn_point"):
			var new_spawn_instance = SPAWN_NODE_SCENE.instantiate()
			new_spawn_instance.global_position = tilemap_layer.map_to_local(cell_coords)
			add_child(new_spawn_instance)
			tilemap_layer.erase_cell(cell_coords)
			
			if tile_data.get_custom_data("is_starting_spawn_point"):
				spawn = new_spawn_instance
	
	assert(spawn != null)

	player_respawn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
