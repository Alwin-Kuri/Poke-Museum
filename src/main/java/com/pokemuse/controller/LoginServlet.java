package com.pokemuse.controller;

import com.pokemuse.dao.UserDao;
import com.pokemuse.model.User;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDao UserDao = new UserDao();

    // GET: show the login page
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // If already logged in — redirect to appropriate home
        if (SessionUtil.isLoggedIn(req)) {
            redirectByRole(req, res);
            return;
        }

        // Forward to login.jsp
        req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, res);
    }

    // POST: process login form
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Prevent caching of login responses
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        String username = ValidationUtil.sanitise(req.getParameter("username"));
        String password = req.getParameter("password");

        // Basic validation
        if (ValidationUtil.isEmpty(username) || ValidationUtil.isEmpty(password)) {
            req.setAttribute("errorMsg", "Username and password are required.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, res);
            return;
        }

        // Authenticate via DAO
        User user = UserDao.validateLogin(username, password);

        if (user == null) {
            // Check if account got locked after this attempt
            User checkUser = UserDao.getUserByUsername(username);
            if (checkUser != null && checkUser.isLocked()) {
                req.setAttribute("errorMsg",
                    "Account locked after too many failed attempts. Contact admin.");
            } else {
                req.setAttribute("errorMsg",
                    "Invalid username or password. Please try again.");
            }
            req.setAttribute("attemptedUsername", username);
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, res);
            return;
        }

        // Success — create session
        SessionUtil.setUser(req, user);

        // Check for a redirect parameter (after session expiry)
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isBlank()
                && redirect.startsWith("/")
                && !redirect.contains("//")) {
            res.sendRedirect(req.getContextPath() + redirect);
            return;
        }

        redirectByRole(req, res);
    }

    // Helper: redirect to correct dashboard
    private void redirectByRole(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String ctx = req.getContextPath();
        User user  = SessionUtil.getUser(req);
        if (user != null && user.isAdmin()) {
            res.sendRedirect(ctx + "/admin/dashboard");
        } else {
            res.sendRedirect(ctx + "/home");
        }
    }
}
