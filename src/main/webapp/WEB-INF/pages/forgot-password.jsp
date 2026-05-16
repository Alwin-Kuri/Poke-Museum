<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Reset Password</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/forgotpw.css">
</head>
<body>

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-logo">Pokémon <span>Museum</span></a>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/login"    class="nav-btn">LOG IN</a>
      <a href="${pageContext.request.contextPath}/register" class="nav-btn">SIGN UP</a>
    </nav>
  </div>

  <div class="page-center">
    <div class="reset-card">

      <div class="card-header">
        <span class="card-icon"> 
		<img class="card-poke-img" style="width:48px;height:48px;margin-top:10px;margin-left:20px;"
            src="${pageContext.request.contextPath}/images/util/forgetpw.png"
            alt="📦"></span>
        <div class="card-title">Reset Password</div>
        <div class="card-sub">
          <c:choose>
            <c:when test="${step eq 'reset'}">Enter your new password below</c:when>
            <c:otherwise>Find your account to reset your password</c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="card-body">

        <%-- Step indicator --%>
        <div class="step-row">
          <div class="step-dot <c:choose><c:when test='${step eq "reset"}'>done</c:when><c:otherwise>active</c:otherwise></c:choose>">
            <c:choose><c:when test="${step eq 'reset'}">✓</c:when><c:otherwise>1</c:otherwise></c:choose>
            Find Account
          </div>
          <div class="step-dot <c:if test='${step eq "reset"}'>active</c:if>">
            2 New Password
          </div>
        </div>

        <%-- Error alert --%>
        <c:if test="${not empty errorMsg}">
          <div class="alert-error">⚠️ <c:out value="${errorMsg}"/></div>
        </c:if>

        <%--
             STEP 1: Find account
         --%>
        <c:if test="${step eq 'lookup' or empty step}">
          <div class="alert-info">
            Enter the username or email address associated with your account.
          </div>

          <form method="post" action="${pageContext.request.contextPath}/forgot-password">
            <input type="hidden" name="step" value="lookup">

            <div class="form-group">
              <label class="form-label" for="identifier">Username or Email</label>
              <input class="form-control" type="text" id="identifier" name="identifier"
                     placeholder="Enter your username or email..."
                     autocomplete="username" required>
            </div>

            <button type="submit" class="btn-red">FIND MY ACCOUNT</button>
          </form>
        </c:if>

        <%-- 
             STEP 2: Enter new password
  		--%>
        <c:if test="${step eq 'reset'}">
          <c:if test="${not empty resetForUser}">
            <div class="alert-info">
              Account found: <strong><c:out value="${resetForUser}"/></strong>. Enter a new password below.
            </div>
          </c:if>

          <form method="post" action="${pageContext.request.contextPath}/forgot-password">
            <input type="hidden" name="step" value="reset">

            <div class="form-group">
              <label class="form-label" for="newPassword">New Password</label>
              <input class="form-control" type="password" id="newPassword" name="newPassword"
                     placeholder="Minimum 8 characters"
                     autocomplete="new-password" required>
              <div class="form-hint">At least 8 characters, maximum 100.</div>
            </div>

            <div class="form-group">
              <label class="form-label" for="confirmPassword">Confirm New Password</label>
              <input class="form-control" type="password" id="confirmPassword" name="confirmPassword"
                     placeholder="Repeat your new password"
                     autocomplete="new-password" required>
            </div>

            <button type="submit" class="btn-red">SAVE NEW PASSWORD</button>
          </form>

          <%-- Option to start over --%>
          <div class="divider"></div>
          <div class="footer-link">
            Wrong account?
            <a href="${pageContext.request.contextPath}/forgot-password">Start over</a>
          </div>
        </c:if>

        <div class="divider"></div>
        <div class="footer-link">
          Remember your password?
          <a href="${pageContext.request.contextPath}/login">Back to Login</a>
        </div>

      </div><%-- /card-body --%>
    </div><%-- /reset-card --%>
  </div>

  <div class="chatbar">
    <span style="font-size:15px;">🔑</span>
    <span class="chatbar-label">Password Reset</span>
  </div>

</body>
</html>
