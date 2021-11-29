![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)
#Conteneur Docker
Databricks offre un service de conteneur personnalisé, ce service permet de spécifier une image Docker pour la création d'un cluster. Ce type de service peut servir à :

Personnaliser les bibliothèques systèmes et de développements nécessaires à la conduite des études en Hydrologie. Les ingénieurs et scientifiques de données disposeront d'un contrôle total sur l'environnement Python (conda ou pip) installé sur les clusters de traitement.
Créer une image Docker de référence qui permettra l'utilisation d'un environnement Python verrouillé et réutilisable dans le temps (reproduction des infra nécessaires aux études en Hydrologie).
Faciliter l'intégration et le déploiement continus (CI / CD) avec les outils devops (Azure devops, Bitbucket, Teamcity, etc.).

> Note: Un profil `ADMIN` est requis pour cette config.

##Pré-requis
Databricks runtime 6.1 ou version ultérieure. Pour des exemples de personnalisation d'image Docker avec le runtime Databricks, voir Github.
L'option "Services de conteneur Databricks" doit être cochée dans l'espace de travail Azure Databricks.

##Activer les services de conteneurs
Pour utiliser des conteneurs personnalisés sur les clusters Databricks, l’administrateur de l’espace de travail doit activer les services de conteneur Databricks comme suit :

- Accéder à la console d’administration.
- cliquez sur l’onglet Paramètres de l’espace de travail .
- Dans la section cluster , cliquez sur le bouton bascule services de conteneur .
- Cliquez sur Confirmer.

Le porte de travail doit exécuter un démon Docker récent (testé et fonctionnel avec la version client/serveur 18.03.0-ce) et la commande Docker doit être disponible sur le variable d'environnement PATH.

##Créer l'image de base
Databricks recommande d'utiliser ses images Docker de base pour construire ses propres images personnalisées.

Exemple d'image Docker pour un environnement Databricks sous conda-python :
```
    Dockerfile
    env.yml
```
Utiliser un script d'initialisation
Les clusters Databricks Container Services permettent d'inclure des scripts d'initialisation dans le conteneur Docker. Dans la plupart des cas, il est conseiller d'éviter les scripts d'initialisation et d'effectuer des personnalisations directement via Docker (en utilisant le Dockerfile). Cependant, certaines tâches doivent être exécutées au démarrage du conteneur, plutôt qu'au moment de la construction du conteneur. Utilisez un script d'initialisation pour ces tâches.

Par exemple, exécuter les processus Dask (scheduler & workers) au runtime.

Pour les images Databricks Container Services, il est possible de stocker les scripts d'initialisation dans DBFS ou dans un stockage cloud.

Les étapes suivantes ont lieu lors du lancement du cluster Databricks Container Services :

Les machines virtuelles VM sont acquises auprès du fournisseur de cloud (Azure ou AWS).
L'image Docker personnalisée est téléchargée à partir du référentiel (ex. Azure Container Registry).
Databricks crée un conteneur Docker à partir de l'image.
Le code d'exécution de Databricks est copié dans le conteneur Docker.
Les scripts d'initialisation sont exécutés. Voir l'ordre d'exécution du script d'initialisation.
Databricks ignore les primitives Docker CMD et ENTRYPOINT.
```
init_script_dask.sh
```
```console
Docker build
docker build --file Dockerfile -t hydro/xkp/hydrologie/daskenv:beta1.0 --label 'solution=xkp'
```

##Enregistrement de l'image de base
```console
Docker push
docker login 985f8118fd684242ab80beb99b2a1e19.azurecr.io
docker tag hydro/xkp/hydrologie/daskenv:beta1.0 985f8118fd684242ab80beb99b2a1e19.azurecr.io/hydro/xkp/hydrologie/daskenv:beta1.0
docker push 985f8118fd684242ab80beb99b2a1e19.azurecr.io/hydro/xkp/hydrologie/daskenv:beta1.0
```

##Lancer le cluster ADB
À l'aide de l'interface utilisateur Databricks

