package com.pokemuse.dao;

import com.pokemuse.config.DbConfig;
import com.pokemuse.model.PokeModel;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDao {

    /**
     * Adds a card to a user's inventory.
     * The UNIQUE constraint on (user_id, card_id) prevents duplicates.
     *
     * @param userId      the trainer's user_id
     * @param cardId      the card to add
     * @param obtainedVia how the card was obtained ("browse","catch","booster","trade","quest_reward")
     * @return true if added successfully, false if already owned or DB error
     */
    public boolean addToInventory(int userId, int cardId, String obtainedVia) {
        String sql = "INSERT IGNORE INTO user_inventory (user_id, card_id, obtained_via) VALUES (?, ?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setInt   (2, cardId);
            ps.setString(3, obtainedVia);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InventoryDAO.addToInventory] " + e.getMessage());
            return false;
        }
    }

    /**
     * Removes a card from a user's inventory.
     * @return true if the card was removed.
     */
    public boolean removeFromInventory(int userId, int cardId) {
        String sql = "DELETE FROM user_inventory WHERE user_id = ? AND card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, cardId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[InventoryDAO.removeFromInventory] " + e.getMessage());
            return false;
        }
    }

    /**
     * Returns all PokeModel objects in a user's inventory,
     * joined with pokemon_cards for full details.
     */
    public List<PokeModel> getUserInventory(int userId) {
        String sql = "SELECT pc.* FROM pokemon_cards pc "
                   + "JOIN user_inventory ui ON pc.card_id = ui.card_id "
                   + "WHERE ui.user_id = ? AND pc.is_available = 1 "
                   + "ORDER BY ui.obtained_at DESC";
        List<PokeModel> cards = new ArrayList<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) cards.add(mapCard(rs));
            }
        } catch (SQLException e) {
            System.err.println("[InventoryDAO.getUserInventory] " + e.getMessage());
        }
        return cards;
    }

    /**
     * Returns the count of cards in a user's inventory.
     */
    public int getInventoryCount(int userId) {
        String sql = "SELECT COUNT(*) FROM user_inventory WHERE user_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[InventoryDAO.getInventoryCount] " + e.getMessage());
        }
        return 0;
    }

    /**
     * Returns true if the user already owns a specific card.
     */
    public boolean ownsCard(int userId, int cardId) {
        String sql = "SELECT COUNT(*) FROM user_inventory WHERE user_id = ? AND card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, cardId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[InventoryDAO.ownsCard] " + e.getMessage());
        }
        return false;
    }

    private PokeModel mapCard(ResultSet rs) throws SQLException {
        PokeModel c = new PokeModel();
        c.setCardId        (rs.getInt        ("card_id"));
        c.setCardCode      (rs.getString     ("card_code"));
        c.setName          (rs.getString     ("name"));
        c.setType          (rs.getString     ("type"));
        c.setRarity        (rs.getString     ("rarity"));
        c.setConditionState(rs.getString     ("condition_state"));
        c.setValue         (rs.getBigDecimal ("value"));
        c.setImagePath     (rs.getString     ("image_path"));
        c.setDescription   (rs.getString     ("description"));
        c.setCatchRate     (rs.getInt        ("catch_rate"));
        return c;
    }
}
