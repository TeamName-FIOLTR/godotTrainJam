extends SkeletonIK3D

static var moving_leg_count : int  = 0

const MAX_LEG_MOVIES : int = 3

var can_move : bool = false 

var spidor : Spidor
var raycast : RayCast3D 
var step_speed : float = 5


var min_threshold : float  = 50
var max_threshold : float  = 200
var leg_index : int = 0
var left_leg : bool = false

var ik_target : Node3D

var new_target_position : Vector3 
var old_target_position : Vector3

var leg_step_time : float = 0.0
func norm(x):
	return exp(-x**2)

func update_position()->void:
	if raycast.is_colliding():
		spidor.align_to_average_norm()
		new_target_position = raycast.get_collision_point()
		old_target_position = ik_target.global_position
		if left_leg: spidor.left_leg_positions[leg_index] = raycast.get_collision_point()
		else: spidor.right_leg_positions[leg_index] = raycast.get_collision_point()

# Called when the node enters the scene tree for the first time.
func _ready():
	new_target_position = ik_target.global_position 
	old_target_position = new_target_position
	start()
#returns the squred distance to the target interpolation
#coninence function
func get_interp_offset()->float:
	return ik_target.global_position.distance_squared_to(new_target_position)**0.5
func _physics_process(delta):
	var d = ik_target.global_position.distance_squared_to(spidor.global_position)
	if  d > max_threshold or d < min_threshold:
		self.update_position()
	if ik_target.global_position.distance_squared_to(new_target_position) > 25:
		#we want to move
		if not can_move and moving_leg_count < MAX_LEG_MOVIES:
			moving_leg_count += 1
			can_move = true 
			leg_step_time = 0
	elif can_move:
		can_move = false 
		moving_leg_count -= 1
	if can_move:
		leg_step_time += delta*step_speed
		leg_step_time = clamp(leg_step_time,0,1)
		ik_target.global_position = lerp(old_target_position,new_target_position,leg_step_time)
		interpolation = remap(cos(2*PI*leg_step_time),-1,1,0.8,1)
	else:
		interpolation = 1.0
	
