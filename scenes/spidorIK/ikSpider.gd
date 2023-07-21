extends Node3D

class_name Spidor 


var originial_transform : Transform3D

@export var skele  : Skeleton3D # 💀
@export var targets : Node3D 
@export var raycasts : Node3D
@export var ik : PackedScene

@export var left_leg_positions : PackedVector3Array
@export var right_leg_positions : PackedVector3Array

#the number of legs and segments in the spidor
@export var leg_count : int #the count of total legs


@export_range(0,1) var leg_offset : float 

@export var debug_mouse_sensitivity : float = 1.0

var average_normal : Vector3 = Vector3.UP
func align_to_average_norm()->void:
	#global_transform = originial_transform.looking_at(global_position + average_normal)
	var llp = left_leg_positions
	var rlp = right_leg_positions
	var norms = [
		get_normal_of_points(llp[3],rlp[0],llp[0]),
		get_normal_of_points(llp[3],rlp[1],llp[0]),
		get_normal_of_points(llp[3],rlp[2],llp[0]),
		get_normal_of_points(llp[3],rlp[3],llp[0]),
		get_normal_of_points(rlp[3],llp[0],rlp[0]),
		get_normal_of_points(rlp[3],llp[1],rlp[0]),
		get_normal_of_points(rlp[3],llp[2],rlp[0]),
		get_normal_of_points(rlp[3],llp[3],rlp[0]),
	]
#	print(get_normal_of_points(llp[3],rlp[2],llp[0]))
#	print(norms)
#	print(norms.reduce(func(accume, thing): return accume + thing, Vector3.ZERO).normalized())
	var cooler_norm = norms.reduce(func(accume, thing): return accume + thing, Vector3.ZERO).normalized()
#	global_transform = originial_transform.looking_at(global_position + cooler_norm)
	$TestPlane.global_transform.basis = originial_transform.basis.looking_at(cooler_norm)
	pass

func get_normal_of_points(first : Vector3, second : Vector3, third : Vector3):
	return (first-second).cross(third-second).normalized()
	pass

func add_ik(i,lr):
	var ik_local = self.ik.instantiate()
	ik_local.spidor = self
	ik_local.root_bone = StringName(  "Leg " + str(i) + " 0 " + lr ) 
	ik_local.tip_bone = StringName(  "Leg " + str(i) + " Target " + lr ) 
	ik_local.leg_index = i
	ik_local.left_leg = (lr == "L")
	
	var target = Node3D.new()
	var sphear = CSGSphere3D.new()
	target.add_child(sphear)

	var raycast = RayCast3D.new()

	target.name = "Leg " + str(i) + " target"
	targets.add_child(target)
	ik_local.target_node = target.get_path()

	ik_local.ik_target = target
	var angle = float(i)/leg_count 
	angle = remap(angle,0,1,PI/4,2*PI)
	var offset = leg_offset*PI
	target.transform.origin.x = cos(angle + offset)*19 * (1 if lr == 'L' else -1)
	target.transform.origin.z = -sin(angle + offset)*19



	raycasts.add_child(raycast)

	raycast.transform.origin.y += 10
	raycast.target_position = (target.global_transform.origin - raycast.global_transform.origin)*2
	#raycast.target_position = Vector3(0,-100,0)
	#raycast.look_at(target.transform.origin)
	
	ik_local.raycast = raycast 

	skele.add_child(ik_local)

# Called when the node enters the scene tree for the first time.
func _ready():
	originial_transform = self.global_transform
	left_leg_positions.resize(leg_count/2)
	right_leg_positions.resize(leg_count/2)
	for i in range(leg_count / 2):
		#left 
		add_ik(i,"L")
		
		#right
		add_ik(i,"R")

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position += debug_mouse_sensitivity*(Vector3(event.relative.x,event.relative.y, 0.0) if Input.is_key_pressed(KEY_SHIFT) else Vector3(event.relative.x,0.0,event.relative.y))
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			global_position += debug_mouse_sensitivity*(Vector3(event.relative.x,0.0,event.relative.y) if Input.is_key_pressed(KEY_SHIFT) else Vector3(event.relative.x,event.relative.y,0.0))
