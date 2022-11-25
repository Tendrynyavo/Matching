package main;

import java.sql.Connection;
import axe.Axe;
import connection.BddObject;
import info.Intervalle;
import note.Note;
import user.User;

public class Main {
    public static void main(String[] args) throws Exception {
        User user = new User();
        user.setIdUser("USR0088");
        user.setGenre("feminin");
        user.getProposition(true);
    }
}