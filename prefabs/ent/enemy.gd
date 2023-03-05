extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D 

@export var SPEED = 3
@export var ACCELERATION = 1.5 #Without this, they turn to you instantly with no friction :,(

@export var MAX_DISTANCE = 50

var last_known_position : Vector3 = Vector3.ZERO

var seen_player_once = false

func _physics_process(delta):
	var direction = global_position.direction_to(last_known_position)
	velocity.x = velocity.lerp(direction * SPEED, ACCELERATION * delta).x
	velocity.z = velocity.lerp(direction * SPEED, ACCELERATION * delta).z

	%flag.global_position = last_known_position
	%range.scale = Vector3(MAX_DISTANCE * 2, MAX_DISTANCE * 2, MAX_DISTANCE * 2)

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= util.player_node.vars.gravity * delta

	if !seen_player_once:
		velocity.x = 0
		velocity.z = 0

	if !nav_agent.is_target_reachable() && 5 > nav_agent.distance_to_target() && is_on_floor():
		velocity.y = 10.05

	move_and_slide()

func _process(delta):
	nav_agent.target_position = util.player_node.global_position
	
	if !seen_player_once && MAX_DISTANCE > nav_agent.distance_to_target():
		seen_player_once = true

	if !nav_agent.is_target_reached() && MAX_DISTANCE > nav_agent.distance_to_target() && util.player_node.vars.health > 0:
		last_known_position = nav_agent.get_next_path_position()
