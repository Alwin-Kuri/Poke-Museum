package com.pokemuse.controller;

import com.pokemuse.config.DbConfig;
import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.InventoryDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/booster")
public class BoosterPackServlet extends HttpServlet {

    private final CardDao      cardDao      = new CardDao();
    private final InventoryDao inventoryDao = new InventoryDao();

    // Rarity thresholds per pack type [legendary, epic, rare] — rest = common
    private static final double[][] ODDS = {
        // legendary, epic,  rare  (common = remainder)
        { 0.03,       0.15,  0.40 },  // basic
        { 0.08,       0.30,  0.70 },  // elite
        { 0.20,       0.65,  0.95 },  // master
    };
    private static final String[] PACK_NAMES = { "basic", "elite", "master" };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (SessionUtil.requireLogin(req, res)) return;
        req.getRequestDispatcher("/WEB-INF/pages/booster.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);

        String packType = req.getParameter("packType");
        int packIndex = switch (packType == null ? "basic" : packType) {
            case "elite"  -> 1;
            case "master" -> 2;
            default       -> 0;
        };

        // Roll 5 cards
        List<PokeModel> pulledCards = new ArrayList<>();
        for (int i = 0; i < 5; i++) {
            String rarity = rollRarity(packIndex);
            PokeModel card = cardDao.getRandomCardByRarity(rarity);
            if (card == null) card = cardDao.getRandomCard(); // fallback
            if (card != null) {
                pulledCards.add(card);
                inventoryDao.addToInventory(userId, card.getCardId(), "booster");
            }
        }

        // Log the pack opening
        int packId = logPackOpening(userId, packType == null ? "basic" : packType, pulledCards);

        // Update quest progress for open_pack action
        updateQuestProgress(userId, "open_pack");

        req.setAttribute("pulledCards", pulledCards);
        req.setAttribute("packType",    PACK_NAMES[packIndex]);
        req.setAttribute("packOpened",  true);

        req.getRequestDispatcher("/WEB-INF/pages/booster.jsp").forward(req, res);
    }

    // ── Rarity roll using cumulative probability ───────
    private String rollRarity(int packIndex) {
        double roll = Math.random();
        double[] thresholds = ODDS[packIndex];
        if (roll < thresholds[0]) return PokeModel.RARITY_LEGENDARY;
        if (roll < thresholds[1]) return PokeModel.RARITY_EPIC;
        if (roll < thresholds[2]) return PokeModel.RARITY_RARE;
        return PokeModel.RARITY_COMMON;
    }

    // ── Log the pack and its cards to the database ─────
    private int logPackOpening(int userId, String packType, List<PokeModel> cards) {
        int packId = -1;
        String insertPack = "INSERT INTO booster_packs (user_id, pack_type) VALUES (?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertPack, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt   (1, userId);
            ps.setString(2, packType);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) packId = rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[BoosterPackServlet.logPackOpening] " + e.getMessage());
            return -1;
        }

        // Log individual cards
        String insertCards = "INSERT INTO booster_pack_cards (pack_id, card_id) VALUES (?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertCards)) {
            for (PokeModel card : cards) {
                ps.setInt(1, packId);
                ps.setInt(2, card.getCardId());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            System.err.println("[BoosterPackServlet.logPackCards] " + e.getMessage());
        }
        return packId;
    }

    // ── Update quest progress ──────────────────────────
    private void updateQuestProgress(int userId, String actionType) {
        String sql =
            "UPDATE user_quest_progress uqp " +
            "JOIN quests q ON uqp.quest_id = q.quest_id " +
            "SET uqp.current_count = uqp.current_count + 1, " +
            "    uqp.is_completed = IF(uqp.current_count + 1 >= q.target_count, 1, 0) " +
            "WHERE uqp.user_id = ? AND q.action_type = ? AND uqp.is_claimed = 0";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, actionType);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[BoosterPackServlet.updateQuestProgress] " + e.getMessage());
        }
    }
}
