package user;

import agregation.Liste;
import axe.Axe;
import connection.BddObject;
import info.Critere;
import info.Information;
import match.Match;
import note.Note;
import java.util.ArrayList;
import java.util.List;

public class User extends BddObject {

    String idUser;
    String nom;
    String password;
    String genre;
    double note;
    Critere[] criteres;
    Information[] infos;

    public String getGenre() {
        return genre;
    }
    
    public double getNote() {
        return note;
    }

    public String getPassword() {
        return password;
    }
    
    public String getIdUser() {
        return idUser;
    }
    
    public String getNom() {
        return nom;
    }
    
    public Critere[] getCriteres() {
        
        return criteres;
    }
    
    public Information[] getInfos() {
        return infos;
    }

    public void setGenre(String genre) throws Exception {
        if (genre.equals("masculin") || genre.equals("feminin"))
            this.genre = genre;
        else throw new Exception("Genre is not found");
    }
    
    public void setNote(double note) {
        this.note = note;
    }
    
    public void setIdUser(String id) throws Exception {
        if (!id.contains(this.getPrefix()) || id.length() != this.getCountPK()) 
            throw new Exception("idUser is invalid");
        this.idUser = id;
    }

    public void setNom(String name) {
        this.nom = name;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setCriteres(Critere[] criteres) {
        this.criteres = criteres;
    }

    public void setInfos(Information[] infos) {
        this.infos = infos;
    }

    public User() throws Exception {
        this.setTable("users");
        this.setCountPK(7);
        this.setPrefix("USR");
        this.setFunctionPK("getsequser()");
    }

    public User(String name, String password, String genre) throws Exception {
        this();
        this.setIdUser(buildPrimaryKey(getPostgreSQL()));
        this.setNom(name);
        this.setPassword(password);
        this.setGenre(genre);
    }

    public User(String name, String password) throws Exception {
        this();
        this.setNom(name);
        this.setPassword(password);
    }

    public void setCritereInfos() throws Exception {
        Critere critere = new Critere(idUser);
        critere.setTable("Criteres AS c JOIN Axes AS a ON c.idAxe = a.idAxe");
        this.setCriteres(Critere.convert(critere.getData(getPostgreSQL(), "c.idAxe", "idUser")));
        this.setInfos(Information.convert(new Information(idUser).getData(getPostgreSQL(), "idAxe", "idUser")));
    }

    public static User[] convert(Object[] objects) {
        User[] users = new User[objects.length];
        for (int i = 0; i < users.length; i++)
            users[i] = (User) objects[i];
        return users;
    }

    public User[] find() throws Exception {
        return convert(this.getData(getPostgreSQL(), null, "nom", "password"));
    }

    public User[] convert(List<User> users) {
        User[] results = new User[users.size()]; 
        for (int i = 0; i < results.length; i++)
            results[i] = users.get(i);
        return results;
    }

    public double getNote(User user) throws Exception {
        double somme = 0;
        double coefficient = 0;
        for (int i = 0; i < this.criteres.length; i++) {
            Axe axe = new Axe();
            axe.setIdAxe(this.criteres[i].getIdAxe());
            Note note = new Note(axe, this);
            somme += this.criteres[i].getCoefficient() * note.convertToNote(user.getInfos()[i].getValeur());
            coefficient += this.criteres[i].getCoefficient();
        }
        return somme;
    }

    public User[] getProposition(boolean condition) throws Exception {
        User userTable = new User();
        userTable.setTable("get_users_disponible('" + this.getIdUser() + "') AS f(idUser, nom, password, genre)");
        User[] users = User.convert(userTable.getData(getPostgreSQL(), null));
        List<User> match = new ArrayList<>();
        this.setCritereInfos();
        for (User user : users) {
            user.setCritereInfos();
            user.setNote(this.getNote(user));
            boolean check = (condition) ? user.getNote() >= 10 && user.getNote(this) >= 10 && !this.getIdUser().equals(user.getIdUser()) && !this.getGenre().equals(user.getGenre()) 
            : (!this.getIdUser().equals(user.getIdUser()) && !this.getGenre().equals(user.getGenre()));
            if (check)
                match.add(user);
        }
        User[] results = convert(match);
        Liste.sort(results, "getNote", "ASC");
        return results;
    }

    public boolean checkMatch(User user) throws Exception {
        Match match = new Match();
        match.setIdUser(this.getIdUser());
        match.setIdUserMatch(user.getIdUser());
        Match[] matchs = Match.convert(match.getData(getPostgreSQL(), null, "idUserMatch", "idUser"));
        return (matchs.length > 0);
    }

    public Match checkInvited(User user) throws Exception {
        Match match = new Match();
        match.setIdUser(user.getIdUser());
        match.setIdUserMatch(this.getIdUser());
        Match[] matchs = Match.convert(match.getData(getPostgreSQL(), null, "idUserMatch", "idUser"));
        return (matchs.length > 0) ? matchs[0] : null;
    }
}