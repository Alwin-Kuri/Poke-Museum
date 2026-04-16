<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Add Card</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vortex.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-btn">DASHBOARD</a>
      <a href="${pageContext.request.contextPath}/cards"           class="nav-btn">CARDS</a>
      <a href="${pageContext.request.contextPath}/cards?action=add" class="nav-btn active">ADD CARD</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-tab">DASH</a>
      <a href="${pageContext.request.contextPath}/cards"           class="sidebar-tab">CARDS</a>
      <a href="${pageContext.request.contextPath}/cards?action=add" class="sidebar-tab active">ADD</a>
      <a href="${pageContext.request.contextPath}/admin/users"     class="sidebar-tab">USERS</a>
    </nav>

    <main class="main-content">
      <div class="section-header">
        ➕ Add New Card
        <a href="${pageContext.request.contextPath}/cards" class="btn-ghost btn-sm">← Back to Cards</a>
      </div>

      <div style="padding:20px;max-width:680px;">

        <%-- Error alert --%>
        <c:if test="${not empty errorMsg}">
          <div class="alert-error" style="margin-bottom:16px;">
            ⚠️ <c:out value="${errorMsg}"/>
          </div>
        </c:if>

        <%-- Form — multipart for image upload --%>
        <form method="post"
              action="${pageContext.request.contextPath}/cards"
              enctype="multipart/form-data">
          <input type="hidden" name="action" value="add">

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">

            <%-- Card Code --%>
            <div class="form-group">
              <label class="form-label" for="cardCode">Card Code *</label>
              <input class="form-control" type="text" id="cardCode" name="cardCode"
                     placeholder="e.g. PC021" required
                     pattern="PC\d{3,6}" title="Format: PC followed by numbers">
              <div class="form-hint">Format: PC001, PC021 etc.</div>
            </div>

            <%-- Name --%>
            <div class="form-group">
              <label class="form-label" for="name">Pokémon Name *</label>
              <input class="form-control" type="text" id="name" name="name"
                     placeholder="e.g. Charizard" required maxlength="100">
            </div>

            <%-- Type --%>
            <div class="form-group">
              <label class="form-label" for="type">Type *</label>
              <select class="form-control" id="type" name="type" required>
                <option value="">Select type...</option>
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
                <option value="Rock">🪨 Rock</option>
                <option value="Ground">🌍 Ground</option>
                <option value="Ice">🧊 Ice</option>
                <option value="Dark">🌑 Dark</option>
                <option value="Steel">⚙️ Steel</option>
              </select>
            </div>

            <%-- Rarity --%>
            <div class="form-group">
              <label class="form-label" for="rarity">Rarity *</label>
              <select class="form-control" id="rarity" name="rarity" required>
                <option value="">Select rarity...</option>
                <option value="Common">Common</option>
                <option value="Rare">Rare</option>
                <option value="Epic">Epic</option>
                <option value="Legendary">Legendary</option>
              </select>
            </div>

            <%-- Condition --%>
            <div class="form-group">
              <label class="form-label" for="conditionState">Condition *</label>
              <select class="form-control" id="conditionState" name="conditionState" required>
                <option value="Mint">Mint</option>
                <option value="Near Mint">Near Mint</option>
                <option value="Good">Good</option>
                <option value="Fair">Fair</option>
                <option value="Poor">Poor</option>
              </select>
            </div>

            <%-- Value --%>
            <div class="form-group">
              <label class="form-label" for="value">Market Value ($) *</label>
              <input class="form-control" type="number" id="value" name="value"
                     placeholder="e.g. 420.00" min="0" step="0.01" required>
            </div>

            <%-- Catch Rate --%>
            <div class="form-group">
              <label class="form-label" for="catchRate">Catch Rate (1–255) *</label>
              <input class="form-control" type="number" id="catchRate" name="catchRate"
                     placeholder="e.g. 45" min="1" max="255" required>
              <div class="form-hint">Lower = harder to catch. Legendary = 3–5, Common = 150–200</div>
            </div>

            <%-- Image upload --%>
            <div class="form-group">
              <label class="form-label" for="cardImage">Card Image (optional)</label>
              <input class="form-control" type="file" id="cardImage" name="cardImage"
                     accept="image/*" onchange="previewImage(this)">
              <img id="img-preview" src="" alt="Preview"
                   style="display:none;margin-top:8px;width:80px;height:80px;object-fit:contain;border:1px solid var(--border);border-radius:4px;">
            </div>
          </div>

          <%-- Description — full width --%>
          <div class="form-group">
            <label class="form-label" for="description">Description</label>
            <textarea class="form-control" id="description" name="description"
                      rows="3" placeholder="Optional flavour text about this Pokémon..."
                      maxlength="500"></textarea>
          </div>

          <div style="display:flex;gap:10px;margin-top:6px;">
            <button type="submit" class="btn-red">➕ Add Card to Museum</button>
            <a href="${pageContext.request.contextPath}/cards" class="btn-ghost">Cancel</a>
          </div>

        </form>
      </div>
    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">➕</span>
    <span class="chatbar-label">Add New Card</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
