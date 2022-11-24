package connection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Vector;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
public abstract class BddObject {

    String prefix;
    String functionPK;
    String table;
    int countPK;

    public String getPrefix() {
        return prefix;
    }

    public String getTable() {
        return table;
    }

    public void setTable(String table) {
        this.table = table;
    }

    public String getFunctionPK() {
        return functionPK;
    }

    public int getCountPK() {
        return countPK;
    }

    public void setCountPK(int countPK) {
        this.countPK = countPK;
    }

    public void setFunctionPK(String function) {
        this.functionPK = function;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public static Connection getOracle() throws SQLException, ClassNotFoundException {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection connection = DriverManager.getConnection("jdbc:oracle:thin:@192.168.88.21:1521:orcl", "scott", "tiger");
        connection.setAutoCommit(false);
        return connection;
    }

    public static Connection getPostgreSQL() throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Connection connection = DriverManager.getConnection("jdbc:postgresql://localhost:5433/matching?user=postgres&password=postgres");
        connection.setAutoCommit(false);
        return connection;
    }
    
    /**
     * <p>Get list of column name in query<p>
     * @param query : {@code SELECT} query
     * @param connection : your database 
     * @return
     * @throws Exception
     */
    public static String[] listColumn(String query, Connection connection) throws Exception {
        Statement stmt = connection.createStatement();
        ResultSet rs = stmt.executeQuery(query);
        ResultSetMetaData rsMetaData = rs.getMetaData();
        int count = rsMetaData.getColumnCount();
        String[] colonnes = new String[count];
        int increment = 0;
        for(int i = 1; i <= count; i++) {
            colonnes[increment] = rsMetaData.getColumnName(i);
            increment++;
        }
        return colonnes;
    }

    public Object[] getData(Connection connection, String order, String... predicat) throws Exception {
        String sql = (predicat.length == 0) ? "SELECT * FROM " + this.getTable() 
                    : "SELECT * FROM " + this.getTable() + " WHERE " + predicat(predicat);
        if (order != null) sql += " ORDER BY " + order;
        return getData(sql, connection);
    }

    public Object[] getData(String query, Connection connection) throws Exception {
        Statement statement = connection.createStatement();
        ResultSet result = statement.executeQuery(query);
        String[] liste = listColumn(query, connection); // get liste of column length
        Object[] employees = convertToObject(result, liste.length);
        result.close();
        statement.close();
        connection.close();
        return employees;
    }

    public Object[] convertToObject(ResultSet result, int attribut) throws Exception {
        Field[] attributs = this.getClass().getDeclaredFields();
        Vector<Object> objects = new Vector<Object>();
        while (result.next()) {
            Object object = this.getClass().getConstructor().newInstance();
            for (int i = 0; i < attribut; i++) {
                Method setter = this.getClass().getMethod("set" + toUpperCaseFisrtLetter(attributs[i].getName()), attributs[i].getType()); // Setter of this object
                Method getter = ResultSet.class.getMethod("get" + toUpperCaseFisrtLetter(attributs[i].getType().getSimpleName()), int.class);  // Method in ResultSet
                getter.setAccessible(true); // get(int.class) method isn't accessible
                setter.invoke(object, getter.invoke(result, i + 1));
            }
            objects.add(object);
        }
        return objects.toArray();
    }

    public String predicat(String[] predicats) throws Exception {
        String sql = ""; // Condition with AND clause
        for (String predicat : predicats)
            sql += predicat + "=" + convertToLegal(this.getClass().getMethod("get" + toUpperCaseFisrtLetter(predicat)).invoke(this)) + " AND ";
        return sql.substring(0, sql.length() - 5); // Delete last " AND " in sql
    }
    
    public void insert(Connection connection) throws Exception {
        boolean connect = false;
        if (connection == null) {connection = getPostgreSQL(); connect = true;}
        String[] liste = listColumn("SELECT * FROM " + this.getTable(), connection);
        Statement statement = connection.createStatement();
        String sql = "INSERT INTO " + this.getTable() + " " + createColumn(liste) + " VALUES ("; // Insert with all column
        Field[] attributs = this.getClass().getDeclaredFields();
        for (int i = 0; i < liste.length; i++)
            sql += convertToLegal(this.getClass().getMethod("get" + toUpperCaseFisrtLetter(attributs[i].getName())).invoke(this)) + ",";
        sql = sql.substring(0, sql.length() - 1) + ")";
        statement.executeUpdate(sql);
        statement.close();
        if (connect) {connection.commit(); connection.close();}
    }
    
    static String createColumn(String[] colonnes) {
        String result = "(";
        for (String colonne : colonnes)
            result += colonne + ",";
        result = result.substring(0, result.length()-1)+")";
        return result;
    }

    public void update(String[] column, Object[] value, String ID, Connection connection) throws Exception {
        if (value.length != column.length) throw new Exception("Value and column must be equals");
        boolean connect = false;
        if (connection == null) {connection = getPostgreSQL(); connect = true;}
        historiser(ID, connection);
        Statement statement = connection.createStatement();
        String sql = "UPDATE " + this.getTable() + " \nSET ";
        for (int i = 0; i < column.length; i++)
            sql += column[i] + " = " + convertToLegal(value[i]) + ",\n";
        sql = sql.substring(0, sql.length() - 2);
        sql += " WHERE " + ID + " = " + convertToLegal(this.getClass().getMethod("get" + toUpperCaseFisrtLetter(ID)).invoke(this));
        statement.executeUpdate(sql);
        statement.close();
        if (connect) {connection.commit(); connection.close();}
    }

    public String convertToLegal(Object args) {
        return (args == null) ? "null"
        : (args.getClass() == Date.class) ? "TO_DATE('" + args + "', 'YYYY-MM-DD')"
        : (args.getClass() == Timestamp.class) ? "TO_TIMESTAMP('"+ args +"', 'YYYY-MM-DD HH24:MI:SS.FF')"
        : ((args.getClass() == String.class) || (args.getClass() == Time.class)) ? "'"+ args +"'"
        : args.toString();
    }

    public static String toUpperCaseFisrtLetter(String name) {
        String firstLetter = name.substring(0, 1);
        String remainingLetters = name.substring(1);
        firstLetter = firstLetter.toUpperCase();
        name = firstLetter + remainingLetters;
        return name;
    }

    public String buildPrimaryKey(Connection connection) throws SQLException {
        return this.getPrefix() + completeZero(getSequence(connection), this.getCountPK() - this.getPrefix().length());
    }

    public String getSequence(Connection connection) throws SQLException {
        Statement statement = connection.createStatement();
        String sql = (getDatabaseName(connection).equals("PostgreSQL")) ? "SELECT " + this.getFunctionPK() : "SELECT " + this.getFunctionPK() + " FROM DUAL";
        ResultSet result = statement.executeQuery(sql);
        result.next();
        String sequence = result.getString(1);
        statement.close();
        result.close();
        connection.close();
        return sequence;
    }

    public static String getDatabaseName(Connection connection) throws SQLException {
        return connection.getMetaData().getDatabaseProductName();
    }
    
    public static String completeZero(String seq, int count) {
        int length = count - seq.length();
        String zero = "";
        for (int i = 0; i < length; i++)
            zero += "0";
        return zero + seq;
    }

    public void historiser(String ID, Connection connection) throws Exception {
        boolean connect = false;
        if (connection == null) {connection = getOracle(); connect = true;}
        Statement statement = connection.createStatement();
        String sql = "SELECT * FROM " + this.getTable() + " WHERE " + ID + " = " + convertToLegal(this.getClass().getMethod("get" + toUpperCaseFisrtLetter(ID)).invoke(this));
        ResultSet result = statement.executeQuery(sql);
        while (result.next()) {
            Historique historique = new Historique(this.getTable(), "update", new Date(System.currentTimeMillis()), getValue(result, listColumn(sql, connection).length));
            historique.insert(connection);
        }
        statement.close();
        if (connect) {connection.commit(); connection.close();}
    }

    public String getValue(ResultSet result, int nombre) throws SQLException {
        Field[] fields = this.getClass().getDeclaredFields();
        String sql = ""; // Condition with AND clause
        for (int i = 0; i < nombre; i++)
            sql += fields[i].getName() + ":" + result.getString(i + 1) + ";";
        return sql.substring(0, sql.length() - 1); // Delete last " AND " in sql
    }

    public String getColonneID(Connection connection) throws Exception {
        ResultSet pkColumns = connection.getMetaData().getPrimaryKeys(null, null, this.getTable());
        pkColumns.next();
        String pkColumnName = pkColumns.getString("COLUMN_NAME");
        pkColumns.close();
        return pkColumnName;
    }
}