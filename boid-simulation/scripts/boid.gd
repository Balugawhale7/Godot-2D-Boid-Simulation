extends Area2D
class_name Boid
@onready var vision: Area2D = $Vision

@onready var rays:= $Rays.get_children()
var boidsISee := []
var vel := Vector2.RIGHT
var speed := 300
var screenSize : Vector2
var movv := 48

var speedStr:float = 1
var alignStr:float = 1
var cohesionStr:float = 1
var steerStr:float = 1
var canSee = true

func _ready() -> void:
	# set velocity to random, get screen size, and randomize rotation
	vel = Vector2(randf_range(100,-100),randf_range(100,-100))
	screenSize = get_viewport_rect().size
	randomize()
	rotation = randf()
	
func _physics_process(delta: float) -> void:
	boids()
	#checkCollision()
	vel = vel.normalized() * (speed * speedStr) * delta
	move()
	if speed * speedStr != 0:
		rotation = lerp_angle(rotation, vel.angle_to_point(Vector2.ZERO),0.4)

func boids() -> void:
	# If Boid is in vision range, reset variables
	if boidsISee:
		var numOfBoids := boidsISee.size()
		var avgVel := Vector2.ZERO
		var avgPos := Vector2.ZERO
		var steerAway := Vector2.ZERO
		# For each Boid in vision range calculate average velocity, position, separation forces
		for boid in boidsISee:
			avgVel += boid.vel
			avgPos += boid.position
			steerAway -= (boid.global_position - global_position) * (movv/(global_position - boid.global_position).length())
		
		#Alignment
		avgVel /= numOfBoids
		vel += ((avgVel - vel)/2) * alignStr
		
		#Cohesion
		avgPos /= numOfBoids
		vel += (avgPos - position) * cohesionStr
		
		#Separation
		steerAway/= numOfBoids
		vel += (steerAway) * steerStr
		
func checkCollision() -> void:
	for ray in rays:
		var r : RayCast2D = ray
		if r.is_colliding():
			if r.get_collider().is_in_group("blocks"):
				var magi := 100/(r.get_collision_point() - global_position).length_squared()
				vel -= (r.target_position.rotated(rotation) * magi)
		pass
	
	
func move() -> void:
	# Add velocity to global position
	global_position += vel
	
	# Teleport Boid when it leaves the screen
	if global_position.x < 0:
		global_position.x = screenSize.x
	if global_position.x > screenSize.x:
		global_position.x = 0
	if global_position.y < 0:
		global_position.y = screenSize.y
	if global_position.y > screenSize.y:
		global_position.y = 0


func _on_vision_area_entered(area: Area2D) -> void:
	# If another Boid is within vision area add Boid to boidsISee array
	if area != self and area.is_in_group("boid") && canSee:
		boidsISee.append(area)


func _on_vision_area_exited(area: Area2D) -> void:
	if area:
		boidsISee.erase(area)
		
func set_vision(state: bool) -> void:
	if state:
		canSee = true
	else:
		canSee = false
	
