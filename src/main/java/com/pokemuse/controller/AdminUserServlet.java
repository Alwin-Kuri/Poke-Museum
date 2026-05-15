package com.pokemuse.controller;

import com.pokemuse.dao.UserDao;
import com.pokemuse.model.User;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * AdminUserServlet.java — Controller (FIXED)
 * ─────────────────────────────────────────────────────
 * Changes:
 *   + Reads search and role filter params from request
 *   + Filters user list in-memory (fast for small user counts)
 *   + Passes filter values back to JSP so inputs stay filled
 *   + Passes user counts (total, locked, admin) for stats strip
 *
 * Author : Alwin Maharjan | CS5003NI
 */
@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDao UserDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireAdmin(req, res)) return;

        // ── Read filter params ──────────────────────────────
        String search     = ValidationUtil.sanitise(req.getParameter("search"));
        String roleFilter = ValidationUtil.sanitise(req.getParameter("role"));

        // ── Load all users then filter in-memory ────────────
        // (User counts are small — DB filtering adds complexity without benefit)
        List<User> allUsers = UserDao.getAllUsers();

        // Apply username search filter
        List<User> filtered = allUsers;
        if (!search.isEmpty()) {
            final String q = search.toLowerCase();
            filtered = filtered.stream()
                .filter(u -> u.getUsername().toLowerCase().contains(q)
                          || u.getEmail().toLowerCase().contains(q))
                .collect(Collectors.toList());
        }

        // Apply role filter
        if (!roleFilter.isEmpty()) {
            final String r = roleFilter.toLowerCase();
            filtered = filtered.stream()
                .filter(u -> u.getRole().equalsIgnoreCase(r))
                .collect(Collectors.toList());
        }

        // ── Compute summary counts from full list ───────────
        long adminCount  = allUsers.stream().filter(User::isAdmin).count();
        long lockedCount = allUsers.stream().filter(User::isLocked).count();
        long userCount   = allUsers.size() - adminCount;

        // ── Set request attributes ──────────────────────────
        req.setAttribute("allUsers",     filtered);
        req.setAttribute("totalUsers",   allUsers.size());
        req.setAttribute("adminCount",   adminCount);
        req.setAttribute("userCount",    userCount);
        req.setAttribute("lockedCount",  lockedCount);
        req.setAttribute("resultCount",  filtered.size());

        // Pass filter values back so inputs stay filled
        req.setAttribute("searchQuery",  search);
        req.setAttribute("roleFilter",   roleFilter);

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

        // Admin cannot perform actions on their own account
        if (targetId == adminId) {
            res.sendRedirect(req.getContextPath() + "/admin/users?error=selfAction");
            return;
        }

        switch (action == null ? "" : action) {
            case "unlock" -> {
                boolean ok = UserDao.unlockAccount(targetId);
                res.sendRedirect(req.getContextPath() +
                    (ok ? "/admin/users?success=unlocked"
                        : "/admin/users?error=unlockFailed"));
            }
            default -> res.sendRedirect(req.getContextPath() + "/admin/users");
        }
    }
}