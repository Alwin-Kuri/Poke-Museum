package com.pokemuse.controller;

import com.pokemuse.dao.UserDao;
import com.pokemuse.model.User;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * AdminUserServlet.java — Controller
 * ─────────────────────────────────────────────────────
 * GET  /admin/users               → list all users
 * POST /admin/users?action=unlock → unlock a locked account
 * POST /admin/users?action=delete → remove a user account
 *
 * Access: Admin only.
 * Author : Alwin Maharjan | CS5003NI
 */
@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDao UserDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireAdmin(req, res)) return;

        List<User> allUsers = UserDao.getAllUsers();
        req.setAttribute("allUsers", allUsers);

        req.getRequestDispatcher("/WEB-INF/pages/admin-users.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireAdmin(req, res)) return;
        int adminId = SessionUtil.getUserId(req);
        String action = req.getParameter("action");

        int targetId;
        try {
            targetId = Integer.parseInt(req.getParameter("userId"));
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/admin/users?error=invalid");
            return;
        }

        // Admin cannot action on themselves
        if (targetId == adminId) {
            res.sendRedirect(req.getContextPath() + "/admin/users?error=selfAction");
            return;
        }

        switch (action == null ? "" : action) {
            case "unlock" -> {
                boolean ok = UserDao.unlockAccount(targetId);
                res.sendRedirect(req.getContextPath() +
                    (ok ? "/admin/users?success=unlocked" : "/admin/users?error=unlockFailed"));
            }
            default -> res.sendRedirect(req.getContextPath() + "/admin/users");
        }
    }
}
