<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- Compute URI once for active nav state --%>
<c:set var="uri" value="${pageContext.request.requestURI}"/>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Admin: Users</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_users.css">

</head>
<body>

  <%--  Topbar — active class driven by URI  --%>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <div class="topbar-meta">
      <span style="color:var(--white);font-weight:800;">
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
      <span style="color:var(--gold);font-family:'Oxanium',monospace;font-size:10px;font-weight:800;">
        ⚙ ADMIN
      </span>
    </div>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/admin/dashboard"
         class="nav-btn <c:if test='${uri.contains("/dashboard")}'>active</c:if>">
        DASHBOARD
      </a>
      <a href="${pageContext.request.contextPath}/cards"
         class="nav-btn <c:if test='${uri.contains("/cards")}'>active</c:if>">
        CARDS
      </a>
      <a href="${pageContext.request.contextPath}/admin/users"
         class="nav-btn <c:if test='${uri.contains("/users")}'>active</c:if>">
        USERS
      </a>
    </nav>
    <div class="topbar-right">
      <a href="${pageContext.request.contextPath}/logout" class="logout-btn">⇥</a>
    </div>
  </div>

  <div class="page-layout">

    <%-- Sidebar — active by URI --%>
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

      <%-- Success / error feedback --%>
      <c:if test="${param.success eq 'unlocked'}">
        <div class="alert-success">✅ Account unlocked successfully!</div>
      </c:if>
      <c:if test="${param.error eq 'selfAction'}">
        <div class="alert-error">⚠️ You cannot perform this action on your own account.</div>
      </c:if>
      <c:if test="${param.error eq 'unlockFailed'}">
        <div class="alert-error">⚠️ Could not unlock account. Please try again.</div>
      </c:if>

      <div class="section-header">
        👥 User Management
        <span style="font-size:11px;opacity:.7;">
          <c:out value="${totalUsers}"/> registered trainers
        </span>
      </div>

      <%--  Stats strip — values from servlet  --%>
      <div class="stat-strip">
        <div class="stat-cell">
          <span class="stat-val"><c:out value="${totalUsers}"/></span>
          <div class="stat-lbl">Total Users</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val" style="color:var(--blue);">
            <c:out value="${userCount}"/>
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
          <div class="stat-lbl">Locked</div>
        </div>
      </div>

      <%-- 
           SEARCH + FILTER FORM
           Action points to /admin/users (GET)
           All controls submit the same form together.
       --%>
      <form method="get"
            action="${pageContext.request.contextPath}/admin/users"
            id="user-filter-form">
        <div class="search-row">

          <%-- Username/email search — pre-filled from ${searchQuery} --%>
          <input type="text"
                 name="search"
                 class="search-input"
                 placeholder="Search by username or email..."
                 value="<c:out value='${searchQuery}'/>">

          <%-- Role filter — pre-selected from ${roleFilter} --%>
          <select name="role"
                  class="filter-select"
                  onchange="document.getElementById('user-filter-form').submit()">
            <option value=""
                    <c:if test="${empty roleFilter}">selected</c:if>>
              All Roles
            </option>
            <option value="user"
                    <c:if test="${roleFilter eq 'user'}">selected</c:if>>
              🎮 Trainers Only
            </option>
            <option value="admin"
                    <c:if test="${roleFilter eq 'admin'}">selected</c:if>>
              ⚙️ Admins Only
            </option>
          </select>

          <button type="submit" class="search-btn">🔍 Search</button>

          <%-- Clear all filters --%>
          <a href="${pageContext.request.contextPath}/admin/users"
             class="btn-ghost">✕ Clear</a>
        </div>
      </form>

      <%-- Results count feedback --%>
      <div class="results-meta">
        Showing <strong><c:out value="${resultCount}"/></strong>
        of <strong><c:out value="${totalUsers}"/></strong> users
        <c:if test="${not empty searchQuery}">
          · search: "<c:out value='${searchQuery}'/>"
        </c:if>
        <c:if test="${not empty roleFilter}">
          · role: <c:out value="${roleFilter}"/>
        </c:if>
      </div>

      <%--  Users table  --%>
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
              <th>Failed Attempts</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty allUsers}">
                <tr>
                  <td colspan="10">
                    <div class="empty-state">
                      <span>🔍</span>
                      No users match your search.
                      <a href="${pageContext.request.contextPath}/admin/users"
                         style="color:var(--red);">Clear filters</a>
                    </div>
                  </td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="u" items="${allUsers}">
                  <tr>
                    <%-- ID --%>
                    <td class="td-dim" style="font-family:'Oxanium',monospace;">
                      <c:out value="${u.userId}"/>
                    </td>

                    <%-- Username --%>
                    <td class="td-name">
                      <c:out value="${u.username}"/>
                    </td>

                    <%-- Email --%>
                    <td class="td-dim">
                      <c:out value="${u.email}"/>
                    </td>

                    <%-- Role badge --%>
                    <td>
                      <c:choose>
                        <c:when test="${u.role eq 'admin'}">
                          <span class="badge badge-admin">⚙ Admin</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-user">🎮 Trainer</span>
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <%-- Coins --%>
                    <td class="td-gold">
                      <c:out value="${u.coins}"/>
                    </td>

                    <%-- Login streak --%>
                    <td>
                      <span style="color:var(--orange);font-weight:700;">
                        🔥 <c:out value="${u.loginStreak}"/>
                      </span>
                    </td>

                    <%-- Last login --%>
                    <td class="td-dim">
                      <c:choose>
                        <c:when test="${not empty u.lastLogin}">
                          <c:out value="${u.lastLogin}"/>
                        </c:when>
                        <c:otherwise>Never</c:otherwise>
                      </c:choose>
                    </td>

                    <%-- Failed attempts — highlighted if close to lockout --%>
                    <td>
                      <span style="color:${u.failedAttempts >= 3 ? '#ff6b6b' : 'var(--text-dim)'};font-weight:${u.failedAttempts >= 3 ? '800' : '400'};">
                        <c:out value="${u.failedAttempts}"/> / 5
                      </span>
                    </td>

                    <%-- Status badge --%>
                    <td>
                      <c:choose>
                        <c:when test="${u.locked}">
                          <span class="badge badge-locked">🔒 Locked</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-active">✓ Active</span>
                        </c:otherwise>
                      </c:choose>
                    </td>

                    <%-- Actions --%>
                    <td>
                      <div class="td-actions">

                        <%-- Unlock button — only shown for locked accounts --%>
                        <c:if test="${u.locked}">
                          <form method="post"
                                action="${pageContext.request.contextPath}/admin/users">
                            <input type="hidden" name="action"  value="unlock">
                            <input type="hidden" name="userId"  value="${u.userId}">
                            <button type="submit" class="tbl-btn tbl-unlock">
                              Unlock
                            </button>
                          </form>
                        </c:if>

                        <%-- View placeholder (expandable in future) --%>
                        <button class="tbl-btn tbl-view">View</button>

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
    <span class="chatbar-label">User Management</span>
    <div class="chatbar-right">🕐 <span id="clk">--:--</span></div>
  </div>

  <script>
    function tick(){const n=new Date();document.getElementById('clk').textContent=String(n.getHours()).padStart(2,'0')+':'+String(n.getMinutes()).padStart(2,'0');}
    tick();setInterval(tick,30000);
  </script>

</body>
</html>
