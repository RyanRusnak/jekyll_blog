/* Omarchy theme switcher — click the header button or press T. */
(function () {
  var THEMES = [
    {
      "id": "gruvbox",
      "name": "Gruvbox",
      "sw": [
        "#fabd2f",
        "#fe8019",
        "#b8bb26",
        "#282828"
      ]
    },
    {
      "id": "tokyo-night",
      "name": "Tokyo Night",
      "sw": [
        "#7aa2f7",
        "#ff9e64",
        "#9ece6a",
        "#1a1b26"
      ]
    },
    {
      "id": "catppuccin",
      "name": "Catppuccin",
      "sw": [
        "#cba6f7",
        "#fab387",
        "#a6e3a1",
        "#1e1e2e"
      ]
    },
    {
      "id": "catppuccin-latte",
      "name": "Catppuccin Latte",
      "sw": [
        "#8839ef",
        "#fe640b",
        "#40a02b",
        "#eff1f5"
      ]
    },
    {
      "id": "everforest",
      "name": "Everforest",
      "sw": [
        "#a7c080",
        "#e69875",
        "#a7c080",
        "#2d353b"
      ]
    },
    {
      "id": "nord",
      "name": "Nord",
      "sw": [
        "#88c0d0",
        "#d08770",
        "#a3be8c",
        "#2e3440"
      ]
    },
    {
      "id": "rose-pine",
      "name": "Rose Pine",
      "sw": [
        "#c4a7e7",
        "#f6c177",
        "#9ccfd8",
        "#191724"
      ]
    },
    {
      "id": "kanagawa",
      "name": "Kanagawa",
      "sw": [
        "#ffa066",
        "#7e9cd8",
        "#98bb6c",
        "#1f1f28"
      ]
    },
    {
      "id": "matte-black",
      "name": "Matte Black",
      "sw": [
        "#cfcfcf",
        "#8a8a8a",
        "#8f9f7a",
        "#0f0f0f"
      ]
    },
    {
      "id": "osaka-jade",
      "name": "Osaka Jade",
      "sw": [
        "#54b39a",
        "#e0a458",
        "#7ecb9a",
        "#111c18"
      ]
    },
    {
      "id": "ristretto",
      "name": "Ristretto",
      "sw": [
        "#f9cc6c",
        "#f38d70",
        "#adda78",
        "#2c2525"
      ]
    }
  ];

  var root = document.documentElement;
  var palette = document.getElementById("palette");
  var list = document.getElementById("palette-list");
  var btn = document.getElementById("theme-btn");
  var label = document.getElementById("theme-name");
  var statusLabel = document.getElementById("status-theme");
  var current = root.getAttribute("data-theme") || "gruvbox";

  function apply(id) {
    current = id;
    root.setAttribute("data-theme", id);
    try { localStorage.setItem("omarchy-theme", id); } catch (e) {}
    var t = THEMES.filter(function (x) { return x.id === id; })[0];
    var name = t ? t.name.toLowerCase() : id;
    if (label) label.textContent = name;
    if (statusLabel) statusLabel.textContent = name;
    render();
  }

  function render() {
    if (!list) return;
    list.innerHTML = "";
    THEMES.forEach(function (t) {
      var row = document.createElement("div");
      row.className = "palette-item" + (t.id === current ? " is-current" : "");
      row.innerHTML =
        '<span class="sw">' + t.sw.map(function (c) { return '<i style="background:' + c + '"></i>'; }).join("") + "</span>" +
        '<span class="nm">' + t.name + "</span>" +
        '<span class="mk">' + (t.id === current ? "active" : "") + "</span>";
      row.addEventListener("click", function () { apply(t.id); close(); });
      list.appendChild(row);
    });
  }

  function open() { if (palette) { palette.hidden = false; render(); } }
  function close() { if (palette) palette.hidden = true; }

  if (btn) btn.addEventListener("click", function () { palette.hidden ? open() : close(); });
  if (palette) palette.addEventListener("click", function (e) { if (e.target === palette) close(); });

  document.addEventListener("keydown", function (e) {
    var typing = /^(INPUT|TEXTAREA)$/.test(e.target.tagName || "");
    if (e.key === "Escape") close();
    else if (!typing && (e.key === "t" || e.key === "T")) { palette.hidden ? open() : close(); }
  });

  apply(current);
})();
