extends Node

const SUPABASE_URL = "https://mvvfitflrigvbctboegx.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12dmZpdGZscmlndmJjdGJvZWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTI0MTMsImV4cCI6MjA5Mjg2ODQxM30.LFw7QbIHiHltRs14FOmUd7n7ClLIH5zGVi3EANgOkpA"

# Ce token sera rempli lors de la connexion du joueur
var current_user_token: String = ""

# --- UTILITAIRE : GÉNÉRATION DES HEADERS ---
func _get_headers() -> PackedStringArray:
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY
	]
	
	if current_user_token != "":
		headers.append("Authorization: Bearer " + current_user_token)
	else:
		headers.append("Authorization: Bearer " + SUPABASE_KEY)
		
	return headers

# --- 1. AUTHENTIFICATION (LOGIN) ---
func login(email: String, password: String, login_node: Node):
	var url = SUPABASE_URL + "/auth/v1/token?grant_type=password"
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# On utilise "request_body" pour éviter les conflits de nom (alerte jaune)
	var request_body = JSON.stringify({
		"email": email,
		"password": password
	})
	
	# La réponse du serveur
	http_request.request_completed.connect(func(_result, response_code, _resp_headers, resp_body):
		var response_str = resp_body.get_string_from_utf8()
		var json = JSON.new()
		json.parse(response_str)
		var data = json.get_data()
		
		http_request.queue_free()
		
		if response_code == 200:
			print("✅ Connexion réussie !")
			current_user_token = data["access_token"]
			if login_node.has_method("on_login_success"):
				login_node.on_login_success(data["user"]["id"])
		else:
			print("❌ Erreur de connexion : ", response_code)
			var error_msg = data.get("error_description", "Erreur inconnue")
			if login_node.has_method("on_login_failed"):
				login_node.on_login_failed(error_msg)
	)
	
	http_request.request(url, _get_headers(), HTTPClient.METHOD_POST, request_body)

# --- 2. ENVOI DU BILAN FINAL (game_sessions) ---
func send_score_to_db(user_id: String, scenario_id: String, scores: Dictionary):
	var url = SUPABASE_URL + "/rest/v1/game_sessions"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(func(_result, response_code, _headers, resp_body):
		_on_request_completed(_result, response_code, _headers, resp_body, "Bilan final")
		http_request.queue_free()
	)
	
	var request_body = JSON.stringify({
		"user_id": user_id,
		"scenario_id": scenario_id,
		"human_core_score": scores.human,
		"ai_synergy_score": scores.ai,
		"quality_score": scores.quality,
		"time_left": scores.time
	})
	
	http_request.request(url, _get_headers(), HTTPClient.METHOD_POST, request_body)

# --- 3. ENVOI DU TRACKING DES CHOIX (session_choices) ---
func send_choice_to_db(session_id: String, node_id: String, option_id: String, step: int, user_id: String):
	var url = SUPABASE_URL + "/rest/v1/session_choices"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(func(_result, response_code, _headers, resp_body):
		_on_request_completed(_result, response_code, _headers, resp_body, "Tracking Choix")
		http_request.queue_free()
	)
	
	var request_body = JSON.stringify({
		"session_id": session_id,
		"node_id": node_id,
		"option_id": option_id,
		"step_index": step,
		"user_id": user_id
	})
	
	http_request.request(url, _get_headers(), HTTPClient.METHOD_POST, request_body)

# --- GESTION DES RÉPONSES ---
func _on_request_completed(_result, response_code, _headers, body, context: String):
	if response_code == 201 or response_code == 200:
		print("✅ [", context, "] Données enregistrées avec succès !")
	else:
		print("❌ [", context, "] Échec de l'envoi. Code : ", response_code)
		if body != null:
			print("Détail erreur : ", body.get_string_from_utf8())
