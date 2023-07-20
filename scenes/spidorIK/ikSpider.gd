extends Node3D

@export var skele  : Skeleton3D
@export var targets : Node3D
@export var ik : PackedScene


#the number of legs and segments in the spidor
@export var leg_count : int #the count of total legs


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(leg_count / 2):
		
		#left 
		var ik_local = self.ik.instantiate()
		ik_local.root_bone = StringName(  "Leg " + str(i) + " 0 L" ) 
		ik_local.tip_bone = StringName(  "Leg " + str(i) + " Target L" ) 
		
		var target = Node3D.new()
		target.name = "Leg " + str(i) + " target"
		targets.add_child(target)
		ik_local.target_node = target.get_path()
	
		skele.add_child(ik_local)

		#right
		ik_local = self.ik.instantiate()
		ik_local.root_bone = StringName(  "Leg " + str(i) + " 0 R" ) 
		ik_local.tip_bone = StringName(  "Leg " + str(i) + " Target R" ) 

		target = Node3D.new()
		target.name = "Leg " + str(i) + " target"
		targets.add_child(target)
		ik_local.target_node = target.get_path()

		skele.add_child(ik_local)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
