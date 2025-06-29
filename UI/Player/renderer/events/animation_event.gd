class_name AnimationEvent

var animation_name: String
var action: Enums.AnimationEventAction
var is_test: bool


static func play(anim_name: String, test: bool = false) -> AnimationEvent:
	return AnimationEvent.new(anim_name, Enums.AnimationEventAction.PLAY, test)
static func stop(anim_name: String, test: bool = false) -> AnimationEvent:
	return AnimationEvent.new(anim_name, Enums.AnimationEventAction.STOP, test)
static func continue_(anim_name: String, test: bool = false) -> AnimationEvent:
	return AnimationEvent.new(anim_name, Enums.AnimationEventAction.CONTINUE, test)
	
static func playing(anim_name: String, test: bool = false) -> AnimationEvent:
	return AnimationEvent.new(anim_name, Enums.AnimationEventAction.PLAYING, test)
	
static func paused(anim_name: String, test: bool = false) -> AnimationEvent:
	return AnimationEvent.new(anim_name, Enums.AnimationEventAction.PAUSED, test)
	
static func finished(anim_name: String, test: bool = false) -> AnimationEvent:
	return AnimationEvent.new(anim_name, Enums.AnimationEventAction.FINISHED, test)
	
@warning_ignore("SHADOWED_VARIABLE")
func _init(animation_name: String, action: Enums.AnimationEventAction, is_test: bool):
	self.animation_name = animation_name
	self.action = action
	self.is_test = is_test

	