import json

def extract_json(file_path):
    # Charger les données à partir du fichier JSON d'entrée
    with open(file_path, 'r') as input_file:
        data = json.load(input_file)
    # Maintenant, vous pouvez accéder aux données extraites comme un dictionnaire Python
    # Par exemple, si le fichier JSON contient un dictionnaire avec une clé "resultat":
    ICH0= data['I_ch0']
    UCH0= data['U_ch0']
    ICH1= data['I_ch1']
    UCH1= data['U_ch1']
    ICH2= data['I_ch2']
    UCH2= data['U_ch2']
    return([ICH0,UCH0],[ICH1,UCH1],[ICH2,UCH2])


