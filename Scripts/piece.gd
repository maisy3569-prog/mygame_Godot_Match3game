extends Node2D

@export var color:String;
var matched = false

#move effects
func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self, 'position', target, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#TRANS_SINE or _BOUNCE or _ELASTIC

#effects
func dim():
	var sprite = get_node('Sprite2D')
	sprite.modulate = Color(1, 1, 1, 0.5)
