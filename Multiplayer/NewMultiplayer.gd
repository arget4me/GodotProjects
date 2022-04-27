extends Node2D

var clients = {}
var client_controls = {}
var GameStarted = false

func _ready():
	var args = Array(OS.get_cmdline_args())
	if args.has("-server"):
		get_node("ClientButton").hide()
		get_node("ServerButton").hide()
		CreateHost()
		GameStarted = true
	
func _process(delta):
	if not GameStarted:
		return
	
	if get_tree().is_network_server():
		for p in client_controls:
			var controlls = client_controls[p]
			var client = clients[p]
			client["position"].x += controlls["Horizontal"] * delta * 250
			client["position"].y -= controlls["Vertical"] * delta * 250
			clients[p] = client
		rpc("SendTransform", clients)
	else:
		var v = 0
		var h = 0
		if Input.is_action_pressed("move_right"):
			h = 1
		if Input.is_action_pressed("move_left"):
			h = -1
		if Input.is_action_pressed("move_up"):
			v = 1
		if Input.is_action_pressed("move_down"):
			v = -1
		var controlls = {Vertical = v, Horizontal = h}
		rpc_id(1, "UpdateClientControls", controlls)

func CreateHost():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()
	var SERVER_PORT = 7777
	print("Starting server on port: " + str(SERVER_PORT))
	peer.create_server(SERVER_PORT, 10)
	get_tree().network_peer = peer

func CreateClient():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()
	var SERVER_IP = "127.0.0.1"
	var SERVER_PORT = 7777
	print("Client connecting to server at " + SERVER_IP + " : " + str(SERVER_PORT))
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer

# -------------------------------------

func _player_connected(id):
	print("New player connected " + str(id))
	if get_tree().is_network_server():
		client_controls[id] = {Vertical = 0, Horizontal = 0}
		clients[id] = { position = Vector3(0,0,0), rotation = Vector3(0,0,0) }

func _player_disconnected(id):
	print("Player disconnected " + str(id))
	if get_tree().is_network_server():
		clients.erase(id)
		client_controls.erase(id)

func _connected_ok():
	print("Connected to server")

func _server_disconnected():
	print("Server disconnected")

func _connected_fail():
	print("Failed to connect to server")

# ------------------------------------

remote func UpdateClientControls(controlls):
	var id = get_tree().get_rpc_sender_id()
	client_controls[id] = controlls

remote func SendTransform(c):
	if not get_tree().is_network_server():
		GameStarted = true
		for p in clients:
			if !c.has(p):
				var node = get_node_or_null("/root/" + str(p))
				if node:
					get_node("/root/").remove_child(node)
					node.free()
		clients = c
		for p in clients:
			var node = get_node_or_null("/root/" + str(p))
			if !node:
				node = preload("res://DummyPlayer.tscn").instance()
				node.set_name(str(p))
				get_node("/root").add_child(node)
			var client = clients[p]
			var pos3 = client["position"]
			node.position = Vector2(pos3.x, pos3.y)

func _on_ClientButton_pressed():
	get_node("ClientButton").hide()
	get_node("ServerButton").hide()
	CreateClient()

func _on_ServerButton_pressed():
	get_node("ClientButton").hide()
	get_node("ServerButton").hide()
	get_node("StartButton").show()
	CreateHost()

func _on_StartButton_pressed():
	get_node("StartButton").hide()
	GameStarted = true
