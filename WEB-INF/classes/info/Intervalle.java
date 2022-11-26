package info;

import java.sql.SQLException;

import connection.BddObject;

public class Intervalle extends BddObject {
    
    String idIntervalle;
    String idAxe;
    String intervalle;

    public void setIdIntervalle(String idIntervalle) {
        this.idIntervalle = idIntervalle;
    }

    public void setIdAxe(String idAxe) {
        this.idAxe = idAxe;
    }

    public void setIntervalle(String intervalle) {
        this.intervalle = intervalle;
    }

    public String getIdIntervalle() {
        return idIntervalle;
    }

    public String getIdAxe() {
        return idAxe;
    }

    public String getIntervalle() {
        return intervalle;
    }

    public Intervalle() {
        this.setTable("intervalle");
        this.setCountPK(7);
        this.setPrefix("INT");
        this.setFunctionPK("getSeqIntervalle()");
    }

    public Intervalle(String idAxe, String intervalle) throws Exception {
        this();
        this.setIdIntervalle(buildPrimaryKey(getPostgreSQL()));
        this.setIdAxe(idAxe);
        this.setIntervalle(intervalle);
    }

    public Intervalle(String idAxe) throws ClassNotFoundException, SQLException {
        this();
        this.setIdAxe(idAxe);
    }

    public static Intervalle[] convert(Object[] objects) {
        Intervalle[] intervalles = new Intervalle[objects.length];
        for (int i = 0; i < intervalles.length; i++)
            intervalles[i] = (Intervalle) objects[i];
        return intervalles;
    }
}
