<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Quests</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">Pokémon <span>Museum</span></a>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span>
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"   class="nav-btn">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/quests" class="nav-btn active">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"  class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"  class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster" class="nav-btn">PACKS</a>
    </nav>
    <div class="topbar-right">
      <span class="streak-badge">🔥 <c:out value="${sessionScope.loggedInUser.loginStreak}"/></span>
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"      class="sidebar-tab">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory" class="sidebar-tab">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"    class="sidebar-tab active">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"     class="sidebar-tab">CATCH</a>
    </nav>

    <main class="main-content">

      <%-- Success / error toasts --%>
      <c:if test="${param.success eq 'claimed'}">
        <script>document.addEventListener('DOMContentLoaded',()=>showToast('Quest reward claimed! 🎁'));</script>
      </c:if>
      <c:if test="${not empty param.error}">
        <script>document.addEventListener('DOMContentLoaded',()=>showToast('Could not claim reward.', true));</script>
      </c:if>

      <div class="section-header">
        🎯 Quests &amp; Achievements
        <div class="header-tabs">
          <button class="header-tab active js-quest-tab"
                  onclick="switchQuestTab(this,'daily')">Daily</button>
          <button class="header-tab js-quest-tab"
                  onclick="switchQuestTab(this,'weekly')">Weekly</button>
          <button class="header-tab js-quest-tab"
                  onclick="switchQuestTab(this,'permanent')">Achievements</button>
        </div>
      </div>

      <div class="quest-list">

        <%-- Daily quests --%>
        <c:forEach var="p" items="${dailyQuests}">
          <div class="quest-item" data-type="daily">
            <div class="quest-icon
              <c:choose>
                <c:when test="${p.completed and p.claimed}">qi-done</c:when>
                <c:otherwise>qi-daily</c:otherwise>
              </c:choose>">
              <c:out value="${p.quest.questEmoji}"/>
            </div>
            <div class="quest-info">
              <div class="quest-title">
                <c:out value="${p.quest.title}"/>
                <span class="tag tag-daily">Daily</span>
              </div>
              <div class="quest-desc"><c:out value="${p.quest.description}"/></div>
              <div class="quest-reward">
                🎁 Reward:
                <c:choose>
                  <c:when test="${p.quest.rewardType eq 'coins'}">
                    +<c:out value="${p.quest.rewardValue}"/> PokéCoins
                  </c:when>
                  <c:when test="${p.quest.rewardType eq 'basic_pack'}">Basic Booster Pack</c:when>
                  <c:when test="${p.quest.rewardType eq 'elite_pack'}">Elite Booster Pack</c:when>
                  <c:when test="${p.quest.rewardType eq 'master_pack'}">Master Booster Pack</c:when>
                  <c:otherwise><c:out value="${p.quest.rewardType}"/></c:otherwise>
                </c:choose>
              </div>
            </div>
            <div class="quest-right">
              <c:choose>
                <c:when test="${p.claimed}">
                  <div class="quest-done-label">✓ Claimed!</div>
                </c:when>
                <c:when test="${p.completed}">
                  <form method="post" action="${pageContext.request.contextPath}/quests">
                    <input type="hidden" name="action"  value="claim">
                    <input type="hidden" name="questId" value="${p.questId}">
                    <button type="submit" class="quest-claim-btn">Claim ✓</button>
                  </form>
                </c:when>
                <c:otherwise>
                  <div class="progress-meta">
                    <span>Progress</span>
                    <span><c:out value="${p.progressLabel}"/></span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill blue"
                         style="width:${p.progressPercent}%">
                    </div>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>

        <%-- Weekly quests (hidden by default, shown via JS tab) --%>
        <c:forEach var="p" items="${weeklyQuests}">
          <div class="quest-item" data-type="weekly" style="display:none;">
            <div class="quest-icon
              <c:choose>
                <c:when test="${p.completed and p.claimed}">qi-done</c:when>
                <c:otherwise>qi-weekly</c:otherwise>
              </c:choose>">
              <c:out value="${p.quest.questEmoji}"/>
            </div>
            <div class="quest-info">
              <div class="quest-title">
                <c:out value="${p.quest.title}"/>
                <span class="tag tag-weekly">Weekly</span>
              </div>
              <div class="quest-desc"><c:out value="${p.quest.description}"/></div>
              <div class="quest-reward">
                🎁 Reward:
                <c:choose>
                  <c:when test="${p.quest.rewardType eq 'coins'}">+<c:out value="${p.quest.rewardValue}"/> PokéCoins</c:when>
                  <c:when test="${p.quest.rewardType eq 'elite_pack'}">Elite Booster Pack</c:when>
                  <c:when test="${p.quest.rewardType eq 'rare_card'}">Rare Card</c:when>
                  <c:otherwise><c:out value="${p.quest.rewardType}"/></c:otherwise>
                </c:choose>
              </div>
            </div>
            <div class="quest-right">
              <c:choose>
                <c:when test="${p.claimed}">
                  <div class="quest-done-label">✓ Claimed!</div>
                </c:when>
                <c:when test="${p.completed}">
                  <form method="post" action="${pageContext.request.contextPath}/quests">
                    <input type="hidden" name="action"  value="claim">
                    <input type="hidden" name="questId" value="${p.questId}">
                    <button type="submit" class="quest-claim-btn">Claim ✓</button>
                  </form>
                </c:when>
                <c:otherwise>
                  <div class="progress-meta">
                    <span>Progress</span>
                    <span><c:out value="${p.progressLabel}"/></span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill"
                         style="width:${p.progressPercent}%;background:linear-gradient(90deg,#7b1fa2,var(--rar-epic));">
                    </div>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>

        <%-- Permanent achievements (hidden by default) --%>
        <c:forEach var="p" items="${achievements}">
          <div class="quest-item" data-type="permanent" style="display:none;">
            <div class="quest-icon
              <c:choose>
                <c:when test="${p.completed and p.claimed}">qi-done</c:when>
                <c:otherwise>qi-achieve</c:otherwise>
              </c:choose>">
              <c:out value="${p.quest.questEmoji}"/>
            </div>
            <div class="quest-info">
              <div class="quest-title">
                <c:out value="${p.quest.title}"/>
                <span class="tag tag-achieve">Achievement</span>
              </div>
              <div class="quest-desc"><c:out value="${p.quest.description}"/></div>
              <div class="quest-reward">
                🏆 Reward:
                <c:choose>
                  <c:when test="${p.quest.rewardType eq 'coins'}">+<c:out value="${p.quest.rewardValue}"/> PokéCoins</c:when>
                  <c:when test="${p.quest.rewardType eq 'master_pack'}">Master Booster Pack</c:when>
                  <c:when test="${p.quest.rewardType eq 'badge'}">Special Badge</c:when>
                  <c:otherwise><c:out value="${p.quest.rewardType}"/></c:otherwise>
                </c:choose>
              </div>
            </div>
            <div class="quest-right">
              <c:choose>
                <c:when test="${p.claimed}">
                  <div class="quest-done-label" style="color:var(--gold);">★ Completed!</div>
                </c:when>
                <c:when test="${p.completed}">
                  <form method="post" action="${pageContext.request.contextPath}/quests">
                    <input type="hidden" name="action"  value="claim">
                    <input type="hidden" name="questId" value="${p.questId}">
                    <button type="submit" class="quest-claim-btn"
                            style="background:var(--gold);color:#111;">
                      Claim ★
                    </button>
                  </form>
                </c:when>
                <c:otherwise>
                  <div class="progress-meta">
                    <span>Progress</span>
                    <span><c:out value="${p.progressLabel}"/></span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill gold"
                         style="width:${p.progressPercent}%">
                    </div>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>

        <%-- Empty state if no quests --%>
        <c:if test="${empty dailyQuests and empty weeklyQuests and empty achievements}">
          <div class="empty-state">
            <span class="empty-icon">📋</span>
            <p>No quests available right now. Check back soon!</p>
          </div>
        </c:if>

      </div><%-- /quest-list --%>

    </main>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">🎯</span>
    <span class="chatbar-label"><span class="online-dot"></span> Quests Active</span>
    <div class="chatbar-right">
      <span class="coins-display">🪙 <c:out value="${sessionScope.loggedInUser.coins}"/></span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
