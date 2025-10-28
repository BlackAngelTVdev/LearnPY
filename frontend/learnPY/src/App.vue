<script setup>
import { ref, onMounted, nextTick, computed, onUnmounted } from "vue";

/* ---------------------------- CONFIG GLOBALE ---------------------------- */
const port = 8040;

/* --------------------------- ÉTATS PRINCIPAUX --------------------------- */
// Niveau stocké
if (!localStorage.getItem("learnPY.level")) localStorage.setItem("learnPY.level", 1);
let level = Number(localStorage.getItem("learnPY.level"));
const maxLevels = ref(20);

// Contenu principal
const code = ref(`# Exemple\nprint("Hello Damien")`);
const enonce = ref("Explication non");
const output = ref("Prêt à exécuter ton code…");
const running = ref(false);

// UI / Composants
const showPythonHelp = ref(false);
const open = ref(false);
const terminal = ref(null);
const editorTextarea = ref(null);
const highlightedDiv = ref(null);

// Gestion lignes
const lineNumbers = ref("1");

/* --------------------------- MOTS CLÉS PYTHON --------------------------- */
const keywords = [
  "False", "class", "finally", "is", "return", "None", "continue", "for", "lambda",
  "try", "True", "def", "from", "nonlocal", "while", "and", "del", "global", "not",
  "with", "as", "elif", "if", "or", "yield", "assert", "else", "import", "pass",
  "break", "except", "in", "raise", "print", "sum", "range"
];

const pythonKeywordsHelp = [
  { word: "print", desc: "Affiche dans la console", example: "print('Hello')", url: "https://www.w3schools.com/python/ref_func_print.asp" },
  { word: "False", desc: "Valeur booléenne fausse", example: "is_active = False", url: "https://www.w3schools.com/python/ref_keyword_false.asp" },
  { word: "True", desc: "Valeur booléenne vraie", example: "is_ready = True", url: "https://www.w3schools.com/python/ref_keyword_true.asp" },
  { word: "None", desc: "Valeur nulle ou vide", example: "result = None", url: "https://www.w3schools.com/python/ref_keyword_none.asp" },
  { word: "and", desc: "Opérateur logique ET", example: "if a > 0 and b > 0: print('Both positive')", url: "https://www.w3schools.com/python/ref_keyword_and.asp" },
  { word: "or", desc: "Opérateur logique OU", example: "if a < 0 or b < 0: print('One negative')", url: "https://www.w3schools.com/python/ref_keyword_or.asp" },
  { word: "not", desc: "Opérateur logique NON", example: "if not done: print('Not done yet')", url: "https://www.w3schools.com/python/ref_keyword_not.asp" },
  { word: "if", desc: "Condition", example: "if x > 10: print('x > 10')", url: "https://www.w3schools.com/python/ref_keyword_if.asp" },
  { word: "elif", desc: "Sinon si", example: "elif x == 10: print('x = 10')", url: "https://www.w3schools.com/python/ref_keyword_elif.asp" },
  { word: "else", desc: "Sinon", example: "else: print('x < 10')", url: "https://www.w3schools.com/python/ref_keyword_else.asp" },
  { word: "for", desc: "Boucle sur une séquence", example: "for i in range(5): print(i)", url: "https://www.w3schools.com/python/ref_keyword_for.asp" },
  { word: "while", desc: "Boucle tant que la condition est vraie", example: "while x > 0: x -= 1", url: "https://www.w3schools.com/python/ref_keyword_while.asp" },
  { word: "break", desc: "Sort de la boucle", example: "for i in range(10): if i==5: break", url: "https://www.w3schools.com/python/ref_keyword_break.asp" },
  { word: "continue", desc: "Passe à l’itération suivante", example: "for i in range(5): if i==2: continue", url: "https://www.w3schools.com/python/ref_keyword_continue.asp" },
  { word: "len", desc: "Longueur d'une séquence", example: "len([1,2,3])  # 3", url: "https://www.w3schools.com/python/ref_func_len.asp" },
  { word: "range", desc: "Génère une séquence de nombres", example: "for i in range(5): print(i)", url: "https://www.w3schools.com/python/ref_func_range.asp" },
  { word: "enumerate", desc: "Itère sur une séquence avec index", example: "for i, val in enumerate(['a','b']): print(i, val)", url: "https://www.w3schools.com/python/ref_func_enumerate.asp" },
  { word: "zip", desc: "Itère simultanément sur plusieurs séquences", example: "for a, b in zip([1,2],[3,4]): print(a,b)", url: "https://www.w3schools.com/python/ref_func_zip.asp" },
  { word: "reversed", desc: "Itère sur une séquence dans l’ordre inverse", example: "for i in reversed([1,2,3]): print(i)", url: "https://www.w3schools.com/python/ref_func_reversed.asp" },
  { word: "sorted", desc: "Itère sur une séquence et la trie", example: "for i in sorted([3,1,2]): print(i)", url: "https://www.w3schools.com/python/ref_func_sorted.asp" },

  // mots et méthodes qu’on a utilisés mais pas encore listés
  { word: "append", desc: "Ajoute un élément à la fin d'une liste", example: "my_list.append(5)", url: "https://www.w3schools.com/python/ref_list_append.asp" },
  { word: "upper", desc: "Met une chaîne en majuscule", example: "'abc'.upper()  # 'ABC'", url: "https://www.w3schools.com/python/ref_string_upper.asp" },
  { word: "items", desc: "Itère sur les couples clé/valeur d'un dictionnaire", example: "for k,v in my_dict.items(): print(k,v)", url: "https://www.w3schools.com/python/ref_dictionary_items.asp" },
];


/* ------------------------- SYNTAXE & LIGNES ------------------------- */
const escapeHtml = (str) =>
  str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

const updateLineNumbers = () => {
  const lines = code.value.split("\n").length;
  lineNumbers.value = Array.from({ length: lines }, (_, i) => i + 1).join("\n");
};

const highlightedCode = computed(() => {
  if (!code.value) return "";
  let escaped = escapeHtml(code.value);

  const kwPattern = new RegExp(`\\b(${keywords.join("|")})\\b`, "g");
  escaped = escaped.replace(kwPattern, `<span class="keyword">$1</span>`);
  escaped = escaped.replace(/([()])/g, `<span class="paren">$1</span>`);
  escaped = escaped.replace(/([{}])/g, `<span class="acolade">$1</span>`);
  escaped = escaped.replace(/(\[|\])/g, `<span class="corchait">$1</span>`);
  escaped = escaped.replace(/(#.*)$/gm, `<span class="comments">$1</span>`);

  const varMatches = [...code.value.matchAll(/^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=/gm)];
  const variableNames = new Set(varMatches.map((m) => m[1]));
  escaped = escaped.replace(
    /^(\s*)([a-zA-Z_][a-zA-Z0-9_]*)(\s*=)/gm,
    `$1<span class="variable">$2</span>$3`
  );
  if (variableNames.size > 0) {
    const varsRegex = new RegExp(`\\b(${[...variableNames].join("|")})\\b`, "g");
    escaped = escaped.replace(varsRegex, `<span class="variable">$1</span>`);
  }

  return escaped;
});

/* --------------------------- SYNC & SCROLL --------------------------- */
const syncScroll = () => {
  if (highlightedDiv.value && editorTextarea.value) {
    highlightedDiv.value.scrollTop = editorTextarea.value.scrollTop;
    highlightedDiv.value.scrollLeft = editorTextarea.value.scrollLeft;
  }
};

const scrollToBottom = async () => {
  await nextTick();
  if (terminal.value) terminal.value.scrollTop = terminal.value.scrollHeight;
};

/* --------------------------- NIVEAUX / API --------------------------- */
async function chargerEnonce(level) {
  try {
    const res = await fetch(`http://localhost:${port}/api/levels/${level}`);
    const data = await res.json();

    if (data.success) {
      enonce.value = data.enonce;
      if (data.code) {
        code.value = data.code;
        await nextTick();
        updateLineNumbers();
        syncScroll();
      }
    } else {
      enonce.value = data.error;
    }
  } catch (err) {
    console.error("Erreur fetch :", err);
    enonce.value = "⚠️ Erreur de communication avec le serveur";
  }
}

const goToNextLevel = () => {
  if (level < maxLevels.value) {
    level++;
    localStorage.setItem("learnPY.level", level);
    chargerEnonce(level);
  }
};

const goToPreviousLevel = () => {
  if (level > 1) {
    level--;
    localStorage.setItem("learnPY.level", level);
    chargerEnonce(level);
  }
};

const selectLevel = (n) => {
  if (n >= 1 && n <= maxLevels.value) {
    level = n;
    localStorage.setItem("learnPY.level", level);
    chargerEnonce(level);
    open.value = false;
  }
};

/* ---------------------------- ÉDITEUR CODE ---------------------------- */
const clearCode = () => {
  code.value = "";
  updateLineNumbers();
};

const handleEditorKeydown = async (e) => {
  const el = editorTextarea.value;
  if (!el) return;
  const val = code.value;
  const start = el.selectionStart;
  const end = el.selectionEnd;

  // Indentation
  if (e.key === "Tab") {
    e.preventDefault();
    code.value = val.substring(0, start) + "    " + val.substring(end);
    await nextTick();
    el.selectionStart = el.selectionEnd = start + 4;
    updateLineNumbers();
    return;
  }

  // Auto-close guillemets
  const pairs = { '"': '"', "'": "'", "`": "`" };
  if (pairs[e.key]) {
    e.preventDefault();
    code.value = val.slice(0, start) + e.key + pairs[e.key] + val.slice(end);
    await nextTick();
    el.selectionStart = el.selectionEnd = start + 1;
    updateLineNumbers();
    return;
  }

  // Bloc automatique
  if (e.key === "Enter" && val[start - 1] === "{" && val[end] === "}") {
    e.preventDefault();
    const indent = "  ";
    code.value = val.slice(0, start) + "\n" + indent + "\n" + val.slice(end);
    await nextTick();
    el.selectionStart = el.selectionEnd = start + 1 + indent.length;
    updateLineNumbers();
  }
};

/* -------------------------- EXÉCUTION PYTHON -------------------------- */
const runCode = async () => {
  if (running.value) return;
  running.value = true;
  output.value = "⏳ Exécution en cours…";
  await scrollToBottom();

  try {
    const response = await fetch(`http://localhost:${port}/api/run`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ code: code.value }),
    });
    const data = await response.json();

    output.value = data?.success
      ? String(data.output || "(aucune sortie)").trim()
      : "❌ Erreur : " + (data?.error || data?.message || "inconnue");
  } catch {
    output.value = `⚠️ Impossible de contacter le serveur (vérifie qu’il tourne sur le port ${port})`;
  } finally {
    running.value = false;
    await scrollToBottom();
  }
};
/* -------------------------- DIFFICULTÉS NIVEAUX -------------------------- */
const hoverLevel = ref(null);

const getDifficulty = (n) => {
  if (n <= 5) return { label: "Easy", color: "#4caf50" };       // Vert
  if (n <= 10) return { label: "Normal", color: "#2196f3" };    // Bleu
  if (n <= 15) return { label: "Hard", color: "#ff9800" };      // Orange
  return { label: "Expert", color: "#f44336" };                 // Rouge
};


/* ----------------------------- RACCOURCIS ----------------------------- */


let blockingSave = false;

const onKey = (e) => {
  // Bloquer exécution code avec Ctrl+Enter 
  if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
    e.preventDefault();
    runCode();
    return;
  }

  // Bloquer Ctrl+S
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "s") {
    e.preventDefault();
    if (!blockingSave) {
      blockingSave = true;
      alert("L'enregistrement de cette page est désactivé pour protéger le code source.");
      setTimeout(() => (blockingSave = false), 500);
    }
    return;
  }

  /* ----------------------- BLOCK LE DEV TOOLS --------------------- */
  // F12
  if (e.key === "F12") {
    e.preventDefault();
    if (!blockingSave) {
      blockingSave = true;
      alert("Le DEV Tools de cette page est désactivé pour protéger le code source.");
      setTimeout(() => (blockingSave = false), 500);
    }
    return;
  }
  // Ctrl+Shift+I ou Ctrl+Shift+J
  if ((e.ctrlKey || e.metaKey) && e.shiftKey && ["I", "J"].includes(e.key.toUpperCase())) {
    e.preventDefault();
    if (!blockingSave) {
      blockingSave = true;
      alert("Le DEV Tools de cette page est désactivé pour protéger le code source.");
      setTimeout(() => (blockingSave = false), 500);
    }
    return;
  }
  // Ctrl+U (afficher source)
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "u") {
    e.preventDefault();
    if (!blockingSave) {
      blockingSave = true;
      alert("Voire le code source de cette page est désactivé pour le protéger");
      setTimeout(() => (blockingSave = false), 500);
    }
    return;
  }

  /* ----------------------- FLECHES --------------------- */
  if ((e.ctrlKey || e.metaKey) && e.key === "ArrowLeft") {
    e.preventDefault();
    goToPreviousLevel();
    return;
  }
  if ((e.ctrlKey || e.metaKey) && e.key === "ArrowRight") {
    e.preventDefault();
    goToNextLevel();
    return;
  }
};

const onContextMenu = (e) => {
  e.preventDefault(); // bloque clic droit

};



const theme = ref("default"); // par défaut notre thème existant

const themes = {
  default: {
    "--color-keyword": "#f59e0b",
    "--color-comment": "#00660efb",
    "--color-variable": "#c96ee0",
    "--color-string": "#00ff80",
    "--color-paren": "#3b82f6",
    "--color-accolade": "#22c55e",
    "--color-crochet": "#d41616"
  },
  solarized: {
    "--color-keyword": "#b58900",
    "--color-comment": "#93a1a1",
    "--color-variable": "#268bd2",
    "--color-string": "#2aa198",
    "--color-paren": "#859900",
    "--color-accolade": "#cb4b16",
    "--color-crochet": "#d33682"
  },
  dracula: {
    "--color-keyword": "#ff79c6",
    "--color-comment": "#6272a4",
    "--color-variable": "#50fa7b",
    "--color-string": "#f1fa8c",
    "--color-paren": "#8be9fd",
    "--color-accolade": "#ffb86c",
    "--color-crochet": "#ff5555"
  },
  monokai: {
    "--color-keyword": "#f92672",
    "--color-comment": "#75715e",
    "--color-variable": "#a6e22e",
    "--color-string": "#e6db74",
    "--color-paren": "#66d9ef",
    "--color-accolade": "#fd971f",
    "--color-crochet": "#f92672"
  }
};

const applyTheme = () => {
  const selected = themes[theme.value];
  for (const key in selected) {
    document.documentElement.style.setProperty(key, selected[key]);
  }
};





onMounted(async () => { // Niveau initial 
  if (level > maxLevels.value) {
    level = maxLevels.value; localStorage.setItem("learnPY.level", level);
  }
  await chargerEnonce(level);
  await nextTick();
  updateLineNumbers();
  syncScroll();
  applyTheme();
  window.addEventListener("keydown", onKey, { capture: true });
  window.addEventListener("contextmenu", onContextMenu);
});

onUnmounted(() => {
  window.removeEventListener("keydown", onKey, { capture: true });
  window.removeEventListener("contextmenu", onContextMenu);
});


</script>

<template>

  <!-- Bouton Poule -->
  <button class="poule-btn" title="Clique pour voir les astuces Python" @click="showPythonHelp = true">
    <img src="../public/aide.png" alt="Poulette" width="40" />
  </button>

  <!-- Popup Python -->
  <div v-if="showPythonHelp" class="popup-overlay" @click.self="showPythonHelp = false">
    <div class="popup-content">
      <h2>Mots-clés Python</h2>
      <div class="popup-list">
        <div v-for="item in pythonKeywordsHelp" :key="item.word" class="popup-item">
          <a :href="item.url" target="_blank" class="keyword-popup">
            <strong>{{ item.word }}</strong>
          </a>
          : <span class="desc-popup">{{ item.desc }}</span>
          <pre class="example-popup">{{ item.example }}</pre>
        </div>

      </div>
      <button class="close-btn" @click="showPythonHelp = false">Fermer</button>
    </div>
  </div>



  <div class="app" @keydown="onKey">
    <header class="topbar">
      <div class="actions">
        <button class="prev" @click="goToPreviousLevel">◀ Précédent</button>

        <!-- Sélecteur de niveau -->
        <label for="level-select" style="margin: 0 10px;">LearnPY</label>


        <button class="next" @click="goToNextLevel">Suivant ▶</button>

      </div>

      <div class="actions">
        <div class="custom-select">
          <div class="selected" @click="open = !open">
            Niveau {{ level }} <strgon class="fleche">▼</strgon>
          </div>
          <div class="options" v-if="open">
            <div v-for="n in 20" :key="n" class="option-item" @mouseover="hoverLevel = n"
              @mouseleave="hoverLevel = null" @click="selectLevel(n)">
              Niveau {{ n }}
              <span class="difficulty-tag" :style="{
                color: hoverLevel === n ? '#000000' : getDifficulty(n).color
              }">
                {{ getDifficulty(n).label }}
              </span>
            </div>

          </div>
        </div>

        <button class="run" :disabled="running" @click="runCode">
          ▶ Run <span class="hint">(Ctrl+Enter)</span>
        </button>
      </div>
    </header>


    <div class="enoncer" ref="enoncer">
      <p>Explication level {{ level }}</p>
      <pre> {{ enonce }} </pre>
    </div>
    <main class="workspace">
      <!-- Colonne gauche : code -->
      <section class="pane code-pane">
        <div class="pane-title editor-header">
          <span>Code Python</span>
          <button class="clear-btn" @click="clearCode">✕</button>
        </div>
        <div class="editor-wrapper">
          <div class="line-numbers">
            <pre>{{ lineNumbers }}</pre>
          </div>

          <!-- Highlighted code -->
          <pre class="highlighted" v-html="highlightedCode" ref="highlightedDiv"></pre>

          <!-- Textarea where user types -->
          <textarea v-model="code" class="editor overlay" spellcheck="false" @input="updateLineNumbers"
            @scroll="syncScroll" ref="editorTextarea" @keydown="handleEditorKeydown"></textarea>
        </div>
      </section>


      <!-- Colonne droite : terminal -->
      <section class="pane terminal-pane">
        <div class="pane-title">Terminal
          <select v-model="theme" @change="applyTheme" class="theme-select">
            <option value="default">Default</option>
            <option value="solarized">Solarized Light</option>
            <option value="dracula">Dracula</option>
            <option value="monokai">Monokai</option>
          </select>
        </div>
        <div class="terminal" ref="terminal">
          <pre>{{ output }}</pre>
        </div>
      </section>
    </main>
  </div>
</template>