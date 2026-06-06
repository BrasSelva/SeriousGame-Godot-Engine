extends Control

# --- RÉFÉRENCES AUX NŒUDS ---
# Si le jeu plante ici, c'est que les chemins ou les noms des nœuds ne correspondent pas à ton arbre !
@onready var input_email = $ColorRect/PanelContainer/VBoxContainer/InputEmail
@onready var input_password = $ColorRect/PanelContainer/VBoxContainer/InputPassword
@onready var btn_connexion = $ColorRect/PanelContainer/VBoxContainer/BtnConnexion
@onready var label_erreur = $ColorRect/PanelContainer/VBoxContainer/LabelErreur

func _ready():
	# On connecte le clic du bouton à notre fonction d'action
	btn_connexion.pressed.connect(_on_btn_connexion_pressed)

func _on_btn_connexion_pressed():
	# On bloque le bouton pour éviter que le joueur clique 40 fois
	label_erreur.text = "Connexion au serveur..."
	label_erreur.add_theme_color_override("font_color", Color.YELLOW)
	btn_connexion.disabled = true
	
	# On lance la requête via notre Autoload
	Network.login(input_email.text, input_password.text, self)

# --- RETOURS DE SUPABASE ---

# Si la connexion réussit (appelé par Network.gd)
func on_login_success(user_id: String):
	print("L'ID du joueur est : ", user_id)
	
	# On sauvegarde l'ID globalement
	GameManager.current_user_id = user_id 
	
	# On change d'écran !
	get_tree().change_scene_to_file("res://Scenes/Core/CharacterSelection.tscn")
# Si la connexion échoue (mauvais mdp, etc.)
func on_login_failed(message: String):
	label_erreur.text = "Accès refusé : " + message
	label_erreur.add_theme_color_override("font_color", Color.RED)
	
	# On débloque le bouton pour qu'il puisse réessayer
	btn_connexion.disabled = false
