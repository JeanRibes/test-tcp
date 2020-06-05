import os
from statistics import mean

from matplotlib import pyplot as plt
import csv


class ListDict(dict):
    def __getitem__(self, item) -> list:
        try:
            return super().__getitem__(item)
        except KeyError:
            nl = []
            self.__setitem__(item, nl)
            return nl


def process_donnees(filename, algos:ListDict):

    with open(filename) as infile:
        r = csv.reader(infile, delimiter=',')
        for row in r:
            if row[2] == '' or row[0] == 'algo':  # saute les en-êtes
                continue

            algo, time, size, speed = row  # algo,temps(s),taille(octets),débit utile(o/s)
            algos[algo].append(float(time))
def afficher_graphique(algos:ListDict, title):
    resultats = {}
    for algo in algos.keys():
        resultats[algo] = mean(algos[algo])
        print(f"{algo}: {resultats[algo]}")
    plt.barh(y=list(range(len(algos))), width=resultats.values(), tick_label=list(resultats.keys()))
    plt.xlabel(xlabel=title)

if __name__ == '__main__':
    algos_up = ListDict()
    algos_down = ListDict()
    for fichier in list(os.walk('resultats'))[0][2]:
        if fichier.startswith('up_'):
            process_donnees(os.path.join('resultats',fichier), algos_up)
        elif fichier.startswith('down_'):
            process_donnees(os.path.join('resultats',fichier), algos_down)
    plt.subplot(1,2,1)
    afficher_graphique(algos_up, f"Durée montante (x{len(list(algos_up.values())[0])})")
    plt.subplot(1,2,2)
    afficher_graphique(algos_down, f"Durée descendante (x{len(list(algos_down.values())[0])})")
    plt.show()

