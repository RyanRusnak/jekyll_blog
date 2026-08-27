/* =============================================================
   snake.js — Retro Monospace Snake CAPTCHA for ryanrusnak.com
   Proves humanity by collecting 5 apples to decrypt email.
   ============================================================= */

(function () {
  var ENCRYPTED_HEX = "213b322524341029362a6b27302c";
  var KEY = "SNAKE_PASSED_AUTHENTICATED_HUMAN_2026";
  var TARGET_SCORE = 5;

  var canvas = document.getElementById("snake-canvas");
  if (!canvas) return;

  var ctx = canvas.getContext("2d");
  var scoreEl = document.getElementById("snake-score");
  var statusEl = document.getElementById("snake-status");
  var revealedBox = document.getElementById("snake-revealed");
  var emailSlot = document.getElementById("snake-email-slot");
  var copyBtn = document.getElementById("snake-copy-btn");
  var replayBtn = document.getElementById("snake-replay-btn");

  var COLS = 20;
  var ROWS = 15;
  var CELL = 20; // 400x300 logical resolution

  var state = "IDLE"; // IDLE, PLAYING, GAMEOVER, VICTORY
  var snake = [];
  var dir = { x: 1, y: 0 };
  var nextDir = { x: 1, y: 0 };
  var apple = { x: 0, y: 0 };
  var score = 0;
  var lastTick = 0;
  var tickSpeed = 125; // ms per move
  var particles = [];
  var animFrameId = null;

  function decryptPayload(hexStr, keyStr) {
    var bytes = [];
    for (var i = 0; i < hexStr.length; i += 2) {
      bytes.push(parseInt(hexStr.substr(i, 2), 16));
    }
    var out = "";
    for (var j = 0; j < bytes.length; j++) {
      out += String.fromCharCode(bytes[j] ^ keyStr.charCodeAt(j % keyStr.length));
    }
    return out;
  }

  function getTheme() {
    var s = getComputedStyle(document.documentElement);
    return {
      bg: s.getPropertyValue("--panel").trim() || "#282828",
      raised: s.getPropertyValue("--raised").trim() || "#32302f",
      line: s.getPropertyValue("--line").trim() || "#3c3836",
      line2: s.getPropertyValue("--line2").trim() || "#504945",
      fg: s.getPropertyValue("--fg").trim() || "#ebdbb2",
      dim: s.getPropertyValue("--dim").trim() || "#a89984",
      faint: s.getPropertyValue("--faint").trim() || "#7c6f64",
      accent: s.getPropertyValue("--accent").trim() || "#fabd2f",
      accent2: s.getPropertyValue("--accent2").trim() || "#fe8019",
      red: s.getPropertyValue("--red").trim() || "#fb4934",
      green: s.getPropertyValue("--green").trim() || "#b8bb26",
      blue: s.getPropertyValue("--blue").trim() || "#83a598"
    };
  }

  function resetGame() {
    snake = [
      { x: 5, y: 7 },
      { x: 4, y: 7 },
      { x: 3, y: 7 }
    ];
    dir = { x: 1, y: 0 };
    nextDir = { x: 1, y: 0 };
    score = 0;
    particles = [];
    spawnApple();
    updateUI();
  }

  function spawnApple() {
    var empty = [];
    for (var r = 0; r < ROWS; r++) {
      for (var c = 0; c < COLS; c++) {
        var onSnake = snake.some(function (seg) { return seg.x === c && seg.y === r; });
        if (!onSnake) empty.push({ x: c, y: r });
      }
    }
    if (empty.length > 0) {
      apple = empty[Math.floor(Math.random() * empty.length)];
    }
  }

  function addParticles(x, y, color) {
    for (var i = 0; i < 14; i++) {
      var angle = Math.random() * Math.PI * 2;
      var speed = 1 + Math.random() * 3;
      particles.push({
        x: x * CELL + CELL / 2,
        y: y * CELL + CELL / 2,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 1.0,
        color: color
      });
    }
  }

  function updateUI() {
    if (scoreEl) scoreEl.textContent = score;
    if (statusEl) {
      if (state === "VICTORY") {
        statusEl.className = "status-unlocked";
        statusEl.textContent = "VERIFIED ✓";
      } else if (state === "GAMEOVER") {
        statusEl.className = "status-error";
        statusEl.textContent = "CRASHED ✕";
      } else if (state === "PLAYING") {
        statusEl.className = "status-active";
        statusEl.textContent = "PLAYING...";
      } else {
        statusEl.className = "status-locked";
        statusEl.textContent = "LOCKED 🔒";
      }
    }
  }

  function onVictory() {
    state = "VICTORY";
    updateUI();
    var email = decryptPayload(ENCRYPTED_HEX, KEY);
    
    if (emailSlot) {
      emailSlot.innerHTML = '<a href="mailto:' + email + '" class="revealed-email-link">' + email + '</a>';
    }
    if (revealedBox) {
      revealedBox.hidden = false;
      revealedBox.classList.add("is-visible");
      revealedBox.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }

    try {
      sessionStorage.setItem("ryan_snake_verified", "true");
    } catch (e) {}

    addParticles(apple.x, apple.y, getTheme().accent);
  }

  function handleGameOver() {
    state = "GAMEOVER";
    updateUI();
  }

  function step() {
    dir = { x: nextDir.x, y: nextDir.y };
    var head = { x: snake[0].x + dir.x, y: snake[0].y + dir.y };

    // Wall collision check
    if (head.x < 0 || head.x >= COLS || head.y < 0 || head.y >= ROWS) {
      handleGameOver();
      return;
    }

    // Self collision check
    for (var i = 0; i < snake.length; i++) {
      if (snake[i].x === head.x && snake[i].y === head.y) {
        handleGameOver();
        return;
      }
    }

    snake.unshift(head);

    // Apple eaten?
    if (head.x === apple.x && head.y === apple.y) {
      score++;
      var th = getTheme();
      addParticles(apple.x, apple.y, th.accent);
      updateUI();

      if (score >= TARGET_SCORE) {
        onVictory();
        return;
      } else {
        spawnApple();
      }
    } else {
      snake.pop();
    }
  }

  function draw() {
    var th = getTheme();
    ctx.fillStyle = th.bg;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Subtle grid lines
    ctx.strokeStyle = th.line;
    ctx.lineWidth = 0.5;
    for (var c = 0; c <= COLS; c++) {
      ctx.beginPath();
      ctx.moveTo(c * CELL, 0);
      ctx.lineTo(c * CELL, ROWS * CELL);
      ctx.stroke();
    }
    for (var r = 0; r <= ROWS; r++) {
      ctx.beginPath();
      ctx.moveTo(0, r * CELL);
      ctx.lineTo(COLS * CELL, r * CELL);
      ctx.stroke();
    }

    // Draw apple
    var ax = apple.x * CELL;
    var ay = apple.y * CELL;
    var time = Date.now() / 250;
    var pulse = Math.sin(time) * 1.5;

    ctx.fillStyle = th.red;
    ctx.beginPath();
    ctx.arc(ax + CELL / 2, ay + CELL / 2, Math.max(3, CELL / 2.5 + pulse), 0, Math.PI * 2);
    ctx.fill();

    // Apple stem / leaf
    ctx.fillStyle = th.green;
    ctx.fillRect(ax + CELL / 2 - 1, ay + 2, 2, 4);

    // Draw snake body
    for (var i = snake.length - 1; i >= 0; i--) {
      var seg = snake[i];
      var sx = seg.x * CELL;
      var sy = seg.y * CELL;

      if (i === 0) {
        // Head
        ctx.fillStyle = th.accent;
        ctx.fillRect(sx + 1, sy + 1, CELL - 2, CELL - 2);

        // Eyes
        ctx.fillStyle = th.bg;
        var eyeOffset1 = 4;
        var eyeOffset2 = 12;
        var eyeSize = 3;

        if (dir.x === 1) { // Right
          ctx.fillRect(sx + 13, sy + eyeOffset1, eyeSize, eyeSize);
          ctx.fillRect(sx + 13, sy + eyeOffset2, eyeSize, eyeSize);
        } else if (dir.x === -1) { // Left
          ctx.fillRect(sx + 4, sy + eyeOffset1, eyeSize, eyeSize);
          ctx.fillRect(sx + 4, sy + eyeOffset2, eyeSize, eyeSize);
        } else if (dir.y === -1) { // Up
          ctx.fillRect(sx + eyeOffset1, sy + 4, eyeSize, eyeSize);
          ctx.fillRect(sx + eyeOffset2, sy + 4, eyeSize, eyeSize);
        } else { // Down
          ctx.fillRect(sx + eyeOffset1, sy + 13, eyeSize, eyeSize);
          ctx.fillRect(sx + eyeOffset2, sy + 13, eyeSize, eyeSize);
        }
      } else {
        // Body
        ctx.fillStyle = th.green;
        ctx.fillRect(sx + 2, sy + 2, CELL - 4, CELL - 4);
      }
    }

    // Draw particles
    for (var p = particles.length - 1; p >= 0; p--) {
      var pt = particles[p];
      pt.x += pt.vx;
      pt.y += pt.vy;
      pt.life -= 0.04;
      if (pt.life <= 0) {
        particles.splice(p, 1);
        continue;
      }
      ctx.fillStyle = pt.color;
      ctx.globalAlpha = Math.max(0, pt.life);
      ctx.fillRect(pt.x, pt.y, 3, 3);
    }
    ctx.globalAlpha = 1.0;

    // Overlays
    if (state === "IDLE") {
      drawBanner(th, "SNAKE PROOF-OF-WORK", "PRESS SPACE, ARROW, OR TAP TO PLAY", th.accent);
    } else if (state === "GAMEOVER") {
      drawBanner(th, "COLLISION DETECTED", "TAP OR PRESS SPACE TO RETRY", th.red);
    } else if (state === "VICTORY") {
      drawBanner(th, "HUMAN PROVEN! [5/5]", "EMAIL DECRYPTED BELOW ↓", th.accent);
    }
  }

  function drawBanner(th, title, subtitle, titleColor) {
    ctx.fillStyle = "rgba(0, 0, 0, 0.75)";
    ctx.fillRect(20, 95, canvas.width - 40, 110);
    ctx.strokeStyle = th.line2;
    ctx.lineWidth = 1;
    ctx.strokeRect(20, 95, canvas.width - 40, 110);

    ctx.textAlign = "center";
    ctx.font = "bold 15px 'JetBrains Mono', monospace";
    ctx.fillStyle = titleColor;
    ctx.fillText(title, canvas.width / 2, 138);

    ctx.font = "12px 'JetBrains Mono', monospace";
    ctx.fillStyle = th.fg;
    ctx.fillText(subtitle, canvas.width / 2, 172);
  }

  function loop(now) {
    if (state === "PLAYING") {
      if (now - lastTick > tickSpeed) {
        step();
        lastTick = now;
      }
    }
    draw();
    animFrameId = requestAnimationFrame(loop);
  }

  function setDirection(dx, dy) {
    if (state === "IDLE" || state === "GAMEOVER") {
      resetGame();
      state = "PLAYING";
      lastTick = performance.now();
      updateUI();
      return;
    }
    if (state === "VICTORY") {
      return;
    }
    // Prevent 180° instant turn into self
    if (dx !== 0 && dir.x === -dx) return;
    if (dy !== 0 && dir.y === -dy) return;
    nextDir = { x: dx, y: dy };
  }

  // Keyboard navigation
  window.addEventListener("keydown", function (e) {
    // Only capture if not typing in an input
    if (/^(INPUT|TEXTAREA)$/.test(e.target.tagName || "")) return;

    switch (e.key) {
      case "ArrowUp":
      case "w":
      case "W":
        e.preventDefault();
        setDirection(0, -1);
        break;
      case "ArrowDown":
      case "s":
      case "S":
        e.preventDefault();
        setDirection(0, 1);
        break;
      case "ArrowLeft":
      case "a":
      case "A":
        e.preventDefault();
        setDirection(-1, 0);
        break;
      case "ArrowRight":
      case "d":
      case "D":
        e.preventDefault();
        setDirection(1, 0);
        break;
      case " ":
        e.preventDefault();
        if (state === "IDLE" || state === "GAMEOVER") {
          resetGame();
          state = "PLAYING";
          lastTick = performance.now();
          updateUI();
        } else if (state === "PLAYING") {
          state = "IDLE";
          updateUI();
        }
        break;
    }
  });

  // Canvas click / tap
  canvas.addEventListener("click", function () {
    if (state === "IDLE" || state === "GAMEOVER") {
      resetGame();
      state = "PLAYING";
      lastTick = performance.now();
      updateUI();
    }
  });

  // Touch swipe support on canvas
  var touchStartX = 0;
  var touchStartY = 0;
  canvas.addEventListener("touchstart", function (e) {
    if (e.touches && e.touches[0]) {
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
    }
  }, { passive: true });

  canvas.addEventListener("touchend", function (e) {
    if (!e.changedTouches || !e.changedTouches[0]) return;
    var dx = e.changedTouches[0].clientX - touchStartX;
    var dy = e.changedTouches[0].clientY - touchStartY;
    var absX = Math.abs(dx);
    var absY = Math.abs(dy);

    if (Math.max(absX, absY) < 18) {
      // Tap
      if (state === "IDLE" || state === "GAMEOVER") {
        resetGame();
        state = "PLAYING";
        lastTick = performance.now();
        updateUI();
      }
      return;
    }

    if (absX > absY) {
      setDirection(dx > 0 ? 1 : -1, 0);
    } else {
      setDirection(0, dy > 0 ? 1 : -1);
    }
  }, { passive: true });

  // On-screen D-Pad buttons
  function bindDpad(id, dx, dy) {
    var btn = document.getElementById(id);
    if (!btn) return;
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      setDirection(dx, dy);
    });
  }
  bindDpad("snake-btn-up", 0, -1);
  bindDpad("snake-btn-down", 0, 1);
  bindDpad("snake-btn-left", -1, 0);
  bindDpad("snake-btn-right", 1, 0);

  // Copy email button
  if (copyBtn) {
    copyBtn.addEventListener("click", function () {
      var email = decryptPayload(ENCRYPTED_HEX, KEY);
      navigator.clipboard.writeText(email).then(function () {
        var origText = copyBtn.textContent;
        copyBtn.textContent = "✓ Copied!";
        copyBtn.classList.add("is-copied");
        setTimeout(function () {
          copyBtn.textContent = origText;
          copyBtn.classList.remove("is-copied");
        }, 2000);
      }).catch(function () {
        // Fallback prompt if clipboard API blocked
        prompt("Email address:", email);
      });
    });
  }

  // Replay button
  if (replayBtn) {
    replayBtn.addEventListener("click", function () {
      resetGame();
      state = "PLAYING";
      lastTick = performance.now();
      updateUI();
    });
  }

  // Check if session was already verified
  try {
    if (sessionStorage.getItem("ryan_snake_verified") === "true") {
      var email = decryptPayload(ENCRYPTED_HEX, KEY);
      if (emailSlot) {
        emailSlot.innerHTML = '<a href="mailto:' + email + '" class="revealed-email-link">' + email + '</a>';
      }
      if (revealedBox) {
        revealedBox.hidden = false;
        revealedBox.classList.add("is-visible");
      }
      state = "VICTORY";
      score = TARGET_SCORE;
      updateUI();
    }
  } catch (e) {}

  resetGame();
  loop(0);
})();
