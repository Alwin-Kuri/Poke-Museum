<%-- ═══════════════════════════════════════════════════════
     deck.jsp — Deck Builder Page
     Served by : DeckServlet (GET /deck)
     JSTL used : c:forEach, c:if, c:out, c:choose, fmt
     Author    : Alwin Maharjan | CS5003NI
═══════════════════════════════════════════════════════ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Deck Builder</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span><c:out value="${sessionScope.loggedInUser.username}"/></span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"  class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/trade" class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/catch" class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/deck"  class="nav-btn active">DECKS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/trade"     class="sidebar-tab">TRADE</a>
      <a href="${pageContext.request.contextPath}/deck"      class="sidebar-tab active">DECKS</a>
    </nav>

    <main class="main-content">

      <%-- Toast feedback --%>
      <c:if test="${param.success eq 'created'}">    <script>document.addEventListener('DOMContentLoaded',()=>showToast('New deck created! 🃏'));</script></c:if>
      <c:if test="${param.success eq 'cardAdded'}">  <script>document.addEventListener('DOMContentLoaded',()=>showToast('Card added to deck!'));</script></c:if>
      <c:if test="${param.success eq 'cardRemoved'}"><script>document.addEventListener('DOMContentLoaded',()=>showToast('Card removed from deck.'));</script></c:if>
      <c:if test="${param.error eq 'maxDecks'}">     <script>document.addEventListener('DOMContentLoaded',()=>showToast('You already have 3 decks (maximum).', true));</script></c:if>
      <c:if test="${param.error eq 'deckFull'}">     <script>document.addEventListener('DOMContentLoaded',()=>showToast('Deck is full (20 cards max).', true));</script></c:if>

      <div class="section-header">
        🃏 Deck Builder
        <span style="font-size:11px;opacity:0.7;"><c:out value="${deckCount}"/> / 3 Decks</span>
      </div>

      <%-- Deck tabs (one per existing deck + create button) --%>
      <div class="deck-tabs">
        <c:forEach var="deck" items="${myDecks}" varStatus="st">
          <button class="deck-tab <c:if test="${param.deckId eq deck.deckId or (empty param.deckId and st.first)}">active</c:if>"
                  onclick="showDeck(${deck.deckId})">
            <c:out value="${deck.deckName}"/>
            (<c:out value="${deck.cardCount}"/>/<c:out value="20"/>)
          </button>
        </c:forEach>
        <c:if test="${deckCount < 3}">
          <button class="deck-tab"
                  onclick="document.getElementById('create-deck-form').style.display='flex';">
            + New Deck
          </button>
        </c:if>
      </div>

      <%-- Create deck inline form --%>
      <form id="create-deck-form" method="post"
            action="${pageContext.request.contextPath}/deck"
            style="display:none;gap:10px;padding:10px 14px;background:var(--bg-deep);border-bottom:1px solid var(--border);align-items:center;">
        <input type="hidden" name="action" value="create">
        <input class="form-control" type="text" name="deckName"
               placeholder="Deck name..." style="max-width:220px;"
               maxlength="100" required>
        <button type="submit" class="btn-red btn-sm">Create</button>
        <button type="button" class="btn-ghost btn-sm"
                onclick="document.getElementById('create-deck-form').style.display='none';">
          Cancel
        </button>
      </form>

      <%-- ── Deck content --%>
      <c:choose>
        <c:when test="${empty myDecks}">
          <div class="empty-state" style="padding:48px 20px;">
            <span class="empty-icon">🃏</span>
            <p>No decks yet. Create your first deck to get started!</p>
            <button class="btn-red" style="margin-top:14px;"
                    onclick="document.getElementById('create-deck-form').style.display='flex';">
              + Create First Deck
            </button>
          </div>
        </c:when>
        <c:otherwise>
          <%-- Show the first deck or the requested deck --%>
          <c:forEach var="deck" items="${myDecks}" varStatus="st">
            <div id="deck-${deck.deckId}"
                 style="display:<c:choose><c:when test="${param.deckId eq deck.deckId or (empty param.deckId and st.first)}">block</c:when><c:otherwise>none</c:otherwise></c:choose>;">

              <div class="deck-builder-layout">

                <%-- Left: Slots grid --%>
                <div class="deck-slots-panel">
                  <div class="deck-slots-header">
                    <%-- Rename form --%>
                    <form method="post" action="${pageContext.request.contextPath}/deck"
                          class="deck-name-form">
                      <input type="hidden" name="action" value="rename">
                      <input type="hidden" name="deckId" value="${deck.deckId}">
                      <input class="deck-name-input" type="text" name="deckName"
                             value="<c:out value='${deck.deckName}'/>" maxlength="100">
                      <button type="submit" class="btn-red btn-sm">Save</button>
                    </form>
                    <div style="display:flex;align-items:center;gap:10px;">
                      <span style="font-family:'Oxanium',monospace;font-size:11px;color:rgba(255,255,255,0.6);">
                        <c:out value="${deck.cardCount}"/> / 20 Cards
                      </span>
                      <form method="post" action="${pageContext.request.contextPath}/deck"
                            style="display:inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="deckId" value="${deck.deckId}">
                        <button type="submit" class="card-btn danger btn-sm"
                                onclick="return confirm('Delete this deck?')"
                                style="padding:3px 10px;">
                          Delete Deck
                        </button>
                      </form>
                    </div>
                  </div>

                  <%-- Completion progress bar --%>
                  <div class="deck-progress-bar">
                    <div class="deck-progress-fill"
                         style="width:${deck.completionPct}%"></div>
                  </div>

                  <%-- Card slots --%>
                  <div class="card-slots-grid">
                    <%-- Filled card slots --%>
                    <c:forEach var="card" items="${deck.cards}">
                      <div class="card-slot filled ${card.rarityCssClass}">
                        <span class="slot-emoji">
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
                        <span class="slot-name"><c:out value="${card.name}"/></span>
                        <%-- Remove button --%>
                        <form method="post" action="${pageContext.request.contextPath}/deck"
                              style="position:absolute;top:3px;right:3px;">
                          <input type="hidden" name="action" value="removeCard">
                          <input type="hidden" name="deckId" value="${deck.deckId}">
                          <input type="hidden" name="cardId" value="${card.cardId}">
                          <button type="submit" class="slot-remove">×</button>
                        </form>
                      </div>
                    </c:forEach>

                    <%-- Empty slots --%>
                    <c:forEach begin="1" end="${deck.slotsRemaining}">
                      <div class="card-slot">+</div>
                    </c:forEach>
                  </div>
                </div>

                <%-- Right: Card picker (from inventory) --%>
                <div class="card-picker">
                  <div class="picker-header">Your Inventory</div>
                  <div class="picker-list">
                    <c:choose>
                      <c:when test="${empty myInventory}">
                        <div style="padding:20px;text-align:center;color:var(--text-dim);font-size:11px;">
                          Your inventory is empty. Catch or browse cards first!
                        </div>
                      </c:when>
                      <c:otherwise>
                        <c:forEach var="card" items="${myInventory}">
                          <div class="picker-item">
                            <span class="picker-emoji">
                              <c:choose>
                                <c:when test="${card.type eq 'Fire'}">🔥</c:when>
                                <c:when test="${card.type eq 'Water'}">🌊</c:when>
                                <c:when test="${card.type eq 'Electric'}">⚡</c:when>
                                <c:when test="${card.type eq 'Psychic'}">🔮</c:when>
                                <c:when test="${card.type eq 'Grass'}">🌿</c:when>
                                <c:when test="${card.type eq 'Dragon'}">🐉</c:when>
                                <c:otherwise>🃏</c:otherwise>
                              </c:choose>
                            </span>
                            <div class="picker-info">
                              <div class="picker-name"><c:out value="${card.name}"/></div>
                              <div class="picker-type">
                                <c:out value="${card.type}"/> ·
                                <c:out value="${card.rarity}"/>
                              </div>
                            </div>
                            <%-- Add to deck form --%>
                            <form method="post" action="${pageContext.request.contextPath}/deck">
                              <input type="hidden" name="action" value="addCard">
                              <input type="hidden" name="deckId" value="${deck.deckId}">
                              <input type="hidden" name="cardId" value="${card.cardId}">
                              <button type="submit" class="picker-add"
                                      title="Add to deck"
                                      style="background:none;border:none;cursor:pointer;">
                                +
                              </button>
                            </form>
                          </div>
                        </c:forEach>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>

              </div><%-- /deck-builder-layout --%>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>

    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">🃏</span>
    <span class="chatbar-label"><span class="online-dot"></span> Deck Builder</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
  <script>
    function showDeck(deckId) {
      // Hide all deck panels
      document.querySelectorAll('[id^="deck-"]').forEach(d => d.style.display = 'none');
      // Show the selected one
      const target = document.getElementById('deck-' + deckId);
      if (target) target.style.display = 'block';
      // Update tab active states
      document.querySelectorAll('.deck-tab').forEach(t => t.classList.remove('active'));
      event.target.classList.add('active');
    }
  </script>
</body>
</html>
