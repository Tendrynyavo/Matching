import axe.Axe;
import connection.BddObject;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class ListCritere extends HttpServlet {
    
    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        try {
            request.setAttribute("axes", Axe.convert(new Axe().getData(BddObject.getPostgreSQL(), null)));
            RequestDispatcher disparate = request.getRequestDispatcher("critere.jsp");
            disparate.forward(request, response);
        } catch (Exception e) {
            response.sendRedirect("error.jsp?error="+e.getMessage());
        }
    }
}