extends Node

enum ContactType {
	Collision,
	Radius
}

export(String) var stim_type
export var continuous = false

export(ContactType) var contact_type = ContactType.Collision
export var max_distance = 0.0

var collisions = []

signal triggered


func _ready():
	
	pass


func _physics_process(delta):
	
	var colliders = []
	
	for collision in collisions:
		colliders.append(collision.collider)
	
	
	var new_collisions = []
	
	if contact_type == ContactType.Collision:
	
		for index in range(owner.get_slide_count()):
			
			var collision = owner.get_slide_collision(index)
			
			if continuous or not collision.collider in colliders:
				
				var data
				
				Meta.StimulateActor(collision.collider, stim_type, owner, $'../Movement'._get_speed() * -1, collision.position, collision.normal * -1)
				
				emit_signal('triggered', data)
			
			new_collisions.append(collision)
	
	else:
		
		for actor in $'/root/Mission/Actors'.get_children():
			
			if actor == owner:
				continue
			
			var collision = { 'collider': actor }
			var within_distance = max_distance == 0 or owner.global_transform.origin.distance_to(actor.global_transform.origin) < max_distance
			
			if within_distance and continuous or not collision.collider in colliders:
				
				var data
				
				Meta.StimulateActor(collision.collider, stim_type, owner)
				
				emit_signal('triggered', data)
			
			new_collisions.append(collision)
	
	
	collisions = new_collisions
