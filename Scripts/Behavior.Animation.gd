extends AnimationNodeAnimation

export(Infiltrator.visibility) var type
export(Infiltrator.blend) var blend_mode
export var speed = 1.0
export var distance = 0.0

var name
var parent


func _on_animation_changed(new_name):
	
	if name == new_name:
		parent.get_node('AnimationPlayer').playback_speed = speed
		parent.blend_mode = blend_mode


func init(_name, _parent):
	
	name = _name
	parent = _parent
	
	parent.connect('animation_changed', self, '_on_animation_changed')