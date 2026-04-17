package com.pokemuse.controller;

import com.pokemuse.dao.UserDao;
import com.pokemuse.model.User;
import com.pokemuse.util.PasswordUtil;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDao UserDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // Already logged in → go home
        if (SessionUtil.isLoggedIn(req)) {
            res.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String username = ValidationUtil.sanitise(req.getParameter("username"));
        String email    = ValidationUtil.sanitise(req.getParameter("email"));
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirmPassword");

        // Validate all fields
        String usernameErr = ValidationUtil.validateUsername(username);
        String emailErr    = ValidationUtil.validateEmail(email);
        String passwordErr = ValidationUtil.validatePassword(password);
        String matchErr    = passwordErr == null
                           ? ValidationUtil.validatePasswordMatch(password, confirm)
                           : null;

        if (usernameErr != null) { setErrorAndForward(req, res, usernameErr, username, email); return; }
        if (emailErr    != null) { setErrorAndForward(req, res, emailErr,    username, email); return; }
        if (passwordErr != null) { setErrorAndForward(req, res, passwordErr, username, email); return; }
        if (matchErr    != null) { setErrorAndForward(req, res, matchErr,    username, email); return; }

        // Duplicate checks
        if (UserDao.usernameExists(username)) {
            setErrorAndForward(req, res, "Username '" + username + "' is already taken.", username, email);
            return;
        }
        if (UserDao.emailExists(email)) {
            setErrorAndForward(req, res, "An account with that email already exists.", username, email);
            return;
        }

        // Create user
        User newUser = new User(username, PasswordUtil.hash(password), email);
        if (!UserDao.registerUser(newUser)) {
            setErrorAndForward(req, res, "Registration failed. Please try again.", username, email);
            return;
        }

        // Redirect to login with success message
        res.sendRedirect(req.getContextPath() + "/login?registered=true");
    }

    private void setErrorAndForward(HttpServletRequest req, HttpServletResponse res,
                                     String error, String username, String email)
            throws ServletException, IOException {
        req.setAttribute("errorMsg", error);
        req.setAttribute("formUsername", username);
        req.setAttribute("formEmail", email);
        req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res);
    }
}
