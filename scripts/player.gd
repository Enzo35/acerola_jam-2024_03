extends CharacterBody3D


const WALK_SPEED := 5.0
const RUN_SPEED := 8.0
const JUMP_VELOCITY := 4.5
const SENSITIVITY := 0.003
const BOB_FREQ := 2.0
const BOB_AMP := 0.08

var speed : float
var gravity = 9.8
var bob_t := 0.0

@onready var head := $Head
@onready var camera := $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle run
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("to_left", "to_right", "to_front", "to_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
			velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
	else:
		velocity.x = lerp(velocity.x, velocity.x * speed, delta * 0.01)
		velocity.z = lerp(velocity.z, velocity.z * speed, delta * 0.01)
	
	move_and_slide()
	head_bob(delta)
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		

func head_bob(delta):
	bob_t += delta * velocity.length() * float(is_on_floor())
	
	var pos := Vector3.ZERO
	pos.y = sin(bob_t * BOB_FREQ) * BOB_AMP
	pos.x = cos(bob_t * BOB_FREQ / 2) * BOB_AMP
	
	camera.transform.origin = pos

