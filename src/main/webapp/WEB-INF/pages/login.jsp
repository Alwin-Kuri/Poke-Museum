<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Login</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vortex.css">
</head>
<body>

  <%-- Topbar --%>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/"        class="nav-btn">HOME</a>
      <a href="${pageContext.request.contextPath}/register" class="nav-btn">SIGN UP</a>
      <a href="${pageContext.request.contextPath}/login"    class="nav-btn active">LOG IN</a>
    </nav>
  </div>

  <%-- Login body --%>
  <div class="login-page">
    <div class="login-card">

      <%-- Header with pokéball logo --%>
      <div class="login-header">
        <div class="login-pokeball"></div>
        <div class="login-title">PokéMuseum</div>
        <div class="login-sub">Your digital card museum awaits</div>
      </div>

      <div class="login-body">

        <%-- Role toggle (visual only — username determines actual role) --%>
        <div class="role-tabs">
          <button class="role-tab active" id="tab-trainer"
                  onclick="document.getElementById('tab-trainer').classList.add('active');
                           document.getElementById('tab-admin').classList.remove('active');
                           document.getElementById('username').value='trainer';
                           document.getElementById('password').value='user123';">
            🎮 Trainer
          </button>
          <button class="role-tab" id="tab-admin"
                  onclick="document.getElementById('tab-admin').classList.add('active');
                           document.getElementById('tab-trainer').classList.remove('active');
                           document.getElementById('username').value='admin';
                           document.getElementById('password').value='poke123';">
            ⚙️ Admin
          </button>
        </div>

        <%-- Success message after registration --%>
        <c:if test="${param.registered eq 'true'}">
          <div class="alert-success">
            ✅ Account created! Please log in to enter the museum.
          </div>
        </c:if>

        <%-- Success message after logout --%>
        <c:if test="${param.logout eq 'true'}">
          <div class="alert-success">
            👋 You have been logged out. See you next time, Trainer!
          </div>
        </c:if>

        <%-- Session expired redirect --%>
        <c:if test="${param.error eq 'session'}">
          <div class="alert-error">
            ⏱️ Your session expired. Please log in again.
          </div>
        </c:if>

        <%-- Invalid credentials / locked account --%>
        <c:if test="${not empty errorMsg}">
          <div class="alert-error">
            ⚠️ <c:out value="${errorMsg}"/>
          </div>
        </c:if>

        <%-- Login form --%>
        <form action="${pageContext.request.contextPath}/login" method="post">

          <%-- Preserve redirect target if present --%>
          <c:if test="${not empty param.redirect}">
            <input type="hidden" name="redirect" value="<c:out value='${param.redirect}'/>">
          </c:if>

          <div class="form-group">
            <label class="form-label" for="username">Username</label>
            <input class="form-control" type="text" id="username" name="username"
                   placeholder="Enter your username..."
                   value="<c:out value='${attemptedUsername}'/>"
                   autocomplete="username" required>
          </div>

          <div class="form-group">
            <label class="form-label" for="password">Password</label>
            <input class="form-control" type="password" id="password" name="password"
                   placeholder="••••••••"
                   autocomplete="current-password" required>
          </div>

          <button type="submit" class="btn-red btn-full">
            ENTER THE MUSEUM →
          </button>

        </form>

        <div class="login-footer" style="margin-top:12px;">
          <a href="${pageContext.request.contextPath}/forgot-password">Forgot password?</a>
        </div>

        <div class="login-divider"></div>

        <div class="login-footer">
          New trainer?
          <a href="${pageContext.request.contextPath}/register">Create an account</a>
        </div>

      </div><%-- /login-body --%>
    </div><%-- /login-card --%>
  </div>

  <%-- Bottom chatbar --%>
  <div class="chatbar">
    <span class="chatbar-icon">🔒</span>
    <span class="chatbar-label">Secure Login Portal</span>
    <div class="chatbar-right">
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
