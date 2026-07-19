extends Node2D
class_name PlexusBackground

class PlexusNode:
	var position: Vector2
	var velocity: Vector2
	var radius: float
	var base_speed: float

var nodes: Array[PlexusNode] = []
var num_nodes: int = 80
var max_distance: float = 120.0
var mouse_connect_distance: float = 250.0

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	get_viewport().size_changed.connect(_on_size_changed)
	
	for i in range(num_nodes):
		var n = PlexusNode.new()
		n.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		n.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		n.base_speed = randf_range(10.0, 25.0)
		n.velocity *= n.base_speed
		n.radius = randf_range(1.0, 2.0)
		nodes.append(n)

func _on_size_changed() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	# Move nodes
	for n in nodes:
		n.position += n.velocity * delta
		
		# Bounce off walls
		if n.position.x < 0:
			n.position.x = 0
			n.velocity.x *= -1
		elif n.position.x > screen_size.x:
			n.position.x = screen_size.x
			n.velocity.x *= -1
			
		if n.position.y < 0:
			n.position.y = 0
			n.velocity.y *= -1
		elif n.position.y > screen_size.y:
			n.position.y = screen_size.y
			n.velocity.y *= -1
			
		# Gradually return to base speed if pushed
		var speed = n.velocity.length()
		if speed > n.base_speed:
			n.velocity = n.velocity.normalized() * lerp(speed, n.base_speed, delta * 2.0)
			
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_apply_shockwave(event.position)

func _apply_shockwave(pos: Vector2) -> void:
	for n in nodes:
		var dir = n.position - pos
		var dist = dir.length()
		if dist < 400.0:
			var force = (400.0 - dist) / 400.0
			n.velocity += dir.normalized() * force * 500.0

func _draw() -> void:
	var mouse_pos = get_local_mouse_position()
	
	# Draw lines between nodes
	for i in range(nodes.size()):
		var n1 = nodes[i]
		
		# Draw node
		draw_circle(n1.position, n1.radius, Color(1, 1, 1, 0.4))
		
		# Connect to other nodes
		for j in range(i + 1, nodes.size()):
			var n2 = nodes[j]
			var dist = n1.position.distance_to(n2.position)
			if dist < max_distance:
				var alpha = 1.0 - (dist / max_distance)
				draw_line(n1.position, n2.position, Color(1, 1, 1, alpha * 0.15), 1.0, true)
		
		# Connect to mouse
		var mouse_dist = n1.position.distance_to(mouse_pos)
		if mouse_dist < mouse_connect_distance:
			var alpha = 1.0 - (mouse_dist / mouse_connect_distance)
			draw_line(n1.position, mouse_pos, Color(1, 1, 1, alpha * 0.6), 1.5, true)
