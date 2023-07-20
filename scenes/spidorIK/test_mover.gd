extends Marker3D



var time : float
# Called every frame. 'delta' is the elapsed time since the previous frame.
var original
func _start():
	original = self.transform.origin
func _process(delta):
	time += delta 
	if original:
		self.transform.origin.x+= cos(time) 
