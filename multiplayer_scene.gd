extends Node

@export var level: Node2D
@export var player_node: Node2D
@export var camera_p1: Camera2D
@export var camera_p2: Camera2D
@export var viewport_p1: SubViewport
@export var viewport_p2: SubViewport


@onready var level_music: AudioStreamPlayer = $AudioStreamPlayer
@onready var progress_bar: MarginContainer = $CanvasLayer/ProgressBar
@onready var card_container: Panel = $CanvasLayer/CardContainer
@onready var end_screen: Panel = $CanvasLayer/EndScreen

@onready var player_scene = preload("res://src/scenes/player/player.tscn")
@onready var camera_scene = preload("res://src/scenes/camera_2d.tscn")
@onready var portal_scene = preload("res://src/scenes/level/tiles/portal.tscn")

var race_started: bool = false
var first_pickup: bool = true
var total_time: float = 0.0
var delta_time: float = 0.0
var update_interval: float = 0.2

var nb_players = 2
var player_nodes = []


func _ready():
	initialize_players()
	level._update_race_finish_position()
	SignalBus.player_touched_crown.connect(_on_player_touched_crown)
	SignalBus.player_finished_run.connect(_on_player_finished_run)


func _process(delta: float) -> void:
	if not race_started:
		return
	total_time += delta
	delta_time += delta
	if delta_time >= update_interval:
		update_player_progress()
		delta_time = 0.0


func initialize_players() -> void:
	var player_position = level.player_start_position
	
	for i in range(nb_players):
		var player: Player = player_scene.instantiate()
		if i == 0:
			player.controller_type = player.CONTROLLERS.PLAYER_ONE
			player.camera = camera_p1
			player.picked_powerup.connect(card_container._on_player_picked_powerup)
			player.used_powerup.connect(card_container._on_player_used_powerup)
		elif i == 1:
			player.controller_type = player.CONTROLLERS.PLAYER_TWO
			player.camera = camera_p2
			viewport_p2.world_2d = viewport_p1.world_2d
		
		player.name = "Player%s"%(i+1)
		player.global_position = player_position
		player_node.add_child(player)
		player_nodes.append(player)


func freeze_frame(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func update_player_progress() -> void:
	var progress_data = {}
	for player in player_nodes:
		var player_info = player.get_info()
		progress_data[player.name] = player_info["progress"]
	progress_bar.update_player_progress(progress_data)


func _on_player_touched_crown(_player: Player):
	if not first_pickup:
		return
	
	first_pickup = false
	for camera in [camera_p1, camera_p2]:
		camera.apply_shake(20)
	freeze_frame(.2, .5)
	#var tween = create_tween()
	#tween.tween_property(level_music, "pitch_scale", 1.25, 1)
	level_music.pitch_scale = 1.25
	
	var portal_position = level.player_start_position
	var portal = portal_scene.instantiate()
	level.add_child(portal)
	portal.global_position = portal_position


func _on_start_timer_timeout() -> void:
	race_started = true


func _on_player_finished_run(player: Player) -> void:
	var info = player.get_info()
	
	var stats = {
		"time": Utils.format_time(total_time),
		"restarts": info["restarts"],
		"crowns_dropped": info["crowns_dropped"]
	}
	end_screen.show_stats(stats)


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
