class_name ply_vars

extends Node

const SPEED_MIN = 3
const SPEED_DEFAULT = 5
const SPEED_MAX = 10

const ACCEL_DEFAULT = 10
const ACCEL_AIR = 1

const SPRINT_USAGE = 0.5
const FLASHLIGHT_USAGE = 0.2

var speed = SPEED_DEFAULT
var accel = ACCEL_DEFAULT

var gravity = 12
var jump = 5

var target_height = 1.9

var mouse_sense = 0.1

var footsteps_timer = 0

var direction = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

var camera_rotation = Vector3()
var camera_translation = Vector3()
var camera_fov : float = 90.0

var default_fov = 100.0

var mouse_delta = Vector2()

var health : int = 100
var armour : int = 0

var power : float = 0.0
var power_usage : float = 0.0

var sprinting : bool = false
var flashlight : bool = false

var power_depleted : bool = false

var player_frozen : bool = false
var power_shown : bool = false

var power_less : bool = false

var weapon_inventory : Array = [
]

var weapon_active : String = ""
var weapon_active_index : int = 0

# CHEATS

var god_mode : bool = false
var noclip : bool = false
var full_bright : bool = false
