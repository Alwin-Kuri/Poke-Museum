<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Edit Card</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-btn">DASHBOARD</a>
      <a href="${pageContext.request.contextPath}/cards"           class="nav-btn">CARDS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-tab">DASH</a>
      <a href="${pageContext.request.contextPath}/cards"           class="sidebar-tab active">CARDS</a>
      <a href="${pageContext.request.contextPath}/cards?action=add" class="sidebar-tab">ADD</a>
      <a href="${pageContext.request.contextPath}/admin/users"     class="sidebar-tab">USERS</a>
    </nav>

    <main class="main-content">
      <div class="section-header">
        ✏️ Edit Card —
        <c:out value="${editCard.cardCode}"/>: <c:out value="${editCard.name}"/>
        <a href="${pageContext.request.contextPath}/cards" class="btn-ghost btn-sm">← Back</a>
      </div>

      <div style="padding:20px;max-width:680px;">

        <c:if test="${not empty errorMsg}">
          <div class="alert-error" style="margin-bottom:16px;">
            ⚠️ <c:out value="${errorMsg}"/>
          </div>
        </c:if>

        <form method="post"
              action="${pageContext.request.contextPath}/cards"
              enctype="multipart/form-data">
          <input type="hidden" name="action"  value="edit">
          <input type="hidden" name="cardId"  value="${editCard.cardId}">

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">

            <%-- Read-only code --%>
            <div class="form-group">
              <label class="form-label">Card Code (read-only)</label>
              <input class="form-control" type="text"
                     value="<c:out value='${editCard.cardCode}'/>" disabled
                     style="opacity:0.5;cursor:not-allowed;">
            </div>

            <%-- Name --%>
            <div class="form-group">
              <label class="form-label" for="name">Pokémon Name *</label>
              <input class="form-control" type="text" id="name" name="name"
                     value="<c:out value='${editCard.name}'/>" required maxlength="100">
            </div>

            <%-- Type --%>
            <div class="form-group">
              <label class="form-label" for="type">Type *</label>
				<select class="form-control" id="type" name="type" required>
				  <option value="Fire"     <c:if test="${editCard.type eq 'Fire'}">selected</c:if>>🔥 Fire</option>
				  <option value="Water"    <c:if test="${editCard.type eq 'Water'}">selected</c:if>>🌊 Water</option>
				  <option value="Electric" <c:if test="${editCard.type eq 'Electric'}">selected</c:if>>⚡ Electric</option>
				  <option value="Psychic"  <c:if test="${editCard.type eq 'Psychic'}">selected</c:if>>🔮 Psychic</option>
				  <option value="Grass"    <c:if test="${editCard.type eq 'Grass'}">selected</c:if>>🌿 Grass</option>
				  <option value="Dragon"   <c:if test="${editCard.type eq 'Dragon'}">selected</c:if>>🐉 Dragon</option>
				  <option value="Ghost"    <c:if test="${editCard.type eq 'Ghost'}">selected</c:if>>👻 Ghost</option>
				  <option value="Normal"   <c:if test="${editCard.type eq 'Normal'}">selected</c:if>>⭕ Normal</option>
				  <option value="Fighting" <c:if test="${editCard.type eq 'Fighting'}">selected</c:if>>🥊 Fighting</option>
				  <option value="Fairy"    <c:if test="${editCard.type eq 'Fairy'}">selected</c:if>>🌸 Fairy</option>
				  <option value="Rock"     <c:if test="${editCard.type eq 'Rock'}">selected</c:if>>🪨 Rock</option>
				  <option value="Ground"   <c:if test="${editCard.type eq 'Ground'}">selected</c:if>>🌍 Ground</option>
				  <option value="Ice"      <c:if test="${editCard.type eq 'Ice'}">selected</c:if>>🧊 Ice</option>
				  <option value="Dark"     <c:if test="${editCard.type eq 'Dark'}">selected</c:if>>🌑 Dark</option>
				  <option value="Steel"    <c:if test="${editCard.type eq 'Steel'}">selected</c:if>>⚙️ Steel</option>
				</select>
            </div>

            <%-- Rarity --%>
            <div class="form-group">
              <label class="form-label" for="rarity">Rarity *</label>
              <select class="form-control" id="rarity" name="rarity" required>
				  <option value="Common"    
				  	<c:if test="${editCard.rarity eq 'Common'}">selected</c:if>>Common</option>
				  <option value="Rare"      
				  	<c:if test="${editCard.rarity eq 'Rare'}">selected</c:if>>Rare</option>
				  <option value="Epic"      
				  	<c:if test="${editCard.rarity eq 'Epic'}">selected</c:if>>Epic</option>
				  <option value="Legendary" 
				  	<c:if test="${editCard.rarity eq 'Legendary'}">selected</c:if>>Legendary</option>
			  </select>
            </div>

            <%-- Condition --%>
            <div class="form-group">
              <label class="form-label" for="conditionState">Condition *</label>
				<select class="form-control" id="conditionState" name="conditionState" required>
				  <option value="Mint"      <c:if test="${editCard.conditionState eq 'Mint'}">selected</c:if>>Mint</option>
				  <option value="Near Mint" <c:if test="${editCard.conditionState eq 'Near Mint'}">selected</c:if>>Near Mint</option>
				  <option value="Good"      <c:if test="${editCard.conditionState eq 'Good'}">selected</c:if>>Good</option>
				  <option value="Fair"      <c:if test="${editCard.conditionState eq 'Fair'}">selected</c:if>>Fair</option>
				  <option value="Poor"      <c:if test="${editCard.conditionState eq 'Poor'}">selected</c:if>>Poor</option>
				</select>
            </div>

            <%-- Value --%>
            <div class="form-group">
              <label class="form-label" for="value">Market Value ($) *</label>
              <input class="form-control" type="number" id="value" name="value"
                     value="<fmt:formatNumber value='${editCard.value}' minFractionDigits='2' maxFractionDigits='2'/>"
                     min="0" step="0.01" required>
            </div>

            <%-- Catch Rate --%>
            <div class="form-group">
              <label class="form-label" for="catchRate">Catch Rate *</label>
              <input class="form-control" type="number" id="catchRate" name="catchRate"
                     value="${editCard.catchRate}" min="1" max="255" required>
            </div>

            <%-- New image upload --%>
            <div class="form-group">
              <label class="form-label" for="cardImage">Replace Image (optional)</label>
              <c:if test="${not empty editCard.imagePath}">
                <img src="${pageContext.request.contextPath}/images/<c:out value='${editCard.imagePath}'/>"
                     alt="Current image"
                     style="width:60px;height:60px;object-fit:contain;display:block;margin-bottom:6px;border:1px solid var(--border);border-radius:4px;">
              </c:if>
              <input class="form-control" type="file" id="cardImage" name="cardImage"
                     accept="image/*" onchange="previewImage(this)">
              <img id="img-preview" style="display:none;margin-top:6px;width:60px;height:60px;object-fit:contain;">
            </div>
          </div>

          <%-- Description --%>
          <div class="form-group">
            <label class="form-label" for="description">Description</label>
            <textarea class="form-control" id="description" name="description"
                      rows="3" maxlength="500"><c:out value="${editCard.description}"/></textarea>
          </div>

          <div style="display:flex;gap:10px;margin-top:6px;">
            <button type="submit" class="btn-red">💾 Save Changes</button>
            <a href="${pageContext.request.contextPath}/cards" class="btn-ghost">Cancel</a>
          </div>

        </form>
      </div>
    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">✏️</span>
    <span class="chatbar-label">Edit Card</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
