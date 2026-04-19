<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Booster Packs</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span>
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"    class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/quests"  class="nav-btn">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"   class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"   class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster" class="nav-btn active">PACKS</a>
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
      <a href="${pageContext.request.contextPath}/booster"   class="sidebar-tab active">PACKS</a>
    </nav>

    <main class="main-content">
      <div class="section-header">📦 Booster Pack Simulator</div>

      <div style="padding:12px 16px 4px;font-size:11px;color:var(--text-dim);">
        Choose a pack type and open it to reveal 5 random Pokémon cards.
        All pulled cards are automatically added to your inventory.
      </div>

      <%-- Pack selection form--%>
      <c:if test="${empty packOpened}">
        <form method="post" action="${pageContext.request.contextPath}/booster"
              id="pack-form">
          <%-- Hidden input updated by JS when a pack is selected --%>
          <input type="hidden" name="packType" id="pack-type-input" value="basic">

          <div class="pack-grid">

            <%-- Basic Pack --%>
            <div class="pack-card selected" id="pack-basic"
                 onclick="selectPack('basic', this)">
              <span class="pack-icon">🎴</span>
              <div class="pack-name">Basic Pack</div>
              <div class="pack-desc">Standard odds. Good for beginners starting their collection.</div>
              <div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Common</span>
                  <span style="color:var(--rar-com);font-family:'Oxanium',monospace;font-weight:800;">60%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Rare</span>
                  <span style="color:var(--rar-rare);font-family:'Oxanium',monospace;font-weight:800;">25%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Epic</span>
                  <span style="color:var(--rar-epic);font-family:'Oxanium',monospace;font-weight:800;">12%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Legendary</span>
                  <span style="color:var(--rar-leg);font-family:'Oxanium',monospace;font-weight:800;">3%</span></div>
              </div>
            </div>

            <%-- Elite Pack --%>
            <div class="pack-card" id="pack-elite"
                 onclick="selectPack('elite', this)">
              <span class="pack-icon">💎</span>
              <div class="pack-name">Elite Pack</div>
              <div class="pack-desc">Better odds for experienced trainers hunting rare finds.</div>
              <div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Common</span>
                  <span style="color:var(--rar-com);font-family:'Oxanium',monospace;font-weight:800;">30%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Rare</span>
                  <span style="color:var(--rar-rare);font-family:'Oxanium',monospace;font-weight:800;">40%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Epic</span>
                  <span style="color:var(--rar-epic);font-family:'Oxanium',monospace;font-weight:800;">22%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Legendary</span>
                  <span style="color:var(--rar-leg);font-family:'Oxanium',monospace;font-weight:800;">8%</span></div>
              </div>
            </div>

            <%-- Master Pack --%>
            <div class="pack-card" id="pack-master"
                 onclick="selectPack('master', this)">
              <span class="pack-icon">🏆</span>
              <div class="pack-name">Master Pack</div>
              <div class="pack-desc">Guaranteed Epic. Real shot at Legendary. For champions only.</div>
              <div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Common</span>
                  <span style="color:var(--rar-com);font-family:'Oxanium',monospace;font-weight:800;">5%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Rare</span>
                  <span style="color:var(--rar-rare);font-family:'Oxanium',monospace;font-weight:800;">30%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Epic</span>
                  <span style="color:var(--rar-epic);font-family:'Oxanium',monospace;font-weight:800;">45%</span></div>
                <div class="pack-odds-row"><span class="pack-odds-lbl">Legendary</span>
                  <span style="color:var(--rar-leg);font-family:'Oxanium',monospace;font-weight:800;">20%</span></div>
              </div>
            </div>

          </div><%-- /pack-grid --%>

          <div style="text-align:center;padding:8px 0 14px;">
            <button type="submit" class="btn-red btn-lg"
                    style="font-family:'Oxanium',monospace;letter-spacing:1.5px;">
              OPEN PACK
            </button>
          </div>

        </form>
      </c:if>

      <%-- Revealed cards (after pack is opened) --%>
      <c:if test="${not empty packOpened and packOpened eq true}">
        <div style="text-align:center;padding:16px 0 8px;">
          <div style="font-family:'Oxanium',monospace;font-size:18px;font-weight:800;color:var(--white);">
            <c:out value="${packType}"/> Pack Opened!
          </div>
          <div style="font-size:12px;color:var(--text-dim);margin-top:4px;">
            All cards have been added to your inventory.
          </div>
        </div>

        <div class="revealed-area">
          <c:forEach var="card" items="${pulledCards}" varStatus="status">
            <div class="revealed-card ${card.rarityCssClass}"
                 style="animation-delay:${status.index * 0.18}s;">
              <span class="rev-emoji">
                <c:choose>
                  <c:when test="${card.type eq 'Fire'}">🔥</c:when>
                  <c:when test="${card.type eq 'Water'}">🌊</c:when>
                  <c:when test="${card.type eq 'Electric'}">⚡</c:when>
                  <c:when test="${card.type eq 'Psychic'}">🔮</c:when>
                  <c:when test="${card.type eq 'Grass'}">🌿</c:when>
                  <c:when test="${card.type eq 'Dragon'}">🐉</c:when>
                  <c:when test="${card.type eq 'Ghost'}">👻</c:when>
                  <c:when test="${card.type eq 'Fairy'}">🌸</c:when>
                  <c:otherwise>🃏</c:otherwise>
                </c:choose>
              </span>
              <div class="rev-name"><c:out value="${card.name}"/></div>
              <div class="rev-rarity rar-${card.rarityCssClass}">
                <c:out value="${card.rarity}"/>
              </div>
              <div style="font-family:'Oxanium',monospace;font-size:10px;color:var(--gold);margin-top:4px;">
                $<fmt:formatNumber value="${card.value}" maxFractionDigits="0"/>
              </div>
            </div>
          </c:forEach>
        </div>

        <div style="text-align:center;padding:14px 0;">
          <a href="${pageContext.request.contextPath}/booster" class="btn-red">
            Open Another Pack
          </a>
          <a href="${pageContext.request.contextPath}/inventory" class="btn-ghost" style="margin-left:10px;">
            View Inventory
          </a>
        </div>

        <script>
          document.addEventListener('DOMContentLoaded', () => {
            // Animate reveal cards (staggered)
            document.querySelectorAll('.revealed-card').forEach((card, i) => {
              card.style.opacity = '0';
              setTimeout(() => {
                card.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
                card.style.opacity = '1';
              }, 100 + i * 180);
            });
            showToast('5 cards added to your inventory! 🎴');
          });
        </script>
      </c:if>

    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">📦</span>
    <span class="chatbar-label"><span class="online-dot"></span> Booster Station</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
