<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Digital Card Museum</title>
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <%-- ── Topbar ─────────────────────────────────────── --%>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <div class="topbar-meta">
      <a href="#">Discord</a>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/"         class="nav-btn active">HOME</a>
      <a href="${pageContext.request.contextPath}/register" class="nav-btn">SIGN UP</a>
      <a href="${pageContext.request.contextPath}/login"    class="nav-btn">LOG IN</a>
    </nav>
  </div>

  <%-- ── Hero section ────────────────────────────────── --%>
  <div class="hero">
    <div class="hero-grid-bg"><img src ="${pageContext.request.contextPath}/images/util/back.png"></div>
    <div class="hero-vignette"></div>
    <div class="hero-content">
      <div class="hero-eyebrow">Digital Pokémon Card Museum</div>
      <div class="hero-title">
        Pokémon<br><span class="red">Museum</span>
      </div>
      <div class="hero-sub">
        Collect, catch, and trade Pokémon cards in the ultimate
        digital museum experience. Build your deck, complete quests,
        and become the greatest Trainer.
      </div>
      <div class="hero-btns">
        <a href="${pageContext.request.contextPath}/register" class="btn-red btn-lg">
          SIGN UP FREE
        </a>
        <a href="${pageContext.request.contextPath}/login" class="btn-ghost btn-lg">
          LOG IN
        </a>
      </div>
    </div>

    <%-- Floating Pokémon circles (right side) --%>
    <div class="hero-pokemons">
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi1.png"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi2.png"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi9.png"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi69.png" width = "140px" height = "70px"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi67.png"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi420.png"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi6.png"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi10.png" width = "55px" height = "55px"></div>
      <div class="hero-poke"><img src="${pageContext.request.contextPath}/images/util/chibi11.png"></div>
    </div>
  </div>

  <%-- ── Stats strip ──────────────────────────────────── --%>
  <div class="stat-strip">
    <div class="stat-cell">
      <span class="stat-val"><c:out value="${totalCards}"/></span>
      <div class="stat-lbl">Cards in Museum</div>
    </div>
    <div class="stat-cell">
      <span class="stat-val">
        $<fmt:formatNumber value="${totalValue}" maxFractionDigits="0"/>
      </span>
      <div class="stat-lbl">Total Collection Value</div>
    </div>
    <div class="stat-cell">
      <span class="stat-val">Free</span>
      <div class="stat-lbl">Always &amp; Forever</div>
    </div>
    <div class="stat-cell">
      <span class="stat-val">24/7</span>
      <div class="stat-lbl">Museum is Open</div>
    </div>
  </div>

  <%-- ── Featured Cards ──────────────────────────────── --%>
  <div class="section-header">
    Featured Cards
    <a href="${pageContext.request.contextPath}/login"
       style="font-size:11px;opacity:0.75;">Ready to experience the world of wild, cute Pokemons?</a>
  </div>

  <div class="poke-grid">
    <c:choose>
      <c:when test="${empty featuredCards}">
        <div class="empty-state" style="grid-column:1/-1;">
          <span class="empty-icon">📭</span>
          <p>Museum is being set up. Check back soon!</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="card" items="${featuredCards}">
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
                        <c:when test="${card.type eq 'Fairy'}">🌸</c:when>
                        <c:when test="${card.type eq 'Fighting'}">🥊</c:when>
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
              <a href="${pageContext.request.contextPath}/login"
                 class="card-btn">Login to Collect</a>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>

  <%-- ── Features strip --%>
  <div class="section-header" style="margin-top:4px;">What You Can Do</div>
  <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:1px;background:var(--border);">
    <div style="background:var(--bg-panel);padding:20px;text-align:center;">
       <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/pokeball.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;">
      <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:700;color:var(--white);margin-bottom:6px;">Catch Pokémon</div>
      <div style="font-size:11px;color:var(--text-dim);line-height:1.5;">Throw Pokéballs at wild Pokémon with realistic shake mechanics.</div>
    </div>
    <div style="background:var(--bg-panel);padding:20px;text-align:center;">
       <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/booster.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;">
      <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:700;color:var(--white);margin-bottom:6px;">Open Booster Packs</div>
      <div style="font-size:11px;color:var(--text-dim);line-height:1.5;">Pull cards with real rarity odds: Basic, Elite, and Master packs.</div>
    </div>
    <div style="background:var(--bg-panel);padding:20px;text-align:center;">
       <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/tradecentre.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;">
      <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:700;color:var(--white);margin-bottom:6px;">Trade Cards</div>
      <div style="font-size:11px;color:var(--text-dim);line-height:1.5;">List your cards and offer trades with other trainers.</div>
    </div>
    <div style="background:var(--bg-panel);padding:20px;text-align:center;">
       <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/quest.png"
            alt="📦" style="width:32px;height:32px;margin-bottom:10px;">
      <div style="font-family:'Oxanium',monospace;font-size:13px;font-weight:700;color:var(--white);margin-bottom:6px;">Complete Quests</div>
      <div style="font-size:11px;color:var(--text-dim);line-height:1.5;">Daily, weekly, and permanent achievements with real rewards.</div>
    </div>
  </div>

  <%-- ── CTA ─────────────────────────────────────────── --%>
  <div style="text-align:center;padding:36px 20px;background:var(--bg-panel);border-top:1px solid var(--border);">
    <div style="font-family:'Oxanium',monospace;font-size:22px;font-weight:800;color:var(--white);margin-bottom:8px;">
      Ready to become a Trainer?
    </div>
    <div style="font-size:13px;color:var(--text-dim);margin-bottom:20px;">
      Sign up free and start building your collection today.
    </div>
    <a href="${pageContext.request.contextPath}/register" class="btn-red btn-lg">
      GET STARTED
    </a>
  </div>

  <%-- ── Chatbar ──────────────────────────────────────── --%>
  <div class="chatbar">
    <span class="chatbar-icon">🦇</span>
    <span class="chatbar-label">
         Developed by Alwin Maharjan
    </span>
    <div class="chatbar-right">
      <span class="clock-display"> <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
