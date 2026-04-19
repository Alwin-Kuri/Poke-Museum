<%-- register.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Register</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
</head>
<body>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-logo">Pokémon <span>Museum</span></a>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/"        class="nav-btn">HOME</a>
      <a href="${pageContext.request.contextPath}/register" class="nav-btn active">SIGN UP</a>
      <a href="${pageContext.request.contextPath}/login"    class="nav-btn">LOG IN</a>
    </nav>
  </div>

  <div class="login-page">
    <div class="login-card" style="max-width:420px;width:100%;">
      <div class="login-header">
        <div class="login-pokeball"></div>
        <div class="login-title">Create Account</div>
        <div class="login-sub">Join the PokéMuseum today — it's free!</div>
      </div>
      <div class="login-body">

        <c:if test="${not empty errorMsg}">
          <div class="alert-error">⚠️ <c:out value="${errorMsg}"/></div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/register">
          <div class="form-group">
            <label class="form-label" for="username">Username</label>
            <input class="form-control" type="text" id="username" name="username"
                   placeholder="3–50 characters, letters/numbers/underscore"
                   value="<c:out value='${formUsername}'/>" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="email">Email</label>
            <input class="form-control" type="email" id="email" name="email"
                   placeholder="you@example.com"
                   value="<c:out value='${formEmail}'/>" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="password">Password</label>
            <input class="form-control" type="password" id="password" name="password"
                   placeholder="Minimum 6 characters" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="confirmPassword">Confirm Password</label>
            <input class="form-control" type="password" id="confirmPassword" name="confirmPassword"
                   placeholder="Repeat your password" required>
          </div>
          <button type="submit" class="btn-red btn-full">CREATE ACCOUNT →</button>
        </form>

        <div class="login-divider"></div>
        <div class="login-footer">
          Already a trainer? <a href="${pageContext.request.contextPath}/login">Log in here</a>
        </div>
      </div>
    </div>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon">📝</span>
    <span class="chatbar-label">Registration</span>
  </div>
  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
