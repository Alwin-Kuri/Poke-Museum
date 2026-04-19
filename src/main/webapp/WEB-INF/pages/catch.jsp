<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Catch Pokémon</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <%--Topbar --%>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span>
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"   class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/quests" class="nav-btn">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"  class="nav-btn active">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"  class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster" class="nav-btn">PACKS</a>
    </nav>
    <div class="topbar-right">
      <span class="streak-badge">🔥 <c:out value="${sessionScope.loggedInUser.loginStreak}"/></span>
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">

    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"    class="sidebar-tab">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab active">CATCH</a>
    </nav>

    <main class="main-content">

      <div class="section-header">⚡ Wild Pokémon Encounter</div>

      <div style="padding:14px;">
        <div class="catch-arena">

          <%--Catch Scene--%>
          <div class="catch-scene">

            <%-- Wild Pokémon display --%>
            <div class="wild-display" id="wild-display">
              <div class="wild-circle" id="wild-circle">
                <c:choose>
                  <c:when test="${not empty wildPokemon and not empty wildPokemon.imagePath}">
                    <img src="${pageContext.request.contextPath}/images/<c:out value='${wildPokemon.imagePath}'/>"
                         alt="<c:out value='${wildPokemon.name}'/>"
                         style="width:80px;height:80px;object-fit:contain;position:relative;z-index:3;">
                  </c:when>
                  <c:when test="${not empty wildPokemon}">
                    <span style="font-size:64px;position:relative;z-index:3;">
                      <c:choose>
                        <c:when test="${wildPokemon.type eq 'Fire'}">🔥</c:when>
                        <c:when test="${wildPokemon.type eq 'Water'}">🌊</c:when>
                        <c:when test="${wildPokemon.type eq 'Electric'}">⚡</c:when>
                        <c:when test="${wildPokemon.type eq 'Psychic'}">🔮</c:when>
                        <c:when test="${wildPokemon.type eq 'Grass'}">🌿</c:when>
                        <c:when test="${wildPokemon.type eq 'Dragon'}">🐉</c:when>
                        <c:when test="${wildPokemon.type eq 'Ghost'}">👻</c:when>
                        <c:when test="${wildPokemon.type eq 'Fairy'}">🌸</c:when>
                        <c:otherwise>🃏</c:otherwise>
                      </c:choose>
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span style="font-size:48px;position:relative;z-index:3;">❓</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="wild-name">
                <c:choose>
                  <c:when test="${not empty wildPokemon}">
                    <c:out value="${wildPokemon.name}"/>
                  </c:when>
                  <c:otherwise>???</c:otherwise>
                </c:choose>
              </div>

              <c:if test="${not empty wildPokemon}">
                <div class="wild-rarity rar-${wildPokemon.rarityCssClass}"
                     style="font-size:12px;font-weight:800;">
                  <c:out value="${wildPokemon.rarity}"/>
                </div>
              </c:if>

              <%-- Shake result indicators (shown after throw) --%>
              <c:if test="${catchState ne 'idle' and not empty shake1}">
                <div style="display:flex;gap:8px;margin-top:8px;">
                  <span style="font-size:20px;">
                    <c:choose><c:when test="${shake1}">✅</c:when><c:otherwise>❌</c:otherwise></c:choose>
                  </span>
                  <span style="font-size:20px;">
                    <c:choose><c:when test="${shake2}">✅</c:when><c:otherwise>❌</c:otherwise></c:choose>
                  </span>
                  <span style="font-size:20px;">
                    <c:choose><c:when test="${shake3}">✅</c:when><c:otherwise>❌</c:otherwise></c:choose>
                  </span>
                </div>
              </c:if>
            </div>

            <%-- Throw zone --%>
            <div class="throw-zone">
              <div class="throw-hint">
                <c:choose>
                  <c:when test="${catchState eq 'caught'}">🎉 Gotcha!</c:when>
                  <c:when test="${catchState eq 'failed'}">💨 It broke free!</c:when>
                  <c:when test="${not empty wildPokemon}">Click to throw!</c:when>
                  <c:otherwise>Encounter a Pokémon first</c:otherwise>
                </c:choose>
              </div>

              <%-- Pokéball — acts as throw button --%>
              <c:if test="${not empty wildPokemon and catchState eq 'idle'}">
                <form id="catch-form" method="post"
                      action="${pageContext.request.contextPath}/catch">
                  <input type="hidden" name="cardId" value="${wildPokemon.cardId}">
                  <button type="submit" class="pokeball-throw" id="pokeball-throw"
                          data-caught="false"
                          data-pokemon-name="<c:out value='${wildPokemon.name}'/>"
                          title="Throw Pokéball!">
                  </button>
                </form>
              </c:if>

              <%-- Result display (after throw) --%>
              <c:if test="${catchState eq 'caught'}">
                <div class="catch-result catch-success">
                  ★ <c:out value="${wildPokemon.name}"/> was caught!
                </div>
              </c:if>
              <c:if test="${catchState eq 'failed'}">
                <div class="catch-result catch-fail">
                  <c:out value="${wildPokemon.name}"/> broke free!
                </div>
              </c:if>
            </div>

          </div><%-- /catch-scene --%>

          <%-- Controls bar --%>
          <div class="catch-controls">
            <a href="${pageContext.request.contextPath}/catch"
               class="btn-red" id="encounter-btn">
              ⚡ Encounter Wild Pokémon
            </a>
            <span class="catch-hint">
              <c:if test="${not empty wildPokemon}">
                Catch rate: <strong><c:out value="${wildPokemon.catchRate}"/>/255</strong>
                &nbsp;|&nbsp;
                <c:out value="${wildPokemon.rarity}"/> Pokémon
              </c:if>
            </span>
            <span class="flex-end" style="font-size:11px;color:var(--text-dim);">
              Pokéballs: <strong style="color:var(--white);">∞</strong>
            </span>
          </div>

        </div><%-- /catch-arena --%>

        <%-- Catch tips box --%>
        <div style="background:var(--bg-panel);border:1px solid var(--border);border-radius:4px;padding:14px;margin-top:12px;">
          <div style="font-family:'Oxanium',monospace;font-size:11px;font-weight:700;color:var(--text-dim);margin-bottom:10px;letter-spacing:1px;text-transform:uppercase;">
            Catch Rate Guide
          </div>
          <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;">
            <div style="text-align:center;">
              <span class="rar-badge rar-common" style="position:relative;top:0;right:0;display:inline-block;margin-bottom:4px;">Common</span>
              <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:800;color:var(--rar-com);">~78%</div>
            </div>
            <div style="text-align:center;">
              <span class="rar-badge rar-rare" style="position:relative;top:0;right:0;display:inline-block;margin-bottom:4px;">Rare</span>
              <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:800;color:var(--rar-rare);">~31%</div>
            </div>
            <div style="text-align:center;">
              <span class="rar-badge rar-epic" style="position:relative;top:0;right:0;display:inline-block;margin-bottom:4px;">Epic</span>
              <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:800;color:var(--rar-epic);">~12%</div>
            </div>
            <div style="text-align:center;">
              <span class="rar-badge rar-legendary" style="position:relative;top:0;right:0;display:inline-block;margin-bottom:4px;">Legendary</span>
              <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:800;color:var(--rar-leg);">~2%</div>
            </div>
          </div>
        </div>

      </div><%-- /padding --%>

    </main>
  </div>

  <%-- Chatbar --%>
  <div class="chatbar">
    <span class="chatbar-icon">⚡</span>
    <span class="chatbar-label"><span class="online-dot"></span> Catch Mode Active</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>

  <%-- Trigger confetti if caught --%>
  <c:if test="${caught eq true}">
    <script>
      document.addEventListener('DOMContentLoaded', () => {
        spawnConfetti();
        showToast('<c:out value="${wildPokemon.name}"/> added to your inventory! 🎉');
        // Hide the wild circle (already caught)
        const circle = document.getElementById('wild-circle');
        if (circle) { circle.style.transform = 'scale(0)'; circle.style.opacity = '0'; }
      });
    </script>
  </c:if>

  <c:if test="${caught eq false and catchState ne 'idle'}">
    <script>
      document.addEventListener('DOMContentLoaded', () => {
        showToast('<c:out value="${wildPokemon.name}"/> broke free! Try again.', true);
      });
    </script>
  </c:if>

</body>
</html>
