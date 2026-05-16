<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Trading Station</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span style="color:var(--white);font-weight:800;"><c:out value="${sessionScope.loggedInUser.username}"/></span>
      <span>🔄 Active Listings <strong><c:out value="${openCount}"/></strong></span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"  class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/trade" class="nav-btn active">TRADE</a>
      <a href="${pageContext.request.contextPath}/catch" class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/booster" class="nav-btn">PACKS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/trade"     class="sidebar-tab active">TRADE</a>
      <a href="${pageContext.request.contextPath}/deck"      class="sidebar-tab">DECKS</a>
    </nav>

    <main class="main-content">

      <%-- Toast messages --%>
      <c:if test="${param.success eq 'listed'}">       <script>document.addEventListener('DOMContentLoaded',()=>showToast('Card listed on the marketplace! 🔄'));</script></c:if>
      <c:if test="${param.success eq 'tradeComplete'}"><script>document.addEventListener('DOMContentLoaded',()=>showToast('Trade completed! Cards swapped! 🎉'));</script></c:if>
      <c:if test="${param.success eq 'offerSent'}">    <script>document.addEventListener('DOMContentLoaded',()=>showToast('Offer sent! Waiting for response...'));</script></c:if>
      <c:if test="${param.success eq 'cancelled'}">    <script>document.addEventListener('DOMContentLoaded',()=>showToast('Listing cancelled.'));</script></c:if>

      <%-- Section header with tabs --%>
      <div class="section-header">
       <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/tradecentre.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;">Trading Station
        <div class="header-tabs">
          <a href="${pageContext.request.contextPath}/trade?tab=home"
             class="header-tab <c:if test="${activeTab eq 'home'}">active</c:if>">Trade Home</a>
          <a href="${pageContext.request.contextPath}/trade?tab=mine"
             class="header-tab <c:if test="${activeTab eq 'mine'}">active</c:if>">Listed Pokémon</a>
          <a href="${pageContext.request.contextPath}/trade?tab=offers"
             class="header-tab <c:if test="${activeTab eq 'offers'}">active</c:if>">
            Offers
            <c:if test="${not empty myOffers}">
              (<c:out value="${myOffers.size()}"/>)
            </c:if>
          </a>
        </div>
      </div>

      <%--
           TAB: TRADE HOME — browse open listings
      --%>
      <c:if test="${activeTab eq 'home'}">

        <div class="search-row">
          <input type="text" id="live-search" class="search-input"
                 placeholder="Search trades..." oninput="liveSearch(this)">
          <select id="filter-rarity" class="filter-select">
            <option value="">All Rarities</option>
            <option value="Legendary">Legendary</option>
            <option value="Epic">Epic</option>
            <option value="Rare">Rare</option>
            <option value="Common">Common</option>
          </select>
          <button class="search-btn">🔍</button>
        </div>

        <div class="section-header" style="font-size:12px;padding:8px 16px;">
          Recently Listed Trades
          <span style="font-size:10px;opacity:0.6;"><c:out value="${openCount}"/> open listings</span>
        </div>

        <c:choose>
          <c:when test="${empty openListings}">
            <div class="empty-state">
              <span class="empty-icon">🔄</span>
              <p>No cards listed for trade right now. Be the first to list one!</p>
              <a href="${pageContext.request.contextPath}/inventory"
                 class="btn-red" style="margin-top:14px;">List a Card</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="trade-grid">
              <c:forEach var="listing" items="${openListings}">
                <div class="trade-card">
                  <div class="trade-card-top">
                    <div class="trade-ball">
                      <c:choose>
                        <c:when test="${not empty listing.card.imagePath}">
                          <img src="${pageContext.request.contextPath}/images/<c:out value='${listing.card.imagePath}'/>"
                               alt="<c:out value='${listing.card.name}'/>">
                        </c:when>
                        <c:otherwise>
                          <span class="ball-emoji">
                            <c:choose>
                              <c:when test="${listing.card.type eq 'Fire'}">🔥</c:when>
                              <c:when test="${listing.card.type eq 'Water'}">🌊</c:when>
                              <c:when test="${listing.card.type eq 'Electric'}">⚡</c:when>
                              <c:when test="${listing.card.type eq 'Psychic'}">🔮</c:when>
                              <c:when test="${listing.card.type eq 'Grass'}">🌿</c:when>
                              <c:when test="${listing.card.type eq 'Dragon'}">🐉</c:when>
                              <c:when test="${listing.card.type eq 'Ghost'}">👻</c:when>
                              <c:otherwise>🃏</c:otherwise>
                            </c:choose>
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </div>
                    <span class="rar-badge rar-${listing.rarityCss}"
                          style="position:absolute;top:8px;right:8px;">
                      <c:out value="${listing.card.rarity}"/>
                    </span>
                  </div>
                  <div class="trade-info">
                    <div class="trade-name"><c:out value="${listing.card.name}"/></div>
                    <div class="trade-meta">
                      <c:out value="${listing.card.type}"/> ·
                      Lvl <c:out value="${listing.card.conditionState}"/> ·
                      Value:
                      <span style="color:var(--gold);font-family:'Oxanium',monospace;font-weight:800;">
                        $<fmt:formatNumber value="${listing.card.value}" maxFractionDigits="0"/>
                      </span>
                    </div>

                    <%-- Offer form — user picks a card from their inventory --%>
                    <form method="post" action="${pageContext.request.contextPath}/trade">
                      <input type="hidden" name="action"  value="offer">
                      <input type="hidden" name="tradeId" value="${listing.tradeId}">
                      <select name="offeredCardId" class="filter-select"
                              style="width:100%;margin-bottom:6px;font-size:11px;"
                              required>
                        <option value="">Offer one of your cards...</option>
                        <c:forEach var="myCard" items="${myInventory}">
                          <option value="${myCard.cardId}">
                            <c:out value="${myCard.name}"/> —
                            <c:out value="${myCard.rarity}"/> —
                            $<fmt:formatNumber value="${myCard.value}" maxFractionDigits="0"/>
                          </option>
                        </c:forEach>
                      </select>
                      <button type="submit" class="btn-red"
                              style="width:100%;font-size:11px;padding:7px;">
                        OFFER
                      </button>
                    </form>

                    <div class="listed-by">
                      Listed By: <span><c:out value="${listing.listerUsername}"/></span>
                    </div>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:otherwise>
        </c:choose>
      </c:if>

      <%--
           TAB: MY LISTINGS
      --%>
      <c:if test="${activeTab eq 'mine'}">

        <div style="padding:12px 16px;display:flex;align-items:center;justify-content:space-between;background:var(--bg-panel);border-bottom:1px solid var(--border);">
          <span style="font-size:12px;color:var(--text-dim);">
            Cards you have listed for trade
          </span>
          <a href="${pageContext.request.contextPath}/inventory"
             class="btn-red btn-sm">+ List a Card</a>
        </div>

        <c:choose>
          <c:when test="${empty myListings}">
            <div class="empty-state">
              <span class="empty-icon">📋</span>
              <p>You haven't listed any cards for trade yet.</p>
              <a href="${pageContext.request.contextPath}/inventory"
                 class="btn-red" style="margin-top:14px;">Go to Inventory</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="trade-grid">
              <c:forEach var="listing" items="${myListings}">
                <div class="trade-card" style="<c:if test="${listing.status ne 'open'}">opacity:0.6;</c:if>">
                  <div class="trade-card-top">
                    <div class="trade-ball">
                      <span class="ball-emoji">
                        <c:choose>
                          <c:when test="${listing.card.type eq 'Fire'}">🔥</c:when>
                          <c:when test="${listing.card.type eq 'Water'}">🌊</c:when>
                          <c:when test="${listing.card.type eq 'Electric'}">⚡</c:when>
                          <c:when test="${listing.card.type eq 'Psychic'}">🔮</c:when>
                          <c:when test="${listing.card.type eq 'Grass'}">🌿</c:when>
                          <c:otherwise>🃏</c:otherwise>
                        </c:choose>
                      </span>
                    </div>
                    <%-- Status badge --%>
                    <span style="position:absolute;top:8px;right:8px;font-size:9px;font-weight:800;
                          font-family:'Oxanium',monospace;padding:2px 8px;border-radius:10px;
                          background:<c:choose>
                            <c:when test="${listing.status eq 'open'}">rgba(76,175,80,0.15)</c:when>
                            <c:when test="${listing.status eq 'completed'}">rgba(79,195,247,0.15)</c:when>
                            <c:otherwise>rgba(204,26,26,0.15)</c:otherwise>
                          </c:choose>;
                          color:<c:choose>
                            <c:when test="${listing.status eq 'open'}">var(--green)</c:when>
                            <c:when test="${listing.status eq 'completed'}">var(--blue)</c:when>
                            <c:otherwise>#ff6b6b</c:otherwise>
                          </c:choose>;">
                      <c:out value="${listing.status}"/>
                    </span>
                  </div>
                  <div class="trade-info">
                    <div class="trade-name"><c:out value="${listing.card.name}"/></div>
                    <div class="trade-meta" style="margin-bottom:8px;">
                      <c:out value="${listing.card.rarity}"/> ·
                      $<fmt:formatNumber value="${listing.card.value}" maxFractionDigits="0"/>
                    </div>
                    <c:if test="${listing.status eq 'open'}">
                      <form method="post" action="${pageContext.request.contextPath}/trade">
                        <input type="hidden" name="action"  value="cancel">
                        <input type="hidden" name="tradeId" value="${listing.tradeId}">
                        <button type="submit" class="card-btn danger"
                                style="width:100%;font-size:10px;">
                          Cancel Listing
                        </button>
                      </form>
                    </c:if>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:otherwise>
        </c:choose>
      </c:if>

      <%--
           TAB: INCOMING OFFERS
      --%>
      <c:if test="${activeTab eq 'offers'}">
        <c:choose>
          <c:when test="${empty myOffers}">
            <div class="empty-state">
              <span class="empty-icon">📭</span>
              <p>No pending offers on your listings right now.</p>
            </div>
          </c:when>
          <c:otherwise>
            <div style="display:flex;flex-direction:column;gap:0;">
              <c:forEach var="offer" items="${myOffers}">
                <div style="background:var(--bg-panel);border-bottom:1px solid var(--border);
                            padding:14px 18px;display:flex;align-items:center;gap:16px;">

                  <%-- Offer summary --%>
                  <div style="flex:1;">
                    <div style="font-weight:800;font-size:13px;color:var(--white);margin-bottom:4px;">
                      <c:out value="${offer.offererName}"/> wants to trade for your
                      <span style="color:var(--gold);"><c:out value="${offer.listedCardName}"/></span>
                    </div>
                    <div style="font-size:11px;color:var(--text-dim);">
                      They're offering:
                      <strong style="color:var(--white);">
                        <c:out value="${offer.offeredCardName}"/>
                      </strong>
                      (<c:out value="${offer.offeredRarity}"/> ·
                      $<fmt:formatNumber value="${offer.offeredValue}" maxFractionDigits="0"/>)
                    </div>
                    <div style="font-size:10px;color:var(--text-dark);margin-top:4px;">
                      Your card value: $<fmt:formatNumber value="${offer.listedValue}" maxFractionDigits="0"/> |
                      Their card value: $<fmt:formatNumber value="${offer.offeredValue}" maxFractionDigits="0"/>
                    </div>
                  </div>

                  <%-- Accept / Reject --%>
                  <div style="display:flex;gap:8px;">
                    <form method="post" action="${pageContext.request.contextPath}/trade">
                      <input type="hidden" name="action"  value="accept">
                      <input type="hidden" name="offerId" value="${offer.offerId}">
                      <button type="submit" class="btn-red btn-sm">✓ Accept</button>
                    </form>
                    <form method="post" action="${pageContext.request.contextPath}/trade">
                      <input type="hidden" name="action"  value="reject">
                      <input type="hidden" name="offerId" value="${offer.offerId}">
                      <button type="submit" class="card-btn danger btn-sm"
                              style="padding:5px 14px;font-size:10px;">
                        ✕ Reject
                      </button>
                    </form>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:otherwise>
        </c:choose>
      </c:if>

    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">🔄</span>
    <span class="chatbar-label"><span class="online-dot"></span> Trading Station</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
