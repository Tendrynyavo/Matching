package note;

import info.Precision;
import user.User;
import axe.Axe;
import connection.BddObject;
public class Note extends BddObject {

    double note;
    User user;
    Axe axe;

    public double getNote() {
        return note;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Axe getAxe() {
        return axe;
    }

    public void setNote(double note) {
        this.note = note;
    }

    public void setAxe(Axe axe) {
        this.axe = axe;
    }

    public Note(Axe axe, User user) throws Exception {
        this.setAxe(axe);
        this.setUser(user);
    }
    
    public double convertToNote(String value) throws Exception {
        double note = 0;
        switch (this.getAxe().getIdAxe()) {
            case "A020":
                note = getNote(value);
                break;
            case "A030":
                note = Double.parseDouble(value) / 10;
                break;
            case "A040":
                note = getNote(getIntervaleSalaire(value));
                break;
            case "A050":
                String index = value.split("[+]")[1];
                note = 10 + Integer.parseInt(index);
                break;
            case "A060":
                note = getNote(value);
                break;
            case "A070":
                note = getNote(getIntervalAge(value));
                break;
            default:
                note = Double.parseDouble(value);
        }
        return (note > 20) ? 20 : note;
    }

    public static String getIntervalAge(String value) throws Exception {
        int age = Integer.parseInt(value);
        int[][] intervals = {{20, 30}, {30, 40}, {40, 50}, {50, 60}};
        for (int[] interval : intervals) {
            if (interval[0] <= age && age < interval[1])
                return interval[0] + "-" + interval[1];
        }
        throw new Exception("Intervalle not found");
    }

    public static String getIntervaleSalaire(String value) throws Exception {
        double age = Double.parseDouble(value);
        double[][] intervals = {{0, 50000}, {50000, 100000}};
        if (age >= 100000) return "100000 et superieur";
        for (double[] interval : intervals) {
            if (interval[0] <= age && age <= interval[1])
                return interval[0] + "-" + interval[1];
        }
        throw new Exception("Intervalle not found");
    }

    public double getNote(String intervalle) throws Exception {
        Precision precision = new Precision();
        String sql = "SELECT idprecision, p.idintervalle, p.valeur, idUser, intervalle, idAxe, note FROM precisions AS p JOIN intervalle AS i ON p.idIntervalle = i.idIntervalle JOIN valeur AS v ON p.valeur = v.valeur WHERE idAxe='" + axe.getIdAxe() + "' AND i.intervalle='" + intervalle + "' AND idUser='" + user.getIdUser() + "'";
        precision = Precision.convert(precision.getData(sql, getPostgreSQL()))[0];
        return precision.getNote();
    }
}