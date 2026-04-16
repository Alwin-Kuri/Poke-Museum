<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – My Inventory</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vortex.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span><c:out value="${sessionScope.loggedInUser.username}"/></span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"      class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="nav-btn active">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"     class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster"   class="nav-btn">PACKS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/export/pdf?type=inventory"
         class="btn-ghost btn-sm" style="font-size:10px;">⬇ Export PDF</a>
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab active">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"    class="sidebar-tab">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab">CATCH</a>
    </nav>

    <main class="main-content">
      <div class="section-header">
        My Collection
        <span style="font-size:11px;opacity:0.7;">
          <c:out value="${ownedCount}"/> / <c:out value="${totalMuseum}"/> cards
        </span>
      </div>

      <%-- Inventory stats bar--%>
      <div style="display:flex;gap:24px;padding:12px 16px;background:var(--bg-panel);border-bottom:1px solid var(--border);">
        <div>
          <span style="font-family:'Oxanium',monospace;font-size:20px;font-weight:800;color:var(--red);">
            <c:out value="${ownedCount}"/>
          </span>
          <div style="font-size:9px;color:var(--text-dim);text-transform:uppercase;letter-spacing:0.6px;">Cards Owned</div>
        </div>
        <div>
          <span style="font-family:'Oxanium',monospace;font-size:20px;font-weight:800;color:var(--gold);">
            <%-- Sum values with JSTL --%>
            $<fmt:formatNumber value="${totalInventoryValue}" maxFractionDigits="0"/>
          </span>
          <div style="font-size:9px;color:var(--text-dim);text-transform:uppercase;letter-spacing:0.6px;">Total Value</div>
        </div>
      </div>

      <%-- Pokédex completion progress--%>
      <div style="padding:10px 16px;background:var(--bg-deep);border-bottom:1px solid var(--border);">
        <div class="progress-meta">
          <span>Pokédex Completion</span>
          <span style="color:var(--teal);font-weight:700;">
            <c:out value="${ownedCount}"/> / <c:out value="${totalMuseum}"/>
            (<fmt:formatNumber value="${(ownedCount / totalMuseum) * 100}" maxFractionDigits="0"/>%)
          </span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill green"
               style="width:<fmt:formatNumber value="${(ownedCount / totalMuseum) * 100}" maxFractionDigits="1"/>%">
          </div>
        </div>
      </div>

      <%-- Card grid--%>
      <div class="poke-grid">
        <c:choose>
          <c:when test="${empty myCards}">
            <div class="empty-state" style="grid-column:1/-1;">
              <span class="empty-icon">📭</span>
              <p>Your inventory is empty! Browse cards or catch Pokémon to build your collection.</p>
              <div style="margin-top:14px;display:flex;gap:8px;justify-content:center;">
                <a href="${pageContext.request.contextPath}/home"  class="btn-red btn-sm">Browse Cards</a>
                <a href="${pageContext.request.contextPath}/catch" class="btn-ghost btn-sm">Catch Pokémon</a>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="card" items="${myCards}">
              <div class="poke-card ${card.rarityCssClass}">
                <div class="card-img-area">
                  <div class="pokeball-bg">
                    <c:choose>
                      <c:when test="${not empty card.imagePath}">
                        <img class="card-poke-img"
                             src="${pageContext.request.contextPath}/images/<c:out value='${card.imagePath}'/>"
                             alt="<c:out value='${card.name}'/>">
                      </c:when>
                      <c:otherwise>
                        <span class="card-poke-emoji">
                          <c:choose>
                            <c:when test="${card.type eq 'Fire'}">🔥</c:when>
                            <c:when test="${card.type eq 'Water'}">🌊</c:when>
                            <c:when test="${card.type eq 'Electric'}">⚡</c:when>
                            <c:when test="${card.type eq 'Psychic'}">🔮</c:when>
                            <c:when test="${card.type eq 'Grass'}">🌿</c:when>
                            <c:when test="${card.type eq 'Dragon'}">🐉</c:when>
                            <c:when test="${card.type eq 'Ghost'}">👻</c:when>
                            <c:otherwise>🃏</c:otherwise>
                          </c:choose>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <span class="rar-badge rar-${card.rarityCssClass}">
                    <c:out value="${card.rarity}"/>
                  </span>
                </div>
                <div class="card-name-bar">
                  <c:out value="${card.name}"/>
                  <span class="card-type-tag"><c:out value="${card.type}"/></span>
                </div>
                <div class="card-stats-row">
                  <span><c:out value="${card.conditionState}"/></span>
                  <span class="card-val">
                    $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                  </span>
                </div>
                <div class="card-actions">
                  <%-- Remove from inventory --%>
                  <form method="post" id="rem-${card.cardId}"
                        action="${pageContext.request.contextPath}/inventory"
                        style="flex:1;">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="cardId" value="${card.cardId}">
                    <button type="button" class="card-btn danger"
                            onclick="confirmRemoveInventory('rem-${card.cardId}','<c:out value="${card.name}" escapeXml="true"/>')">
                      Remove
                    </button>
                  </form>
                  <%-- List for trade --%>
                  <form method="post"
                        action="${pageContext.request.contextPath}/trade"
                        style="flex:1;">
                    <input type="hidden" name="action"  value="list">
                    <input type="hidden" name="cardId"  value="${card.cardId}">
                    <button type="submit" class="card-btn ghost">Trade</button>
                  </form>
                </div>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">🃏</span>
    <span class="chatbar-label"><span class="online-dot"></span> My Inventory</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
