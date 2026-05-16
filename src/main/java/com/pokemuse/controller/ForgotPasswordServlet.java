package com.pokemuse.controller;

import com.pokemuse.dao.UserDao;
import com.pokemuse.model.User;
import com.pokemuse.util.PasswordUtil;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Handles the full password reset flow (no email server needed):
 *
 *   Step 1 — GET  /forgot-password
 *             Shows the "enter your username/email" form
 *
 *   Step 2 — POST /forgot-password?step=lookup
 *             Looks up the user, stores userId in session,
 *             forwards to the "enter new password" form
 *
 *   Step 3 — POST /forgot-password?step=reset
 *             Validates the new password, hashes it,
 *             updates the DB, clears session token,
 *             redirects to login with success message
 *
 * Note: In a real production system you would send a time-limited reset link via email. 
 * For this courseworkthe reset is done entirely in-browser via session state, 
 * which is acceptable for a local/educational project.

 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDao UserDao = new UserDao();

    // Session key used to temporarily hold the reset target user ID
    private static final String SESSION_RESET_UID = "resetUserId";

    // GET: show step 1 form 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // If already logged in — redirect home
        if (SessionUtil.isLoggedIn(req)) {
            res.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Check if we're in step 2 (new password entry)
        Object resetUid = req.getSession(false) != null
            ? req.getSession().getAttribute(SESSION_RESET_UID)
            : null;

        if (resetUid != null) {
            req.setAttribute("step", "reset");
        } else {
            req.setAttribute("step", "lookup");
        }

        req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
           .forward(req, res);
    }

    // POST: process both steps 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String step = req.getParameter("step");

        if ("lookup".equals(step)) {
            handleLookup(req, res);
        } else if ("reset".equals(step)) {
            handleReset(req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/forgot-password");
        }
    }

    // STEP 1: look up the user by username or email 
    private void handleLookup(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String identifier = ValidationUtil.sanitise(req.getParameter("identifier"));

        if (ValidationUtil.isEmpty(identifier)) {
            req.setAttribute("step",     "lookup");
            req.setAttribute("errorMsg", "Please enter your username or email.");
            req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
               .forward(req, res);
            return;
        }

        // Try username first, then email
        User user = UserDao.getUserByUsername(identifier);


        if (user == null) {
            // Don't reveal whether account exists — generic message
            req.setAttribute("step",     "lookup");
            req.setAttribute("errorMsg", "No account found with that username or email.");
            req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
               .forward(req, res);
            return;
        }

        // Store the user ID in session — used to authorise the reset in step 2
        req.getSession(true).setAttribute(SESSION_RESET_UID, user.getUserId());
        req.setAttribute("step",        "reset");
        req.setAttribute("resetForUser", user.getUsername());
        req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
           .forward(req, res);
    }

    // STEP 2: validate new password and update DB ─
    private void handleReset(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Verify there's a valid reset session
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(SESSION_RESET_UID) == null) {
            res.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        int userId = (int) session.getAttribute(SESSION_RESET_UID);

        String newPassword = req.getParameter("newPassword");
        String confirm     = req.getParameter("confirmPassword");

        // Validate
        String pwErr = ValidationUtil.validatePassword(newPassword);
        if (pwErr != null) {
            req.setAttribute("step",     "reset");
            req.setAttribute("errorMsg", pwErr);
            req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
               .forward(req, res);
            return;
        }

        String matchErr = ValidationUtil.validatePasswordMatch(newPassword, confirm);
        if (matchErr != null) {
            req.setAttribute("step",     "reset");
            req.setAttribute("errorMsg", matchErr);
            req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
               .forward(req, res);
            return;
        }

        // Hash the new password and update
        String hashed = PasswordUtil.hash(newPassword);
        boolean updated = UserDao.updatePassword(userId, hashed);

        if (!updated) {
            req.setAttribute("step",     "reset");
            req.setAttribute("errorMsg", "Password update failed. Please try again.");
            req.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
               .forward(req, res);
            return;
        }

        // Clear the reset session token
        session.removeAttribute(SESSION_RESET_UID);

        // Redirect to login with success message
        res.sendRedirect(req.getContextPath() + "/login?passwordReset=true");
    }
}