/* Client-side search over /search.json */
(function () {
  var input = document.getElementById("q");
  var out = document.getElementById("results");
  var count = document.getElementById("count");
  var posts = [];
  var sel = -1;

  fetch("/search.json")
    .then(function (r) { return r.json(); })
    .then(function (data) { posts = data; run(param("q") || ""); });

  function param(k) {
    var m = new RegExp("[?&]" + k + "=([^&]*)").exec(location.search);
    return m ? decodeURIComponent(m[1].replace(/\+/g, " ")) : "";
  }

  function run(q) {
    q = (q || "").trim().toLowerCase();
    var hits = q
      ? posts.filter(function (p) {
          return (p.title + " " + p.blurb + " " + p.tags + " " + p.kind + " " + p.body).toLowerCase().indexOf(q) > -1;
        })
      : posts;
    count.textContent = hits.length + (hits.length === 1 ? " match" : " matches");
    out.innerHTML = hits.map(function (p) {
      return '<a class="result" href="' + p.url + '">' +
        '<span class="r-date">' + p.date + "</span><span>" +
        '<span class="r-title">' + p.title + "</span>" +
        '<span class="r-blurb">' + p.blurb + "</span>" +
        '<span class="r-meta">' + p.kind + (p.tags ? " · #" + p.tags.split(" ").join(" #") : "") + "</span>" +
        "</span></a>";
    }).join("");
    sel = -1;
  }

  if (input) {
    input.value = param("q");
    input.addEventListener("input", function () { run(input.value); });
    input.addEventListener("keydown", function (e) {
      var rows = out.querySelectorAll(".result");
      if (e.key === "ArrowDown" || e.key === "ArrowUp") {
        e.preventDefault();
        if (!rows.length) return;
        if (sel > -1) rows[sel].classList.remove("is-sel");
        sel = e.key === "ArrowDown" ? Math.min(sel + 1, rows.length - 1) : Math.max(sel - 1, 0);
        rows[sel].classList.add("is-sel");
      } else if (e.key === "Enter" && sel > -1) {
        location.href = rows[sel].getAttribute("href");
      } else if (e.key === "Escape") {
        input.value = ""; run("");
      }
    });
  }
})();
