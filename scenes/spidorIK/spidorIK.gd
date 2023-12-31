extends SkeletonIK3D

static var moving_leg_count : int  = 0

const MAX_LEG_MOVIES : int = 3

var can_move : bool = false 

var spidor : Spidor
var raycast : RayCast3D  #used in raycasting ik
var ledge_raycast : RayCast3D  #used in raycasting ik if above fails

var step_speed : float = 5


var min_threshold : float  = 10
var max_threshold : float  = 0.2
var leg_index : int = 0
var left_leg : bool = false

var ik_target : Node3D

var new_target_position : Vector3 
var old_target_position : Vector3

var old_spidor_position : Vector3

var leg_step_time : float = 0.0
func norm(x):
	return exp(-x**2)

#updates the array on the spidor containing our position
#and used for computing the normal of the surface
func update_leg_array(pos : Vector3)->void:
	if left_leg: spidor.left_leg_positions[leg_index] = pos
	else: spidor.right_leg_positions[leg_index] = pos

func update_position_given_ray(ray)->bool:
	if ray.is_colliding():
		new_target_position = ray.get_collision_point()
		old_target_position = ik_target.global_position
		old_spidor_position = spidor.global_position
		update_leg_array(ray.get_collision_point())
		spidor.align_to_average_norm()
		return true 
	return false 

func update_position()->void:
	if not update_position_given_ray(raycast): update_position_given_ray(ledge_raycast)

# Called when the node enters the scene tree for the first time.
func _ready():
	new_target_position = ik_target.global_position 
	old_target_position = new_target_position 
	old_spidor_position = spidor.global_position
	start()
#returns the squred distance to the target interpolation
#coninence function
func get_interp_offset()->float:
	return ik_target.global_position.distance_squared_to(new_target_position)**0.5
func sigmoid(x : float)->float:
	var v = exp(x)
	return v/(v+1)
func _physics_process(delta):
	var d = spidor.global_position.distance_to(old_spidor_position)
	if  d > max_threshold  or abs(spidor.rotation_distance) > spidor.rotation_check_threshold:
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
		var speed = spidor.velocity.length()
		var speed_bonus = (clamp(remap( ( spidor.global_position - ik_target.global_position - spidor.velocity).length_squared(),100,800,0,1.5)-.5,0,1))

		speed_bonus = 0
		leg_step_time += delta*step_speed*( 
			clamp(speed,0,300) +
			clamp(abs(32*spidor.angular_velocity),0,300)
		)*(1+speed_bonus)
		leg_step_time = clamp(leg_step_time,0,1)
		ik_target.global_position = lerp(old_target_position,new_target_position,leg_step_time)
		interpolation = remap(cos(2*PI*leg_step_time),-1,1,.7,1)
	else:
		interpolation = 1.0
	
