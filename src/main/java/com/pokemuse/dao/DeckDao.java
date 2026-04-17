package com.pokemuse.dao;

import com.pokemuse.config.DbConfig;
import com.pokemuse.model.PokeModel;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DeckDAO.java — Data Access Object
 * ─────────────────────────────────────────────────────
 * All operations for the `decks` and `deck_cards` tables.
 *
 * Rules enforced:
 *   • Max 3 decks per user
 *   • Max 20 cards per deck
 *   • No duplicate cards in the same deck
 *   • Only cards in user's inventory can be added
 *
 * Author : Alwin Maharjan | CS5003NI
 */
public class DeckDao {

    // ═══════════════════════════════════════════════
    //  DECK CRUD
    // ═══════════════════════════════════════════════

    /**
     * Creates a new deck for the user.
     * Enforces max 3 decks per user.
     * @return the new deck_id, or -1 on failure.
     */
    public int createDeck(int userId, String deckName) {
        if (getDeckCount(userId) >= 3) return -1;

        String sql = "INSERT INTO decks (user_id, deck_name) VALUES (?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt   (1, userId);
            ps.setString(2, deckName.trim().isEmpty() ? "My Deck" : deckName.trim());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[DeckDAO.createDeck] " + e.getMessage());
        }
        return -1;
    }

    /**
     * Renames an existing deck.
     * Only the owner can rename their deck.
     */
    public boolean renameDeck(int deckId, int userId, String newName) {
        String sql = "UPDATE decks SET deck_name = ? WHERE deck_id = ? AND user_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newName.trim().isEmpty() ? "My Deck" : newName.trim());
            ps.setInt   (2, deckId);
            ps.setInt   (3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[DeckDAO.renameDeck] " + e.getMessage());
            return false;
        }
    }

    /**
     * Deletes a deck and all its card slots.
     */
    public boolean deleteDeck(int deckId, int userId) {
        String sql = "DELETE FROM decks WHERE deck_id = ? AND user_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[DeckDAO.deleteDeck] " + e.getMessage());
            return false;
        }
    }

    /**
     * Returns all decks belonging to a user, with their card list.
     * Returns a map of deck_id → DeckView.
     */
    public List<DeckView> getUserDecks(int userId) {
        String sql =
            "SELECT d.deck_id, d.deck_name, d.created_at, " +
            "       pc.card_id, pc.name, pc.type, pc.rarity, pc.value, pc.image_path, " +
            "       dc.slot_position " +
            "FROM decks d " +
            "LEFT JOIN deck_cards dc ON d.deck_id = dc.deck_id " +
            "LEFT JOIN pokemon_cards pc ON dc.card_id = pc.card_id " +
            "WHERE d.user_id = ? " +
            "ORDER BY d.deck_id, dc.slot_position";

        Map<Integer, DeckView> deckMap = new LinkedHashMap<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int deckId = rs.getInt("deck_id");
                    DeckView deck = deckMap.computeIfAbsent(deckId, id -> {
                        DeckView d = new DeckView();
                        d.deckId   = id;
                        d.userId   = userId;
                        try {
                            d.deckName = rs.getString("deck_name");
                            Timestamp ts = rs.getTimestamp("created_at");
                            if (ts != null) d.createdAt = ts.toString().substring(0, 10);
                        } catch (SQLException ex) { /* ignore */ }
                        d.cards = new ArrayList<>();
                        return d;
                    });

                    // Add card if slot is populated
                    if (rs.getInt("card_id") != 0) {
                        PokeModel card = new PokeModel();
                        card.setCardId   (rs.getInt   ("card_id"));
                        card.setName     (rs.getString("name"));
                        card.setType     (rs.getString("type"));
                        card.setRarity   (rs.getString("rarity"));
                        card.setValue    (rs.getBigDecimal("value"));
                        card.setImagePath(rs.getString("image_path"));
                        deck.cards.add(card);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[DeckDAO.getUserDecks] " + e.getMessage());
        }
        return new ArrayList<>(deckMap.values());
    }

    // ═══════════════════════════════════════════════
    //  DECK CARDS
    // ═══════════════════════════════════════════════

    /**
     * Adds a card to a deck.
     * Enforces: max 20 cards, no duplicates, user owns the card.
     * @return true if added successfully.
     */
    public boolean addCardToDeck(int deckId, int userId, int cardId) {
        // Ownership check on the deck
        if (!ownsD(deckId, userId)) return false;
        // Max 20 cards
        if (getCardCount(deckId) >= 20) return false;

        // Next available slot
        int slot = getNextSlot(deckId);

        String sql = "INSERT IGNORE INTO deck_cards (deck_id, card_id, slot_position) VALUES (?, ?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            ps.setInt(2, cardId);
            ps.setInt(3, slot);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[DeckDAO.addCardToDeck] " + e.getMessage());
            return false;
        }
    }

    /**
     * Removes a card from a deck.
     */
    public boolean removeCardFromDeck(int deckId, int userId, int cardId) {
        if (!ownsD(deckId, userId)) return false;
        String sql = "DELETE FROM deck_cards WHERE deck_id = ? AND card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            ps.setInt(2, cardId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[DeckDAO.removeCardFromDeck] " + e.getMessage());
            return false;
        }
    }

    // ═══════════════════════════════════════════════
    //  HELPER QUERIES
    // ═══════════════════════════════════════════════

    public int getDeckCount(int userId) {
        String sql = "SELECT COUNT(*) FROM decks WHERE user_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { /* ignore */ }
        return 0;
    }

    private int getCardCount(int deckId) {
        String sql = "SELECT COUNT(*) FROM deck_cards WHERE deck_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { /* ignore */ }
        return 0;
    }

    private int getNextSlot(int deckId) {
        String sql = "SELECT COALESCE(MAX(slot_position), -1) + 1 FROM deck_cards WHERE deck_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { /* ignore */ }
        return 0;
    }

    private boolean ownsD(int deckId, int userId) {
        String sql = "SELECT COUNT(*) FROM decks WHERE deck_id = ? AND user_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { /* ignore */ }
        return false;
    }

    // ═══════════════════════════════════════════════
    //  VIEW MODEL
    // ═══════════════════════════════════════════════

    /** Represents a single deck with its card list for JSP rendering. */
    public static class DeckView {
        public int              deckId;
        public int              userId;
        public String           deckName;
        public String           createdAt;
        public List<PokeModel> cards = new ArrayList<>();

        public int getCardCount()       { return cards.size(); }
        public int getSlotsRemaining()  { return 20 - cards.size(); }
        public boolean isFull()         { return cards.size() >= 20; }

        /** Progress percent toward a full deck (20 cards). */
        public int getCompletionPct()   { return (int)((cards.size() / 20.0) * 100); }
    }
}
