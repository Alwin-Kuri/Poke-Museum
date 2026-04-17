<%-- ═══════════════════════════════════════════════════════
     fragments/card-grid.jsp — AJAX Card Grid Fragment
     Served by : CardServlet (GET /cards?ajax=true)
     Returns   : just the inner card grid HTML (no full page)
     Used by   : pokemuse.js liveSearch() fetch call
     Author    : Alwin Maharjan | CS5003NI
═══════════════════════════════════════════════════════ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- No DOCTYPE/html/head — this is a fragment injected into an existing grid div --%>
<c:choose>
  <c:when test="${empty cards}">
    <div class="empty-state" style="grid-column:1/-1;padding:40px;">
      <span class="empty-icon">🔍</span>
      <p>No cards match your search. Try a different name or filter!</p>
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
          <form method="post" action="${pageContext.request.contextPath}/inventory" style="flex:1;">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="cardId" value="${card.cardId}">
            <input type="hidden" name="via"    value="browse">
            <button type="submit" class="card-btn">+ Inventory</button>
          </form>
        </div>
      </div>
    </c:forEach>
  </c:otherwise>
</c:choose>
