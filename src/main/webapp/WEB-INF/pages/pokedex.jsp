<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Pokédex: <c:out value="${pokeName}"/></title>
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/pokedex.css">
</head>
<body>

<div class="topbar">
  <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
  <nav class="topbar-nav">
    <a href="${pageContext.request.contextPath}/home"  class="nav-btn">EXPLORE</a>
    <a href="${pageContext.request.contextPath}/cards" class="nav-btn">COLLECTION</a>
    <a href="${pageContext.request.contextPath}/catch" class="nav-btn">CATCH</a>
  </nav>
  <div class="topbar-right">
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
  </div>
</div>

<div class="page-layout">
  <nav class="sidebar">
    <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
    <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
    <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab">CATCH</a>
  </nav>

  <main class="main-content">
    <div class="section-header" style="">
     <img class="card-poke-img" 
            src="${pageContext.request.contextPath}/images/util/pokedex1.png"
            alt="📦" style="   position: relative;z-index: 3;filter: drop-shadow(0 2px 4px rgba(0,0,0,0.8));width:40px;height:40px;margin-bottom:10px;margin-top:4px;"> 
            <span style= "margin-right:1540px"> Pokédex Entry</span>
      <span style="font-size:10px;opacity:.7;">Powered by PokeAPI v2</span>
    </div>

    <%-- Error state --%>
    <c:if test="${not empty pokeError}">
      <div class="alert-err">
        ⚠️ <c:out value="${pokeError}"/>
        — Could not load Pokédex data. Check the Pokémon name and try again.
      </div>
    </c:if>

    <div class="dex-wrap">

      <%-- Back button --%>
      <div style="margin-bottom:16px;display:flex;gap:10px;">
        <a href="javascript:history.back()" class="btn-ghost">←  Back</a>
        <a href="${pageContext.request.contextPath}/inventory" class="btn-ghost">Collection</a>
        <a href="${pageContext.request.contextPath}/catch" class="btn-red">Catch This Pokémon</a>
      </div>

      <%-- ── HEADER: sprite + basic info ── --%>
      <div class="dex-header">
        <div class="dex-sprite-panel">
          <c:if test="${not empty pokeId}">
            <span class="dex-num">#<c:out value="${pokeId}"/></span>
          </c:if>
          <c:choose>
            <c:when test="${not empty pokeSpriteUrl}">
              <img class="dex-sprite"
                   src="<c:out value='${pokeSpriteUrl}'/>"
                   alt="<c:out value='${pokeName}'/>">
            </c:when>
            <c:otherwise>
              <div class="dex-sprite-placeholder">🃏</div>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="dex-info">
          <div class="dex-name"><c:out value="${pokeName}"/></div>

          <%-- Type badges — split on "/" --%>
          <div class="dex-types">
            <c:if test="${not empty pokeTypes}">
              <c:forEach var="t" items="${pokeTypes.split(' / ')}">
                <span class="type-badge type-${t.toLowerCase()}">
                  <c:out value="${t}"/>
                </span>
              </c:forEach>
            </c:if>
          </div>

          <%-- Pokédex flavour text from PokeAPI species endpoint --%>
          <c:if test="${not empty pokeFlavorText}">
            <div class="dex-flavor">
              "<c:out value='${pokeFlavorText}'/>"
            </div>
          </c:if>

          <%-- Meta grid: height, weight, generation, habitat --%>
          <div class="dex-meta-grid">
            <c:if test="${not empty pokeHeight}">
              <div class="dex-meta-item">
                <div class="dex-meta-label">Height</div>
                <div class="dex-meta-val"><c:out value="${pokeHeight}"/></div>
              </div>
            </c:if>
            <c:if test="${not empty pokeWeight}">
              <div class="dex-meta-item">
                <div class="dex-meta-label">Weight</div>
                <div class="dex-meta-val"><c:out value="${pokeWeight}"/></div>
              </div>
            </c:if>
            <c:if test="${not empty pokeGeneration}">
              <div class="dex-meta-item">
                <div class="dex-meta-label">Generation</div>
                <div class="dex-meta-val"><c:out value="${pokeGeneration}"/></div>
              </div>
            </c:if>
            <c:if test="${not empty pokeCaptureRate}">
              <div class="dex-meta-item">
                <div class="dex-meta-label">Catch Rate</div>
                <div class="dex-meta-val"><c:out value="${pokeCaptureRate}"/> / 255</div>
              </div>
            </c:if>
            <c:if test="${not empty pokeHabitat}">
              <div class="dex-meta-item">
                <div class="dex-meta-label">Habitat</div>
                <div class="dex-meta-val"><c:out value="${pokeHabitat}"/></div>
              </div>
            </c:if>
            <c:if test="${not empty pokeBaseExp}">
              <div class="dex-meta-item">
                <div class="dex-meta-label">Base EXP</div>
                <div class="dex-meta-val"><c:out value="${pokeBaseExp}"/></div>
              </div>
            </c:if>
          </div>
        </div>
      </div>

      <%-- ── BASE STATS ── --%>
      <c:if test="${not empty statHp}">
        <div class="stats-card">
          <div class="stats-header">⚔️ Base Stats</div>
          <div class="stats-body">

            <%-- HP --%>
            <div class="stat-row">
              <span class="stat-label">HP</span>
              <span class="stat-val"><c:out value="${statHp}"/></span>
              <div class="stat-bar-bg">
                <div class="stat-bar-fill ${statHp < 50 ? 'stat-low' : statHp < 80 ? 'stat-mid' : statHp < 120 ? 'stat-high' : 'stat-max'}"
                     style="width:${statHp / 255.0 * 100}%"></div>
              </div>
            </div>

            <%-- Attack --%>
            <div class="stat-row">
              <span class="stat-label">Attack</span>
              <span class="stat-val"><c:out value="${statAtk}"/></span>
              <div class="stat-bar-bg">
                <div class="stat-bar-fill ${statAtk < 50 ? 'stat-low' : statAtk < 80 ? 'stat-mid' : statAtk < 120 ? 'stat-high' : 'stat-max'}"
                     style="width:${statAtk / 255.0 * 100}%"></div>
              </div>
            </div>

            <%-- Defense --%>
            <div class="stat-row">
              <span class="stat-label">Defense</span>
              <span class="stat-val"><c:out value="${statDef}"/></span>
              <div class="stat-bar-bg">
                <div class="stat-bar-fill ${statDef < 50 ? 'stat-low' : statDef < 80 ? 'stat-mid' : statDef < 120 ? 'stat-high' : 'stat-max'}"
                     style="width:${statDef / 255.0 * 100}%"></div>
              </div>
            </div>

            <%-- Sp. Attack --%>
            <div class="stat-row">
              <span class="stat-label">Sp. Atk</span>
              <span class="stat-val"><c:out value="${statSpAtk}"/></span>
              <div class="stat-bar-bg">
                <div class="stat-bar-fill ${statSpAtk < 50 ? 'stat-low' : statSpAtk < 80 ? 'stat-mid' : statSpAtk < 120 ? 'stat-high' : 'stat-max'}"
                     style="width:${statSpAtk / 255.0 * 100}%"></div>
              </div>
            </div>

            <%-- Sp. Defense --%>
            <div class="stat-row">
              <span class="stat-label">Sp. Def</span>
              <span class="stat-val"><c:out value="${statSpDef}"/></span>
              <div class="stat-bar-bg">
                <div class="stat-bar-fill ${statSpDef < 50 ? 'stat-low' : statSpDef < 80 ? 'stat-mid' : statSpDef < 120 ? 'stat-high' : 'stat-max'}"
                     style="width:${statSpDef / 255.0 * 100}%"></div>
              </div>
            </div>

            <%-- Speed --%>
            <div class="stat-row">
              <span class="stat-label">Speed</span>
              <span class="stat-val"><c:out value="${statSpd}"/></span>
              <div class="stat-bar-bg">
                <div class="stat-bar-fill ${statSpd < 50 ? 'stat-low' : statSpd < 80 ? 'stat-mid' : statSpd < 120 ? 'stat-high' : 'stat-max'}"
                     style="width:${statSpd / 255.0 * 100}%"></div>
              </div>
            </div>

            <%-- Total --%>
            <c:set var="total" value="${statHp + statAtk + statDef + statSpAtk + statSpDef + statSpd}"/>
            <div style="border-top:1px solid var(--border);padding-top:10px;margin-top:4px;text-align:right;">
              <span style="font-family:'Oxanium',monospace;font-size:11px;color:var(--text-dim);">TOTAL</span>
              <span style="font-family:'Oxanium',monospace;font-size:18px;font-weight:800;color:var(--gold);margin-left:10px;">
                <c:out value="${total}"/>
              </span>
            </div>
          </div>
        </div>
      </c:if>

      <%-- ── ABILITIES ── --%>
      <c:if test="${not empty pokeAbilities}">
        <div class="abilities-card">
          <div class="stats-header">✨ Abilities</div>
          <c:forEach var="ability" items="${pokeAbilities.split(', ')}">
            <div class="ability-row">
              <span class="ability-name"><c:out value="${ability}"/></span>
              <span class="ability-tag">Ability</span>
            </div>
          </c:forEach>
        </div>
      </c:if>

      <%-- API credit --%>
      <div style="text-align:center;font-size:10px;color:var(--text-dark);padding-top:8px;">
        Data sourced from <a href="https://pokeapi.co" target="_blank"
           style="color:var(--red);">PokéAPI v2</a>
      </div>
    </div>

  </main>
</div>

<div class="chatbar">
  <span style="font-size:15px;"> </span>
  <span class="chatbar-label">Pokédex</span>
  <div class="chatbar-right">🕐 <span id="clk">--:--</span></div>
</div>

<script>
  // Animate stat bars on load
  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.stat-bar-fill').forEach(bar => {
      const target = bar.style.width;
      bar.style.width = '0%';
      setTimeout(() => { bar.style.width = target; }, 200);
    });
  });
  function tick(){const n=new Date();document.getElementById('clk').textContent=String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0');}
  tick();setInterval(tick,30000);
</script>
</body>
</html>
