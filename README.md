# Godot 2D Boid Simulation
This is a 2D simulation of Boids. A Boid being an individual agent following simple rules, an example of bird/fish flocking simulation. This was part of a University
project. Both the project files and build included.

<img width="1870" height="1040" alt="Boids Project" src="https://github.com/user-attachments/assets/5a5d13f8-8f06-45f9-a173-e3affa30bfb3" />

**Link to a video demo of the project:** https://youtu.be/A_b6pAyuzwU

## Development:

**Tools used:** Godot, GDscript
### Why Godot?
The reason for choosing Godot for the first prototype was due to it being primarily used for 2D game creation and having more experience using Godot at the time. 
The reason for creating the Boids in 2D was to make it easier to understand the behaviour in a simpler simulation before extending it to 3D. 
Godot uses GDScript as a programming language which is like Python, Lua, etc. Since programming the Boids was a significant part of the solution 
most of the development section will discuss this aspect of the project. 
### Boid Components
The Boids start off as individual objects that have variables that effect how they behave. The simple ones being their speed and direction. 
Each boid has a CollisionShape2D and Area2D colliders. The CollisionShape2D being a box representing their own location and the Area2D being a circle representing their range of vision:
<p align="center">
 <img align="center" width="250" height="124" alt="image" src="https://github.com/user-attachments/assets/cffa3905-56cb-4daa-90a3-f87cf894f914" />
</p>
<p align="center">
  2D Boid Components
</p>
<p align="center">
  <img width="250" height="150" alt="image" src="https://github.com/user-attachments/assets/1cc68ff7-4153-4cc3-a4f2-2083c7253d6e" />
</p>
<p align="center">
  2D Boid Colliders
</p>
An individual Boid is created and given random velocity, based on the direction relative to the forward Vector and a randomized rotation. 
The velocity of the boid is multiplied by a speed value to move the Boid towards the forward direction.

### Random Velocity and Spawning Area

Multiple Boids needed to be created for there to be complex behaviour. To achieve this Boids were spawned in a box that was the size of the screen. This box determined the space which the Boids were allowed to occupy.

  ```ruby
  func _ready() -> void:
	# set velocity to random, get screen size, and randomize rotation
	vel = Vector2(randf_range(100,-100),randf_range(100,-100))
	screenSize = get_viewport_rect().size
	randomize()
	rotation = randf()
  ```
</p>
<p align="center">
 Start Function
</p>

### Spawn Boid Function
The Boids were spawned within the box and were given a random position within the range of the width and length of the box and a direction for them to head in. This allowed for many different variations of the Boids even when the number of Boids remained constant.

```ruby
func spawnBoid() -> void:
	# Reference to Boid object
	var boid : Area2D = preload("res://scenes/boid.tscn").instantiate()
	# Append object to Boids array
	allBoids.append(boid)
	# Parent Boid to node
	$Boids.add_child(boid)
	
	# Set Boid variables
	boid.alignStr = alignStr/100
	boid.cohesionStr = cohesionStr/100
	boid.steerStr = steerStr/100
	boid.vision.global_scale = Vector2(visionScale/100,visionScale/100)
	boid.speedStr = speedStr/100
	
	# Change Boid color
	if rRand:
		rValue = randf_range(0,255)
	if gRand:
		gValue = randf_range(0,255)
	if bRand:
		bValue = randf_range(0,255)
boid.modulate = Color((rValue/255*1) ,(gValue/255*1),(bValue/255*1),1)
	
	# Set Boid position to be a random position within the screen's size
boid.global_position = Vector2((randf_range(0+margin, screenSize.x - margin)),(randf_range(0+margin,screenSize.y - margin)))
```
<p align="center">
 Spawn Boid Function
</p> 

### Teleporting Boids and Movement
To prevent the Boids from leaving the box Boids that were outside the box’s range were teleported to the other side of the box relative to where they exited. 
So, a Boid that left the box from the right side, will appear on the left side.

```ruby
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
```
<p align="center">
 Boid Movement Function
</p> 

### Boid Vision Range
Boids determine their behaviour based on other Boids around them. The Boids therefore needed a variable to determine whether they were close to another Boid. This is the Vision Range of the Boid. This is a range that is the radius of a circle around the Boid. A Boid that enters that range will be added to an array of Boids that is within that range.

```ruby
func _on_vision_area_entered(area: Area2D) -> void:
	# If another Boid is within vision area add Boid to boidsISee array
	if area != self and area.is_in_group("boid") && canSee:
		boidsISee.append(area)
```
<p align="center">
 Boid Detection Function
</p> 

### Boid Behaviour Function
The Boid will have access to information on Boids within its vision such as its position relative to itself and the direction that the other Boids are traveling in and will use this information to determine its behaviour.

```ruby
func boids() -> void:
	# If Boid is in vision range, reset variables
	if boidsISee:
		var numOfBoids := boidsISee.size()
		var avgVel := Vector2.ZERO
		var avgPos := Vector2.ZERO
		var steerAway := Vector2.ZERO
# For each Boid in vision range calculate average velocity,  position, and separation forces
		for boid in boidsISee:
			avgVel += boid.vel
			avgPos += boid.position
steerAway -= (boid.global_position - global_position) * (movv/(global_position - boid.global_position).length())
```
<p align="center">
 Boid Behaviour Function
</p> 

A Boid has three primary forces that act upon it for the emergent behaviour to show itself. While there can be other external forces, 
these three forces relate to the information that the Boid gets from interacting with other Boids.

### Separation
A Boid will steer away from Boids that are too close to itself. This is a separation force that is applied proportionally based on how close a Boid is to another Boid. 
The closer a Boid is, the stronger the force that is applied. It is calculated by getting the direction from another Boid to the current Boid then multiplying the vector using the distance between them. This can be seen from the previous figure.

```ruby
#Separation
		steerAway/= numOfBoids
		vel += (steerAway) * steerStr
```
<p align="center">
 Separation Code
</p> 

### Alignment
A Boid will try to align itself with other Boids. This means that a Boid will try to go in the same direction that other Boids are heading in. 
The directions of all Boids within the vision range of the current Boid are added together and divided by the number of Boids to get the average direction of all Boids.

```ruby
#Alignment
		avgVel /= numOfBoids
		vel += ((avgVel - vel)/2) * alignStr
```
<p align="center">
 Alignment Code
</p> 

### Cohesion
A Boid will try to go towards the centre of the flock. This is called cohesion. The centre of the flock is the average position of all other Boids that are within the Boid’s vision. 
This position is calculated by getting the position of all Boids, adding them together, and dividing by the number of Boids.

```ruby
#Cohesion
		avgPos /= numOfBoids
		vel += (avgPos - position) * cohesionStr
```
<p align="center">
 Cohesion Code
</p> 

All these forces are aggregated after being multiplied by a weight, for example: “alignStr” (alignment strength) which determines how strong a given force is relative to the other forces. Small changes in the weights of these variables have a big impact on the resulting behaviour of the Boids in the simulation.
### Variable Menu and Colour
To make it easier to test the variables in real-time a menu was created to allow you to spawn a specific number of Boids with the variables being controlled by sliders that go from the weights being zero to twice the base value (for weights this is 1, this differs for other variables).

<p align="center"> 
 <img width="205" height="275" alt="image" src="https://github.com/user-attachments/assets/d9f985e7-bffa-4215-ae32-b86f836ff30b" />
</p>
<p align="center">
 Variables Menu
</p> 

An additional variable allowed for the Boids to be given a colour to give the Boids some variance, the colour could be randomized between the individual RGB values from 0 to 255. 

<p align="center">
<img width="210" height="65" alt="image" src="https://github.com/user-attachments/assets/a1e1cee4-1a40-4cb0-b6be-4983e46b9173" />
</p>
<p align="center">
 Colour Variable
</p> 

## Possible Improvements

Adding an aditional rule for steering away from obstacles would have been a good thing to add. Since all calculations happen on the main thread multi-threading could have
been used to improve performance.

## Helpful Resources
Sebastian Lague's video on Boids: https://www.youtube.com/watch?v=bqtqltqcQhw&t=26s




