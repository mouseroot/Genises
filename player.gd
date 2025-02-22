extends CharacterBody3D
class_name nPlayer


@export var walking_speed = 2.0
@export var running_speed = 4.0

var jump_counter = 0
var current_speed = walking_speed

const lerp_speed = 9.0

@export var JUMP_VELOCITY: float = 10.0
@export var mouse_sens: float = 0.2


#Head Bob mechanic
const headbob_frequency = 2.0
const headbob_amplitude = 0.04
var headbob = 0.00
var is_running: bool = false

var direction = Vector3.ZERO

@export var interactionHandler: InteractionHandler
var lastFocus: InteractableItem = null

@onready var pivot: Node3D = $Pivot
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var ray_cast_3d: RayCast3D = $Pivot/Camera3D/RayCast3D
@onready var label_fps: Label = $Pivot/Camera3D/Panel/labelFPS
@onready var label_object_count: Label = $Pivot/Camera3D/Panel/labelObjectCount


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#speed_text.text = "Speed: " + str(current_speed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func process_headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * headbob_frequency) * headbob_amplitude
	pos.x = cos(time * headbob_frequency / 2) * headbob_amplitude
	return pos
	
func _process(delta: float) -> void:
	label_fps.text = "FPS: %1.f (%.2f ms)" % [
		Performance.get_monitor(Performance.Monitor.TIME_FPS),
		Performance.get_monitor(Performance.Monitor.TIME_PROCESS) * 1000
	]
	label_object_count.text = "Objects: %d (%d Resources)" % [
		Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	]	
	var collider: InteractableItem = $Pivot/Camera3D/RayCast3D.get_collider()
	if collider and interactionHandler.nearbyItems.has(collider):
		lastFocus = collider
		collider.Focus()
	else:
		if lastFocus:
			lastFocus.UnFocus()

func _physics_process(delta: float) -> void:

	# Quit
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Jump Logic
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = (JUMP_VELOCITY/2)
			
	# Sprint Logic
	if Input.is_action_pressed("sprint"):
		current_speed = running_speed
	else:
		current_speed = walking_speed


	var input_dir := Input.get_vector("left", "right", "up", "down")
	direction = lerp(direction,transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized(),delta * lerp_speed)
	#direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		headbob = 0
	
	#Head bob Mechanic
	headbob += delta * velocity.length() * float(is_on_floor())
	pivot.get_child(0).transform.origin = process_headbob(headbob)
	
	# Handle Collisions
	move_and_slide()
