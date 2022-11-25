import connection.BddObject;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import match.Match;
import user.User;

import java.io.IOException;
import java.io.PrintWriter;

public class ListMatch extends HttpServlet {
    
    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("id");
        try {
            Match match = new Match();
            match.setIdUserMatch(user.getIdUser());
            request.setAttribute("matchs", Match.convert(match.getData(BddObject.getPostgreSQL(), null, "idUserMatch")));
            request.setAttribute("user", user);
            RequestDispatcher disparate = request.getRequestDispatcher("listeMatch.jsp");
            disparate.forward(request, response);
        } catch (Exception e) {
            PrintWriter out = response.getWriter();
            out.println(e.getMessage());
        }
    }
}
