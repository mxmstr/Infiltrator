extends Node

export(String) var interaction

signal animation_changed



func set_behavior(new_behavior):
	
	var path = owner.behaviors_root + owner.behaviors + '/' + new_behavior + '.tscn'
	var behavior_source = load(path).instance()
	
	for child in get_children():
		child.name = child.name + '_'
		child.queue_free()
	
	for child in behavior_source.get_children():
		var child_name = child.name
		var new_child = child.duplicate()
		add_child(new_child)
		new_child.name = child_name
	
	start_interaction(behavior_source.interaction, true)
	
	behavior_source.queue_free()


func get_visible_interactions(sender):
	
	var interactions = []
	
	var dist = sender.global_transform.origin.distance_to(owner.global_transform.origin)
	
	for child in get_children():
		if child.is_visible() \
			and (child.dist == 0 or child.dist > dist):
			interactions.append(child.name)
	
	return interactions


func reset_interaction():
	
	start_interaction('Default')


func start_interaction(_name, override=false):
	
	if not has_node(_name):
		return
	
	
	var next = get_node(_name)
	var has_priority = false
	
	if override:
		has_priority = true
	else:
		var last = get_node(interaction)
		has_priority = next.priority == -1 or next.priority > last.priority
		
		if has_priority:
			last.exit()
	
	
	if has_priority:
		
		if not next.animation in [null, 'Null']:
			emit_signal('animation_changed', next.animation)
		
		next.enter()
		interaction = next.name


func _ready():
	
	pass#get_node(interaction).enter()