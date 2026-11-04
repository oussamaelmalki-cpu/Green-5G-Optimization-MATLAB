import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

st.set_page_config(page_title="Green 5G Optimization", layout="wide")

st.title("🌱 Optimisation Énergétique 5G (MATLAB)")
st.markdown("Simulation de l'algorithme d'optimisation (Load Balancing & Sleep Mode) développé sous MATLAB.")

# 1. Affichage de la Vidéo (L'Animation)
st.subheader("📺 Simulation Dynamique (Video)")
try:
    # Ila l'vidéo m7eta f nafs l'dossier
    st.video("simulation_video.mp4") 
except:
    st.warning("⚠️ Vidéo introuvable. Veuillez vérifier que le fichier est bien dans le dossier.")

# 2. Affichage des Résultats (Graphique)
st.subheader("📊 Impact de l'Optimisation sur l'Énergie")
try:
    df = pd.read_csv("resultats_green_5g.csv")
    
    # Les Métriques
    col1, col2, col3 = st.columns(3)
    col1.metric("Énergie Moyenne (Sans Opt)", f"{df['Energy_Sans_Opt'].mean():.2f} W")
    col2.metric("Énergie Moyenne (Avec Opt)", f"{df['Energy_Avec_Opt'].mean():.2f} W")
    
    economie = (1 - df['Energy_Avec_Opt'].mean() / df['Energy_Sans_Opt'].mean()) * 100
    col3.metric("Économie Réalisée", f"{economie:.1f} %", delta=f"{economie:.1f}% Gain")
    
    # Le Graphique
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(df['Time_Steps'], df['Energy_Sans_Opt'], 'r--', label='Sans Optimisation')
    ax.plot(df['Time_Steps'], df['Energy_Avec_Opt'], 'g-', linewidth=2, label='Avec Optimisation')
    
    ax.set_xlabel("Temps (Étapes)")
    ax.set_ylabel("Consommation (Watts)")
    ax.legend()
    ax.grid(True, linestyle='--', alpha=0.7)
    
    st.pyplot(fig)

except FileNotFoundError:
    st.error("⚠️ Fichier 'resultats_green_5g.csv' introuvable.")