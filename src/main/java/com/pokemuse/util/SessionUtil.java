package com.pokemuse.util;

import com.pokemuse.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;


public class SessionUtil {

    public static final String ATTR_USER = "loggedInUser";
    public static final String ATTR_ROLE = "userRole";
    public static final String ATTR_ID   = "userId";

    // Prevent instantiation
    private SessionUtil() {}

    // Stores user in session after logging in

    /**
     * Stores the authenticated user in the HTTP session.
     * Called by LoginServlet after successful credential check.
     */
    public static void setUser(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute(ATTR_USER, user);
        session.setAttribute(ATTR_ROLE, user.getRole());
        session.setAttribute(ATTR_ID,   user.getUserId());
    }

    // Retrieve user from session

    /**
     * Returns the logged-in User from the current session.
     * @return the User object, or null if not logged in.
     */
    public static User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute(ATTR_USER);
    }

    /**
     * Returns the user_id of the logged-in user.
     * @return user_id as int, or -1 if not logged in.
     */
    public static int getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return -1;
        Object id = session.getAttribute(ATTR_ID);
        return id == null ? -1 : (int) id;
    }


    /**
     * Returns true if a user is currently logged in.
     */
    public static boolean isLoggedIn(HttpServletRequest request) {
        return getUser(request) != null;
    }

    /**
     * Returns true if the logged-in user is an admin.
     */
    public static boolean isAdmin(HttpServletRequest request) {
        User user = getUser(request);
        return user != null && user.isAdmin();
    }

    /**
     * Guard for pages that require login.
     * Redirects to /login if not authenticated.
     * @return true if redirect happened (caller should return immediately).
     */
    public static boolean requireLogin(HttpServletRequest req,
                                       HttpServletResponse res) throws IOException {
        if (!isLoggedIn(req)) {
            res.sendRedirect(req.getContextPath() + "/login?error=session");
            return true;
        }
        return false;
    }

    /**
     * Guard for admin-only pages.
     * Redirects to /home with an error if not admin.
     * @return true if redirect happened (caller should return immediately).
     */
    public static boolean requireAdmin(HttpServletRequest req,
                                       HttpServletResponse res) throws IOException {
        if (requireLogin(req, res)) return true;
        if (!isAdmin(req)) {
            res.sendRedirect(req.getContextPath() + "/home?error=unauthorized");
            return true;
        }
        return false;
    }

    // Destroy session on logout

    /**
     * Invalidates the current session (called by LogoutServlet).
     */
    public static void invalidate(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
}
