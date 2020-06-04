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


if __name__ == '__main__':
    algos = ListDict()

    with open('up.csv') as infile:
        r = csv.reader(infile, delimiter=',')
        for row in r:
            if row[2] == '' or row[0] == 'algo':  # saute les en-êtes
                continue

            algo, time, size, speed = row  # algo,temps(s),taille(octets),débit utile(o/s)
            algos[algo].append(float(time))

    resultats = {}
    for algo in algos.keys():
        resultats[algo] = mean(algos[algo])
        print(f"{algo}: {resultats[algo]}")
    barchart = plt.barh(y=list(range(len(algos))), width=resultats.values(), tick_label=list(resultats.keys()))
    plt.xlabel(xlabel='Durée montante (s)')
    plt.show()
