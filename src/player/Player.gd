extends KinematicBody2D

var velocity = Vector2.ZERO

const GRAVITY = 1000
const MAX_HORIZONTAL_SPEED = 140
const HORIZONTAL_ACCELERATION = 2000
const JUMP_SPEED = 360
const JUMP_TERMINATION_MULTIPLIER = 5

onready var animated_sprite = $AnimatedSprite
onready var jump_sound = $JumpSound
onready var coyote_timer = $CoyoteTimer

func _process(delta):
	var move_vector = get_movement_vector()
	
	velocity.x += move_vector.x * HORIZONTAL_ACCELERATION * delta
	if move_vector.x == 0:
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
		
	velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	
	if move_vector.y < 0 && (is_on_floor() || !coyote_timer.is_stopped()):
		velocity.y = move_vector.y * JUMP_SPEED
		jump_sound.play()

	if velocity.y < 0 && !Input.is_action_pressed("jump"):
		velocity.y += GRAVITY * JUMP_TERMINATION_MULTIPLIER * delta
	else:
		velocity.y += GRAVITY * delta
	
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if was_on_floor && !is_on_floor():
		coyote_timer.start()

	update_animation(move_vector)
	
func get_movement_vector():
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return move_vector

func update_animation(move_vector):
	if !is_on_floor():
		animated_sprite.play("jump")
	elif move_vector.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if move_vector.x != 0:
		animated_sprite.flip_h = true if move_vector.x < 0 else false
