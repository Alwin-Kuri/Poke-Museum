<%--
     anime.jsp — PokéMuseum Anime Watch Page
     Served by : AnimeServlet (GET /anime)
     APIs used :
       Jikan API v4 — episode list, anime metadata
       YouTube API v3 — video search + embed player
     JSTL used : c:forEach, c:if, c:out, c:choose
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Watch Anime</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/anime.css">
</head>
<body>

<%-- Topbar --%>
<div class="topbar">
  <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
  <div class="topbar-meta">
    <span style="color:var(--white);font-weight:800;"><c:out value="${sessionScope.loggedInUser.username}"/></span>
  </div>
  <nav class="topbar-nav">
    <a href="${pageContext.request.contextPath}/home"   class="nav-btn">EXPLORE</a>
    <a href="${pageContext.request.contextPath}/catch"  class="nav-btn">CATCH</a>
    <a href="${pageContext.request.contextPath}/trade"  class="nav-btn">TRADE</a>
    <a href="${pageContext.request.contextPath}/quests" class="nav-btn">QUESTS</a>
    <a href="${pageContext.request.contextPath}/anime"  class="nav-btn active">ANIME</a>
  </nav>
  <div class="topbar-right">
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
  </div>
</div>

<div class="page-layout">
    <%-- Sidebar tabs --%>
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"
         class="sidebar-tab" data-path="/home">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory"
         class="sidebar-tab" data-path="/inventory">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"
         class="sidebar-tab" data-path="/quests">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"
         class="sidebar-tab" data-path="/catch">CATCH</a>
      <a href="${pageContext.request.contextPath}/anime"
         class="sidebar-tab active" data-path="anime">ANIME</a>
    </nav>

  <main class="main-content">

    <%-- ANIME INFO BANNER (from Jikan)--%>
    <div class="section-header">
                  <img class="card-poke-img"
            src="${pageContext.request.contextPath}/images/util/ani.png"
            alt="📦" style="width:32px;height:32px;margin-top:4px;margin-bottom:5px;">
            <span style= "margin-right:1520px">Pokémon Anime</span>
      <span style="font-size:10px;opacity:.7;">
        Jikan API + YouTube API
      </span>
    </div>

    <c:if test="${not empty animeInfo}">
      <div class="anime-banner">
        <%-- Anime poster image from Jikan --%>
        <c:choose>
          <c:when test="${not empty animeInfo.imageUrl}">
            <img class="anime-banner-img"
                 src="<c:out value='${animeInfo.imageUrl}'/>"
                 alt="<c:out value='${animeInfo.title}'/>">
          </c:when>
          <c:otherwise>
            <div class="anime-banner-img placeholder">📺</div>
          </c:otherwise>
        </c:choose>

        <div class="anime-banner-info">
          <div class="anime-banner-title">
            <c:out value="${animeInfo.title}"/>
          </div>
          <div class="anime-banner-meta">
            <c:if test="${not empty animeInfo.episodes and animeInfo.episodes > 0}">
              <span class="anime-meta-pill">
                📺 <c:out value="${animeInfo.episodes}"/> Episodes
              </span>
            </c:if>
            <c:if test="${not empty animeInfo.year and animeInfo.year > 0}">
              <span class="anime-meta-pill">
                📅 <c:out value="${animeInfo.year}"/>
              </span>
            </c:if>
            <c:if test="${not empty animeInfo.score and animeInfo.score > 0}">
              <span class="anime-meta-pill gold">
                ⭐ <c:out value="${animeInfo.score}"/> / 10
              </span>
            </c:if>
            <c:if test="${not empty animeInfo.status}">
              <span class="anime-meta-pill">
                <c:out value="${animeInfo.status}"/>
              </span>
            </c:if>
          </div>
          <div class="anime-banner-synopsis">
            <c:out value="${animeInfo.synopsis}"/>
          </div>

          <%-- Play trailer if Jikan returned a YouTube ID --%>
          <c:if test="${not empty animeInfo.trailerId}">
            <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&videoId=<c:out value='${animeInfo.trailerId}'/>&videoTitle=Trailer&tab=episodes"
               style="display:inline-flex;align-items:center;gap:6px;margin-top:10px;background:var(--red);color:var(--white);padding:5px 14px;border-radius:3px;font-family:'Oxanium',monospace;font-size:10px;font-weight:700;letter-spacing:.5px;">
              ▶ Watch Trailer
            </a>
          </c:if>
        </div>
      </div>
    </c:if>

    <%-- Jikan error --%>
    <c:if test="${not empty jikanError}">
      <div class="alert alert-err">
        ⚠️ <c:out value="${jikanError}"/>
      </div>
    </c:if>

    <%--SEASON SELECTOR PILLS--%>
    <div class="season-strip">
      <c:forEach var="s" items="${seasons}">
        <a href="${pageContext.request.contextPath}/anime?malId=${s[0]}&tab=episodes"
           class="season-pill <c:if test='${activeMalId == s[0]}'>active</c:if>">
          <c:out value="${s[2]}"/> — <c:out value="${s[1]}"/>
        </a>
      </c:forEach>
    </div>

    <%-- TABS: Episodes | Watch on YouTube--%>
    <div class="tab-row">
      <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&page=${activePage}&tab=episodes"
         class="tab-item <c:if test='${activeTab eq "episodes"}'>active</c:if>">
        📋 Episode List
      </a>
      <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&tab=youtube"
         class="tab-item <c:if test='${activeTab eq "youtube"}'>active</c:if>">
        ▶ Watch on YouTube
      </a>
    </div>

    <%--  
         YOUTUBE PLAYER — shown when videoId set
      --%>
    <c:if test="${not empty activeVideoId}">
      <div class="player-wrap">
        <div class="player-inner">
          <iframe class="player-iframe"
                  src="https://www.youtube.com/embed/${activeVideoId}?autoplay=0&rel=0&modestbranding=1"
                  title="<c:out value='${activeTitle}'/>"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen>
          </iframe>
        </div>
        <div class="player-meta">
          <div class="player-title"><c:out value="${activeTitle}"/></div>
          <a class="player-link"
             href="https://www.youtube.com/watch?v=${activeVideoId}"
             target="_blank">
            Open in YouTube ↗
          </a>
        </div>
      </div>
    </c:if>

    <%--  
         TAB: EPISODE LIST (Jikan data)
      --%>
    <c:if test="${activeTab eq 'episodes'}">
      <div class="episode-list">
        <c:choose>
          <c:when test="${empty episodes}">
            <div class="empty-state">
              <span class="ei">📭</span>
              <p>No episodes found for this season.</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="ep" items="${episodes}">
              <%--
                Clicking an episode searches YouTube for that episode title.
                We build the YouTube search URL client-side via JS to avoid
                an extra servlet round-trip.
              --%>
              <a class="episode-item <c:if test='${not empty activeVideoId}'><%-- highlight if playing --%></c:if>"
                 href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&page=${activePage}&tab=youtube&search=Pokemon+<c:out value='${ep.title}'/>&videoTitle=<c:out value='${ep.title}'/>">

                <span class="ep-num">
                  <c:out value="${ep.malId}"/>
                </span>

                <div class="ep-info">
                  <div class="ep-title"><c:out value="${ep.title}"/></div>
                  <c:if test="${not empty ep.titleJp}">
                    <div class="ep-title-jp"><c:out value="${ep.titleJp}"/></div>
                  </c:if>
                </div>

                <div class="ep-meta">
                  <%-- Filler badge --%>
                  <c:if test="${ep.filler eq true}">
                    <span class="ep-badge ep-filler">Filler</span>
                  </c:if>
                  <%-- Recap badge --%>
                  <c:if test="${ep.recap eq true}">
                    <span class="ep-badge ep-recap">Recap</span>
                  </c:if>
                  <%-- Score --%>
                  <c:if test="${ep.score > 0}">
                    <span class="ep-score">⭐ <c:out value="${ep.score}"/></span>
                  </c:if>
                  <%-- Air date --%>
                  <c:if test="${not empty ep.aired}">
                    <span class="ep-date"><c:out value="${ep.aired}"/></span>
                  </c:if>
                  <span class="ep-play">▶</span>
                </div>
              </a>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

      <%-- Pagination --%>
      <div class="pagination">
        <c:if test="${activePage > 1}">
          <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&page=${prevPage}&tab=episodes"
             class="page-btn">← Previous</a>
        </c:if>
        <span class="page-info">Page <c:out value="${activePage}"/></span>
        <c:if test="${hasNextPage}">
          <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&page=${nextPage}&tab=episodes"
             class="page-btn">Next →</a>
        </c:if>
      </div>
    </c:if>

    <%--  
         TAB: YOUTUBE SEARCH
      --%>
    <c:if test="${activeTab eq 'youtube'}">

      <%-- YouTube not configured notice --%>
      <c:if test="${not ytConfigured}">
        <div class="alert alert-warn">
          ⚠️ <strong>YouTube API key not configured.</strong>
          Open <code>AnimeServlet.java</code> → replace
          <code>YOUR_YOUTUBE_API_KEY_HERE</code> with your key from
          <a href="https://console.cloud.google.com/" target="_blank">Google Cloud Console</a>.
          Free tier gives 10,000 units/day.
        </div>
      </c:if>

      <%-- YouTube API error --%>
      <c:if test="${not empty ytError}">
        <div class="alert alert-err">⚠️ <c:out value="${ytError}"/></div>
      </c:if>

      <%-- Search form for YouTube --%>
      <form method="get" action="${pageContext.request.contextPath}/anime">
        <input type="hidden" name="malId" value="${activeMalId}">
        <input type="hidden" name="tab"   value="youtube">
        <div class="search-row">
          <input type="text" name="search" class="search-input"
                 placeholder="Search YouTube for episodes... (e.g. Pikachu, Charizard)"
                 value="<c:out value='${ytSearch}'/>">
          <button type="submit" class="search-btn">🔍 Search YouTube</button>
          <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&tab=youtube"
             class="btn-ghost">Clear</a>
        </div>
      </form>

      <%-- YouTube video grid --%>
      <c:choose>
        <c:when test="${empty ytVideos and ytConfigured}">
          <div class="empty-state">
            <span class="ei">📭</span>
            <p>No videos found. Try a different search term!</p>
          </div>
        </c:when>
        <c:otherwise>
          <div class="yt-grid">
            <c:forEach var="v" items="${ytVideos}">
              <a href="${pageContext.request.contextPath}/anime?malId=${activeMalId}&tab=youtube&videoId=<c:out value='${v.videoId}'/>&videoTitle=<c:out value='${v.title}'/>&search=<c:out value='${ytSearch}'/>"
                 class="yt-card <c:if test='${activeVideoId eq v.videoId}'>active</c:if>">
                <c:choose>
                  <c:when test="${not empty v.thumbnail}">
                    <img class="yt-thumb"
                         src="<c:out value='${v.thumbnail}'/>"
                         alt="<c:out value='${v.title}'/>"
                         loading="lazy">
                  </c:when>
                  <c:otherwise>
                    <div class="yt-thumb-ph">🎬</div>
                  </c:otherwise>
                </c:choose>
                <div class="yt-info">
                  <div class="yt-title"><c:out value="${v.title}"/></div>
                  <div class="yt-channel"><c:out value="${v.channel}"/></div>
                  <div class="yt-play">▶ Watch</div>
                </div>
              </a>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </c:if>

  </main>
</div>

<div class="chatbar">
  <span style="font-size:15px;">📺</span>
  <span class="chatbar-label"> Anime Viewer</span>
  <div class="chatbar-right">🕐 <span id="clk">--:--</span></div>
</div>

<script>
  function tick(){const n=new Date();document.getElementById('clk').textContent=String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0');}
  tick();setInterval(tick,30000);
</script>
</body>
</html>
