package com.pokemuse.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // ── Database credentials ───────────────────────────────
    private static final String DRIVER   = "com.mysql.cj.jdbc.Driver";
    private static final String URL      = "jdbc:mysql://localhost:3306/pokemuse_db"
                                         + "?useSSL=false"
                                         + "&serverTimezone=UTC"
                                         + "&allowPublicKeyRetrieval=true"
                                         + "&characterEncoding=UTF-8";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";           // change for production

    /*
     * Static initialiser — loads the MySQL JDBC driver once
     * when the class is first used.
     */
    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "MySQL JDBC Driver not found. Add mysql-connector-j-*.jar to WEB-INF/lib.\n" + e
            );
        }
    }
	


    /**
     * Returns fresh JDBC Connection
     *
     * @return Connection to pokemuse
     * @throws SQLException if the database is unreachable
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    /**
     * Safely closes a connection without propagating exceptions
     * Accepts null so its safe to call even if getConnection() failed
     *
     * @param conn the Connection to close
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("[DBConfig] Warning: could not close connection — " + e.getMessage());
            }
        }
    }

    // utility class only
    private DBConfig() {}
}
