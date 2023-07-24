extends Node3D

class_name Spidor 


var originial_transform : Transform3D

@export var skele  : Skeleton3D # 💀 spooky scary
@export var targets : Node3D 
@export var raycasts : Node3D
@export var ik : PackedScene

@export var left_leg_positions : PackedVector3Array
@export var right_leg_positions : PackedVector3Array

#the number of legs and segments in the spidor
@export var leg_count : int #the count of total legs


@export_range(0,1) var leg_offset : float 

@export var debug_mouse_sensitivity : float = 1.0
@export var movement_speed : float = 4
@export var rotation_speed : float = 1

@export var basis_lerp_speed : float = 10
@export var target_plane_distance : float = 0.5

var average_normal : Vector3 = Vector3.UP

var velocity : Vector3
var prev_position : Vector3

var input_movement : Vector2
var input_rotation : float

var target_basis : Basis
var rotation_distance : float = 0.0
var prev_rotation_distance : float = 0.0
var rotation_check_threshold : float = .3
var angular_velocity : float = 0

func align_to_average_norm()->void:
	#global_transform = originial_transform.looking_at(global_position + average_normal)
	var llp = left_leg_positions
	var rlp = right_leg_positions
	var norms = [
		get_normal_of_points(llp[0],rlp[0],llp[3]),
		get_normal_of_points(llp[0],rlp[1],llp[3]),
		get_normal_of_points(llp[0],rlp[2],llp[3]),
		get_normal_of_points(llp[0],rlp[3],llp[3]),
		get_normal_of_points(rlp[3],llp[0],rlp[0]),
		get_normal_of_points(rlp[3],llp[1],rlp[0]),
		get_normal_of_points(rlp[3],llp[2],rlp[0]),
		get_normal_of_points(rlp[3],llp[3],rlp[0]),
	]
#	print(get_normal_of_points(llp[3],rlp[2],llp[0]))
#	print(norms)
#	print(norms.reduce(func(accume, thing): return accume + thing, Vector3.ZERO).normalized())
	var cooler_norm : Vector3 = norms.reduce(func(accume, thing): return accume + thing, Vector3.ZERO).normalized()
	
	if cooler_norm == Vector3.ZERO: return 

#	global_transform = originial_transform.looking_at(global_position + cooler_norm)
	#$TestPlane.global_transform.basis = originial_transform.basis.looking_at(cooler_norm)
	#global_transform.basis = originial_transform.basis.looking_at(cooler_norm)

	#print(cooler_norm)
	var nz : Vector3 = -cooler_norm.cross(global_transform.basis.x).normalized()
	var nx : Vector3= cooler_norm.cross(nz).normalized()

	var b = Basis(nx,cooler_norm,nz)
	
	#print('---')
	#print(nx)
	#print(cooler_norm)
	#print(nz)
	#print('---')


	target_basis = b#.orthonormalized()
	
	#global_transform.basis.y = cooler_norm 
	#global_transform.basis.x = j
	#global_transform.basis.z = k
	
	pass

#returns the average distance to planes created from the leg points
func get_average_distance_to_plane()->float:
	var llp = left_leg_positions
	var rlp = right_leg_positions 
	
	var average_distance : float = 0
	
	average_distance += Plane(llp[0],rlp[0],llp[3]).distance_to(global_position)
	average_distance += Plane(llp[0],rlp[1],llp[3]).distance_to(global_position)
	average_distance += Plane(llp[0],rlp[2],llp[3]).distance_to(global_position)
	average_distance += Plane(llp[0],rlp[3],llp[3]).distance_to(global_position)
	average_distance += Plane(rlp[3],llp[0],rlp[0]).distance_to(global_position)
	average_distance += Plane(rlp[3],llp[1],rlp[0]).distance_to(global_position)
	average_distance += Plane(rlp[3],llp[2],rlp[0]).distance_to(global_position)
	average_distance += Plane(rlp[3],llp[3],rlp[0]).distance_to(global_position)

	return average_distance / 8

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
	var ledge_raycast = RayCast3D.new()

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
	raycasts.add_child(ledge_raycast)

	raycast.transform.origin.y += 10
	raycast.target_position = (target.global_transform.origin - raycast.global_transform.origin)*2
	
	ledge_raycast.global_position = raycast.global_position + raycast.target_position

	#point to the spidor
	ledge_raycast.target_position = (self.global_transform.origin - ledge_raycast.global_transform.origin)
	ledge_raycast.target_position.y -= 10
	#raycast.target_position = Vector3(0,-100,0)
	#raycast.look_at(target.transform.origin)
	
	ik_local.raycast = raycast 
	ik_local.ledge_raycast = ledge_raycast

	skele.add_child(ik_local)

	ik_local.update_leg_array(ik_local.ik_target.global_position)

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
func sigmoid(x : float)->float:
	var ex = exp(x)
	return ex / (ex + 1)
func _physics_process(delta):
	var dist = get_average_distance_to_plane()
	global_transform.origin += global_transform.basis * Vector3.UP * (target_plane_distance - dist) * delta * 5
	global_transform.basis = lerp(global_transform.basis,target_basis,delta*basis_lerp_speed)
	velocity = prev_position - global_position
	angular_velocity = rotation_distance - prev_rotation_distance
	prev_position = global_position 
	if rotation_distance > rotation_check_threshold*1.2:
		rotation_distance = 0
func _process(delta):
	global_position += global_transform.basis*(Vector3(input_movement.x,0.0,input_movement.y)*delta*movement_speed)
	prev_rotation_distance = rotation_distance
	rotation_distance += input_rotation * delta 
	target_basis = target_basis.rotated(target_basis.y,input_rotation*delta*rotation_speed)
	var local_velocity = (global_transform.basis.inverse()*velocity).normalized()
	raycasts.rotation.z = -(sigmoid(local_velocity.x) - 0.5)*2
	raycasts.rotation.x = -(sigmoid(-local_velocity.z) - 0.5)*2
func _input(event):
	var input_vec = Input.get_vector("leftwards","rightwards","forwards","backwards")
	input_movement = input_vec
	input_rotation = Input.get_axis("turn_rightwards","turn_leftwards")
