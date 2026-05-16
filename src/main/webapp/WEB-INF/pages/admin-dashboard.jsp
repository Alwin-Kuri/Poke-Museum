<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- Determine current path once — used for active nav state --%>
<c:set var="uri" value="${pageContext.request.requestURI}"/>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Admin Dashboard</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

  <%-- 
       TOPBAR — active class driven by URI
   --%>
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

      <%-- ── Success / error feedback   --%>
      <c:if test="${param.success eq 'added'}">
        <div class="alert-success">✅ Card added to museum successfully!</div>
      </c:if>
      <c:if test="${param.success eq 'deleted'}">
        <div class="alert-success">🗑️ Card deleted. Use Undo Delete to restore it.</div>
      </c:if>
      <c:if test="${param.success eq 'restored'}">
        <div class="alert-success">↩ Card restored from undo stack!</div>
      </c:if>
      <c:if test="${param.success eq 'updated'}">
        <div class="alert-success">✅ Card updated successfully!</div>
      </c:if>

      <%-- ── Metric Cards  ───────── --%>
      <div class="section-header">Admin Dashboard</div>
      <div class="admin-metrics">
        <div class="admin-metric">
          <span class="am-icon"></span>
          <span class="am-val"><c:out value="${totalCards}"/></span>
          <div class="am-lbl">Total Cards</div>
          <div class="am-sub">Museum catalogue</div>
        </div>
        <div class="admin-metric">
          <span class="am-icon"></span>
          <span class="am-val">
            $<fmt:formatNumber value="${totalValue}" maxFractionDigits="0"/>
          </span>
          <div class="am-lbl">Total Value</div>
          <div class="am-sub">All cards combined</div>
        </div>
        <div class="admin-metric">
          <span class="am-icon"></span>
          <span class="am-val">
            <c:choose>
              <c:when test="${not empty mostValuable}"><c:out value="${mostValuable.name}"/></c:when>
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
          <span class="am-icon"></span>
          <span class="am-val">
            <c:choose>
              <c:when test="${not empty mostRare}"><c:out value="${mostRare.name}"/></c:when>
              <c:otherwise>—</c:otherwise>
            </c:choose>
          </span>
          <div class="am-lbl">Most Rare</div>
          <c:if test="${not empty mostRare}">
            <div class="am-sub">
              <c:out value="${mostRare.rarity}"/> · <c:out value="${mostRare.conditionState}"/>
            </div>
          </c:if>
        </div>
      </div>

      <%-- ── Rarity Distribution   --%>
      <div style="padding:12px 14px;background:var(--bg-panel);border-bottom:1px solid var(--border);">
        <div style="font-family:'Oxanium',monospace;font-size:11px;font-weight:700;color:var(--text-dim);letter-spacing:1px;text-transform:uppercase;margin-bottom:10px;">
          Rarity Distribution
        </div>
        <c:forEach var="entry" items="${rarityDistribution}">
          <div class="progress-wrap">
            <div class="progress-meta">
              <span class="rar-badge rar-${entry.key.toLowerCase()}">
                <c:out value="${entry.key}"/>
              </span>
              <span><c:out value="${entry.value}"/> cards</span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill
                <c:choose>
                  <c:when test="${entry.key eq 'Common'}">green</c:when>
                  <c:when test="${entry.key eq 'Rare'}">blue</c:when>
                  <c:when test="${entry.key eq 'Legendary'}">gold</c:when>
                </c:choose>"
                   style="width:${totalCards > 0 ? (entry.value * 100 / totalCards) : 0}%">
              </div>
            </div>
          </div>
        </c:forEach>
      </div>

      <%-- 
           CARD TABLE with working search/sort/filter
           ALL inputs submit to /admin/dashboard GET
       --%>
      <div class="section-header" style="margin-top:4px;">
        Card Inventory
        <div style="display:flex;gap:8px;">
          <%-- Undo delete button --%>
          <c:if test="${undoStackSize > 0}">
            <form method="post" action="${pageContext.request.contextPath}/cards"
                  style="display:inline;">
              <input type="hidden" name="action" value="undo">
              <button type="submit" class="btn-ghost"
                      style="color:#ff8c00;border-color:rgba(255,140,0,.3);">
                ↩ Undo Delete (<c:out value="${undoStackSize}"/>)
              </button>
            </form>
          </c:if>
          <a href="${pageContext.request.contextPath}/export/pdf?type=catalogue"
             class="btn-ghost">⬇ Export PDF</a>
          <a href="${pageContext.request.contextPath}/cards?action=add"
             class="btn-red">+ Add Card</a>
        </div>
      </div>

      <%--
        THE FIX: This form action points to /admin/dashboard (GET).
        Previously forms were either missing the action or pointing to /cards.
        All three controls (search, rarity, sort) submit together via GET
        so the servlet reads them as query params and filters the card list.
      --%>
      <form method="get" action="${pageContext.request.contextPath}/admin/dashboard"
            id="filter-form">
        <div class="search-row">
          <%-- Search input — value pre-filled from ${searchQuery} --%>
          <input type="text"
                 name="search"
                 class="search-input"
                 placeholder="Search cards by name..."
                 value="<c:out value='${searchQuery}'/>">

          <%-- Rarity filter — selected option pre-filled from ${filterRarity} --%>
          <select name="rarity" class="filter-select"
                  onchange="document.getElementById('filter-form').submit()">
            <option value="" <c:if test="${empty filterRarity}">selected</c:if>>
              All Rarities
            </option>
            <option value="Legendary"
                    <c:if test="${filterRarity eq 'Legendary'}">selected</c:if>>
              ⭐ Legendary
            </option>
            <option value="Epic"
                    <c:if test="${filterRarity eq 'Epic'}">selected</c:if>>
              💜 Epic
            </option>
            <option value="Rare"
                    <c:if test="${filterRarity eq 'Rare'}">selected</c:if>>
              💙 Rare
            </option>
            <option value="Common"
                    <c:if test="${filterRarity eq 'Common'}">selected</c:if>>
              💚 Common
            </option>
          </select>

          <%-- Sort select — selected option pre-filled from ${sortBy} --%>
          <select name="sort" class="filter-select"
                  onchange="document.getElementById('filter-form').submit()">
            <option value=""
                    <c:if test="${empty sortBy}">selected</c:if>>
              Sort: Default
            </option>
            <option value="name"
                    <c:if test="${sortBy eq 'name'}">selected</c:if>>
              Sort: Name A–Z
            </option>
            <option value="value_desc"
                    <c:if test="${sortBy eq 'value_desc'}">selected</c:if>>
              Sort: Value ↓
            </option>
            <option value="value_asc"
                    <c:if test="${sortBy eq 'value_asc'}">selected</c:if>>
              Sort: Value ↑
            </option>
            <option value="rarity"
                    <c:if test="${sortBy eq 'rarity'}">selected</c:if>>
              Sort: Rarity
            </option>
          </select>

          <button type="submit" class="search-btn">🔍 Search</button>

          <%-- Clear all filters --%>
          <a href="${pageContext.request.contextPath}/admin/dashboard"
             class="btn-ghost">✕ Clear</a>
        </div>
      </form>

      <%-- Results count feedback --%>
      <div class="results-meta">
        Showing <strong><c:out value="${resultCount}"/></strong> of
        <strong><c:out value="${totalCards}"/></strong> cards
        <c:if test="${not empty searchQuery}">
          · search: "<c:out value='${searchQuery}'/>"
        </c:if>
        <c:if test="${not empty filterRarity}">
          · rarity: <c:out value="${filterRarity}"/>
        </c:if>
        <c:if test="${not empty sortBy}">
          · sorted by: <c:out value="${sortBy}"/>
        </c:if>
      </div>

      <%-- Card data table --%>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Code</th>
              <%-- Sortable column headers — clicking re-submits with sort param --%>
              <th class="${sortBy eq 'name' ? 'sorted' : ''}">
                <a href="${pageContext.request.contextPath}/admin/dashboard?search=<c:out value='${searchQuery}'/>&rarity=<c:out value='${filterRarity}'/>&sort=name">
                  Card <c:if test="${sortBy eq 'name'}">↑</c:if>
                </a>
              </th>
              <th>Type</th>
              <th>Rarity</th>
              <th>Condition</th>
              <th>Catch Rate</th>
              <th class="${sortBy eq 'value_desc' or sortBy eq 'value_asc' ? 'sorted' : ''}">
                <a href="${pageContext.request.contextPath}/admin/dashboard?search=<c:out value='${searchQuery}'/>&rarity=<c:out value='${filterRarity}'/>&sort=${sortBy eq 'value_desc' ? 'value_asc' : 'value_desc'}">
                  Value
                  <c:choose>
                    <c:when test="${sortBy eq 'value_desc'}">↓</c:when>
                    <c:when test="${sortBy eq 'value_asc'}">↑</c:when>
                  </c:choose>
                </a>
              </th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty allCards}">
                <tr>
                  <td colspan="8" style="text-align:center;padding:32px;color:var(--text-dim);">
                    <span style="font-size:28px;display:block;margin-bottom:8px;">🔍</span>
                    No cards match your search. Try different filters or
                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       style="color:var(--red);">clear all filters</a>.
                  </td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="card" items="${allCards}">
                  <tr>
                    <td class="td-dim" style="font-family:'Oxanium',monospace;">
                      <c:out value="${card.cardCode}"/>
                    </td>
                    <td class="td-name">
                      <c:out value="${card.name}"/>
                    </td>
                    <td><c:out value="${card.type}"/></td>
                    <td>
                      <span class="rar-badge rar-${card.rarityCssClass}">
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

                        <form method="post" id="del-${card.cardId}"
                              action="${pageContext.request.contextPath}/cards">
                          <input type="hidden" name="action" value="delete">
                          <input type="hidden" name="cardId" value="${card.cardId}">
                        </form>
                        <button class="tbl-btn tbl-del"
                                onclick="if(confirm('Delete ${card.name}? You can undo this.')) document.getElementById('del-${card.cardId}').submit()">
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

  <div class="chatbar">
    <span style="font-size:15px;"> </span>
    <span class="chatbar-label">Admin Panel</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span id="clk">--:--</span></span>
    </div>
  </div>

  <script>
    function tick(){const n=new Date();document.getElementById('clk').textContent=String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0');}
    tick();setInterval(tick,30000);
  </script>

</body>
</html>
