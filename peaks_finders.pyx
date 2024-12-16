# -*- coding:utf-8 -*-


# Importation des modules
import numpy as np
import pandas as pd
from tqdm import tqdm
from typing import Dict


cdef class PeaksFinder(object):
    """
    Classe permettant la détection de pics dans un signal par utilisation d’une machine à états finis.
    
    Les trois états possibles sont :
        - SEARCHING : l’algorithme recherche le début d’un éventuel pic.
        - ASCENDING : un pic est en cours de montée.
        - DESCENDING: un pic est en cours de descente.
    
    Attributes:
        SEARCHING (int): Constante représentant l’état “recherche de pic”.
        ASCENDING (int): Constante représentant l’état “montée du pic”.
        DESCENDING (int): Constante représentant l’état “descente du pic”.
        ascd_min (int): Nombre de points consécutifs minimum pour considérer le début d’un pic.
        dscd_min (int): Nombre de points consécutifs minimum pour considérer la fin d’un pic.
    """
    # Les états possibles de la machine à états
    cdef int SEARCHING
    cdef int ASCENDING
    cdef int DESCENDING

    # Les valeurs minimales de descente et de montée
    cdef int ascd_min
    cdef int dscd_min

    def __init__(
        self,
        int ascd_min = 1,
        int dscd_min = 1
    ) -> None:
        """
        Initialise l’objet PeaksFinder avec les seuils de points consécutifs pour la montée et la descente.

        Args:
            ascd_min (int): Nombre de points consécutifs minimum pour identifier le début d'un pic.
            dscd_min (int): Nombre de points consécutifs minimum pour identifier la fin d'un pic.
        """
        # Seuil minimal de points en montée avant de déclarer un pic
        self.ascd_min = ascd_min

        # Seuil minimal de points en descente avant de valider un pic
        self.dscd_min = dscd_min

        # Définir les états
        self.SEARCHING = 0
        self.ASCENDING = 1
        self.DESCENDING = 2


    cpdef object peaks_detection(self, object df, str column = "intensity"):
        """
        Détecte les pics dans un signal et renvoie une DataFrame contenant une colonne `peaks`.
        
        Le fonctionnement s’appuie sur une machine à états :
            - SEARCHING: on attend d’entrer en ascension (delta > 0 plusieurs fois).
            - ASCENDING: on suit la montée, et dès qu’on descend plusieurs fois, on valide un pic.
            - DESCENDING: on continue la descente jusqu’à revenir au niveau de départ, 
                          ou jusqu’à ce que le signal remonte, indiquant un nouveau pic potentiel.
        
        Args:
            df (pd.DataFrame): DataFrame contenant le signal sous forme de colonnes.
            column (str): Nom de la colonne contenant l’intensité ou la valeur du signal.
        
        Returns:
            pd.DataFrame: Une DataFrame contenant une unique colonne "peaks" (valeurs 0 ou 1),
                          de même longueur que `df`.
        """
        # Extraction de la colonne du signal sous forme de tableau numpy
        cdef object signal = df[column].to_numpy(dtype=np.double)

        # Dictionnaire qui stocke les variables d'état 
        cdef Dict[str, object] sv = {
                                "state": self.SEARCHING,
                                "delta": None,
                                "ascd_cpt": 0, 
                                "dscd_cpt": 0,
                                "start_value": 0,
                                "max_value": None,
                                "max_index": None
                            }

        # Tableau numpy pour marquer la présence de pics (1) ou non (0)
        cdef object peaks = np.zeros(shape=len(signal), dtype=int)

        # Initialiser l'itérateur
        cdef int i = 0

        # Parcours de chaque point du signal (à partir du second pour calculer delta)
        for i in tqdm(range(1, len(signal)), unit=" point", desc="Détection des pics"):
            # Calcul du delta entre deux points consécutifs
            sv["delta"] = signal[i] - signal[i - 1]

            # ÉTAT 1 : SEARCHING — recherche d’un début de pic
            if sv["state"] == self.SEARCHING:
                if sv["delta"] > 0:
                    # On accumule des points en montée
                    sv["ascd_cpt"] += 1

                    # Si on atteint le seuil minimal de points positifs (montée)
                    if sv["ascd_cpt"] >= self.ascd_min:
                        # Passage à l’état ASCENDING
                        sv["state"] = self.ASCENDING

                        # On mémorise la valeur de départ et la première valeur max
                        sv["start_value"] = signal[i]
                        sv["max_value"] = signal[i]
                        sv["max_index"] = i
                else:
                    # Si le delta n’est pas strictement positif, on réinitialise la montée
                    sv["ascd_cpt"] = 0

            # ÉTAT 2 : ASCENDING — on est dans un pic en cours de montée
            elif sv["state"] == self.ASCENDING:
                if sv["delta"] > 0:
                    # On réinitialise de descente
                    sv["dscd_cpt"] = 0

                    # Mise à jour éventuelle de la valeur maximale du pic
                    if sv["max_value"] < signal[i]:
                        sv["max_value"] = signal[i]
                        sv["max_index"] = i

                elif sv["delta"] < 0:
                    # On amorce la descente : incrément de descente, réinit. de montée
                    sv["dscd_cpt"] += 1
                    sv["ascd_cpt"] = 0

                    # Si le seuil de descente est dépassé, on valide la crête du pic
                    if sv["dscd_cpt"] >= self.dscd_min:
                        # Passage en état DESCENDING
                        sv["state"] = self.DESCENDING

                        # On marque la position de la valeur max détectée
                        peaks[sv["max_index"]] = 1

                else:
                    # delta = 0 : on ne change pas d’état, on attend le prochain point
                    pass

            # ÉTAT 3 : DESCENDING — le pic est en cours de descente
            elif sv["state"] == self.DESCENDING:
                # Si on retourne au niveau initial ou en-dessous, on repasse en recherche
                if signal[i] <= sv["start_value"]:
                    sv["state"] = self.SEARCHING
                    sv["ascd_cpt"] = 0
                    sv["dscd_cpt"] = 0

                # Si on repart en montée avant de redescendre au niveau initial
                elif sv["delta"] > 0:
                    sv["ascd_cpt"] += 1
                    sv["dscd_cpt"] = 0

                    # Si on atteint à nouveau le seuil de montée, nouvel éventuel pic
                    if sv["ascd_cpt"] >= self.ascd_min:
                        sv["state"] = self.ASCENDING
                        sv["start_value"] = signal[i]
                        sv["max_value"] = signal[i]
                        sv["max_index"] = i
                else:
                    # delta <= 0, on reste en descente
                    pass

            # ÉTAT INATTENDU — doit normalement ne jamais se produire
            else:
                raise ValueError("Invalid state in finite state machine.")

        # Retourne un DataFrame avec la colonne des pics
        return pd.DataFrame(data={"peaks": peaks})