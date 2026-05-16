package com.pokemuse.controller;

import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.InventoryDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import com.pokemuse.config.DBConfig;

@WebServlet("/catch")
public class CatchServlet extends HttpServlet {

    private final CardDao cardDao = new CardDao();
    private final InventoryDao inventoryDao = new InventoryDao();

    // GET: show catch arena with random wild Pokemon
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;

        // Load a random wild Pokemon for encounter
        PokeModel wildPokemon = cardDao.getRandomCard();
        req.setAttribute("wildPokemon", wildPokemon);
        req.setAttribute("catchState", "idle");

        req.getRequestDispatcher("/WEB-INF/pages/catch.jsp").forward(req, res);
    }

    // POST: process the throw
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);

        int cardId;
        try {
            cardId = Integer.parseInt(req.getParameter("cardId"));
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/catch");
            return;
        }

        PokeModel wildCard = cardDao.getCardById(cardId);
        if (wildCard == null) {
            res.sendRedirect(req.getContextPath() + "/catch");
            return;
        }

        //single roll determines catch, 3 shakes are visual only
        double catchProb = wildCard.getCatchProbability();
        boolean caught   = Math.random() < catchProb;

        // Shake results are for animation display only — always show 3 shakes but only the final outcome matters
        boolean shake1 = caught || Math.random() < 0.6; // pass most of the time
        boolean shake2 = caught || Math.random() < 0.4; // suspense on shake 2
        boolean shake3 = caught; // shake 3 = true only if caught

        // Log the attempt
        logCatchAttempt(userId, cardId, shake1, shake2, shake3, caught);

        // If caught -> add to inventory
        if (caught) {
            inventoryDao.addToInventory(userId, cardId, "catch");
            // Update quest progress for "catch" actions
            updateQuestProgress(userId, "catch");
            if ("Legendary".equals(wildCard.getRarity())) {
                updateQuestProgress(userId, "catch_legendary");
            }
        }

        // Forward back to catch page with result
        req.setAttribute("wildPokemon", wildCard);
        req.setAttribute("catchState",  caught ? "caught" : "failed");
        req.setAttribute("caught",      caught);
        req.setAttribute("shake1",      shake1);
        req.setAttribute("shake2",      shake2);
        req.setAttribute("shake3",      shake3);

        req.getRequestDispatcher("/WEB-INF/pages/catch.jsp").forward(req, res);
    }

    // Log catch attempt to catch_log table
    private void logCatchAttempt(int userId, int cardId,
                                  boolean s1, boolean s2, boolean s3, boolean caught) {
        String sql = "INSERT INTO catch_log (user_id, card_id, shake_1, shake_2, shake_3, caught) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt    (1, userId);
            ps.setInt    (2, cardId);
            ps.setBoolean(3, s1);
            ps.setBoolean(4, s2);
            ps.setBoolean(5, s3);
            ps.setBoolean(6, caught);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[CatchServlet.logCatchAttempt] " + e.getMessage());
        }
    }

    // Increment quest progress for catch actions
    private void updateQuestProgress(int userId, String actionType) {
        String sql = "UPDATE user_quest_progress uqp "
                   + "JOIN quests q ON uqp.quest_id = q.quest_id "
                   + "SET uqp.current_count = uqp.current_count + 1, "
                   + "    uqp.is_completed = IF(uqp.current_count + 1 >= q.target_count, 1, 0) "
                   + "WHERE uqp.user_id = ? AND q.action_type = ? AND uqp.is_claimed = 0";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, actionType);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[CatchServlet.updateQuestProgress] " + e.getMessage());
        }
    }
}