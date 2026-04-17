package com.pokemuse.controller;

import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.UserDao;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final CardDao cardDao = new CardDao();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Guard — admin only
        if (SessionUtil.requireAdmin(req, res)) return;

        // Load all dashboard data
        req.setAttribute("totalCards",          cardDao.getTotalCardCount());
        req.setAttribute("totalValue",          cardDao.getTotalCollectionValue());
        req.setAttribute("mostValuable",        cardDao.getMostValuableCard());
        req.setAttribute("mostRare",            cardDao.getMostRareCard());
        req.setAttribute("rarityDistribution",  cardDao.getRarityDistribution());
        req.setAttribute("allCards",            cardDao.getAllCards());
        req.setAttribute("allUsers",            userDao.getAllUsers());

        // Undo stack size (for the "Undo Delete" button badge)
        req.setAttribute("undoStackSize", UndoStack.size(req.getSession()));

        req.getRequestDispatcher("/WEB-INF/pages/admin-dashboard.jsp")
           .forward(req, res);
    }
}
