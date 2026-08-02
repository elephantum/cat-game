extends Area2D

@onready var scene: CatLevel = $".."

# Connect the body_entered signal from the Inspector, or via code:
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the object that fell in is the player
	if body is CatCharacter:
		scene.player_respawn()
