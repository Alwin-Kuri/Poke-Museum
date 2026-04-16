package com.pokemuse.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class User {

    private int           userId;
    private String        username;
    private String        passwordHash;
    private String        email;
    private String        role;
    private int           loginStreak;
    private int           coins;
    private LocalDate     lastLogin;
    private boolean       locked;
    private int           failedAttempts;
    private LocalDateTime createdAt;


    public User() {}

    // constructor for new registrations
    public User(String username, String passwordHash, String email) {
        this.username     = username;
        this.passwordHash = passwordHash;
        this.email        = email;
        this.role         = "user";
        this.coins        = 100;
        this.loginStreak  = 0;
        this.failedAttempts = 0;
        this.locked       = false;
    }

    // Getters setters

    public int getUserId()               { return userId; }
    public void setUserId(int id)        { this.userId = id; }

    public String getUsername()          { return username; }
    public void setUsername(String u)    { this.username = u; }

    public String getPasswordHash()      { return passwordHash; }
    public void setPasswordHash(String p){ this.passwordHash = p; }

    public String getEmail()             { return email; }
    public void setEmail(String e)       { this.email = e; }

    public String getRole()              { return role; }
    public void setRole(String r)        { this.role = r; }

    public int getLoginStreak()          { return loginStreak; }
    public void setLoginStreak(int s)    { this.loginStreak = s; }

    public int getCoins()                { return coins; }
    public void setCoins(int c)          { this.coins = c; }

    public LocalDate getLastLogin()      { return lastLogin; }
    public void setLastLogin(LocalDate d){ this.lastLogin = d; }

    public boolean isLocked()            { return locked; }
    public void setLocked(boolean l)     { this.locked = l; }

    public int getFailedAttempts()       { return failedAttempts; }
    public void setFailedAttempts(int f) { this.failedAttempts = f; }

    public LocalDateTime getCreatedAt()              { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt){ this.createdAt = createdAt; }

    // Returns true if this account has admin privileges
    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(this.role);
    }

    // Increments failed login attempts (locks after 5)
    public void recordFailedAttempt() {
        this.failedAttempts++;
        if (this.failedAttempts >= 5) {
            this.locked = true;
        }
    }

    // Resets failed attempts on successful login
    public void resetFailedAttempts() {
        this.failedAttempts = 0;
        this.locked         = false;
    }

    @Override
    public String toString() {
        return "User{id=" + userId + ", username='" + username + "', role='" + role + "'}";
    }
}
