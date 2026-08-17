extends CharacterBody2D

class_name CatCharacter

@export var tilemap_layer: TileMapLayer

@onready var state_label: Label = $StateLabel

@onready var visuals: Node2D = $Visuals
@onready var animated_sprite_2d: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var down_ray: RayCast2D = $Visuals/DownRay
@onready var forward_ray: RayCast2D = $Visuals/ForwardRay
@onready var forward_top_ray: RayCast2D = $Visuals/ForwardTopRay

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum State {
	NORMAL,
	WALL_SLIDE,
	WALL_CLIMB,
}

var state = State.NORMAL

var wall_normal: Vector2 = Vector2(0,0)

func check_is_hitting_a_wall() -> void:
	if down_ray.is_colliding():
		state = State.NORMAL
		return
	
	if forward_ray.is_colliding():		
		var collider := forward_ray.get_collider()
	
		if collider == tilemap_layer:
			wall_normal = forward_ray.get_collision_normal()
			
			var hit_position: Vector2 = forward_ray.get_collision_point() - (wall_normal * 4.0)
			var tile_pos: Vector2i = tilemap_layer.local_to_map(hit_position)
			var tile_data: TileData = tilemap_layer.get_cell_tile_data(tile_pos)

			if not forward_top_ray.is_colliding():
				state = State.WALL_CLIMB
				var tile_pos_global = tilemap_layer.map_to_local(tile_pos)
				position.x = tile_pos_global.x + 14
				position.y = tile_pos_global.y - 8
				velocity = Vector2()
				animated_sprite_2d.play("climb")
				
				await animated_sprite_2d.animation_finished
				state = State.NORMAL
				return

			if tile_data and tile_data.get_custom_data("is_climbeable") and velocity.y >= 0:
				state = State.WALL_SLIDE
				return
	
	state = State.NORMAL

func handle_sliding_movement(_delta: float) -> void:
	velocity.y = SPEED / 6
	velocity.x = -wall_normal.x

	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * abs(JUMP_VELOCITY) / 2
		velocity.y = JUMP_VELOCITY / 2


func handle_climbing_movement(_delta: float) -> void:
	position.x += forward_ray.target_position.x
	velocity = Vector2()
	animated_sprite_2d.animation = 'climb'
	


func handle_default_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input control_direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var control_direction := Input.get_axis("left", "right")
	if Input.is_key_label_pressed(KEY_SHIFT):
		control_direction *= 0.25

	if is_on_floor():
		if control_direction:
			# velocity.x = control_direction * SPEED
			velocity.x = move_toward(velocity.x, control_direction * SPEED, SPEED / 10)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED / 10)
	else:
		if control_direction:
			# velocity.x = control_direction * SPEED
			velocity.x = move_toward(velocity.x, control_direction * SPEED, SPEED / 10)


func update_visual() -> void:
	if velocity.x > 0:
		visuals.scale.x = -1
	if velocity.x < 0:
		visuals.scale.x = 1

	if state == State.WALL_SLIDE:
		animated_sprite_2d.play("slide")
		return
	
	if state == State.NORMAL:
		if velocity.x == 0:
			animated_sprite_2d.play("idle")
		else:
			if abs(velocity.x) < 0.7 * SPEED:
				animated_sprite_2d.play("walk")
			else:
				animated_sprite_2d.play("run")

func _physics_process(delta: float) -> void:
	if state == State.WALL_CLIMB:
		velocity = Vector2()
		return
	
	check_is_hitting_a_wall()
	state_label.text = State.keys()[state]
	
	match state:
		State.WALL_CLIMB:
			handle_climbing_movement(delta)
		
		State.WALL_SLIDE:
			handle_sliding_movement(delta)
		
		State.NORMAL:
			handle_default_movement(delta)
	
	update_visual()
	move_and_slide()
