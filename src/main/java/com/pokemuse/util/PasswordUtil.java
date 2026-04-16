package com.pokemuse.util;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    // BCrypt work factor — higher = slower hashing = more secure
    private static final int WORK_FACTOR = 10;

    // Prevent instantiation
    private PasswordUtil() {}

    /**
     * Hashes a plain-text password using BCrypt.
     * @param plainPassword the raw password from the registration form
     * @return the BCrypt hash to store in the database
     */
    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(WORK_FACTOR));
    }

    /**
     * Verifies a plain-text password against a stored BCrypt hash.
     * @param plainPassword  the password the user typed in the login form
     * @param hashedPassword the hash retrieved from the database
     * @return true if the password matches the hash, false otherwise
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            // malformed hash — treat as mismatch, never crash
            return false;
        }
    }
}

