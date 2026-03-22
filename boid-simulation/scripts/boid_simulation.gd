extends Node2D

@onready var spin_box: SpinBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer/SpinBox
@export var boidNum := 100
@export var margin := 100

@onready var r_box: SpinBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer2/RBox
@onready var g_box: SpinBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer2/GBox
@onready var b_box: SpinBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer2/BBox

@onready var r_check_box: CheckBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer2/RCheckBox
@onready var g_check_box_2: CheckBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer2/GCheckBox2
@onready var b_check_box_3: CheckBox = $CanvasLayer/UI/MarginContainer/VBoxContainer/HBoxContainer2/BCheckBox3


var alignStr: float = 100
var cohesionStr: float = 100
var steerStr: float = 100
var visionScale: float = 50
var speedStr: float = 100

var rValue: float = 255
var gValue: float
var bValue: float

var rRand: bool
var gRand: bool
var bRand: bool

var screenSize : Vector2
var allBoids : Array[Boid]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = get_viewport_rect().size
	spin_box.value = boidNum
	randomize()
	for i in spin_box.value:
		spawnBoid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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


func _on_alignment_slider_value_changed(value: float) -> void:
	alignStr = value
	for boid in allBoids:
		boid.alignStr = value/100


func _on_cohesion_slider_value_changed(value: float) -> void:
	cohesionStr = value
	for boid in allBoids:
		boid.cohesionStr = value/100


func _on_separation_slider_value_changed(value: float) -> void:
	steerStr = value
	for boid in allBoids:
		boid.steerStr = value/100


func _on_vision_slider_value_changed(value: float) -> void:
	visionScale = value

	for boid in allBoids:
		if value == 0:
			boid.set_vision(false)
		else:
			boid.set_vision(true)
			boid.vision.global_scale = Vector2(value/100,value/100)


func _on_speed_slider_value_changed(value: float) -> void:
	speedStr = value
	for boid in allBoids:
		boid.speedStr = value/100


func _on_change_button_pressed() -> void:
	for boid in allBoids:
		boid.queue_free()
	allBoids.clear()
	for i in spin_box.value:
		spawnBoid()


func _on_r_box_value_changed(value: float) -> void:
	rValue = value
	calculate_boid_color()
	r_box.release_focus()
func _on_g_box_value_changed(value: float) -> void:
	gValue = value
	calculate_boid_color()
	g_box.release_focus()
func _on_b_box_value_changed(value: float) -> void:
	bValue = value
	calculate_boid_color()

func calculate_boid_color() -> void:
		for i in allBoids.size():
			if rRand:
				rValue = randf_range(0,255)
			else:
				rValue = r_box.value
			if gRand:
				gValue = randf_range(0,255)
			else:
				gValue = g_box.value
			if bRand:
				bValue = randf_range(0,255)
			else:
				bValue = b_box.value
			var boidColor = Color((rValue/255*1) ,(gValue/255*1),(bValue/255*1),1)
			allBoids[i].modulate = boidColor

func _on_r_check_box_toggled(toggled_on: bool) -> void:
	rRand = toggled_on
	r_box.editable = !toggled_on
	calculate_boid_color()
func _on_g_check_box_2_toggled(toggled_on: bool) -> void:
	gRand = toggled_on
	g_box.editable = !toggled_on
	calculate_boid_color()
func _on_b_check_box_3_toggled(toggled_on: bool) -> void:
	bRand = toggled_on
	b_box.editable = !toggled_on
	calculate_boid_color()
