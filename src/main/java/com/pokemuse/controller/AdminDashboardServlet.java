package com.pokemuse.controller;

import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.UserDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * AdminDashboardServlet.java — Controller (FIXED)
 * ─────────────────────────────────────────────────────
 * Changes:
 *   + Now reads search, rarity, sort params from request
 *   + Passes filtered card list to JSP (not always getAllCards)
 *   + Passes filter values back to JSP so inputs stay filled
 *   + Passes undoStackSize for the undo button badge
 *
 * Author : Alwin Maharjan | CS5003NI
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final CardDao CardDao = new CardDao();
    private final UserDao UserDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Guard — admin only
        if (SessionUtil.requireAdmin(req, res)) return;

        // ── Read filter / search / sort params ─────────────
        String search  = ValidationUtil.sanitise(req.getParameter("search"));
        String rarity  = ValidationUtil.sanitise(req.getParameter("rarity"));
        String sort    = ValidationUtil.sanitise(req.getParameter("sort"));

        // Resolve sort column safely
        String orderCol = switch (sort) {
            case "name"       -> "name";
            case "value_asc"  -> "value";
            case "value_desc" -> "value";
            case "rarity"     -> "rarity";
            default           -> "card_id";
        };
        String orderDir = "value_asc".equals(sort) ? "ASC" : "DESC";

        // ── Load filtered card list ─────────────────────────
        List<PokeModel> cards = CardDao.getCardsWithFilter(
            search.isEmpty() ? null : search,
            null,                              // no type filter on admin dashboard
            rarity.isEmpty() ? null : rarity,
            orderCol,
            orderDir
        );

        // ── Dashboard aggregate metrics ─────────────────────
        req.setAttribute("totalCards",         CardDao.getTotalCardCount());
        req.setAttribute("totalValue",         CardDao.getTotalCollectionValue());
        req.setAttribute("mostValuable",       CardDao.getMostValuableCard());
        req.setAttribute("mostRare",           CardDao.getMostRareCard());
        req.setAttribute("rarityDistribution", CardDao.getRarityDistribution());
        req.setAttribute("allUsers",           UserDao.getAllUsers());

        // ── Filtered card list for table ────────────────────
        req.setAttribute("allCards",     cards);
        req.setAttribute("resultCount",  cards.size());

        // ── Pass filter values back so inputs stay filled ───
        req.setAttribute("searchQuery",  search);
        req.setAttribute("filterRarity", rarity);
        req.setAttribute("sortBy",       sort);

        // ── Undo stack size for the undo button badge ───────
        req.setAttribute("undoStackSize", UndoStack.size(req.getSession()));

        req.getRequestDispatcher("/WEB-INF/pages/admin-dashboard.jsp")
           .forward(req, res);
    }
}