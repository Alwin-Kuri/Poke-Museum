<%-- error500.jsp — Internal Server Error --%>
<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>PokéMuseum – 500</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vortex.css">
</head>
<body>
  <div class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-logo">Pokémon <span>Museum</span></a>
  </div>
  <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;flex:1;min-height:60vh;text-align:center;padding:40px;">
    <div style="font-size:80px;margin-bottom:16px;">💥</div>
    <h1 style="font-family:'Oxanium',monospace;font-size:32px;color:var(--red);margin-bottom:8px;">500</h1>
    <p style="font-size:16px;color:var(--text-dim);margin-bottom:24px;">
      Something went wrong on our end. The Pokémon escaped the database!
    </p>
    <a href="${pageContext.request.contextPath}/" class="btn-red">Return to Museum</a>
  </div>
  <div class="chatbar"><span class="chatbar-icon">💥</span><span class="chatbar-label">Server Error</span></div>
  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
