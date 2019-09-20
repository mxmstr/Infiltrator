extends AnimationTree

const directory = 'res://Scenes/Properties/Behaviors/'

var current_node
var blend_mode = Inf.blend.ACTION
var children = []

signal interaction_started
signal animation_changed
signal tree_update


func _get_visible_interactions():
	
	var interactions = []
	
	for child in children:
		if child.is_visible() and tree_root.can_travel(child.name):
			interactions.append(child.name)
	
	return interactions


func _has_interaction(_name):
	
	return has_node(_name)


func _start_interaction(_name):
	
	var playback = get('parameters/playback')
	var current = playback.get_current_node()
	
	playback.travel(_name)


func _init_transitions():
	
	var anim_names = []
	
	for idx in range(tree_root.get_transition_count()):
		
		var transition = tree_root.get_transition(idx)
		var anim_name = tree_root.get_transition_from(idx)
		var animation = tree_root.get_node(anim_name)
		
		if not anim_name in anim_names:
			
			animation.init(anim_name, self)
			animation.transitions.append(transition)
			
			children.append(animation)
			anim_names.append(anim_name)
			
		else:
			animation.transitions.append(transition)
		
		if transition.has_method('init'):
			transition.init(self)


func _ready():
	
	tree_root = tree_root.duplicate(true)
	
	_init_transitions()
	
	current_node = get('parameters/playback').get_current_node()
	
	#anim_player = NodePath('AnimationPlayer')
	active = true


func _process(delta):
	
	var playback = get('parameters/playback')
	
	if current_node != playback.get_current_node():
		emit_signal('animation_changed', playback.get_current_node())
	
	current_node = playback.get_current_node()