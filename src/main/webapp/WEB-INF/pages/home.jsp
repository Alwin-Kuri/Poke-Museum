<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Home</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vortex.css">
  <%-- data-ctx used by pokemuse.js for AJAX URLs --%>
  <body data-ctx="${pageContext.request.contextPath}">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>

    <%-- Meta strip — user info --%>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span>
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
      <span>🔄 Trades <strong>0</strong></span>
      <span>📨 Messages <strong>0</strong></span>
    </div>

    <%-- Nav buttons --%>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"
         class="nav-btn active">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/quests"
         class="nav-btn">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"
         class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"
         class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster"
         class="nav-btn">PACKS</a>
    </nav>

    <div class="topbar-right">
      <%-- Login streak badge --%>
      <c:if test="${sessionScope.loggedInUser.loginStreak > 0}">
        <span class="streak-badge">
          🔥 <c:out value="${sessionScope.loggedInUser.loginStreak}"/>
        </span>
      </c:if>
      <a href="${pageContext.request.contextPath}/logout"
         class="logout-btn" title="Logout">⇥</a>
    </div>
  </div>

  <%-- Sub-bar: coins --%>
  <div class="sub-topbar">
    <span>Welcome back, <strong><c:out value="${sessionScope.loggedInUser.username}"/></strong>!</span>
    <span class="coins-display">
      🪙 <c:out value="${sessionScope.loggedInUser.coins}"/> PokéCoins
    </span>
  </div>


  <div class="page-layout">

    <%-- Sidebar tabs --%>
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"
         class="sidebar-tab active" data-path="/home">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory"
         class="sidebar-tab" data-path="/inventory">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"
         class="sidebar-tab" data-path="/quests">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"
         class="sidebar-tab" data-path="/catch">CATCH</a>
    </nav>

    <%-- Main content --%>
    <main class="main-content">

      <%-- Toast messages from redirects--%>
      <c:if test="${not empty param.success}">
        <script>
          document.addEventListener('DOMContentLoaded', () => {
            showToast('<c:out value="${param.success}"/>');
          });
        </script>
      </c:if>

      <%-- Stats strip--%>
      <div class="stat-strip">
        <div class="stat-cell">
          <span class="stat-val"><c:out value="${totalCards}"/></span>
          <div class="stat-lbl">Cards in Museum</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val">
            $<fmt:formatNumber value="${totalValue}" maxFractionDigits="0"/>
          </span>
          <div class="stat-lbl">Total Value</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val">
            <c:out value="${sessionScope.loggedInUser.loginStreak}"/>
          </span>
          <div class="stat-lbl">Day Streak</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val">
            <c:out value="${sessionScope.loggedInUser.coins}"/>
          </span>
          <div class="stat-lbl">PokéCoins</div>
        </div>
      </div>

      <%-- Featured Cards section--%>
      <div class="section-header">
        ✦ Featured Cards
        <a href="${pageContext.request.contextPath}/cards"
           style="font-size:11px;opacity:0.75;">View All →</a>
      </div>

      <%-- Search + filter row --%>
      <div class="search-row">
        <input type="text" id="live-search" class="search-input"
               placeholder="Search Pokémon by name..."
               oninput="liveSearch(this)">
        <select id="filter-rarity" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value="">All Rarities</option>
          <option value="Common">Common</option>
          <option value="Rare">Rare</option>
          <option value="Epic">Epic</option>
          <option value="Legendary">Legendary</option>
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
          <option value="">Sort: Value ↓</option>
          <option value="value_asc">Sort: Value ↑</option>
          <option value="name">Sort: Name A–Z</option>
          <option value="rarity">Sort: Rarity</option>
        </select>
        <button class="search-btn"
                onclick="liveSearch(document.getElementById('live-search'))">🔍</button>
      </div>

      <%-- Card grid — replaced by AJAX live search --%>
      <div id="card-grid" class="poke-grid">

        <%-- c:forEach over featuredCards set by HomeServlet --%>
        <c:choose>
          <c:when test="${empty featuredCards}">
            <div class="empty-state" style="grid-column:1/-1;">
              <span class="empty-icon">📭</span>
              <p>No cards in the museum yet. Admin needs to add some!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="card" items="${featuredCards}">
              <div class="poke-card ${card.rarityCssClass}">

                <%-- Pokéball image area --%>
                <div class="card-img-area">
                  <div class="pokeball-bg">
                    <c:choose>
                      <c:when test="${not empty card.imagePath}">
                        <img class="card-poke-img"
                             src="${pageContext.request.contextPath}/images/<c:out value='${card.imagePath}'/>"
                             alt="<c:out value='${card.name}'/>">
                      </c:when>
                      <c:otherwise>
                        <%-- Fallback emoji by type --%>
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
                            <c:when test="${card.type eq 'Fighting'}">🥊</c:when>
                            <c:otherwise>🃏</c:otherwise>
                          </c:choose>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <%-- Rarity badge --%>
                  <span class="rar-badge rar-${card.rarityCssClass}">
                    <c:out value="${card.rarity}"/>
                  </span>
                </div>

                <%-- Card name + type --%>
                <div class="card-name-bar">
                  <c:out value="${card.name}"/>
                  <span class="card-type-tag">
                    <c:out value="${card.type}"/> · <c:out value="${card.conditionState}"/>
                  </span>
                </div>

                <%-- Stats row --%>
                <div class="card-stats-row">
                  <span><c:out value="${card.conditionState}"/></span>
                  <span class="card-val">
                    $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                  </span>
                </div>

                <%-- Action button: Add to Inventory --%>
                <div class="card-actions">
                  <form method="post"
                        action="${pageContext.request.contextPath}/inventory"
                        style="flex:1;">
                    <input type="hidden" name="action"  value="add">
                    <input type="hidden" name="cardId"  value="${card.cardId}">
                    <input type="hidden" name="via"     value="browse">
                    <button type="submit" class="card-btn">+ Inventory</button>
                  </form>
                </div>

              </div><%-- /poke-card --%>
            </c:forEach>
          </c:otherwise>
        </c:choose>

      </div><%-- /card-grid --%>

    </main>
  </div><%-- /page-layout --%>

  <%-- Chatbar --%>
  <div class="chatbar">
    <span class="chatbar-icon">🏛️</span>
    <span>🇳🇵</span>
    <span class="chatbar-label">
      <span class="online-dot"></span> Chat (0)
    </span>
    <div class="chatbar-right">
      <span class="coins-display">
        🪙 <c:out value="${sessionScope.loggedInUser.coins}"/>
      </span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
