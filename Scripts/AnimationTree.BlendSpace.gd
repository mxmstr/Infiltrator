extends AnimationRootNode

const camera_rig_track_path = '../../Perspective'

export(String) var blendspace

export var chain = false

export(String, 'process', 'state_starting') var update_mode = 'process'
export var speed = 0.0

export(String) var x_target
export(String) var x_method
export(Array) var x_args
export(float) var x_max_value
export(float) var x_min_value

export(String) var y_target
export(String) var y_method
export(Array) var y_args
export(float) var y_max_value
export(float) var y_min_value

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

var target_pos = Vector2()


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		advance = chain
		
		if update_mode == 'state_starting':
			_update()


func _filter_anim_events(is_action, filter_all=false):

	var blend_position = parameters + 'blend_position'
	var closest_point = call('get_closest_point', owner.get(blend_position))
	var children = get_children()

	for child_name in children:
		
		var child = children[child_name]
		var is_closest = int(child_name) == closest_point

		if child is AnimationNodeAnimation:

			var animation = owner.get_node('AnimationPlayer').get_animation(child.animation)

			for track in animation.get_track_count():

				var is_function_call = animation.track_get_type(track) == 2
				var is_camera_and_overriden = is_action and camera_rig_track_path in str(animation.track_get_path(track))
				animation.track_set_enabled(track, false if (is_function_call and (not is_closest or filter_all)) else true)# or is_camera_and_overriden else true)

		
		if child is AnimationNodeStateMachine or \
			child is AnimationNodeBlendTree or \
			child is AnimationNodeBlendSpace1D or \
			child is AnimationNodeBlendSpace2D:
			
			if not child.has_method('_filter_anim_events'):
				return
			
			child._filter_anim_events(is_action, filter_all) if is_closest else child._filter_anim_events(is_action, true)


func _unfilter_anim_events():
	
	var children = get_children()

	for child_name in children:
		
		var child = children[child_name]
		
		if not child.has_method('_unfilter_anim_events'):
			return
		
		if child is AnimationNodeAnimation:

			var animation = owner.get_node('AnimationPlayer').get_animation(child.animation)

			for track in animation.get_track_count():
				animation.track_set_enabled(track, true)
		
		if child is AnimationNodeStateMachine or \
			child is AnimationNodeBlendTree or \
			child is AnimationNodeBlendSpace1D or \
			child is AnimationNodeBlendSpace2D:
			
			child._unfilter_anim_events()


func _update():

	var x_value = 0
	var y_value = 0
	var x_min = get('min_space').x if get_class() == 'AnimationNodeBlendSpace2D' else get('min_space')
	var y_min = get('min_space').y if get_class() == 'AnimationNodeBlendSpace2D' else get('min_space')
	var x_value_range = get('max_space').x - get('min_space').x if get_class() == 'AnimationNodeBlendSpace2D' else get('max_space') - get('min_space')
	var y_value_range = get('max_space').y - get('min_space').y if get_class() == 'AnimationNodeBlendSpace2D' else get('max_space') - get('min_space')

	if len(x_target) > 0:
		x_value = owner.owner.get_node(x_target).callv(x_method, x_args)
		x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * x_value_range) + x_min

	if len(y_target) > 0:
		y_value = owner.owner.get_node(y_target).callv(y_method, y_args)
		y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * y_value_range) + y_min

	target_pos = Vector2(x_value, y_value)


func _ready(_owner, _parent, _parameters, _node_name):

	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')


	var children = get_children()

	for child_name in children:
		
		var child = children[child_name]
		
		if child.has_method('_ready'):

			if child is AnimationNodeStateMachine or \
				child is AnimationNodeBlendTree or \
				child is AnimationNodeBlendSpace1D or \
				child is AnimationNodeBlendSpace2D:
				child._ready(owner, self, parameters + child_name + '/', child_name)
			else:
				child._ready(owner, self, parameters, child_name)


func _process(delta):

	if advance:
		owner.advance(0.01)
	
	advance = false


	if update_mode == 'process':
		_update()

	if target_pos == null:
		return

	var blend_position = parameters + 'blend_position'

	if speed > 0:
		
		var current_pos = owner.get(blend_position) if get_class() == 'AnimationNodeBlendSpace2D' else Vector2(owner.get(blend_position), 0)
		var new_pos = current_pos.linear_interpolate(target_pos, delta * speed)
		
		owner.set(blend_position, new_pos if get_class() == 'AnimationNodeBlendSpace2D' else new_pos.x)

	else:

		owner.set(blend_position, target_pos if get_class() == 'AnimationNodeBlendSpace2D' else target_pos.x)
