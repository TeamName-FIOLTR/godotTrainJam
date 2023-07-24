@tool
extends Camera3D
class_name GimbalCamera

@export var pitch_node : Node3D
@export var yaw_node : Node3D
@export var roll_node : Node3D
@export var camera_distance : float = 30:
	set(n_distance):
		camera_distance = n_distance 
		if not self.is_inside_tree(): await self.ready
		update_gimbal_rotation()
@export var gimbal_rotation_degrees : Vector3 = Vector3.ZERO:
	set(n_degrees):
		gimbal_rotation_degrees = n_degrees 
		if not self.is_inside_tree(): await self.ready
		update_gimbal_rotation()



func update_gimbal_rotation():
	pitch_node.rotation_degrees.y = gimbal_rotation_degrees.x
	yaw_node.rotation_degrees.x = gimbal_rotation_degrees.y
	roll_node.rotation_degrees.z = gimbal_rotation_degrees.z
	self.position.z = -camera_distance
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delta = delta
	pass
