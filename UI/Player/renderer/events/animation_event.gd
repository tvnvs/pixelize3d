class_name AnimationEvent

var animation_name: String
var action: Enums.AnimationEventAction


static func play(animation_name: String) -> AnimationEvent:
	return AnimationEvent.new(animation_name, Enums.AnimationEventAction.PLAY)


static func test(animation_name: String) -> AnimationEvent:
	return AnimationEvent.new(animation_name, Enums.AnimationEventAction.TEST)
	

@warning_ignore("SHADOWED_VARIABLE")
func _init(animation_name: String, action: Enums.AnimationEventAction):
	self.animation_name = animation_name
	self.action = action
