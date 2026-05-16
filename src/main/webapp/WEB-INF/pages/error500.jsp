<%-- error500.jsp — Internal Server Error --%>
<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>PokéMuseum – 500</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/poke.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/error.css">
</head>
<body>

  <!-- Full screen background image -->
  <img src="${pageContext.request.contextPath}/images/util/200.gif" 
       class="bg-image" 
       alt="">

  <!-- Dark overlay -->
  <div class="overlay"></div>

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-logo">Pokémon <span>Museum</span></a>
  </div>

  <div class="content">
    <h1>500</h1>
    <p style="font-size:20px; margin:20px 0 40px; max-width:700px;">
      Something went wrong on our end.<br>
      The Pokémon escaped the database!
    </p>
    <a href="${pageContext.request.contextPath}/" class="btn-red">Return to Museum</a>
  </div>

  <div class="chatbar">
    <span class="chatbar-icon"> </span>
    <span class="chatbar-label">Server Error</span>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>