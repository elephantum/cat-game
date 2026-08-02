extends Node2D

class_name SpawnNode

@onready var level: CatLevel = $".."
@onready var area_2d: Area2D = $Area2D
@onready var spawn_point: Marker2D = $CatCharacterRespawn
@onready var active_sprite: Sprite2D = $ActiveSprite
@onready var inactive_sprite: Sprite2D = $InactiveSprite


func activate() -> void:
	active_sprite.show()
	inactive_sprite.hide()


func deactivate() -> void:
	active_sprite.hide()
	inactive_sprite.show()


func _on_body_entered(body) -> void:
	if body is CatCharacter:
		level.activate_spawn(self)

func _ready() -> void:
	area_2d.connect("body_entered", _on_body_entered)
