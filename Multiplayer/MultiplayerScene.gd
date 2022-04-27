extends Node2D


# When exporting to Android, make sure to enable the INTERNET permission 
# in the Android export preset before exporting the project or using one-click deploy. 
# Otherwise, network communication of any kind will be blocked by Android.


var player_info = {}
var my_info = "Johnson Magenta"
var is_host = false
var selfPeerID = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func StartServer():
	is_host = true
	print("Start server")
	if get_node("Control/PlayerName").text != "":
		my_info = get_node("Control/PlayerName").text
	var peer = NetworkedMultiplayerENet.new()
	var SERVER_PORT = get_node("Control/PORT").value
	print(SERVER_PORT)
	peer.create_server(SERVER_PORT, 10)
	get_tree().network_peer = peer
	AddLocalPlayer()
	get_node("StartButton").show()
	get_node("ConnectedClients").show()

func StartClient():
	print("Start client")
	if get_node("Control/PlayerName").text != "":
		my_info = get_node("Control/PlayerName").text
	var peer = NetworkedMultiplayerENet.new()
	var SERVER_IP = (str(int(get_node("Control/IP1").value)) + "." + str(int(get_node("Control/IP2").value)) + "." + str(int(get_node("Control/IP3").value)) + "." + str(int(get_node("Control/IP4").value)))
	var SERVER_PORT = get_node("Control/PORT").value
	print(SERVER_IP + " : " + str(SERVER_PORT))
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	AddLocalPlayer()
	get_node("ClientWaiting").show()

func AddLocalPlayer():
	selfPeerID = get_tree().get_network_unique_id()
	var my_player = preload("res://player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later
	my_player.LocalPlayer()
	my_player.SetDisplayName(str(my_info))
	get_node("/root").add_child(my_player)


func _player_connected(id):
	print("Player: ", id)
	rpc("register_player", my_info)

func _player_disconnected(id):
	print("Disconnected: ", id)
	rpc("disconnect_player")

func DisplayConnectedPlayers():
	if is_host:
		var player_names = ""
		for p in player_info:
			player_names += player_info[p] + "\n"
		get_node("ConnectedClients").text = player_names

func _connected_ok():
	get_node("ClientWaiting").hide() # Only called on clients, not server. Will go unused; not useful here.
	get_node("NotStarted").show()

func _server_disconnected():
	get_node("ClientWaiting").hide()
	get_node("NotStarted").hide()
	get_node("ServerDisconnected").show()
	get_node("/root/" + str(selfPeerID)).started = false
	# Server kicked us; show error and abort.
	

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	print(player_info)
	DisplayConnectedPlayers()

remote func disconnect_player(info):
	var id = get_tree().get_rpc_sender_id()
	player_info.erase(id)
	get_node("/root").remove_child(get_node("/root/" + str(id)))
	DisplayConnectedPlayers()

func StartGame():
	if is_host:
		rpc("pre_configure_game")
		get_node("ConnectedClients").show()

remotesync func pre_configure_game():

	# Load world like this:
	# var world = load("res://MultiplayerScene.tscn").instance()
	# get_node("/root").add_child(world)
	get_node("/root/" + str(selfPeerID)).started = true

	# Load other players
	var i = 0
	for p in player_info:
		var player = preload("res://player.tscn").instance()
		player.set_name(str(p))
		player.SetDisplayName(player_info[p])
		player.set_network_master(p) # Will be explained later
		player.position.x += i * 25
		get_node("/root").add_child(player)
		i = i + 1
		player.started = true

	
	get_node("NotStarted").hide()
	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")

