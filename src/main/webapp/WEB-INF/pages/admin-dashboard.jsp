<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Admin Dashboard</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span>
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
      <span style="color:var(--gold);font-family:'Oxanium',monospace;font-size:10px;font-weight:800;">⚙️ ADMIN</span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-btn active">DASHBOARD</a>
      <a href="${pageContext.request.contextPath}/cards"           class="nav-btn">CARDS</a>
      <a href="${pageContext.request.contextPath}/admin/users"     class="nav-btn">USERS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn" title="Logout">⇥</a>
    </div>
  </div>

  <%-- ══════════════════════════════════════════
       SIDEBAR + MAIN
  ══════════════════════════════════════════ --%>
  <div class="page-layout">

    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/admin/dashboard"
         class="sidebar-tab active">DASH</a>
      <a href="${pageContext.request.contextPath}/cards"
         class="sidebar-tab">CARDS</a>
      <a href="${pageContext.request.contextPath}/cards?action=add"
         class="sidebar-tab">ADD</a>
      <a href="${pageContext.request.contextPath}/admin/users"
         class="sidebar-tab">USERS</a>
    </nav>

    <main class="main-content">

      <%-- Success / error messages from redirects --%>
      <c:if test="${param.success eq 'added'}">
        <script>document.addEventListener('DOMContentLoaded',()=>showToast('Card added to museum! ✅'));</script>
      </c:if>
      <c:if test="${param.success eq 'deleted'}">
        <script>document.addEventListener('DOMContentLoaded',()=>showToast('Card deleted. You can undo this! ↩'));</script>
      </c:if>
      <c:if test="${param.success eq 'restored'}">
        <script>document.addEventListener('DOMContentLoaded',()=>showToast('Card restored from undo stack! ✅'));</script>
      </c:if>

      <%-- Admin Metric Cards --%>
      <div class="section-header">Admin Dashboard</div>

      <div class="admin-metrics">
        <div class="admin-metric">
          <span class="am-icon">🃏</span>
          <span class="am-val"><c:out value="${totalCards}"/></span>
          <div class="am-lbl">Total Cards</div>
          <div class="am-sub">Museum catalogue</div>
        </div>
        <div class="admin-metric">
          <span class="am-icon">💰</span>
          <span class="am-val">
            $<fmt:formatNumber value="${totalValue}" maxFractionDigits="0"/>
          </span>
          <div class="am-lbl">Total Value</div>
          <div class="am-sub">All cards combined</div>
        </div>
        <div class="admin-metric">
          <span class="am-icon">⭐</span>
          <span class="am-val">
            <c:choose>
              <c:when test="${not empty mostValuable}">
                <c:out value="${mostValuable.name}"/>
              </c:when>
              <c:otherwise>—</c:otherwise>
            </c:choose>
          </span>
          <div class="am-lbl">Most Valuable</div>
          <c:if test="${not empty mostValuable}">
            <div class="am-sub">
              $<fmt:formatNumber value="${mostValuable.value}" minFractionDigits="2"/>
              · <c:out value="${mostValuable.rarity}"/>
            </div>
          </c:if>
        </div>
        <div class="admin-metric">
          <span class="am-icon">🏆</span>
          <span class="am-val">
            <c:choose>
              <c:when test="${not empty mostRare}">
                <c:out value="${mostRare.name}"/>
              </c:when>
              <c:otherwise>—</c:otherwise>
            </c:choose>
          </span>
          <div class="am-lbl">Most Rare</div>
          <c:if test="${not empty mostRare}">
            <div class="am-sub">
              <c:out value="${mostRare.rarity}"/>
              · <c:out value="${mostRare.conditionState}"/>
            </div>
          </c:if>
        </div>
      </div>

      <%-- Rarity Distribution --%>
      <div class="section-header" style="margin-top:4px;">
        Rarity Distribution
      </div>
      <div style="padding:12px 14px;background:var(--bg-panel);border-bottom:1px solid var(--border);">
        <c:forEach var="entry" items="${rarityDistribution}">
          <div style="margin-bottom:10px;">
            <div class="progress-meta">
              <span class="rar-badge rar-${entry.key.toLowerCase()}"
                    style="position:relative;top:0;right:0;">
                <c:out value="${entry.key}"/>
              </span>
              <span class="text-dim"><c:out value="${entry.value}"/> cards</span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill
                <c:choose>
                  <c:when test="${entry.key eq 'Common'}">green</c:when>
                  <c:when test="${entry.key eq 'Rare'}">blue</c:when>
                  <c:when test="${entry.key eq 'Epic'}"></c:when>
                  <c:otherwise>gold</c:otherwise>
                </c:choose>"
                   style="width:${(entry.value / totalCards) * 100}%">
              </div>
            </div>
          </div>
        </c:forEach>
      </div>

      <%-- Card Table --%>
      <div class="section-header" style="margin-top:4px;">
        Card Inventory
        <div style="display:flex;gap:8px;">
          <%-- Undo delete button --%>
          <c:if test="${undoStackSize > 0}">
            <form method="post" action="${pageContext.request.contextPath}/cards"
                  style="display:inline;">
              <input type="hidden" name="action" value="undo">
              <button type="submit" class="btn-ghost btn-sm"
                      style="color:var(--orange);border-color:rgba(255,140,0,0.3);">
                ↩ Undo Delete (<c:out value="${undoStackSize}"/>)
              </button>
            </form>
          </c:if>
          <a href="${pageContext.request.contextPath}/export/pdf"
             class="btn-ghost btn-sm">⬇ Export PDF</a>
          <a href="${pageContext.request.contextPath}/cards?action=add"
             class="btn-red btn-sm">+ Add Card</a>
        </div>
      </div>

      <%-- Search row --%>
      <div class="search-row">
        <input type="text" id="live-search" class="search-input"
               placeholder="Search cards..."
               oninput="liveSearch(this)">
        <select id="filter-rarity" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value="">All Rarities</option>
          <option value="Legendary">Legendary</option>
          <option value="Epic">Epic</option>
          <option value="Rare">Rare</option>
          <option value="Common">Common</option>
        </select>
        <button class="search-btn">Search</button>
      </div>

      <%-- Card data table --%>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Code</th>
              <th>Card</th>
              <th>Type</th>
              <th>Rarity</th>
              <th>Condition</th>
              <th>Catch Rate</th>
              <th>Value</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty allCards}">
                <tr>
                  <td colspan="8" class="text-center text-dim" style="padding:30px;">
                    No cards found. Add your first card!
                  </td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="card" items="${allCards}">
                  <tr>
                    <td class="td-dim mono"><c:out value="${card.cardCode}"/></td>
                    <td class="td-name">
                      <%-- Type emoji --%>
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
                      <c:out value="${card.name}"/>
                    </td>
                    <td><c:out value="${card.type}"/></td>
                    <td>
                      <span class="rar-badge rar-${card.rarityCssClass}"
                            style="position:relative;top:0;right:0;">
                        <c:out value="${card.rarity}"/>
                      </span>
                    </td>
                    <td><c:out value="${card.conditionState}"/></td>
                    <td class="td-dim"><c:out value="${card.catchRate}"/>/255</td>
                    <td class="td-gold">
                      $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                    </td>
                    <td>
                      <div class="td-actions">
                        <a href="${pageContext.request.contextPath}/cards?action=edit&id=${card.cardId}"
                           class="tbl-btn tbl-edit">Edit</a>

                        <%-- Delete with JS confirmation --%>
                        <form method="post" id="del-${card.cardId}"
                              action="${pageContext.request.contextPath}/cards">
                          <input type="hidden" name="action" value="delete">
                          <input type="hidden" name="cardId" value="${card.cardId}">
                        </form>
                        <button class="tbl-btn tbl-del"
                                onclick="confirmDelete('del-${card.cardId}','<c:out value="${card.name}" escapeXml="true"/>')">
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>

    </main>
  </div>

  <%-- Chatbar --%>
  <div class="chatbar">
    <span class="chatbar-icon">⚙️</span>
    <span class="chatbar-label">Admin Panel</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
