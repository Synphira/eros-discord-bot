// Bundled runtime (webapp/tools/vendor_ruby.rb) first, CDN as a fallback for local dev.
const RUNTIMES = [
  { loader: "../vendor/ruby-wasm-wasi.js", wasm: "vendor/ruby-stdlib.wasm" },
  {
    loader: "https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.10.1/dist/browser/+esm",
    wasm: "https://cdn.jsdelivr.net/npm/@ruby/3.4-wasm-wasi@2.10.1/dist/ruby+stdlib.wasm",
  },
];
const $ = (id) => document.getElementById(id);

let vm = null;

function showError(text) {
  const box = $("error");
  box.textContent = text;
  box.classList.remove("hidden");
}

async function loadRuntime() {
  for (const runtime of RUNTIMES) {
    try {
      const { DefaultRubyVM } = await import(runtime.loader);
      const response = await fetch(runtime.wasm);
      if (!response.ok) continue;
      // compileStreaming needs the application/wasm type; not every host sends it.
      const module = (response.headers.get("content-type") || "").includes("application/wasm")
        ? await WebAssembly.compileStreaming(response)
        : await WebAssembly.compile(await response.arrayBuffer());
      return { DefaultRubyVM, module };
    } catch (e) {
      console.warn(`Ruby runtime from ${runtime.loader} failed:`, e);
    }
  }
  throw new Error("Could not load the Ruby runtime.");
}

async function bootRuby() {
  const { DefaultRubyVM, module } = await loadRuntime();
  ({ vm } = await DefaultRubyVM(module));

  const files = await (await fetch("ruby/manifest.json", { cache: "no-store" })).json();
  for (const file of files) {
    const source = await (await fetch(`ruby/${file}`, { cache: "no-store" })).text();
    try {
      vm.eval(source);
    } catch (e) {
      throw new Error(`Ruby error in ${file}:\n${e.message}`);
    }
  }
}

function dispatch(action, arg = null, value = null) {
  window.erosInput = JSON.stringify({ action, arg, value });
  const view = JSON.parse(vm.eval("Eros::Bridge.handle_from_js").toString());
  if (view.error) {
    showError(`${view.error}\n${(view.backtrace || []).join("\n")}`);
    return;
  }
  render(view);
  if (view.export) showExport(view.export);
  else if (view.import_prompt) showImport();
}

function modalButton(label, style, onClick) {
  const btn = document.createElement("button");
  btn.className = `btn ${style}`;
  btn.textContent = label;
  btn.addEventListener("click", onClick);
  return btn;
}

function openModal(title, text, code, readOnly, buttons) {
  $("modal-title").textContent = title;
  $("modal-text").textContent = text;
  const area = $("modal-code");
  area.value = code;
  area.readOnly = readOnly;
  area.placeholder = readOnly ? "" : "Paste your save code here";
  $("modal-buttons").replaceChildren(...buttons);
  $("modal").classList.remove("hidden");
  readOnly ? area.select() : area.focus();
}

const closeModal = () => $("modal").classList.add("hidden");

function showExport(code) {
  const status = (msg) => { $("modal-text").textContent = msg; };
  openModal(
    "Export save",
    "Keep this code somewhere safe. Paste it into Import save on any browser or device to continue.",
    code, true,
    [
      modalButton("Download file", "primary", () => {
        const link = document.createElement("a");
        link.href = URL.createObjectURL(new Blob([code], { type: "text/plain" }));
        link.download = `endless-ruins-save-${new Date().toISOString().slice(0, 10)}.txt`;
        link.click();
        URL.revokeObjectURL(link.href);
      }),
      modalButton("Copy", "secondary", async () => {
        try {
          await navigator.clipboard.writeText(code);
          status("Copied to your clipboard.");
        } catch {
          $("modal-code").select();
          status("Copying was blocked here. The code is selected: press Ctrl+C (or long-press and copy).");
        }
      }),
      modalButton("Close", "secondary", closeModal),
    ],
  );
}

function showImport() {
  openModal(
    "Import save",
    "Paste a save code, or load a downloaded save file. This replaces your current progress in this browser.",
    "", false,
    [
      modalButton("Import", "primary", () => {
        const code = $("modal-code").value.trim();
        if (!code) return;
        closeModal();
        dispatch("import_save", null, code);
      }),
      modalButton("Load file", "secondary", () => $("modal-file").click()),
      modalButton("Cancel", "secondary", closeModal),
    ],
  );
}

$("modal-file").addEventListener("change", async (e) => {
  const file = e.target.files[0];
  if (file) $("modal-code").value = (await file.text()).trim();
  e.target.value = "";
});

// Minimal, escaped markdown: **bold**, _italic_, `code`, "## heading", "-# small".
function escapeHtml(s) {
  return s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}
function inline(s) {
  return escapeHtml(s)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(\S(?:.*?\S)?)\*/g, "<em>$1</em>")
    .replace(/(^|[\s(])_(.+?)_(?=[\s).,!?:;]|$)/g, "$1<em>$2</em>");
}
function block(text) {
  return text.split("\n").map((line) => {
    if (line.startsWith("## ")) return `<h2>${inline(line.slice(3))}</h2>`;
    if (line.startsWith("-# ")) return `<p class="small">${inline(line.slice(3))}</p>`;
    return `<p>${inline(line)}</p>`;
  }).join("");
}

function meter(label, value, max, cls) {
  const pct = Math.max(0, Math.min(100, (value / max) * 100));
  return `<div class="meter"><label><span>${label}</span><span>${value}/${max}</span></label>
    <div class="bar"><div class="fill ${cls}" style="width:${pct}%"></div></div></div>`;
}

function renderStatus(s, nav) {
  const el = $("status");
  if (!s) { el.classList.add("hidden"); return; }
  el.classList.remove("hidden");
  const cycle = s.cycle > 1 ? ` · Cycle ${s.cycle}` : "";
  el.innerHTML = `
    <h3>${escapeHtml(s.name)}</h3>
    ${s.title ? `<div class="sub">${escapeHtml(s.title)}</div>` : ""}
    <div class="sub">${escapeHtml(s.body)} · Level ${s.level}${cycle}</div>
    ${s.form ? `<div class="sub">Form: ${escapeHtml(s.form)}</div>` : ""}
    ${meter("Defiance", s.defiance, s.max_defiance, "defiance")}
    ${meter("Lust", s.lust, s.lust_max, "lust")}
    <div class="row"><span>Floor</span><span>${s.floor} (deepest ${s.deepest})</span></div>
    <div class="row"><span>Lust Points</span><span>${s.lp}</span></div>
    <div class="row"><span>STR / AGI / RES</span><span>${s.strength} / ${s.agility} / ${s.resistance}</span></div>
    <div class="row"><span>Submission</span><span>${s.submission}</span></div>
    <div class="row"><span>Curses</span><span>${s.curses}</span></div>
    <div class="row"><span>Threat</span><span>${escapeHtml(s.threat)}</span></div>
    ${(s.notes || []).map((n) => `<div class="small">${block(n)}</div>`).join("")}`;

  if (nav?.length) {
    const wrap = document.createElement("div");
    wrap.className = "side-nav";
    nav.forEach((b) => wrap.appendChild(makeButton(b)));
    el.querySelector("h3").after(wrap);
  }
}

function makeButton(b) {
  const btn = document.createElement("button");
  btn.className = `btn ${b.style || "secondary"}`;
  btn.textContent = b.label;
  btn.disabled = !!b.disabled;
  btn.addEventListener("click", () => dispatch(b.action, b.arg));
  return btn;
}

function render(view) {
  $("title").textContent = view.title || "";
  renderStatus(view.status, view.nav);

  const enemy = $("enemy");
  if (view.enemy) {
    enemy.classList.remove("hidden");
    const fill = $("enemy-fill");
    fill.style.width = `${(view.enemy.hp / view.enemy.max_hp) * 100}%`;
    fill.style.background = view.enemy.colour;
  } else {
    enemy.classList.add("hidden");
  }

  const log = $("log");
  log.innerHTML = (view.log || []).map((entry) =>
    entry.kind === "scene" ? `<p class="scene">${inline(entry.text)}</p>` : block(entry.text)
  ).join("");
  log.scrollTop = 0;

  const sections = $("sections");
  sections.innerHTML = "";
  for (const sec of view.sections || []) {
    const div = document.createElement("div");
    div.className = "section";
    div.innerHTML = `<div class="text">${block(sec.text)}</div>`;
    if (sec.actions?.length) {
      const wrap = document.createElement("div");
      sec.actions.forEach((b) => wrap.appendChild(makeButton(b)));
      div.appendChild(wrap);
    }
    sections.appendChild(div);
  }

  const form = $("input-form");
  if (view.input) {
    form.classList.remove("hidden");
    $("input-field").placeholder = view.input.placeholder || "";
    $("input-submit").textContent = view.input.label || "OK";
    form.dataset.action = view.input.action;
    $("input-field").focus();
  } else {
    form.classList.add("hidden");
  }

  const actions = $("actions");
  actions.innerHTML = "";
  for (const row of view.actions || []) {
    const div = document.createElement("div");
    div.className = "row";
    row.forEach((b) => div.appendChild(makeButton(b)));
    actions.appendChild(div);
  }
}

$("input-form").addEventListener("submit", (e) => {
  e.preventDefault();
  dispatch(e.target.dataset.action, null, $("input-field").value);
  $("input-field").value = "";
});

$("gate-yes").addEventListener("click", async () => {
  $("gate").classList.add("hidden");
  $("loading").classList.remove("hidden");
  try {
    await bootRuby();
    $("loading").classList.add("hidden");
    $("app").classList.remove("hidden");
    dispatch("init");
  } catch (e) {
    showError(String(e.stack || e));
  }
});
