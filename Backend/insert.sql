INSERT INTO T_level (id_level, enonce, _result, aide) VALUES
(1, "Le serpent glisse silencieusement dans la jungle.
Il t'observe et attend de voir tes premiers mouvements.", 
"Le serpent t'observe.", "#aide
print('Observe le serpent')"),

(2, "Le serpent te demande ton nom.
Tu dois le lui dire pour qu'il te considère.", 
"Bienvenue, Apprenti", "#aide
print(f'Bienvenue, {nom}')"),

(3, "Pour gagner sa confiance, indique ton âge.
Montre que tu es prêt à continuer.", 
"Tu as 15 ans.", "#aide
print(f'Tu as {age} ans')"),

(4, "Le serpent veut tester ton esprit.
Additionne 7 et 5.", 
"Résultat: 12", "#aide
print(7 + 5)"),

(5, "Il t’enseigne la répétition.
Répète un geste trois fois.", 
"Étape 1
Étape 2
Étape 3", "#aide
for i in range(3): print(i)"),

(6, "Il te montre un coffre rempli d'objets anciens.
Liste-les tous.", 
"Tu trouves une épée
Tu trouves un arc
Tu trouves une dague", "#aide
armes = ['épée','arc','dague']"),

(7, "Le serpent vérifie ton énergie avant de continuer.
Montre que tu es prêt.", 
"Tu es prêt à continuer", "#aide
energie = 100
print('Prêt' if energie>50 else 'Fatigué')"),

(8, "Tu dois dépasser le niveau 3 pour continuer.
Ne reste pas bloqué trop longtemps.", 
"Encore un peu d'entraînement", "#aide
niveau = 4
print('Continue')"),

(9, "Traverse un tunnel en faisant trois pas.
Fais attention à chaque mouvement.", 
"Tu avances dans le tunnel
Tu avances dans le tunnel
Tu avances dans le tunnel", "#aide
for i in range(3): print('Tu avances dans le tunnel')"),

(10, "Salue ton mentor avant de continuer.
Un geste de respect est nécessaire.", 
"Courage à toi, Apprenti", "#aide
print(f'Courage à toi, {nom}')"),

(11, "Crée une variable qui additionne deux nombres.
Affiche le résultat.", 
"10", "#aide
x = 7
y = 3
print(x+y)"),

(12, "Ajoute un objet dans ton sac.
Prépare-toi pour l'aventure.", 
"['torche', 'corde', 'clé']", "#aide
sac = ['torche','corde']
sac.append('clé')
print(sac)"),

(13, "Le serpent veut savoir le nom de ton mentor.
Répond avec honnêteté.", 
"Python", "#aide
mentor = 'Python'
print(mentor)"),

(14, "Affiche le nom et le niveau de ton mentor.
Organise bien les informations.", 
"nom : Python
niveau : 10", "#aide
mentor = {'nom':'Python','niveau':10}
for k,v in mentor.items(): print(f'{k} : {v}')"),

(15, "Améliore tes scores avec un bonus automatique.
Chaque point compte.", 
"[15, 25, 35]", "#aide
scores = [10,20,30]
scores = [s+5 for s in scores]
print(scores)"),

(16, "Gère une erreur si la valeur n'est pas un nombre.
Reste vigilant.", 
"12", "#aide
try:
    x = int('12')
    print(x)
except ValueError:
    print('Erreur')"),

(17, "Teste une condition compacte.
Fais un choix rapide.", 
"x>y", "#aide
x=5
y=3
print('x>y' if x>y else 'x<=y')"),

(18, "Change un texte en majuscules.
Lis bien le message final.", 
"PYTHON", "#aide
texte = 'Python'
print(texte.upper())"),

(19, "Donne un nom à ton serpent.
Puis affiche-le.", 
"Python", "#aide
serpent = 'Python'
print(serpent)"),

(20, "Le serpent te donne son dernier conseil.
Écoute-le attentivement.", 
"Le savoir est une arme.", "#aide
print('Le savoir est une arme.')");
