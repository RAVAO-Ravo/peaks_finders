#-*- coding:utf-8 -*-


# Importation des modules
import pandas as pd
import matplotlib.pyplot as plt
from typing import Tuple


def load_data(
	filepath: str,
	mslevel: str = '1'
) -> pd.DataFrame:
	"""
	Charge et prépare un fichier de données spectrométriques pour une utilisation dans DEIMoS.

	Cette fonction lit un fichier au format Parquet et le filtre pour ne conserver que les scans d'un niveau
	de masse spécifié (par défaut 'MS1'). Elle renomme les colonnes pour correspondre aux noms attendus par DEIMoS
	et effectue les conversions nécessaires des colonnes en type float pour assurer une manipulation correcte
	des données. Les données sont ensuite triées par ordre croissant de masse, temps de rétention, et temps de
	dérive avant d'être retournées sous forme d'un DataFrame formaté.

	Args:
		filepath (str): Le chemin d'accès au fichier Parquet contenant les données brutes.
		mslevel (str): Le niveau de masse à filtrer. Par défaut, '1' pour les scans MS1.

	Returns:
		pd.DataFrame: Un DataFrame contenant les colonnes `mz`, `retention_time`, `drift_time` et `intensity`.
	"""
	# Lire le fichier
	data = pd.read_parquet(path=filepath)

	# Filtrer pour garder uniquement les scans MS du niveau spécifié
	data = data[data["mslevel"] == mslevel]

	# Renommer les colonnes pour correspondre aux attentes de DEIMoS
	data = data.rename(columns={
		"rt": "retention_time",
		"dt": "drift_time"
	})

	# Convertir les colonnes en float si nécessaire
	for column in data.columns:
		data[column] = data[column].astype(float)

	# Conserver uniquement les colonnes d'intérêt
	data = data[["mz", "retention_time", "drift_time", "intensity"]]

	# Retourner le DataFrame formaté pour la détection des pics
	return data.sort_values(by=["mz", "retention_time", "drift_time"], ascending=True).reset_index(drop=True)


def plotting_datas(
	signal: pd.DataFrame, 
	peaks: pd.DataFrame,
	figsize: Tuple[int, int] = (12, 8),
	display_range: Tuple[int, int] = None
) -> None:
	"""
	Affiche le signal simulé et marque les pics identifiés.

	Args:
		signal (pd.DataFrame): Signal simulé avec intensité à chaque point.
		peaks (pd.DataFrame): Indicateur binaire des pics.
		figsize (Tuple[int, int], optional): Taille de la figure.
		display_range (Tuple[int, int], optional): Plage de positions à afficher.
	"""
	# Déterminer la plage d'affichage
	if display_range:
		start, stop = display_range
		signal = signal.iloc[start:stop]
		peaks = peaks.iloc[start:stop]
	else:
		start, stop = 0, len(signal)

	# Création du graphique
	plt.figure(figsize=figsize)

	# Plotting des données
	plt.plot(
		signal.index,
		signal["intensity"],
		label="Signal simulé", 
		color="blue"
	)

	# Affichage des pics
	plt.scatter(
		peaks[peaks["peaks"] == 1].index, 
		signal["intensity"][peaks["peaks"] == 1], 
		label="Vrais pics",
		color="red"
	)

	# Annotation de la figure
	plt.xlabel("Position")
	plt.ylabel("Intensité")
	plt.title(f"Signal simulé avec pics (de {start} à {stop})")

	# Affichage de la figure
	plt.show()