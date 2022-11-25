import axe.Axe;
import connection.BddObject;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import user.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;

public class Liste extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("id");
        try {
            request.setAttribute("proposition", user.getProposition(request.getParameter("check") == null || Boolean.parseBoolean(request.getParameter("check"))));
            request.setAttribute("user", user);
            request.setAttribute("axe", Axe.convert(new Axe().getData(BddObject.getPostgreSQL(), "idAxe")));
            RequestDispatcher disparate = request.getRequestDispatcher("liste.jsp");
            disparate.forward(request, response);
        } catch (InvocationTargetException e) {
            PrintWriter out = response.getWriter();
            out.println(e.getCause().getMessage());
        } catch (Exception e) {
            PrintWriter out = response.getWriter();
            out.println(e.getMessage());
        }
    }
}