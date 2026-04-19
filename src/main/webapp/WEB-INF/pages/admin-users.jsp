<%-- ═══════════════════════════════════════════════════════
     admin-users.jsp — Admin User Management
     Served by : AdminUserServlet (GET /admin/users)
     Requires  : admin role session
     JSTL used : c:forEach, c:if, c:out, c:choose
     Author    : Alwin Maharjan | CS5003NI
═══════════════════════════════════════════════════════ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Admin: Users</title>
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
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-btn">DASHBOARD</a>
      <a href="${pageContext.request.contextPath}/cards"           class="nav-btn">CARDS</a>
      <a href="${pageContext.request.contextPath}/admin/users"     class="nav-btn active">USERS</a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-tab">DASH</a>
      <a href="${pageContext.request.contextPath}/cards"           class="sidebar-tab">CARDS</a>
      <a href="${pageContext.request.contextPath}/cards?action=add" class="sidebar-tab">ADD</a>
      <a href="${pageContext.request.contextPath}/admin/users"     class="sidebar-tab active">USERS</a>
    </nav>

    <main class="main-content">

      <c:if test="${param.success eq 'unlocked'}">
        <script>document.addEventListener('DOMContentLoaded',()=>showToast('Account unlocked! ✅'));</script>
      </c:if>

      <div class="section-header">
        👥 User Management
        <span style="font-size:11px;opacity:0.7;">
          <c:out value="${allUsers.size()}"/> registered trainers
        </span>
      </div>

      <%-- Quick stats --%>
      <div style="display:grid;grid-template-columns:repeat(4,1fr);border-bottom:1px solid var(--border);">
        <c:set var="adminCount"  value="0"/>
        <c:set var="lockedCount" value="0"/>
        <c:forEach var="u" items="${allUsers}">
          <c:if test="${u.role eq 'admin'}">  <c:set var="adminCount"  value="${adminCount + 1}"/></c:if>
          <c:if test="${u.locked}">           <c:set var="lockedCount" value="${lockedCount + 1}"/></c:if>
        </c:forEach>
        <div class="stat-cell">
          <span class="stat-val"><c:out value="${allUsers.size()}"/></span>
          <div class="stat-lbl">Total Users</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val" style="color:var(--blue);">
            <c:out value="${allUsers.size() - adminCount}"/>
          </span>
          <div class="stat-lbl">Trainers</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val" style="color:var(--gold);">
            <c:out value="${adminCount}"/>
          </span>
          <div class="stat-lbl">Admins</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val" style="color:#ff6b6b;">
            <c:out value="${lockedCount}"/>
          </span>
          <div class="stat-lbl">Locked Accounts</div>
        </div>
      </div>

      <%-- Search row --%>
      <div class="search-row">
        <input type="text" class="search-input" placeholder="Search users by username...">
        <select class="filter-select">
          <option value="">All Roles</option>
          <option value="user">Trainer</option>
          <option value="admin">Admin</option>
        </select>
      </div>

      <%-- Users table --%>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Username</th>
              <th>Email</th>
              <th>Role</th>
              <th>Coins</th>
              <th>Streak</th>
              <th>Last Login</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty allUsers}">
                <tr>
                  <td colspan="9" class="text-center text-dim" style="padding:28px;">
                    No users registered yet.
                  </td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="u" items="${allUsers}">
                  <tr>
                    <td class="td-dim mono"><c:out value="${u.userId}"/></td>
                    <td class="td-name"><c:out value="${u.username}"/></td>
                    <td class="td-dim"><c:out value="${u.email}"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${u.role eq 'admin'}">
                          <span style="color:var(--gold);font-weight:800;font-family:'Oxanium',monospace;font-size:10px;">
                            ⚙️ Admin
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span style="color:var(--blue);font-weight:700;font-size:11px;">
                            🎮 Trainer
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="td-gold"><c:out value="${u.coins}"/></td>
                    <td>
                      <span style="color:var(--orange);font-weight:700;">
                        🔥 <c:out value="${u.loginStreak}"/>
                      </span>
                    </td>
                    <td class="td-dim">
                      <c:choose>
                        <c:when test="${not empty u.lastLogin}">
                          <c:out value="${u.lastLogin}"/>
                        </c:when>
                        <c:otherwise>Never</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${u.locked}">
                          <span style="color:#ff6b6b;font-size:10px;font-weight:800;
                                       font-family:'Oxanium',monospace;
                                       background:rgba(204,26,26,0.12);
                                       padding:2px 8px;border-radius:10px;
                                       border:1px solid rgba(204,26,26,0.3);">
                            🔒 LOCKED
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span style="color:var(--green);font-size:10px;font-weight:800;
                                       font-family:'Oxanium',monospace;
                                       background:rgba(76,175,80,0.12);
                                       padding:2px 8px;border-radius:10px;
                                       border:1px solid rgba(76,175,80,0.3);">
                            ✓ Active
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="td-actions">
                        <%-- Unlock if locked --%>
                        <c:if test="${u.locked}">
                          <form method="post"
                                action="${pageContext.request.contextPath}/admin/users">
                            <input type="hidden" name="action" value="unlock">
                            <input type="hidden" name="userId" value="${u.userId}">
                            <button type="submit" class="tbl-btn tbl-view">Unlock</button>
                          </form>
                        </c:if>
                        <button class="tbl-btn tbl-edit">View</button>
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
    <span class="chatbar-icon">👥</span>
    <span class="chatbar-label">User Management</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
