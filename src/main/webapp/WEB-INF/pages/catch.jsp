<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Catch Pokémon</title>
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/catch.css">
</head>
<body>

  <%-- Topbar --%>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span style="color:var(--white);font-weight:800;"><c:out value="${sessionScope.loggedInUser.username}"/></span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"   class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/quests" class="nav-btn">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"  class="nav-btn active">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"  class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster" class="nav-btn">PACKS</a>
      
    </nav>
    <div class="topbar-right">
      <c:if test="${sessionScope.loggedInUser.loginStreak > 0}">
        <span class="streak-badge">🔥 <c:out value="${sessionScope.loggedInUser.loginStreak}"/></span>
      </c:if>
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"    class="sidebar-tab">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab active">CATCH</a>
            <a href="${pageContext.request.contextPath}/anime"
         class="sidebar-tab" data-path="anime">ANIME</a>
    </nav>

    <main class="main-content">
      <div class="section-header">           
       <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/catch.png"
            alt="📦" style="width:60px;height:40px;margin-bottom:10px;">

            <span style= "margin-right:1520px">Wild Pokémon Encounter</span>

        <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/chibi4.png"
            alt="📦" style="width:49px;height:40px;margin-bottom:10px;"></div>
      <div class="arena-wrap">
        <div class="arena">

          <%-- CATCH SCENE--%>
          <div class="arena-scene" id="arena-scene">

            <%-- Wild Pokémon --%>
            <div class="wild-display">

              <%-- HP bar (aesthetic) --%>
              <div class="wild-hp">
                <div style="display:flex;justify-content:space-between;">
                  <span><c:choose><c:when test="${not empty wildPokemon}"><c:out value="${wildPokemon.name}"/></c:when><c:otherwise>???</c:otherwise></c:choose></span>
                  <span style="color:var(--green);">HP</span>
                </div>
                <div class="hp-bar">
                  <div class="hp-fill" id="hp-fill"
                       style="width:${catchState eq 'caught' ? 0 : (catchState eq 'failed' ? 100 : 100)}%">
                  </div>
                </div>
              </div>

              <%-- Pokémon circle with PokeAPI sprite --%>
              <div class="wild-circle <c:if test='${empty catchState or catchState eq "idle"}'>appearing</c:if>
                                      <c:if test='${caught eq true}'>caught-anim</c:if>"
                   id="wild-circle">
                <c:choose>
                  <%-- Use PokeAPI official artwork if pokedexNumber > 0 --%>
                  <c:when test="${not empty wildPokemon and wildPokemon.pokedexNumber > 0}">
                    <img class="wild-sprite"
                         src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${wildPokemon.pokedexNumber}.png"
                         alt="<c:out value='${wildPokemon.name}'/>"
                         onerror="this.style.display='none';document.getElementById('wild-fallback').style.display='block';">
                    <span class="wild-emoji" id="wild-fallback" style="display:none;">
                      <c:choose>
                        <c:when test="${wildPokemon.type eq 'Fire'}">🔥</c:when>
                        <c:when test="${wildPokemon.type eq 'Water'}">🌊</c:when>
                        <c:when test="${wildPokemon.type eq 'Electric'}">⚡</c:when>
                        <c:when test="${wildPokemon.type eq 'Psychic'}">🔮</c:when>
                        <c:when test="${wildPokemon.type eq 'Grass'}">🌿</c:when>
                        <c:when test="${wildPokemon.type eq 'Dragon'}">🐉</c:when>
                        <c:when test="${wildPokemon.type eq 'Ghost'}">👻</c:when>
                        <c:otherwise>🃏</c:otherwise>
                      </c:choose>
                    </span>
                  </c:when>
                  <%-- No pokedexNumber — emoji fallback --%>
                  <c:when test="${not empty wildPokemon}">
                    <span class="wild-emoji">
                      <c:choose>
                        <c:when test="${wildPokemon.type eq 'Fire'}">🔥</c:when>
                        <c:when test="${wildPokemon.type eq 'Water'}">🌊</c:when>
                        <c:when test="${wildPokemon.type eq 'Electric'}">⚡</c:when>
                        <c:when test="${wildPokemon.type eq 'Psychic'}">🔮</c:when>
                        <c:when test="${wildPokemon.type eq 'Grass'}">🌿</c:when>
                        <c:when test="${wildPokemon.type eq 'Dragon'}">🐉</c:when>
                        <c:when test="${wildPokemon.type eq 'Ghost'}">👻</c:when>
                        <c:otherwise>🃏</c:otherwise>
                      </c:choose>
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="wild-emoji">❓</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <%-- Pokémon name + rarity --%>
              <div class="wild-name">
                <c:choose>
                  <c:when test="${not empty wildPokemon}"><c:out value="${wildPokemon.name}"/></c:when>
                  <c:otherwise>???</c:otherwise>
                </c:choose>
              </div>
              <c:if test="${not empty wildPokemon}">
                <div class="wild-rarity"
                     style="color:<c:choose>
                       <c:when test="${wildPokemon.rarity eq 'Legendary'}">var(--gold)</c:when>
                       <c:when test="${wildPokemon.rarity eq 'Epic'}">var(--purple,#b06ef5)</c:when>
                       <c:when test="${wildPokemon.rarity eq 'Rare'}">var(--blue)</c:when>
                       <c:otherwise>var(--green)</c:otherwise>
                     </c:choose>">
                  <c:out value="${wildPokemon.rarity}"/>
                </div>
              </c:if>

              <%-- Shake indicators — shown after throw --%>
              <c:if test="${not empty shake1}">
                <div class="shake-indicators">
                  <div class="shake-dot ${shake1 ? 'pass' : 'fail'}" id="s1"></div>
                  <div class="shake-dot ${shake2 ? 'pass' : 'fail'}" id="s2"></div>
                  <div class="shake-dot ${shake3 ? 'pass' : 'fail'}" id="s3"></div>
                </div>
              </c:if>
              <c:if test="${empty shake1 and not empty wildPokemon}">
                <div class="shake-indicators">
                  <div class="shake-dot" id="s1"></div>
                  <div class="shake-dot" id="s2"></div>
                  <div class="shake-dot" id="s3"></div>
                </div>
              </c:if>

            </div><%-- /wild-display --%>

            <%-- Throw zone --%>
            <div class="throw-zone">
              <div class="throw-hint" id="throw-hint">
                <c:choose>
                  <c:when test="${caught eq true}">🎉 Gotcha!</c:when>
                  <c:when test="${caught eq false}">💨 It broke free!</c:when>
                  <c:when test="${not empty wildPokemon}">Tap to throw!</c:when>
                  <c:otherwise>Encounter a Pokémon first</c:otherwise>
                </c:choose>
              </div>

              <%-- Hidden form — submitted when ball is thrown --%>
              <form id="catch-form" method="post"
                    action="${pageContext.request.contextPath}/catch"
                    style="display:inline;">
                <input type="hidden" name="cardId"
                       value="${not empty wildPokemon ? wildPokemon.cardId : ''}">
              </form>

              <%-- Pokéball button --%>
              <div class="pokeball" id="pokeball"
                   onclick="throwPokeball()"
                   data-can-throw="${not empty wildPokemon and empty caught}"
                   title="Throw Pokéball!">
              </div>

              <%-- Result display (visible immediately if server returned result) --%>
              <c:if test="${caught eq true}">
                <div class="catch-result success" id="catch-result">
                  ★ <c:out value="${wildPokemon.name}"/> was caught!
                </div>
              </c:if>
              <c:if test="${caught eq false}">
                <div class="catch-result fail" id="catch-result">
                  <c:out value="${wildPokemon.name}"/> broke free!
                </div>
              </c:if>
              <c:if test="${empty caught}">
                <div class="catch-result" id="catch-result"></div>
              </c:if>

            </div><%-- /throw-zone --%>
          </div><%-- /arena-scene --%>

          <%-- Controls --%>
          <div class="arena-controls">
            <a href="${pageContext.request.contextPath}/catch"
               class="btn-red" id="encounter-btn">
              New Encounter
            </a>
            <span class="catch-hint">
              <c:if test="${not empty wildPokemon}">
                Catch rate:
                <strong style="color:var(--white);">
                  <c:out value="${wildPokemon.catchRate}"/>/255
                </strong>
                &nbsp;·&nbsp;
                <c:out value="${wildPokemon.rarity}"/> Pokémon
                <c:if test="${wildPokemon.pokedexNumber > 0}">
                  &nbsp;·&nbsp;
                  <a href="${pageContext.request.contextPath}/pokedex?name=${wildPokemon.name.toLowerCase()}"
                     style="color:var(--blue);font-weight:700;">
                    View Pokédex Entry
                  </a>
                </c:if>
              </c:if>
            </span>
            <span style="margin-left:auto;font-size:11px;color:var(--text-dim);">
              Pokéballs: <strong style="color:var(--white);">∞</strong>
            </span>
          </div>
        </div><%-- /arena --%>

        <%-- Catch rate guide --%>
        <div class="rate-guide">
          <div class="rate-guide-title">Catch Rate Guide</div>
          <div class="rate-grid">
            <div class="rate-cell">
              <span class="rate-badge r-com">Common</span>
              <div class="rate-pct" style="color:#78c87a;">~78%</div>
              <div class="rate-desc">Catch rate 150-200</div>
            </div>
            <div class="rate-cell">
              <span class="rate-badge r-rare">Rare</span>
              <div class="rate-pct" style="color:#4fc3f7;">~31%</div>
              <div class="rate-desc">Catch rate ~80</div>
            </div>
            <div class="rate-cell">
              <span class="rate-badge r-epic">Epic</span>
              <div class="rate-pct" style="color:#b06ef5;">~12%</div>
              <div class="rate-desc">Catch rate ~45</div>
            </div>
            <div class="rate-cell">
              <span class="rate-badge r-leg">Legendary</span>
              <div class="rate-pct" style="color:var(--gold);">~2%</div>
              <div class="rate-desc">Catch rate 3-5</div>
            </div>
          </div>
        </div>
      </div><%-- /arena-wrap --%>

    </main>
  </div>

  <div class="chatbar">
    <span style="font-size:15px;"> </span>
    <span class="chatbar-label">Catch Mode Active</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span id="clk">--:--</span></span>
    </div>
  </div>

 <script>
    // Clock
    function tick(){const n=new Date();document.getElementById('clk').textContent=String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0');}
    tick();setInterval(tick,30000);

    // Server result flags from JSTL
    // Changed to 'let' so we can update them with real server data
    let SERVER_CAUGHT = false; 
    let CAN_THROW = ${not empty wildPokemon and empty caught ? 'true' : 'false'};
    const POKE_NAME = "${not empty wildPokemon ? wildPokemon.name : ''}";

    //Shake dot animation helper
    function animateDot(dotId, pass, delay) {
      setTimeout(() => {
        const dot = document.getElementById(dotId);
        if (!dot) return;
        dot.className = 'shake-dot ' + (pass ? 'pass' : 'fail');
      }, delay);
    }

    // Main throw function
    let throwing = false;
    
    // Made the function async to handle the background form submission
    async function throwPokeball() {
      if (!CAN_THROW || throwing) return;
      throwing = true;
      CAN_THROW = false; // Prevent double-clicks

      const ball   = document.getElementById('pokeball');
      const hint   = document.getElementById('throw-hint');
      const form   = document.getElementById('catch-form');

      // 1. Submit form in the background to CatchServlet!
      let s1Pass = false, s2Pass = false, s3Pass = false;

      try {
          const response = await fetch(form.action, {
              method: 'POST',
              body: new URLSearchParams(new FormData(form)),
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
          });
          
          // Parse the HTML returned by the server
          const htmlText = await response.text();
          const doc = new DOMParser().parseFromString(htmlText, 'text/html');

          // Extract the REAL results generated by CatchServlet's math
          const resDiv = doc.getElementById('catch-result');
          SERVER_CAUGHT = resDiv && resDiv.classList.contains('success');

          const s1 = doc.getElementById('s1');
          const s2 = doc.getElementById('s2');
          const s3 = doc.getElementById('s3');

          s1Pass = s1 && s1.classList.contains('pass');
          s2Pass = s2 && s2.classList.contains('pass');
          s3Pass = s3 && s3.classList.contains('pass');

      } catch (err) {
          console.error("Catch request failed", err);
          SERVER_CAUGHT = false; // Default to fail if network error
      }

      // 2. Play the Throw Arc Animation
      hint.textContent = 'Throwing...';
      ball.classList.add('throwing');

      // 3. After ball reaches Pokémon — start shakes using the REAL server data
      setTimeout(() => {
        ball.classList.remove('throwing');
        ball.style.position = 'relative';
        ball.style.opacity  = '1';
        hint.textContent = 'Shake 1...';

        ball.classList.add('shaking');
        setTimeout(() => {
          ball.classList.remove('shaking');
          animateDot('s1', s1Pass, 0); // Real data applied here
          hint.textContent = 'Shake 2...';

          setTimeout(() => {
            ball.classList.add('shaking');
            setTimeout(() => {
              ball.classList.remove('shaking');
              animateDot('s2', s2Pass, 0); // Real data applied here
              hint.textContent = 'Shake 3...';

              setTimeout(() => {
                ball.classList.add('shaking');
                setTimeout(() => {
                  ball.classList.remove('shaking');
                  animateDot('s3', s3Pass, 0); // Real data applied here

                  // Final result
                  setTimeout(() => { showFinalResult(); }, 400);
                }, 450);
              }, 400);
            }, 450);
          }, 400);
        }, 450);
      }, 900);
    }

    function showFinalResult() {
      const ball   = document.getElementById('pokeball');
      const circle = document.getElementById('wild-circle');
      const result = document.getElementById('catch-result');
      const hint   = document.getElementById('throw-hint');
      const hpFill = document.getElementById('hp-fill');

      if (SERVER_CAUGHT) {
        //    CAUGH
        ball.classList.add('caught');
        circle.classList.add('caught-anim');
        if (hpFill) hpFill.style.width = '0%';

        result.className = 'catch-result success';
        result.textContent = '★ ' + POKE_NAME + ' was caught!';
        hint.textContent = 'Gotcha! 🎉 ';

        spawnConfetti();
      } else {
        // BROKE FREE  
        circle.classList.add('fleeing');
        result.className = 'catch-result fail';
        result.textContent = POKE_NAME + ' broke free!';
        hint.textContent = 'It escaped! 💨 ';

        setTimeout(() => {
          circle.style.opacity = '0';
        }, 700);
      }

      document.getElementById('pokeball').style.pointerEvents = 'none';
      document.getElementById('pokeball').style.opacity = '.4';
    }

    //    Confetti explosion  
    function spawnConfetti() {
      const colours = ['#ffd700','#cc1a1a','#4fc3f7','#4caf50','#b06ef5','#ff8c00','#ffffff'];
      for (let i = 0; i < 60; i++) {
        const c = document.createElement('div');
        c.className = 'confetti';
        c.style.cssText = `
          left:${20 + Math.random() * 60}%;
          top:${10 + Math.random() * 40}%;
          background:${colours[Math.floor(Math.random() * colours.length)]};
          animation:confettiFall ${0.8 + Math.random() * 1.4}s ease forwards;
          animation-delay:${Math.random() * 0.5}s;
          transform:rotate(${Math.random() * 360}deg);
          border-radius:${Math.random() > .5 ? '50%' : '2px'};
          width:${5 + Math.random() * 7}px;
          height:${5 + Math.random() * 7}px;
        `;
        document.body.appendChild(c);
        setTimeout(() => c.remove(), 2800);
      }
    }
  </script>

</body>
</html>
