import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.util.List;

import axe.Axe;
import connection.BddObject;
import info.Information;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import user.User;

public class InsertInfo extends HttpServlet {
    
    public void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        try {
            ServletContext context = this.getServletContext();
            List<BddObject> bdd = (List<BddObject>) context.getAttribute("bdd");
            Object[] axes = new Axe().getData(BddObject.getPostgreSQL(), null);
            for (Object object : axes)
                bdd.add(new Information(((Axe) object).getIdAxe(), ((User) bdd.get(0)).getIdUser(), request.getParameter(((Axe) object).getNom())));
            response.sendRedirect("critere");
        } catch (InvocationTargetException e) {
            PrintWriter out = response.getWriter();
            out.println(e.getCause().getMessage());
        } catch (Exception e) {
            PrintWriter out = response.getWriter();
            out.println(e.getMessage());
        }
    }
}