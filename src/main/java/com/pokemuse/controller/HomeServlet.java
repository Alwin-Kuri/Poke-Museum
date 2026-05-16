package com.pokemuse.controller;

import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.UserDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.model.User;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet({"/home", "/"})
public class HomeServlet extends HttpServlet {

    private final CardDao CardDao = new CardDao();
    private final UserDao UserDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // If not logged in — show public landing page
        if (!SessionUtil.isLoggedIn(req)) {
            loadPublicData(req);
            req.getRequestDispatcher("/WEB-INF/pages/landing.jsp").forward(req, res);
            return;
        }

        // Admins go straight to dashboard
        if (SessionUtil.isAdmin(req)) {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        // Logged-in user home
        loadPublicData(req);

        // Refresh user object in session (coins, streak may have changed)
        int userId = SessionUtil.getUserId(req);
        User freshUser = UserDao.getUserById(userId);
        if (freshUser != null) {
            SessionUtil.setUser(req, freshUser);
            req.setAttribute("currentUser", freshUser);
        }

        req.getRequestDispatcher("/WEB-INF/pages/home.jsp").forward(req, res);
    }

    /** Loads data needed by both landing and user home pages. */
    private void loadPublicData(HttpServletRequest req) {
        // Featured cards — top 10 by value
        List<PokeModel> featured = CardDao.getCardsWithFilter(
                null, null, null, "value", "DESC");
        if (featured.size() > 10) featured = featured.subList(0, 10);
        req.setAttribute("featuredCards", featured);

        // Stats
        req.setAttribute("totalCards", CardDao.getTotalCardCount());
        req.setAttribute("totalValue", CardDao.getTotalCollectionValue());
        req.setAttribute("mostValuable", CardDao.getMostValuableCard());
    }
}
