---
layout: default
title: Search
permalink: /search/
search: true
---
<div class="wrap">
  <div class="col col-post search-page">
    <div class="search-field">
      <span class="slash">/</span>
      <input id="q" type="search" autocomplete="off" autofocus placeholder="search {{ site.posts | size }} posts">
      <span class="key">esc</span>
    </div>
    <div class="search-status"><span id="count">{{ site.posts | size }} matches</span><span class="dim">↑↓ to move · ⏎ to open</span></div>
    <div id="results"></div>
  </div>
</div>
