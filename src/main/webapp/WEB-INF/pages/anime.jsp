<%-- ═══════════════════════════════════════════════════════
     anime.jsp — PokéMuseum Anime Watch Page
     Served by : AnimeServlet (GET /anime)
     API used  : YouTube Data API v3
     JSTL used : c:forEach, c:if, c:out, c:choose
     Author    : Alwin Maharjan | CS5003NI

     How it works:
       1. AnimeServlet calls YouTube API and puts results in request
       2. This JSP renders the video grid using c:forEach
       3. Clicking a card sets the videoId → shows YouTube embed player
       4. Search form POSTs back to /anime?q=... for new results
═══════════════════════════════════════════════════════ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Watch Anime</title>

  <%-- ── Internal CSS (Vortex theme — same as vortex.css) ── --%>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Oxanium:wght@400;600;700;800&family=Nunito:wght@400;600;700;800&display=swap');

    :root {
      --bg: #1a1a1a; --bg-deep: #111; --bg-panel: #242424;
      --bg-card: #2c2c2c; --nav: #1e1e1e;
      --red: #cc1a1a; --red-dark: #8a0f0f; --red-light: #e02020;
      --gold: #ffd700; --blue: #4fc3f7; --green: #4caf50;
      --white: #f0f0f0; --text: #dddddd; --text-dim: #999;
      --border: #3a3a3a;
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Nunito', sans-serif; background: var(--bg-deep); color: var(--text); min-height: 100vh; display: flex; flex-direction: column; }
    a { text-decoration: none; color: inherit; }
    ::-webkit-scrollbar { width: 6px; } ::-webkit-scrollbar-track { background: var(--bg); } ::-webkit-scrollbar-thumb { background: var(--red-dark); border-radius: 3px; }

    /* Topbar */
    .topbar { background: var(--nav); border-bottom: 3px solid var(--red); display: flex; align-items: center; height: 52px; padding: 0 16px; position: sticky; top: 0; z-index: 1000; gap: 0; flex-shrink: 0; }
    .topbar-logo { font-family: 'Oxanium', monospace; font-size: 20px; font-weight: 800; color: var(--white); margin-right: 20px; }
    .topbar-logo span { color: var(--red); }
    .topbar-meta { display: flex; align-items: center; gap: 16px; font-size: 11px; color: var(--text-dim); margin-right: auto; }
    .topbar-nav { display: flex; gap: 3px; margin-left: auto; }
    .nav-btn { background: var(--red); color: var(--white); padding: 7px 20px; font-family: 'Oxanium', monospace; font-size: 12px; font-weight: 700; letter-spacing: 0.8px; cursor: pointer; transition: background 0.15s; clip-path: polygon(8px 0%, 100% 0%, calc(100% - 8px) 100%, 0% 100%); border: none; display: inline-flex; align-items: center; }
    .nav-btn:hover { background: var(--red-light); }
    .nav-btn.active { background: var(--red-dark); }
    .topbar-right { display: flex; align-items: center; gap: 12px; margin-left: 14px; }
    .logout-btn { background: none; border: none; color: var(--text-dim); font-size: 18px; padding: 4px 8px; cursor: pointer; }
    .logout-btn:hover { color: var(--red); }

    /* Layout */
    .page-layout { display: flex; flex: 1; overflow: hidden; }
    .sidebar { width: 30px; background: var(--red-dark); display: flex; flex-direction: column; align-items: center; padding: 10px 0; gap: 3px; flex-shrink: 0; border-right: 1px solid var(--red); }
    .sidebar-tab { writing-mode: vertical-rl; transform: rotate(180deg); background: var(--red); color: var(--white); font-family: 'Oxanium', monospace; font-size: 9px; font-weight: 800; letter-spacing: 1.2px; text-transform: uppercase; padding: 10px 5px; cursor: pointer; width: 26px; text-align: center; border: none; border-radius: 2px; text-decoration: none; display: block; }
    .sidebar-tab:hover { background: var(--red-light); }
    .sidebar-tab.active { background: #111; color: var(--red); }
    .main-content { flex: 1; overflow-y: auto; background: var(--bg); display: flex; flex-direction: column; }

    /* Section header */
    .section-header { background: linear-gradient(90deg, var(--red) 0%, var(--red-dark) 100%); padding: 10px 18px; font-family: 'Oxanium', monospace; font-size: 14px; font-weight: 700; color: var(--white); display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }

    /* Video Player */
    .player-section { background: #000; position: relative; }
    .player-container { max-width: 900px; margin: 0 auto; padding: 16px; }
    .player-frame { width: 100%; aspect-ratio: 16/9; border: none; border-radius: 6px; background: #111; display: block; }
    .player-info { max-width: 900px; margin: 0 auto; padding: 10px 16px 16px; }
    .player-title { font-family: 'Oxanium', monospace; font-size: 16px; font-weight: 800; color: var(--white); margin-bottom: 4px; }
    .player-meta  { font-size: 11px; color: var(--text-dim); display: flex; gap: 16px; }
    .player-placeholder { max-width: 900px; margin: 0 auto; padding: 32px 16px; text-align: center; }
    .player-placeholder .ph-icon { font-size: 48px; margin-bottom: 12px; display: block; }
    .player-placeholder p { color: var(--text-dim); font-size: 13px; }

    /* Search row */
    .search-row { display: flex; gap: 8px; padding: 10px 14px; background: var(--bg-panel); border-bottom: 1px solid var(--border); align-items: center; flex-wrap: wrap; flex-shrink: 0; }
    .search-input { flex: 1; min-width: 200px; padding: 8px 12px; background: var(--bg-deep); border: 1px solid var(--border); border-radius: 4px; color: var(--white); font-size: 13px; outline: none; }
    .search-input:focus { border-color: var(--red); }
    .search-input::placeholder { color: #555; }
    .search-btn { background: var(--red); border: none; color: var(--white); padding: 8px 18px; border-radius: 4px; font-size: 12px; font-weight: 700; cursor: pointer; font-family: 'Oxanium', monospace; letter-spacing: 0.5px; }
    .search-btn:hover { background: var(--red-light); }

    /* Season pills */
    .season-pills { display: flex; gap: 6px; padding: 10px 14px; background: var(--bg-panel); border-bottom: 1px solid var(--border); overflow-x: auto; flex-shrink: 0; }
    .season-pills::-webkit-scrollbar { height: 3px; }
    .season-pill { padding: 4px 12px; border-radius: 12px; background: var(--bg-card); border: 1px solid var(--border); font-size: 10px; font-weight: 700; font-family: 'Oxanium', monospace; color: var(--text-dim); cursor: pointer; white-space: nowrap; text-decoration: none; transition: all 0.15s; }
    .season-pill:hover { border-color: var(--red); color: var(--white); }
    .season-pill.active { background: var(--red); color: var(--white); border-color: var(--red); }

    /* Video grid */
    .video-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; padding: 14px; }
    .video-card { background: var(--bg-card); border: 1px solid var(--border); border-radius: 8px; overflow: hidden; cursor: pointer; transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s; text-decoration: none; display: block; }
    .video-card:hover { transform: translateY(-3px); border-color: var(--red); box-shadow: 0 6px 20px rgba(0,0,0,0.5), 0 0 12px rgba(204,26,26,0.25); }
    .video-card.active { border-color: var(--red); box-shadow: 0 0 0 2px var(--red); }
    .video-thumb { width: 100%; aspect-ratio: 16/9; object-fit: cover; display: block; background: #111; }
    .video-thumb-placeholder { width: 100%; aspect-ratio: 16/9; background: linear-gradient(135deg, #1a1a1a, #2a1a1a); display: flex; align-items: center; justify-content: center; font-size: 32px; }
    .video-info { padding: 10px 10px 8px; }
    .video-title { font-size: 11px; font-weight: 800; color: var(--white); line-height: 1.4; margin-bottom: 4px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    .video-channel { font-size: 9px; color: var(--text-dim); font-family: 'Oxanium', monospace; }
    .video-date { font-size: 9px; color: var(--text-dim); margin-top: 2px; }
    .play-badge { display: inline-flex; align-items: center; gap: 4px; background: rgba(204,26,26,0.15); border: 1px solid rgba(204,26,26,0.3); border-radius: 10px; padding: 2px 8px; font-size: 9px; font-weight: 700; color: var(--red); font-family: 'Oxanium', monospace; margin-top: 5px; }

    /* Error alert */
    .api-error { background: rgba(204,26,26,0.1); border: 1px solid rgba(204,26,26,0.3); border-radius: 4px; padding: 14px 16px; margin: 14px; font-size: 12px; color: #ff8a8a; }
    .api-error strong { color: var(--red); }
    .api-key-notice { background: rgba(255,215,0,0.08); border: 1px solid rgba(255,215,0,0.25); border-radius: 4px; padding: 12px 16px; margin: 14px; font-size: 11px; color: var(--gold); }

    /* Empty state */
    .empty-state { text-align: center; padding: 48px 20px; color: var(--text-dim); }
    .empty-icon  { font-size: 48px; display: block; margin-bottom: 14px; }

    /* Results count */
    .results-meta { padding: 8px 16px; font-size: 11px; color: var(--text-dim); background: var(--bg-panel); border-bottom: 1px solid var(--border); }

    /* Chatbar */
    .chatbar { height: 36px; background: var(--nav); border-top: 1px solid var(--border); display: flex; align-items: center; padding: 0 12px; gap: 12px; flex-shrink: 0; margin-top: auto; }
    .online-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--green); }
    .chatbar-label { font-size: 11px; color: var(--text-dim); display: flex; align-items: center; gap: 5px; }
    .chatbar-right { margin-left: auto; display: flex; align-items: center; gap: 14px; }
    .clock-display { font-family: 'Oxanium', monospace; font-size: 12px; font-weight: 700; color: var(--gold); display: flex; align-items: center; gap: 5px; }
    .btn-ghost { background: transparent; color: var(--text-dim); border: 1px solid var(--border); padding: 4px 12px; border-radius: 3px; font-family: 'Oxanium', monospace; font-size: 10px; font-weight: 700; cursor: pointer; transition: all 0.15s; text-decoration: none; display: inline-block; }
    .btn-ghost:hover { border-color: var(--red); color: var(--white); }
  </style>
</head>
<body>

  <%-- ── Topbar ─────────────────────────────────── --%>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <div class="topbar-meta">
      <span style="color:#f0f0f0;font-weight:800;">
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"   class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/anime"  class="nav-btn active">ANIME</a>
      <a href="${pageContext.request.contextPath}/catch"  class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"  class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/quests" class="nav-btn">QUESTS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn" title="Logout">⇥</a>
    </div>
  </div>

  <div class="page-layout">

    <%-- Sidebar --%>
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/anime"     class="sidebar-tab active">ANIME</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab">CATCH</a>
    </nav>

    <main class="main-content">

      <%-- ── API Key Notice (show if not configured) ── --%>
      <c:if test="${not empty apiError and apiError.contains('API key')}">
        <div class="api-key-notice">
          ⚠️ <strong>YouTube API key not configured.</strong>
          Open <code>AnimeServlet.java</code> and replace <code>YOUR_API_KEY_HERE</code>
          with your key from Google Cloud Console.
          <a href="https://console.cloud.google.com/" target="_blank"
             style="color:var(--gold);font-weight:800;">Get API Key →</a>
        </div>
      </c:if>

      <%-- ── Video Player Section ───────────────────── --%>
      <div class="player-section">
        <c:choose>
          <c:when test="${not empty activeVideoId}">
            <%-- Embed the selected YouTube video --%>
            <div class="player-container">
              <iframe class="player-frame"
                      src="https://www.youtube.com/embed/${activeVideoId}?autoplay=0&rel=0&modestbranding=1"
                      title="<c:out value='${activeVideoTitle}'/>"
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                      allowfullscreen>
              </iframe>
            </div>
            <div class="player-info">
              <div class="player-title"><c:out value="${activeVideoTitle}"/></div>
              <div class="player-meta">
                <span>🎬 Pokémon Anime</span>
                <a href="https://www.youtube.com/watch?v=${activeVideoId}"
                   target="_blank" style="color:var(--red);">Watch on YouTube ↗</a>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <div class="player-placeholder">
              <span class="ph-icon">📺</span>
              <p style="font-size:16px;color:#f0f0f0;font-weight:700;margin-bottom:6px;">
                Pokémon Anime Viewer
              </p>
              <p>Select any episode below to start watching!</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <div class="section-header">
        📺 Pokémon Anime Episodes
        <span style="font-size:11px;opacity:0.7;">
          Powered by YouTube Data API v3
          <c:if test="${resultCount > 0}">
            · <c:out value="${resultCount}"/> results
          </c:if>
        </span>
      </div>

      <%-- ── Search Row ──────────────────────────────── --%>
      <form method="get" action="${pageContext.request.contextPath}/anime">
        <div class="search-row">
          <input type="text"
                 name="q"
                 class="search-input"
                 placeholder="Search episodes... (e.g. Pikachu, Charizard, Misty)"
                 value="<c:out value='${searchQuery}'/>">
          <button type="submit" class="search-btn">🔍 Search</button>
          <a href="${pageContext.request.contextPath}/anime"
             class="btn-ghost">Clear</a>
        </div>
      </form>

      <%-- ── Season Filter Pills ─────────────────────── --%>
      <div class="season-pills">
        <c:forEach var="season" items="${seasons}">
          <a href="${pageContext.request.contextPath}/anime?season=<c:out value='${season[0]}'/>"
             class="season-pill <c:if test='${activeSeason eq season[0]}'>active</c:if>">
            <c:out value="${season[1]}"/>
          </a>
        </c:forEach>
      </div>

      <%-- ── API Error display ───────────────────────── --%>
      <c:if test="${not empty apiError}">
        <div class="api-error">
          <strong>⚠️ Could not load episodes</strong><br>
          <c:out value="${apiError}"/>
          <br><br>
          <strong>Fix:</strong> Open <code>AnimeServlet.java</code> →
          replace <code>YOUR_API_KEY_HERE</code> with your YouTube API key.
          <a href="https://console.cloud.google.com/" target="_blank"
             style="color:var(--gold);">Get free key →</a>
        </div>
      </c:if>

      <%-- ── Video Results Grid ──────────────────────── --%>
      <div class="video-grid">
        <c:choose>
          <c:when test="${empty videos and empty apiError}">
            <div class="empty-state" style="grid-column:1/-1;">
              <span class="empty-icon">📭</span>
              <p>No episodes found. Try a different search term!</p>
            </div>
          </c:when>
          <c:otherwise>
            <%-- c:forEach iterates over the List<Map> returned by AnimeServlet --%>
            <c:forEach var="video" items="${videos}">
              <a href="${pageContext.request.contextPath}/anime?videoId=<c:out value='${video.videoId}'/>&videoTitle=<c:out value='${video.title}'/>&q=<c:out value='${searchQuery}'/>&season=<c:out value='${activeSeason}'/>"
                 class="video-card <c:if test='${activeVideoId eq video.videoId}'>active</c:if>">

                <%-- Thumbnail --%>
                <c:choose>
                  <c:when test="${not empty video.thumbnail}">
                    <img class="video-thumb"
                         src="<c:out value='${video.thumbnail}'/>"
                         alt="<c:out value='${video.title}'/>"
                         loading="lazy">
                  </c:when>
                  <c:otherwise>
                    <div class="video-thumb-placeholder">🎬</div>
                  </c:otherwise>
                </c:choose>

                <div class="video-info">
                  <div class="video-title"><c:out value="${video.title}"/></div>
                  <div class="video-channel"><c:out value="${video.channelTitle}"/></div>
                  <div class="video-date">📅 <c:out value="${video.publishedAt}"/></div>
                  <div class="play-badge">▶ Watch Episode</div>
                </div>
              </a>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

    </main>
  </div>

  <%-- Chatbar --%>
  <div class="chatbar">
    <span style="font-size:15px;">📺</span>
    <span class="chatbar-label"><span class="online-dot"></span> Anime Viewer</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span id="clock">--:--</span></span>
    </div>
  </div>

  <script>
    // Clock update
    function tick() {
      const now = new Date();
      document.getElementById('clock').textContent =
        String(now.getHours()).padStart(2,'0') + ':' +
        String(now.getMinutes()).padStart(2,'0');
    }
    tick(); setInterval(tick, 30000);
  </script>

</body>
</html>
