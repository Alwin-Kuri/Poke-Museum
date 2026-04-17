package com.pokemuse.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;

/**
 * AuthFilter.java — Servlet Filter
 * ─────────────────────────────────────────────────────
 * Intercepts all requests and enforces authentication
 * and role-based access at the URL level.
 *
 * Rules:
 *   • Public paths (/, /login, /register, /css, /js, /images)
 *     are always accessible without a session.
 *   • /admin/* requires an admin session — redirects to /home
 *     if a normal user tries to access it.
 *   • All other paths require a logged-in session — redirects
 *     to /login?redirect=<path> if session is missing.
 *
 * This is the "Redirect Management (Filter)" component
 * required by the CS5003NI coursework specification.
 *
 * Author : Alwin Maharjan | CS5003NI
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    // Paths accessible without any login
    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/login", "/register", "/forgot-password",
        "/css", "/js", "/images", "/favicon.ico",
        "/"
    );

    // Paths that require admin role specifically
    private static final String ADMIN_PREFIX = "/admin";

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        String contextPath = request.getContextPath();
        String requestURI  = request.getRequestURI();
        // Strip the context path to get the relative path
        String path = requestURI.substring(contextPath.length());

        // ── Always allow public paths ──────────────────
        if (isPublic(path)) {
            chain.doFilter(req, res);
            return;
        }

        // ── Check for active session ───────────────────
        if (!SessionUtil.isLoggedIn(request)) {
            // Redirect to login, preserve the intended destination
            response.sendRedirect(contextPath + "/login?redirect="
                + java.net.URLEncoder.encode(path, "UTF-8")
                + "&error=session");
            return;
        }

        // ── Check admin paths ──────────────────────────
        if (path.startsWith(ADMIN_PREFIX) && !SessionUtil.isAdmin(request)) {
            // Regular user trying to access admin — send home with error
            response.sendRedirect(contextPath + "/home?error=unauthorized");
            return;
        }

        // ── All checks passed — continue request ───────
        chain.doFilter(req, res);
    }

    /** Returns true if the path is publicly accessible. */
    private boolean isPublic(String path) {
        if (path == null || path.isEmpty() || path.equals("/")) return true;
        for (String pub : PUBLIC_PATHS) {
            if (path.startsWith(pub)) return true;
        }
        return false;
    }

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void destroy() {}
}
