<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="uri" value="${pageContext.request.requestURI}"/>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – My Inventory</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/inv.css">
</head>
<body>

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span style="color:var(--white);font-weight:800;"><c:out value="${sessionScope.loggedInUser.username}"/></span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"      class="nav-btn <c:if test='${uri.contains("/home")}'>active</c:if>">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="nav-btn <c:if test='${uri.contains("/inventory")}'>active</c:if>">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="nav-btn <c:if test='${uri.contains("/catch")}'>active</c:if>">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"     class="nav-btn <c:if test='${uri.contains("/trade")}'>active</c:if>">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster"   class="nav-btn <c:if test='${uri.contains("/booster")}'>active</c:if>">PACKS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/export/pdf?type=inventory"
         class="btn-ghost">⬇ Export PDF</a>
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab active">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"    class="sidebar-tab">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab">CATCH</a>
      <a href="${pageContext.request.contextPath}/anime"     class="sidebar-tab">ANIME</a>
    </nav>

    <main class="main-content">
      <div class="section-header">
            <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/trollchu.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;"><span style= "margin-right:1620px">My Collection</span>
        <span style="font-size:11px;opacity:.7;">
          <c:out value="${ownedCount}"/> / <c:out value="${totalMuseum}"/> cards
        </span>
      </div>

      <%-- Inventory stats --%>
      <div class="inv-stats">
        <div class="inv-stat">
          <span class="inv-stat-val"><c:out value="${ownedCount}"/></span>
          <div class="inv-stat-lbl">Cards Owned</div>
        </div>
        <div class="inv-stat">
          <span class="inv-stat-val" style="color:var(--gold);">
            $<fmt:formatNumber value="${totalInventoryValue}" maxFractionDigits="0"/>
          </span>
          <div class="inv-stat-lbl">Collection Value</div>
        </div>
        <div class="inv-stat">
          <span class="inv-stat-val" style="color:var(--teal);">
            <c:choose>
              <c:when test="${totalMuseum > 0}">
                <fmt:formatNumber value="${(ownedCount / totalMuseum) * 100}" maxFractionDigits="0"/>%
              </c:when>
              <c:otherwise>0%</c:otherwise>
            </c:choose>
          </span>
          <div class="inv-stat-lbl">Pokédex Complete</div>
        </div>
      </div>

      <%-- Completion progress bar --%>
      <div class="progress-wrap">
        <div class="progress-meta">
          <span>Pokédex Completion</span>
          <span style="color:var(--teal);font-weight:700;">
            <c:out value="${ownedCount}"/> / <c:out value="${totalMuseum}"/>
          </span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill"
               style="width:<c:choose>
                 <c:when test='${totalMuseum > 0}'>${(ownedCount * 100) / totalMuseum}%</c:when>
                 <c:otherwise>0%</c:otherwise>
               </c:choose>">
          </div>
        </div>
      </div>

      <%-- Card grid --%>
      <div class="poke-grid">
        <c:choose>
          <c:when test="${empty myCards}">
            <div class="empty-state">
              <span class="empty-icon">📭</span>
              <p>Your inventory is empty! Browse cards or catch Pokémon to build your collection.</p>
              <div style="display:flex;gap:10px;justify-content:center;">
                <a href="${pageContext.request.contextPath}/home"  class="btn-red">Browse Cards</a>
                <a href="${pageContext.request.contextPath}/catch" class="btn-ghost">Catch Pokémon</a>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="card" items="${myCards}">
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
                      <%-- Admin-uploaded image fallback --%>
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
                  <span class="card-type-tag"><c:out value="${card.type}"/></span>
                </div>

                <div class="card-stats-row">
                  <span><c:out value="${card.conditionState}"/></span>
                  <span class="card-val">
                    $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                  </span>
                </div>

                <div class="card-actions">
                  <%-- Pokédex entry --%>
                  <c:if test="${card.pokedexNumber > 0}">
                    <a href="${pageContext.request.contextPath}/pokedex?name=${card.name.toLowerCase()}"
                       class="card-btn ghost" title="Pokédex Entry">📖</a>
                  </c:if>

                  <%-- Trade listing --%>
                  <form method="post" action="${pageContext.request.contextPath}/trade" style="flex:1;">
                    <input type="hidden" name="action" value="list">
                    <input type="hidden" name="cardId" value="${card.cardId}">
                    <button type="submit" class="card-btn ghost" style = "background:rgb(0, 0, 128); margin-left:20px; width: 45px"> Trade </button>
                  </form>

                  <%-- Remove from inventory --%>
                  <form method="post" id="rem-${card.cardId}"
                        action="${pageContext.request.contextPath}/inventory" style="flex:1;">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="cardId" value="${card.cardId}">
                    <button type="button" class="card-btn danger"
                            onclick="if(confirm('Remove ${card.name} from inventory?'))document.getElementById('rem-${card.cardId}').submit()">
                      Remove
                    </button>
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
    <span class="chatbar-label">
         My Collection
    </span>
    <div class="chatbar-right">
      🪙 <c:out value="${sessionScope.loggedInUser.coins}"/>
      &nbsp;&nbsp;🕐 <span id="clk">--:--</span>
    </div>
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
