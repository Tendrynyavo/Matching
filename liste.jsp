<%@ page import="user.User" %>
<%@ page import="info.Critere" %>
<%@ page import="info.Information" %>
<%@ page import="java.util.List" %>
<%
  User[] propositions = (User[]) request.getAttribute("proposition");
  User user = (User) request.getAttribute("user");
  Critere[] criteres = user.getCriteres();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="./assets/css/bootstrap.css">
    <title>Liste</title>
</head>
<body>
    <div class="d-flex flex-column flex-shrink-0 p-3 bg-light fixed-top float-start shadow rounded mt-3 ms-3" style="width: 280px; height: -webkit-fill-available;">
        <h2 class="nav nav-pills flex-column mb-auto border-bottom p-3">
          <% out.print(user.getNom()); %>
        </h2>
        <h5>Vos preferences : </h5>
        <ul>
        <%for (Critere critere : criteres) { 
          critere.setAnnexe();
        %>
          <li><% out.print(critere.getAnnexe().getNom()); %> : <% out.print(critere.getCoefficient()); %></li>
        <% } %>
        </ul>
        <hr>
        <a href="deconnexion" class="align-items-center pb-2">
            <div class="btn btn-primary">
                <strong>Deconnexion</strong>
            </div>
        </a>
    </div>

    
    <div class="container mt-4" style="margin-left: 350px;">
      <h2>Proposition</h2>
      <table class="table w-75">
        <tr>
          <th>Nom</th>
          <th>Fivavahana</th>
          <th>Longueur (metre)</th>
          <th>Salaire par mois</th>
          <th>Diplome</th>
          <th>Nationalite</th>
        </tr>
        <% for (int i = 0; i < propositions.length; i++) { %>
        <tr>
          <td><% out.print(propositions[i].getNom()); %></td>
          <% Information[] infos = propositions[i].getInfos();
          for (int j = 0; j < infos.length; j++) { %>
            <td><% out.print(infos[j].getValeur()); %></td>
          <% } %>
        </tr>
        <% } %>
      </table>
    </div>

</body>
<script src="./assets/js/bootstrap.min.js"></script>
<script src="./assets/js/jquery.min.js"></script>
</html>