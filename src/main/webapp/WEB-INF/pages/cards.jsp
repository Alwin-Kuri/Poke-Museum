<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Card Collection</title>
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
      <a href="${pageContext.request.contextPath}/home"  class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/cards" class="nav-btn active">COLLECTION</a>
      <a href="${pageContext.request.contextPath}/catch" class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade" class="nav-btn">TRADE</a>
    </nav>
    <div class="topbar-right">
      <span class="streak-badge">🔥 <c:out value="${sessionScope.loggedInUser.loginStreak}"/></span>
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/cards"     class="sidebar-tab active">BROWSE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab">CATCH</a>
    </nav>

    <main class="main-content">

      <%-- Admin quick-add button --%>
      <c:if test="${sessionScope.userRole eq 'admin'}">
        <div style="display:flex;justify-content:flex-end;padding:8px 14px;background:var(--bg-panel);border-bottom:1px solid var(--border);">
          <a href="${pageContext.request.contextPath}/cards?action=add"
             class="btn-red btn-sm">+ Add Card</a>
        </div>
      </c:if>

      <div class="section-header">
        🃏 Museum Collection
        <span style="font-size:11px;opacity:0.7;">
          <c:out value="${totalCards}"/> cards
        </span>
      </div>

      <%-- Search & filter row --%>
      <div class="search-row">
        <input type="text" id="live-search" class="search-input"
               placeholder="Search Pokémon by name..."
               value="<c:out value='${searchQuery}'/>"
               oninput="liveSearch(this)">
        <select id="filter-rarity" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value=""   <c:if test="${empty filterRarity}">selected</c:if>>All Rarities</option>
          <option value="Legendary" <c:if test="${filterRarity eq 'Legendary'}">selected</c:if>>⭐ Legendary</option>
          <option value="Epic"      <c:if test="${filterRarity eq 'Epic'}">selected</c:if>>💜 Epic</option>
          <option value="Rare"      <c:if test="${filterRarity eq 'Rare'}">selected</c:if>>💙 Rare</option>
          <option value="Common"    <c:if test="${filterRarity eq 'Common'}">selected</c:if>>💚 Common</option>
        </select>
        <select id="filter-type" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value="">All Types</option>
          <option value="Fire">🔥 Fire</option>
          <option value="Water">🌊 Water</option>
          <option value="Electric">⚡ Electric</option>
          <option value="Psychic">🔮 Psychic</option>
          <option value="Grass">🌿 Grass</option>
          <option value="Dragon">🐉 Dragon</option>
          <option value="Ghost">👻 Ghost</option>
          <option value="Normal">⭕ Normal</option>
          <option value="Fighting">🥊 Fighting</option>
          <option value="Fairy">🌸 Fairy</option>
        </select>
        <select id="sort-by" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value=""         <c:if test="${empty sortBy}">selected</c:if>>Sort: Value ↓</option>
          <option value="value_asc"<c:if test="${sortBy eq 'value_asc'}">selected</c:if>>Sort: Value ↑</option>
          <option value="name"     <c:if test="${sortBy eq 'name'}">selected</c:if>>Sort: Name A–Z</option>
          <option value="rarity"   <c:if test="${sortBy eq 'rarity'}">selected</c:if>>Sort: Rarity</option>
        </select>
        <button class="search-btn">🔍</button>
      </div>

      <%-- Card grid --%>
      <div id="card-grid" class="poke-grid">
        <c:choose>
          <c:when test="${empty cards}">
            <div class="empty-state" style="grid-column:1/-1;">
              <span class="empty-icon">🔍</span>
              <p>No cards match your search. Try different filters!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="card" items="${cards}">
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
                            <c:when test="${card.type eq 'Fairy'}">🌸</c:when>
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
                  <span class="card-type-tag">
                    <c:out value="${card.type}"/> · <c:out value="${card.conditionState}"/>
                  </span>
                </div>

                <div class="card-stats-row">
                  <span class="td-dim"><c:out value="${card.conditionState}"/></span>
                  <span class="card-val">
                    $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                  </span>
                </div>

                <div class="card-actions">
                  <%-- Add to inventory --%>
                  <form method="post"
                        action="${pageContext.request.contextPath}/inventory"
                        style="flex:1;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="cardId" value="${card.cardId}">
                    <input type="hidden" name="via"    value="browse">
                    <button type="submit" class="card-btn">+ Inv</button>
                  </form>

                  <%-- Admin: edit button --%>
                  <c:if test="${sessionScope.userRole eq 'admin'}">
                    <a href="${pageContext.request.contextPath}/cards?action=edit&id=${card.cardId}"
                       class="card-btn ghost">✏️</a>
                    <form method="post" id="del-${card.cardId}"
                          action="${pageContext.request.contextPath}/cards"
                          style="flex:0;">
                      <input type="hidden" name="action" value="delete">
                      <input type="hidden" name="cardId" value="${card.cardId}">
                      <button type="button" class="card-btn danger"
                              onclick="confirmDelete('del-${card.cardId}','<c:out value="${card.name}" escapeXml="true"/>')">
                        🗑️
                      </button>
                    </form>
                  </c:if>
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
    <span class="chatbar-label"><span class="online-dot"></span> Museum Collection</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
