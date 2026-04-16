package com.pokemuse.util;

import java.math.BigDecimal;
import java.util.regex.Pattern;

public class ValidationUtil {

    // Regex patterns
    private static final Pattern EMAIL_PATTERN    = Pattern.compile(
        "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$"
    );
    private static final Pattern USERNAME_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9_]{3,50}$"
    );
    private static final Pattern CARD_CODE_PATTERN = Pattern.compile(
        "^PC\\d{3,6}$"                         // e.g. PC001, PC0123
    );

    // Prevent instantiation
    private ValidationUtil() {}

    // Null
    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    // Username
    /**
     * Validates a username.
     * @return null if valid, otherwise a descriptive error message.
     */
    public static String validateUsername(String username) {
        if (isEmpty(username))
            return "Username cannot be empty.";
        if (!USERNAME_PATTERN.matcher(username.trim()).matches())
            return "Username must be 3–50 characters (letters, numbers, underscores only).";
        return null;
    }

    // Password
    /**
     * Validates a new password.
     * @return null if valid, otherwise a descriptive error message.
     */
    public static String validatePassword(String password) {
        if (isEmpty(password))
            return "Password cannot be empty.";
        if (password.length() < 6)
            return "Password must be at least 6 characters.";
        if (password.length() > 100)
            return "Password must not exceed 100 characters.";
        return null;
    }

    /**
     * Validates that password and confirmPassword match.
     * @return null if they match, otherwise an error message.
     */
    public static String validatePasswordMatch(String password, String confirm) {
        if (!password.equals(confirm))
            return "Passwords do not match.";
        return null;
    }

    // Email

    public static String validateEmail(String email) {
        if (isEmpty(email))
            return "Email cannot be empty.";
        if (!EMAIL_PATTERN.matcher(email.trim()).matches())
            return "Please enter a valid email address.";
        return null;
    }

    // Card fields

    public static String validateCardCode(String code) {
        if (isEmpty(code))
            return "Card code cannot be empty.";
        if (!CARD_CODE_PATTERN.matcher(code.trim().toUpperCase()).matches())
            return "Card code must be in format PC001 (PC followed by numbers).";
        return null;
    }

    public static String validateCardName(String name) {
        if (isEmpty(name))
            return "Card name cannot be empty.";
        if (name.trim().length() > 100)
            return "Card name must not exceed 100 characters.";
        // No numeric-only names — must have at least one letter
        if (!name.trim().matches(".*[a-zA-Z].*"))
            return "Card name must contain at least one letter.";
        return null;
    }

    public static String validateCardValue(String valueStr) {
        if (isEmpty(valueStr))
            return "Card value cannot be empty.";
        try {
            BigDecimal value = new BigDecimal(valueStr.trim());
            if (value.compareTo(BigDecimal.ZERO) < 0)
                return "Card value cannot be negative.";
            if (value.compareTo(new BigDecimal("99999999.99")) > 0)
                return "Card value exceeds maximum allowed.";
        } catch (NumberFormatException e) {
            return "Card value must be a valid number (e.g. 99.99).";
        }
        return null;
    }

    public static String validateCatchRate(String rateStr) {
        if (isEmpty(rateStr))
            return "Catch rate cannot be empty.";
        try {
            int rate = Integer.parseInt(rateStr.trim());
            if (rate < 1 || rate > 255)
                return "Catch rate must be between 1 and 255.";
        } catch (NumberFormatException e) {
            return "Catch rate must be a whole number.";
        }
        return null;
    }

    // General

    /**
     * Sanitises a string by trimming whitespace.
     * Call before storing any user input.
     */
    public static String sanitise(String input) {
        return input == null ? "" : input.trim();
    }
}
