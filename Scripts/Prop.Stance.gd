extends Node

enum StanceType {
	STANDING,
	CROUCHING
	CRAWLING
}

enum SpeedType {
	STOPPED,
	WALKING,
	RUNNING
}

enum LeanDirection {
	DEFAULT,
	LEFT,
	RIGHT
}

export(float) var forward_speed setget _set_forward_speed
export(float) var sidestep_speed setget _set_sidestep_speed

export(StanceType) var stance = StanceType.STANDING setget _set_stance
export(SpeedType) var speed = SpeedType.RUNNING
export(LeanDirection) var lean = LeanDirection.DEFAULT

export var max_speed = 2.75
export var walk_mult = 0.3
export var crouch_mult = 0.25
export var crawl_mult = 0.15

export var max_slope_angle = 30

export var collision_height_mult = 1.0

var speed_mult = 1.0

var lock_stance = false
var lock_speed = false
var lock_direction = false
var lock_rotation = false
var lock_movement = false

onready var movement = $'../Movement' if has_node('../Movement') else null
onready var collision = $'../Collision' if has_node('../Collision') else null
onready var camera = $'../CameraRig/Camera' if has_node('../CameraRig/Camera') else null


func _rotate(delta):
	
	if lock_rotation:
		return
	
	owner.rotation.y += delta


func _set_stance(new_state):
	
	if lock_stance:
		return
		
	stance = new_state
	
	match stance:
	
		StanceType.STANDING:
			
			speed_mult = 1.0
		
		StanceType.CROUCHING:
			
			speed_mult = crouch_mult
		
		StanceType.CRAWLING:
			
			speed_mult = crawl_mult


func _set_forward_speed(new_speed):
	
	forward_speed = new_speed


func _set_sidestep_speed(new_speed):
	
	sidestep_speed = new_speed


func _align_to_camera():
	
	var target = owner.global_transform.origin + camera.global_transform.basis.z#.inverse()
	target.y = owner.global_transform.origin.y
	owner.look_at(target, Vector3(0, 1, 0))


func _resize_collision():
	
	if collision == null:
		return
	
#	if collision_height_mult == null:
#		return
	
	collision.shape.extents.y = collision_height_mult
	collision.translation.y = collision_height_mult


func _physics_process(delta):
	
	_resize_collision()
	
	if lock_movement:
		return
	
	var velocity = Vector3(sidestep_speed, 0, forward_speed) * max_speed * speed_mult
	
	movement._set_speed(velocity.length())
	movement._set_direction(velocity.normalized(), true)
