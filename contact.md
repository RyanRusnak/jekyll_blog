---
layout: default
title: Contact
permalink: /contact/
description: Get in touch with Ryan Rusnak — interactive proof-of-humanity check.
snake: true
---
<div class="wrap">
  <div class="col col-post contact-page">
    <div class="crumb"><a href="{{ '/' | relative_url }}">~</a><span>/</span><span class="here">contact.md</span></div>
    <h1 class="page-title">Contact</h1>
    
    <div class="prose">
      <p>To keep this inbox free of automated scrapers while staying open to real people, my direct email is sealed behind a quick proof-of-humanity check.</p>
      <p><strong>Objective:</strong> Guide the snake to eat <strong>5 apples</strong> to decrypt and unlock my email address.</p>
    </div>

    <div class="snake-frame">
      <div class="snake-header">
        <div class="snake-title">
          <span class="dot">●</span>
          <span>SNAKE_CAPTCHA // PROOF-OF-HUMANITY</span>
        </div>
        <div class="snake-stats">
          <span class="badge">[ APPLES: <b id="snake-score">0</b>/5 ]</span>
          <span id="snake-status" class="status-locked">LOCKED 🔒</span>
        </div>
      </div>

      <div class="snake-stage">
        <canvas id="snake-canvas" width="400" height="300" aria-label="Snake CAPTCHA game"></canvas>
      </div>

      <div class="snake-controls-bar">
        <div class="snake-hints">
          <span class="dim">Controls:</span>
          <span class="key-hint">W A S D</span> / <span class="key-hint">↑ ← ↓ →</span>
          <span class="dim">·</span>
          <span class="key-hint">SPACE</span> <span class="dim">pause / restart</span>
        </div>
        <div class="snake-dpad">
          <button type="button" id="snake-btn-up" class="dpad-btn dpad-up" aria-label="Move Up">▲</button>
          <div class="dpad-row">
            <button type="button" id="snake-btn-left" class="dpad-btn dpad-left" aria-label="Move Left">◄</button>
            <button type="button" id="snake-btn-down" class="dpad-btn dpad-down" aria-label="Move Down">▼</button>
            <button type="button" id="snake-btn-right" class="dpad-btn dpad-right" aria-label="Move Right">►</button>
          </div>
        </div>
      </div>
    </div>

    <div id="snake-revealed" class="snake-revealed" hidden>
      <div class="revealed-header">
        <span class="ok">✓</span>
        <span>HUMAN VERIFIED — ENCRYPTED PAYLOAD DECRYPTED</span>
      </div>
      <div class="revealed-body">
        <div class="revealed-label">Direct Email:</div>
        <div id="snake-email-slot" class="revealed-email"></div>
        <div class="revealed-actions">
          <button type="button" id="snake-copy-btn" class="btn-primary">Copy Email</button>
          <button type="button" id="snake-replay-btn" class="btn-ghost">Play Again</button>
        </div>
      </div>
    </div>

  </div>
</div>
