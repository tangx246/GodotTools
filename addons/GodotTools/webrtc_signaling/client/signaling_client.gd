class_name SignalingClient
extends Node

signal connected(id: int, use_mesh: bool)
signal disconnected()
signal room_list_received(room_list: Dictionary)
signal lobby_joined(lobby: String)
signal lobby_sealed()
