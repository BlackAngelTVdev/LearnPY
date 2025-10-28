// import utiles
const express = require("express");
const { exec } = require("child_process");
const fs = require("fs");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");
const app = express();
const mysql = require("mysql2/promise");

//connection a la db
const db = mysql.createPool({
  host: "localhost",
  port: 3306,
  user: "root",
  password: "root",
  database: "level",
});

app.use(cors());
app.use(express.json());

//port du serveur (doit etre le meme sur le front)
const Port = 8040;

//liste de string banni
const forbidden = [
  "import os",
  "import sys",
  "import subprocess",
  "import socket",
  "import threading",
  "import multiprocessing",
  "__import__",
  "open(",
  "eval(",
  "exec(",
  "import",
];

//Catch des erreur pour etre plus facil
const errorMap = {
  SyntaxError:
    "Syntaxe incorrecte → pense aux parenthèses, deux-points et indentation.",
  IndentationError: "Indentation incorrecte → aligne bien tes blocs de code.",
  NameError:
    "Variable inconnue → peut-être une faute de frappe ou tu ne l’as pas encore définie.",
  TypeError:
    "Mauvais mélange de types → ex: tu ne peux pas additionner un texte et un nombre.",
  ZeroDivisionError: "Division par zéro → impossible en mathématiques 😉.",
  IndexError:
    "Index hors limite → tu cherches une case qui n’existe pas dans ta liste.",
  KeyError:
    "Clé introuvable → tu cherches une clé qui n’existe pas dans ton dictionnaire.",
  ValueError: "Mauvaise valeur → ex: convertir 'abc' en nombre.",
  ImportError:
    "Import impossible → la librairie n’existe pas ou est interdite.",
};

// endpoint RUN
app.post("/api/run", (req, res) => {
  // récuper le body de la requets pour mettre dans userCode
  const userCode = req.body.code;

  // regarde si il y a pas un string ban dans le code qui viens d'arrivé
  for (const bad of forbidden) {
    if (userCode.includes(bad)) {
      // erreur => envoi directement sans exec
      return res.json({
        success: false,
        error: `⚠️ Usage interdit détecté : ${bad}`,
      });
    }
  }

  //créé le nom des du user_script avec un UUID (pas de doublon)
  const filename = `user_script_${uuidv4()}.py`;

  //essaye
  try {
    //ecrit dans le fichier créé avant avec le userCode
    fs.writeFileSync(filename, userCode);

    //execute le python         anti-spam
    exec(`python ${filename}`, { timeout: 10000 }, (error, stdout, stderr) => {
      //supprime le fichier apres l'execution
      try {
        fs.unlinkSync(filename);
      } catch (e) {}

      if (error) {
        let msg = stderr || error.message;
        let userMsg = "Une erreur est survenue, vérifie ton code.";

        for (const key in errorMap) {
          if (msg.includes(key)) {
            userMsg = `${errorMap[key]}`;
            break;
          }
        }

        return res.json({ success: false, error: userMsg });
      }

      res.json({ success: true, output: stdout.trim() });
    });
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

app.get("/api/levels/:id", async (req, res) => {
  const level = req.params.id;

  try {
    const [rows] = await db.query("SELECT * FROM T_level WHERE id_level = ?", [
      level,
    ]);

    if (rows.length === 0) {
      return res.json({ success: false, error: "❌ Aucun énoncé trouvé" });
    }

    res.json({ success: true, enonce: rows[0].enonce, code: rows[0].aide });
  } catch (e) {
    console.error("Erreur SQL:", e);
    res.json({ success: false, error: "⚠️ Erreur base de données" });
  }
});

app.listen(Port, "0.0.0.0",() => {
  console.log(`✅ Backend lancé sur http://0.0.0.0:${Port}`);
});
