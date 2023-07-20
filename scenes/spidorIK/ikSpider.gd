extends Node3D

class_name Spidor 


var originial_transform : Transform3D

@export var skele  : Skeleton3D
@export var targets : Node3D 
@export var raycasts : Node3D
@export var ik : PackedScene



#the number of legs and segments in the spidor
@export var leg_count : int #the count of total legs


@export_range(0,1) var leg_offset : float 


var average_normal : Vector3 = Vector3.UP
func align_to_average_norm()->void:
	global_transform = originial_transform.looking_at(global_position + average_normal)


func add_ik(i,lr):
	var ik_local = self.ik.instantiate()
	ik_local.spidor = self
	ik_local.root_bone = StringName(  "Leg " + str(i) + " 0 " + lr ) 
	ik_local.tip_bone = StringName(  "Leg " + str(i) + " Target " + lr ) 
	
	var target = Node3D.new()
	var sphear = CSGSphere3D.new()
	target.add_child(sphear)

	var raycast =RayCast3D.new()

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
	for i in range(leg_count / 2):
		#left 
		add_ik(i,"L")
		#right
		add_ik(i,"R")
