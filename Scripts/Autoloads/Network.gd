extends Node

# Configuration Supabase (À remplir avec tes clés du projet Supabase)
const SUPABASE_URL = "https://mvvfitflrigvbctboegx.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12dmZpdGZscmlndmJjdGJvZWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTI0MTMsImV4cCI6MjA5Mjg2ODQxM30.LFw7QbIHiHltRs14FOmUd7n7ClLIH5zGVi3EANgOkpA"

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
	if response_code == 201 or response_code == 200:
		print("✅ Données enregistrées avec succès !")
	else:
		print("❌ Échec de l'envoi. Code : ", response_code)
		print("Détail erreur : ", body.get_string_from_utf8())
