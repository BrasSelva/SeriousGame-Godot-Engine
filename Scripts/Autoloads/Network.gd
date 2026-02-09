extends Node

# Configuration Supabase (À remplir avec tes clés du projet Supabase)
const SUPABASE_URL = "https://TON_PROJET.supabase.co"
const SUPABASE_KEY = "TA_CLE_ANON_PUBLIC"

func send_score_to_db(user_id: String, scores: Dictionary):
	var url = SUPABASE_URL + "/rest/v1/game_sessions"
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	
	# Création de la requête HTTP
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	var body = JSON.stringify({
		"user_id": user_id,
		"human_score": scores.human,
		"ai_score": scores.ai
	})
	
	# Envoi de la requête POST
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Erreur lors de l'envoi vers Supabase")

func _on_request_completed(result, response_code, headers, body):
	print("Réponse Supabase : ", response_code)
	# Nettoyage du noeud HTTPRequest
	var sender = get_tree().root.find_child("HTTPRequest", true, false)
	if sender:
		sender.queue_free()
