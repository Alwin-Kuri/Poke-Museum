package com.pokemuse.dao;

import com.pokemuse.config.DBConfig;
import com.pokemuse.model.User;
import com.pokemuse.util.PasswordUtil;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO.java — Data Access Object
 * ─────────────────────────────────────────────────────
 * All database operations for the `users` table.
 * Handles registration, login verification, session tracking,
 * login streak management, and account locking.
 *
 * Author : Alwin Maharjan | CS5003NI
 */
public class UserDao {

    // ── CREATE ─────────────────────────────────────────────

    /**
     * Registers a new user account.
     * Password must already be BCrypt-hashed before calling.
     * @return true if the user was created successfully.
     */
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, password_hash, email, role, coins) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPasswordHash());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getRole());
            ps.setInt   (5, user.getCoins());
            return ps.executeUpdate() > 0;
        } catch (SQLIntegrityConstraintViolationException e) {
            // username or email already exists
            System.err.println("[UserDAO.registerUser] Duplicate entry: " + e.getMessage());
            return false;
        } catch (SQLException e) {
            System.err.println("[UserDAO.registerUser] " + e.getMessage());
            return false;
        }
    }

    // ── READ ───────────────────────────────────────────────

    /** Returns a User by user_id, or null if not found. */
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO.getUserById] " + e.getMessage());
        }
        return null;
    }

    /** Returns a User by username, or null if not found. */
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO.getUserByUsername] " + e.getMessage());
        }
        return null;
    }

    /** Returns all users (admin view). */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection conn = DBConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            while (rs.next()) users.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[UserDAO.getAllUsers] " + e.getMessage());
        }
        return users;
    }

    // ── LOGIN VERIFICATION ─────────────────────────────────

    /**
     * Validates login credentials.
     * Checks: account exists → not locked → password matches.
     *
     * On success: resets failed attempts, updates last_login, manages streak.
     * On failure: increments failed attempts, locks after 5.
     *
     * @return the authenticated User on success, null on failure.
     */
    public User validateLogin(String username, String plainPassword) {
        User user = getUserByUsername(username);
        if (user == null) return null;           // no such user

        if (user.isLocked()) return null;        // account locked

        if (!PasswordUtil.verify(plainPassword, user.getPasswordHash())) {
            // Wrong password — record the failure
            recordFailedAttempt(user.getUserId(), user.getFailedAttempts() + 1);
            return null;
        }

        // Success — update login meta
        updateLoginSuccess(user.getUserId(), user.getLastLogin());
        user.resetFailedAttempts();
        return user;
    }

    // ── LOGIN HELPERS ──────────────────────────────────────

    /**
     * Records a failed login attempt and locks the account if threshold reached.
     */
    private void recordFailedAttempt(int userId, int newCount) {
        boolean lock = newCount >= 5;
        String sql = "UPDATE users SET failed_attempts = ?, is_locked = ? WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt    (1, newCount);
            ps.setBoolean(2, lock);
            ps.setInt    (3, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[UserDAO.recordFailedAttempt] " + e.getMessage());
        }
    }

    /**
     * On successful login:
     * - Resets failed_attempts to 0, unlocks account.
     * - Updates last_login to today.
     * - Increments login_streak if last login was yesterday; resets if older.
     */
    private void updateLoginSuccess(int userId, LocalDate lastLogin) {
        LocalDate today = LocalDate.now();
        int streakUpdate;

        if (lastLogin == null) {
            streakUpdate = 1;                                  // first ever login
        } else if (lastLogin.plusDays(1).equals(today)) {
            streakUpdate = -1;                                 // -1 means "+1 in SQL"
        } else if (lastLogin.equals(today)) {
            streakUpdate = 0;                                  // same day — no change
        } else {
            streakUpdate = 1;                                  // streak broken, reset to 1
        }

        String sql;
        if (streakUpdate == -1) {
            // Increment streak
            sql = "UPDATE users SET failed_attempts = 0, is_locked = 0, "
                + "last_login = CURDATE(), login_streak = login_streak + 1 WHERE user_id = ?";
        } else if (streakUpdate == 0) {
            // Same day login
            sql = "UPDATE users SET failed_attempts = 0, is_locked = 0 WHERE user_id = ?";
        } else {
            // Reset streak to 1
            sql = "UPDATE users SET failed_attempts = 0, is_locked = 0, "
                + "last_login = CURDATE(), login_streak = 1 WHERE user_id = ?";
        }

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[UserDAO.updateLoginSuccess] " + e.getMessage());
        }
    }

    // ── UPDATE ─────────────────────────────────────────────

    /**
     * Updates a user's PokéCoins balance.
     * @param delta positive = add coins, negative = spend coins.
     * @return true if update succeeded.
     */
    public boolean updateCoins(int userId, int delta) {
        String sql = "UPDATE users SET coins = coins + ? WHERE user_id = ? AND coins + ? >= 0";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setInt(2, userId);
            ps.setInt(3, delta);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[UserDAO.updateCoins] " + e.getMessage());
            return false;
        }
    }

    /** Updates a user's password (after forgot-password flow). */
    public boolean updatePassword(int userId, String newHashedPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setInt   (2, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[UserDAO.updatePassword] " + e.getMessage());
            return false;
        }
    }

    /** Unlocks a user account (admin action). */
    public boolean unlockAccount(int userId) {
        String sql = "UPDATE users SET is_locked = 0, failed_attempts = 0 WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[UserDAO.unlockAccount] " + e.getMessage());
            return false;
        }
    }

    // ── DUPLICATE CHECKS ───────────────────────────────────

    public boolean usernameExists(String username) {
        return countWhere("username", username) > 0;
    }

    public boolean emailExists(String email) {
        return countWhere("email", email) > 0;
    }

    private int countWhere(String column, String value) {
        String sql = "SELECT COUNT(*) FROM users WHERE " + column + " = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO.countWhere] " + e.getMessage());
        }
        return 0;
    }

    // ── RESULT SET MAPPER ──────────────────────────────────

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId        (rs.getInt    ("user_id"));
        user.setUsername      (rs.getString ("username"));
        user.setPasswordHash  (rs.getString ("password_hash"));
        user.setEmail         (rs.getString ("email"));
        user.setRole          (rs.getString ("role"));
        user.setLoginStreak   (rs.getInt    ("login_streak"));
        user.setCoins         (rs.getInt    ("coins"));
        user.setLocked        (rs.getBoolean("is_locked"));
        user.setFailedAttempts(rs.getInt    ("failed_attempts"));

        Date lastLogin = rs.getDate("last_login");
        if (lastLogin != null) user.setLastLogin(lastLogin.toLocalDate());

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) user.setCreatedAt(createdAt.toLocalDateTime());
        return user;
    }
}
