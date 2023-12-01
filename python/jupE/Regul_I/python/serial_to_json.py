import serial 
import extract_json as exjson
import txt_to_json as txtjson
import os
import shutil
ser = serial.Serial(port= "COM7", baudrate=460800)
lines=[]
run=True
while(run):
    line=ser.readline()
    line=line.decode()
    lines+=line
    if line.find('STOP')!=-1:
        # Rejoignez les lignes triées en une seule chaîne de caractères
        resulting_text = ''.join(lines)
        lines=[]
        output_file="test.txt"
        with open(output_file, 'w') as file:
            file.writelines(resulting_text)   
        folder_path=txtjson.txt_to_json(output_file)

        # Spécifiez le chemin du fichier source
        source = output_file

        # Spécifiez le chemin du répertoire de destination
        destination = folder_path

        # Utilisez shutil.move pour déplacer le fichier
        shutil.copy(source, destination)

        # Utilisez os.listdir pour obtenir la liste des fichiers dans le dossier
        fichiers_dossier = os.listdir(folder_path)

        # Utilisez une boucle pour filtrer les fichiers JSON
        fichiers_json = [fichier for fichier in fichiers_dossier if fichier.endswith(".json")]

        # Affichez la liste des fichiers JSON
        for fichier in fichiers_json:
            print("fichier créer")
            #exjson.extract_json(folder_path+"/"+fichier)
