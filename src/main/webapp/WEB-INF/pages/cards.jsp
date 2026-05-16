<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="uri" value="${pageContext.request.requestURI}"/>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Card Collection</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/cards.css">
</head>
<body>

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <div class="topbar-meta">
      <span style="color:var(--white);font-weight:800;">
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
      <span style="color:var(--gold);font-family:'Oxanium',monospace;font-size:10px;font-weight:800;">⚙ ADMIN</span>
    </div>
    <nav class="topbar-nav">
      <%-- Active class set by comparing URI — stays correct on every page --%>
      <a href="${pageContext.request.contextPath}/admin/dashboard"
         class="nav-btn <c:if test='${uri.contains("/admin/dashboard")}'>active</c:if>">
        DASHBOARD
      </a>
      <a href="${pageContext.request.contextPath}/cards"
         class="nav-btn <c:if test='${uri.contains("/cards")}'>active</c:if>">
        CARDS
      </a>
      <a href="${pageContext.request.contextPath}/admin/users"
         class="nav-btn <c:if test='${uri.contains("/admin/users")}'>active</c:if>">
        USERS
      </a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn" title="Logout">⇥</a>
    </div>
  </div>

  <div class="page-layout">

    <%-- Sidebar — active class by URI --%>
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/admin/dashboard"
         class="sidebar-tab <c:if test='${uri.contains("/dashboard")}'>active</c:if>">DASH</a>
      <a href="${pageContext.request.contextPath}/cards"
         class="sidebar-tab <c:if test='${uri.contains("/cards")}'>active</c:if>">CARDS</a>
      <a href="${pageContext.request.contextPath}/cards?action=add"
         class="sidebar-tab">ADD</a>
      <a href="${pageContext.request.contextPath}/admin/users"
         class="sidebar-tab <c:if test='${uri.contains("/users")}'>active</c:if>">USERS</a>
    </nav>

    <main class="main-content">

      <div class="section-header">
            <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/admin.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;margin-top:4px;"><span style= "margin-right:1520px">PokeMuse Collection</span>
       <%-- Admin add button --%>
      <c:if test="${sessionScope.userRole eq 'admin'}">
        <div style="display:flex;justify-content:flex-end;padding:8px 14px;">
          <a href="${pageContext.request.contextPath}/cards?action=add" class="btn-red">+ Add Card</a>
        </div>
      </c:if>
      </div>

      <%-- Search & filter — GET form submits to /cards --%>
      <form method="get" action="${pageContext.request.contextPath}/cards" id="filter-form">
        <div class="search-row">
          <input type="text" name="search" class="search-input"
                 placeholder="Search Pokémon by name..."
                 value="<c:out value='${searchQuery}'/>">
          <select name="rarity" class="filter-select"
                  onchange="document.getElementById('filter-form').submit()">
            <option value=""         <c:if test="${empty filterRarity}">selected</c:if>>All Rarities</option>
            <option value="Legendary"<c:if test="${filterRarity eq 'Legendary'}">selected</c:if>>⭐ Legendary</option>
            <option value="Epic"     <c:if test="${filterRarity eq 'Epic'}">selected</c:if>>💜 Epic</option>
            <option value="Rare"     <c:if test="${filterRarity eq 'Rare'}">selected</c:if>>💙 Rare</option>
            <option value="Common"   <c:if test="${filterRarity eq 'Common'}">selected</c:if>>💚 Common</option>
          </select>
          <select name="type" class="filter-select"
                  onchange="document.getElementById('filter-form').submit()">
            <option value="">All Types</option>
            <option value="Fire"    <c:if test="${filterType eq 'Fire'}">selected</c:if>>🔥 Fire</option>
            <option value="Water"   <c:if test="${filterType eq 'Water'}">selected</c:if>>🌊 Water</option>
            <option value="Electric"<c:if test="${filterType eq 'Electric'}">selected</c:if>>⚡ Electric</option>
            <option value="Psychic" <c:if test="${filterType eq 'Psychic'}">selected</c:if>>🔮 Psychic</option>
            <option value="Grass"   <c:if test="${filterType eq 'Grass'}">selected</c:if>>🌿 Grass</option>
            <option value="Dragon"  <c:if test="${filterType eq 'Dragon'}">selected</c:if>>🐉 Dragon</option>
            <option value="Ghost"   <c:if test="${filterType eq 'Ghost'}">selected</c:if>>👻 Ghost</option>
            <option value="Normal"  <c:if test="${filterType eq 'Normal'}">selected</c:if>>⭕ Normal</option>
            <option value="Fighting"<c:if test="${filterType eq 'Fighting'}">selected</c:if>>🥊 Fighting</option>
            <option value="Fairy"   <c:if test="${filterType eq 'Fairy'}">selected</c:if>>🌸 Fairy</option>
          </select>
          <select name="sort" class="filter-select"
                  onchange="document.getElementById('filter-form').submit()">
            <option value=""        <c:if test="${empty sortBy}">selected</c:if>>Value ↓</option>
            <option value="value_asc"<c:if test="${sortBy eq 'value_asc'}">selected</c:if>>Value ↑</option>
            <option value="name"    <c:if test="${sortBy eq 'name'}">selected</c:if>>Name A–Z</option>
            <option value="rarity"  <c:if test="${sortBy eq 'rarity'}">selected</c:if>>Rarity</option>
          </select>
          <button type="submit" class="search-btn">🔍</button>
          <a href="${pageContext.request.contextPath}/cards" class="btn-ghost">✕</a>
        </div>
      </form>

      <div class="results-meta">
        Showing <strong><c:out value="${cards.size()}"/></strong> of
        <strong><c:out value="${totalCards}"/></strong> cards
        <c:if test="${not empty searchQuery}"> · "<c:out value='${searchQuery}'/>"</c:if>
        <c:if test="${not empty filterRarity}"> · <c:out value="${filterRarity}"/></c:if>
      </div>

      <%-- Card grid --%>
      <div id="card-grid" class="poke-grid">
        <c:choose>
          <c:when test="${empty cards}">
            <div class="empty-state">
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
                      <%-- PokeAPI official artwork sprite --%>
                      <c:when test="${card.pokedexNumber > 0}">
                        <img class="card-poke-img"
                             src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${card.pokedexNumber}.png"
                             alt="<c:out value='${card.name}'/>"
                             onerror="this.style.display='none'">
                      </c:when>
                      <%-- Admin-uploaded image --%>
                      <c:when test="${not empty card.imagePath}">
                        <img class="card-poke-img"
                             src="${pageContext.request.contextPath}/images/<c:out value='${card.imagePath}'/>"
                             alt="<c:out value='${card.name}'/>">
                      </c:when>
                      <%-- Emoji fallback --%>
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
                  <span><c:out value="${card.conditionState}"/></span>
                  <span class="card-val">
                    $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                  </span>
                </div>

                <div class="card-actions">
                  <%-- Add to inventory --%>
                  <form method="post" action="${pageContext.request.contextPath}/inventory" style="flex:2;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="cardId" value="${card.cardId}">
                    <input type="hidden" name="via"    value="browse">
                    <button type="submit" class="card-btn">+ Inv</button>
                  </form>

                  <%-- Pokédex entry --%>
                  <c:if test="${card.pokedexNumber > 0}">
                    <a href="${pageContext.request.contextPath}/pokedex?name=${card.name.toLowerCase()}"
                       class="card-btn ghost" title="View Pokédex entry">📖</a>
                  </c:if>

                  <%-- Admin: edit + delete --%>
                  <c:if test="${sessionScope.userRole eq 'admin'}">
                    <a href="${pageContext.request.contextPath}/cards?action=edit&id=${card.cardId}"
                       class="card-btn ghost" title="Edit">✏️</a>
                    <form method="post" id="del-${card.cardId}"
                          action="${pageContext.request.contextPath}/cards">
                      <input type="hidden" name="action" value="delete">
                      <input type="hidden" name="cardId" value="${card.cardId}">
                      <button type="button" class="card-btn danger" title="Delete"
                              onclick="if(confirm('Delete ${card.name}?'))document.getElementById('del-${card.cardId}').submit()">
                        🗑
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
    <span style="font-size:15px;"> </span>
    <span class="chatbar-label"> Museum Collection</span>
    <div class="chatbar-right">🕐 <span id="clk">--:--</span></div>
  </div>

  <script>
    function tick(){const n=new Date();document.getElementById('clk').textContent=String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0');}
    tick();setInterval(tick,30000);
    document.addEventListener('DOMContentLoaded',()=>{
      document.querySelectorAll('.poke-card').forEach((c,i)=>{
        c.style.opacity='0';c.style.transform='translateY(14px)';c.style.transition='opacity .3s ease,transform .3s ease';
        setTimeout(()=>{c.style.opacity='1';c.style.transform='translateY(0)';},40+i*40);
      });
    });
  </script>
</body>
</html>
