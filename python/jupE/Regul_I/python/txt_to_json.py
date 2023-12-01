import matplotlib.pyplot as plt
import numpy as np
import re
import os
import datetime


def txt_to_json(txtfilepath):
    file_number=0
      # Ouvrez le fichier en mode lecture
    with open(txtfilepath, 'r') as file:
        texte = file.read()
    # Supprimer les sauts de ligne
    texte = texte.replace("\n", "")
    texte = texte.replace("\t", "")
    print("texte"+texte)    
    # Utiliser une expression régulière pour extraire le texte entre "bla" et "hello"
    resultat = re.findall(r'START(.*?)STOP', texte)
      
        # Obtenir la date actuelle
    date_actuelle = datetime.datetime.now()

    # Afficher la date au format "Année-Mois-Jour Heure:Minute:Seconde"
    date_formattee = date_actuelle.strftime("%Y-%m-%d_%H_%M_%S")
    print("Date actuelle:", date_formattee)
    # Spécifiez le chemin du dossier que vous souhaitez créer
    nom_dossier = date_formattee

    # Vérifiez si le dossier n'existe pas déjà
    if not os.path.exists(nom_dossier):
        # Créez le dossier
        os.mkdir(nom_dossier)
        print(f"Dossier '{nom_dossier}' créé avec succès.")

    else:
        print(f"Le dossier '{nom_dossier}' existe déjà.")
        # Afficher les textes extraits
    for json_data in resultat:
        print("json_data "+json_data) 
        file_name_path=nom_dossier+"/"+str(file_number)+".json"
        file_number+=1  
        with open(file_name_path, 'w') as file:
            file.write(json_data)
    return nom_dossier
   