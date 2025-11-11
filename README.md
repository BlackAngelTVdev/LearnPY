# 🐍 LearnPY — Guide d’installation

## 🚀 Installation complète

### 1️⃣ Cloner le dépôt
```bash
git clone https://github.com/BlackAngelTVdev/LearnPY.git
cd LearnPY
```
### 2️⃣ Backend — Installation et lancement

Depuis le dossier Backend :
```
npm install
node server.js
```

### 3️⃣ Frontend — Installation et lancement

Depuis le dossier Frontend :
```
npm install
cd learnPY
npm run dev -- --host
```

### 4️⃣ Base de données — Configuration

Installez MySQL via Docker puis exécutez les commandes SQL de création et d’insertion des données présentes dans le dossier Backend.

```
docker run --name learnpy-db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=level -p 6033:3306 -d mysql
```

Ensuite, connectez-vous au conteneur et importez les fichiers SQL :
```
docker exec -i learnpy-db mysql -uroot -proot level < Backend/scripts/create.sql
docker exec -i learnpy-db mysql -uroot -proot level < Backend/scripts/insert.sql
```


### ✅ Votre environnement LearnPY est maintenant prêt !

🌐 Backend : http://localhost:8040 

💻 Frontend : accessible via l’URL indiquée après npm run dev

🗄️ Base de données MySQL : localhost:6033
