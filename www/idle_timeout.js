// Disconnects a tab nobody has used for a while, so a forgotten tab does not
// keep the app running (and using hosting hours). The limit comes from
// IDLE_TIMEOUT_MINUTES in R/constants.R, through <meta name="idle-timeout-minutes">.
(function () {
  var meta = document.querySelector('meta[name="idle-timeout-minutes"]');
  var minutes = meta ? parseFloat(meta.content) : NaN;
  if (!(minutes > 0)) return;

  var limit = minutes * 60 * 1000;
  var last = Date.now();
  var done = false;
  ["mousemove", "mousedown", "keydown", "wheel", "scroll", "touchstart"].forEach(function (ev) {
    window.addEventListener(ev, function () { last = Date.now(); }, { passive: true, capture: true });
  });

  function showNotice() {
    var box = document.createElement("div");
    box.id = "idle-timeout-notice";
    box.setAttribute("role", "alertdialog");
    box.style.cssText = "position:fixed; inset:0; z-index:100000; display:flex; align-items:center; " +
      "justify-content:center; background:rgba(15,23,42,0.55);";
    box.innerHTML =
      '<div style="background:#fff; border-radius:10px; padding:24px 28px; max-width:420px; ' +
      'text-align:center; box-shadow:0 10px 30px rgba(0,0,0,0.25);">' +
      '<div style="font-size:2rem;">⏸️</div>' +
      '<h5 style="color:#1e3a5f; font-weight:700; margin:8px 0;">La sesión se pausó por inactividad</h5>' +
      '<p style="color:#475569; margin:0 0 16px;">Pasaron ' + minutes + ' minutos sin uso. ' +
      'Recargá la página para seguir explorando.</p>' +
      '<button class="btn btn-primary" onclick="location.reload()">Recargar</button></div>';
    document.body.appendChild(box);
  }

  // Checked every 15 seconds against the clock, so it also works when the
  // browser slows down timers in a background tab
  setInterval(function () {
    if (done || Date.now() - last < limit) return;
    if (!window.Shiny || !Shiny.setInputValue) return;
    done = true;
    showNotice();
    Shiny.setInputValue("idle_timeout", true, { priority: "event" });
  }, 15000);
})();
