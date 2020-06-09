import os
from statistics import mean, median

from matplotlib import pyplot as plt
import numpy as np
import csv

max_total = 0  # valeur maximum pour l'échelle des graphique


class ListDict(dict):
    """
    petite class pratique pour stocker un dictionnaire de listes
    il fait en sorte que toutes les valeurs existent
    """

    def __getitem__(self, item) -> list:
        try:
            return super().__getitem__(item)
        except KeyError:
            nl = []
            self.__setitem__(item, nl)
            return nl


def process_donnees(filename, algos: ListDict):
    with open(filename) as infile:
        r = csv.reader(infile, delimiter=',')
        for row in r:
            if row[2] == '' or row[0] == 'algo':  # saute les en-êtes
                continue
            algo, time, size, speed = row  # algo,temps(s),taille(octets),débit utile(o/s)
            valeur = float(time)
            algos[algo].append(valeur)
            global max_total
            if valeur > max_total:
                max_total = valeur


def afficher_graphique(donnees: ListDict, title):
    affichage_y, affichage_val, affichage_label, affichage_confiance = [], [], [], []
    i = 0
    medianes = []
    for algo in donnees.keys():
        affichage_y.append(i)
        i += 1
        moy = mean(donnees[algo])
        affichage_val.append(moy)
        affichage_label.append(algo)
        medianes.append(median(donnees[algo]))

        min_algo, max_algo = min(donnees[algo]), max(donnees[algo])

        # affichage_confiance.append(
        #    (max_algo-min_algo) + (max_algo+min_algo)/2
        # )
        if min_algo < 0:
            print(f"erreur dans {algo} : min<0: {min_algo}")
        if moy < min_algo:
            raise ArithmeticError()
        affichage_confiance.append([(moy - min_algo), (max_algo - moy)])
        # affichage_confiance.append([0.1,0.3])

    plt.barh(  # affichage des moyennes
        y=affichage_y,
        width=affichage_val,
        tick_label=affichage_label,
        xerr=np.array(affichage_confiance).transpose(),
        color='gray',
    )
    plt.barh(  # affiche les médianes avec un petit hack pour montrer juste des barres verticales
        y=affichage_y,
        width=medianes,
        tick_label=affichage_label,
        alpha=0,  # cache la couleur
        yerr=0.25,
    )
    plt.xlabel(xlabel=title)
    plt.xlim(0, max_total)


if __name__ == '__main__':
    algos_up = ListDict()
    algos_down = ListDict()
    for fichier in list(os.walk('resultats'))[0][2]:
        if fichier.startswith('up_'):
            process_donnees(os.path.join('resultats', fichier), algos_up)
        elif fichier.startswith('down_'):
            process_donnees(os.path.join('resultats', fichier), algos_down)
    plt.subplot(1, 2, 1)
    afficher_graphique(algos_up, f"Durée montante ({len(list(algos_up.values())[0])} fois)")
    plt.title("envoi d'une image\nde 1Mo par HTTP")
    plt.subplot(1, 2, 2)
    afficher_graphique(algos_down, f"Durée descendante ({len(list(algos_down.values())[0])} fois)")
    plt.title("réception d'une image\nde 1.3 Mo par HTTPS")
    plt.show()

"""
rajouter la version de l'OS, du kernel
avoir les mêmes échelles horizontales

montrer autre chose que la moyenne -> montrer les barres de dispersion (boites à moustache)
Ubuntu 18.04.3
4.15.0-58-generic
connecté en Ethernet
regarder les paramètres des sessions TCP pour les différents algos
regarder également la croissance de la feneêtre de congestion ....
diagramme x=temps y=segments reçus

mesurer le temps aller-retour pour voir s'il y a de la congestion (si le ping augmente il y a de la congestion)
faire des traceroutes pour montrer que le réseau est le même
essayer de le faire à différentes heures (charges différentes)

on pourrait exporter des traces PCAP wireshark et les analyser
les descripteurs de protocole permettent de reconstruire le chronogramme ...
"""
