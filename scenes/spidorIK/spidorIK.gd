extends SkeletonIK3D

var spidor : Spidor
var raycast : RayCast3D 
var threshold : float  = 600
var leg_index : int = 0
var left_leg : bool = false

var ik_target : Node3D

var prev_normal : Vector3 = Vector3.UP
func update_position()->void:
	if raycast.is_colliding():
		var ray_normal = raycast.get_collision_normal()
		spidor.average_normal  = (spidor.average_normal*spidor.leg_count - prev_normal + ray_normal)/spidor.leg_count
		spidor.align_to_average_norm()
		ik_target.global_position = raycast.get_collision_point()
		prev_normal = ray_normal
		if left_leg: spidor.left_leg_positions[leg_index] = raycast.get_collision_point()
		else: spidor.right_leg_positions[leg_index] = raycast.get_collision_point()

# Called when the node enters the scene tree for the first time.
func _ready():
	start()

func _physics_process(delta):
	if ik_target.global_position.distance_squared_to(spidor.global_position) > threshold:
		self.update_position()
