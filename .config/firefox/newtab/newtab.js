(function(){
  "use strict";

  /* ---- link data ---- */
  var GROUPS = [
    {cls:"dev",  name:"dev",   links:[
      ["github",        "https://github.com"],
      ["linear",        "https://linear.app"],
    ]},
    {cls:"media", name:"media", links:[
      ["youtube", "https://youtube.com"],
      ["spotify", "https://open.spotify.com"],
      ["netflix", "https://netflix.com"]
    ]},
    {cls:"work",  name:"work",  links:[
      ["gmail",     "https://mail.google.com/mail/u/3/"],
      ["calendar",  "https://calendar.google.com/calendar/u/3/"],
      ["slack",     "https://app.slack.com/client/"]
    ]}
  ];

  /* ---- render grid, number every link ---- */
  var grid = document.getElementById("grid");
  var index = [];               // idx -> <a>
  var n = 0;
  GROUPS.forEach(function(g){
    var sec = document.createElement("section");
    sec.className = "group " + g.cls;
    var h = document.createElement("h2");
    h.innerHTML = g.name + '<span class="tick">'+ g.links.length +'</span>';
    sec.appendChild(h);
    var ul = document.createElement("ul");
    g.links.forEach(function(l){
      var i = n++;
      index[i] = l[1];
      var li = document.createElement("li");
      var a = document.createElement("a");
      a.href = l[1];
      a.dataset.idx = i;
      var pad = (i<10?"0":"") + i;
      a.innerHTML = '<span class="idx">['+pad+']</span><span class="lbl">'+l[0]+'</span>';
      li.appendChild(a); ul.appendChild(li);
    });
    sec.appendChild(ul);
    grid.appendChild(sec);
  });

  /* ---- clock ---- */
  var clock = document.getElementById("clock");
  var dateEl = document.getElementById("datetext");
  var greet = document.getElementById("greet");
  var DAYS = ["sun","mon","tue","wed","thu","fri","sat"];
  var MON  = ["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"];
  function p2(x){return (x<10?"0":"")+x;}
  function tick(){
    var d = new Date();
    var h = d.getHours(), m = d.getMinutes(), s = d.getSeconds();
    clock.innerHTML = p2(h) + '<span class="sep">:</span>' + p2(m) +
                      ' <span class="sec">'+ p2(s) +'</span>';
    dateEl.textContent = DAYS[d.getDay()] + " " + p2(d.getDate()) + " " +
                         MON[d.getMonth()] + " " + d.getFullYear();
    var g = h<5?"good night":h<12?"good morning":h<18?"good afternoon":"good evening";
    greet.innerHTML = g + ", <b>guy</b>";
  }
  tick(); setInterval(tick, 1000);

  /* ---- search ---- */
  var form = document.getElementById("searchwrap");
  var q = document.getElementById("q");
  function looksLikeUrl(t){
    if(/\s/.test(t)) return false;
    if(/^https?:\/\//i.test(t)) return true;
    if(/^localhost(:\d+)?(\/|$)/i.test(t)) return true;
    // bare domain: has a dot, a plausible tld, no spaces
    return /^[a-z0-9][a-z0-9.-]*\.[a-z]{2,}(:\d+)?(\/.*)?$/i.test(t);
  }
  form.addEventListener("submit", function(e){
    e.preventDefault();
    var t = q.value.trim();
    if(!t) return;
    var dest;
    if(looksLikeUrl(t)){
      if(/^https?:\/\//i.test(t)) dest = t;
      else if(/^localhost/i.test(t)) dest = "http://" + t;
      else dest = "https://" + t;
    } else {
      dest = "https://www.google.com/search?q=" + encodeURIComponent(t);
    }
    window.location.href = dest;
  });

  /* ---- keyboard nav (non-conflicting): digits jump when not typing ---- */
  var buf = "", bufTimer = null;
  function clearBuf(){ buf=""; document.querySelectorAll(".group a.kb").forEach(function(a){a.classList.remove("kb");}); }
  document.addEventListener("keydown", function(e){
    var typing = document.activeElement === q;
    // '/' focuses search from anywhere
    if(e.key === "/" && !typing){ e.preventDefault(); q.focus(); q.select(); return; }
    if(e.key === "Escape"){ q.blur(); q.value=""; clearBuf(); return; }
    if(typing) return;                       // never hijack typing in the box
    if(e.altKey||e.ctrlKey||e.metaKey) return;
    if(/^[0-9]$/.test(e.key)){
      buf += e.key;
      clearTimeout(bufTimer);
      var i = parseInt(buf,10);
      // highlight candidate
      document.querySelectorAll(".group a.kb").forEach(function(a){a.classList.remove("kb");});
      var a = grid.querySelector('a[data-idx="'+i+'"]');
      if(a) a.classList.add("kb");
      // if no longer index could extend this buffer, commit now
      var couldExtend = grid.querySelector('a[data-idx^="'+buf+'"]') || index[parseInt(buf+"0",10)]!==undefined;
      if(index[i]!==undefined && !couldExtend){ window.location.href = index[i]; return; }
      bufTimer = setTimeout(function(){
        if(index[i]!==undefined) window.location.href = index[i];
        else clearBuf();
      }, 380);
    }
  });

  /* keep focus on the search box */
})();
