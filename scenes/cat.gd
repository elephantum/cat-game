extends CharacterBody2D

class_name CatCharacter

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if Input.is_key_label_pressed(KEY_SHIFT):
		direction *= 0.25

	if direction:
		if abs(direction) < 0.7:
			animated_sprite_2d.animation = 'walk'
		else:
			animated_sprite_2d.animation = 'run'

		velocity.x = direction * SPEED
		if direction > 0:
			animated_sprite_2d.flip_h = true
		if direction < 0:
			animated_sprite_2d.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x == 0:
		animated_sprite_2d.animation = 'idle'

	move_and_slide()
