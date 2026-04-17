package com.pokemuse.dao;

import com.pokemuse.config.DbConfig;
import com.pokemuse.model.PokeModel;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TradeDAO.java — Data Access Object
 * ─────────────────────────────────────────────────────
 * All database operations for the trading marketplace.
 * Covers: `trades` and `trade_offers` tables.
 *
 * Flow:
 *   1. User lists a card → trades (status='open')
 *   2. Another user makes an offer → trade_offers (status='pending')
 *   3. Listing owner accepts → swap inventories + close trade
 *   4. Listing owner rejects → trade_offer (status='rejected')
 *
 * Author : Alwin Maharjan | CS5003NI
 */
public class TradeDao {

    // ═══════════════════════════════════════════════
    //  TRADE LISTINGS
    // ═══════════════════════════════════════════════

    /**
     * Lists a card on the trading marketplace.
     * @return the new trade_id, or -1 on failure.
     */
    public int listCard(int userId, int cardId) {
        // Check: user must own the card
        String sql = "INSERT INTO trades (offered_by, card_id) VALUES (?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, cardId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            System.err.println("[TradeDAO.listCard] Duplicate or constraint error: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("[TradeDAO.listCard] " + e.getMessage());
        }
        return -1;
    }

    /**
     * Cancels a trade listing. Only the owner can cancel.
     */
    public boolean cancelListing(int tradeId, int userId) {
        String sql = "UPDATE trades SET status = 'cancelled' " +
                     "WHERE trade_id = ? AND offered_by = ? AND status = 'open'";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tradeId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TradeDAO.cancelListing] " + e.getMessage());
            return false;
        }
    }

    /**
     * Returns all open trade listings, joined with card + user info.
     * Excludes listings by the current user (they can't offer to themselves).
     */
    public List<TradeListingView> getOpenListings(int excludeUserId) {
        String sql =
            "SELECT t.trade_id, t.offered_by, t.listed_at, " +
            "       u.username AS lister_name, " +
            "       pc.card_id, pc.card_code, pc.name, pc.type, pc.rarity, " +
            "       pc.condition_state, pc.value, pc.image_path " +
            "FROM trades t " +
            "JOIN users u ON t.offered_by = u.user_id " +
            "JOIN pokemon_cards pc ON t.card_id = pc.card_id " +
            "WHERE t.status = 'open' AND t.offered_by != ? " +
            "ORDER BY t.listed_at DESC";

        List<TradeListingView> list = new ArrayList<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, excludeUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapListing(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TradeDAO.getOpenListings] " + e.getMessage());
        }
        return list;
    }

    /**
     * Returns all listings owned by a specific user (including all statuses).
     */
    public List<TradeListingView> getMyListings(int userId) {
        String sql =
            "SELECT t.trade_id, t.offered_by, t.listed_at, t.status, " +
            "       u.username AS lister_name, " +
            "       pc.card_id, pc.card_code, pc.name, pc.type, pc.rarity, " +
            "       pc.condition_state, pc.value, pc.image_path " +
            "FROM trades t " +
            "JOIN users u ON t.offered_by = u.user_id " +
            "JOIN pokemon_cards pc ON t.card_id = pc.card_id " +
            "WHERE t.offered_by = ? ORDER BY t.listed_at DESC";

        List<TradeListingView> list = new ArrayList<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapListing(rs));
            }
        } catch (SQLException e) {
            System.err.println("[TradeDAO.getMyListings] " + e.getMessage());
        }
        return list;
    }

    /**
     * Returns count of open listings (for homepage stats).
     */
    public int getOpenListingCount() {
        String sql = "SELECT COUNT(*) FROM trades WHERE status = 'open'";
        try (Connection conn = DbConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[TradeDAO.getOpenListingCount] " + e.getMessage());
        }
        return 0;
    }

    // ═══════════════════════════════════════════════
    //  TRADE OFFERS
    // ═══════════════════════════════════════════════

    /**
     * Submits an offer on a trade listing.
     * Offering user must own the offered card.
     * @return the new offer_id, or -1 on failure.
     */
    public int makeOffer(int tradeId, int offeringUserId, int offeredCardId) {
        String sql = "INSERT INTO trade_offers (trade_id, offered_by, offered_card) VALUES (?, ?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, tradeId);
            ps.setInt(2, offeringUserId);
            ps.setInt(3, offeredCardId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[TradeDAO.makeOffer] " + e.getMessage());
        }
        return -1;
    }

    /**
     * Accepts a pending trade offer:
     *   1. Swaps cards between inventory records
     *   2. Marks trade as 'completed'
     *   3. Rejects all other pending offers on the same trade
     * All done in a single transaction.
     *
     * @return true if the swap was completed successfully.
     */
    public boolean acceptOffer(int offerId, int listingOwnerId) {
        // First, get the offer and trade details
        String fetchSql =
            "SELECT to2.offered_by AS offerer_id, to2.offered_card AS offerer_card, " +
            "       t.offered_by  AS lister_id,  t.card_id       AS lister_card, " +
            "       t.trade_id " +
            "FROM trade_offers to2 " +
            "JOIN trades t ON to2.trade_id = t.trade_id " +
            "WHERE to2.offer_id = ? AND t.offered_by = ? AND to2.status = 'pending'";

        try (Connection conn = DbConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int offererId, offererCard, listerId, listerCard, tradeId;
                try (PreparedStatement ps = conn.prepareStatement(fetchSql)) {
                    ps.setInt(1, offerId);
                    ps.setInt(2, listingOwnerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); return false; }
                        offererId   = rs.getInt("offerer_id");
                        offererCard = rs.getInt("offerer_card");
                        listerId    = rs.getInt("lister_id");
                        listerCard  = rs.getInt("lister_card");
                        tradeId     = rs.getInt("trade_id");
                    }
                }

                // Swap: remove lister's card, give offerer's card
                removeFromInventory(conn, listerId,  listerCard);
                removeFromInventory(conn, offererId, offererCard);
                addToInventory     (conn, listerId,  offererCard, "trade");
                addToInventory     (conn, offererId, listerCard,  "trade");

                // Mark trade as completed
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE trades SET status='completed', completed_at=NOW() WHERE trade_id=?")) {
                    ps.setInt(1, tradeId);
                    ps.executeUpdate();
                }

                // Accept this offer, reject all others for this trade
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE trade_offers SET status = CASE WHEN offer_id=? THEN 'accepted' ELSE 'rejected' END " +
                        "WHERE trade_id=?")) {
                    ps.setInt(1, offerId);
                    ps.setInt(2, tradeId);
                    ps.executeUpdate();
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[TradeDAO.acceptOffer] Rolled back: " + e.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[TradeDAO.acceptOffer] Connection error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Rejects a specific trade offer.
     */
    public boolean rejectOffer(int offerId, int listingOwnerId) {
        String sql =
            "UPDATE trade_offers to2 " +
            "JOIN trades t ON to2.trade_id = t.trade_id " +
            "SET to2.status = 'rejected' " +
            "WHERE to2.offer_id = ? AND t.offered_by = ? AND to2.status = 'pending'";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, offerId);
            ps.setInt(2, listingOwnerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[TradeDAO.rejectOffer] " + e.getMessage());
            return false;
        }
    }

    /**
     * Returns all pending offers received on the current user's listings.
     */
    public List<TradeOfferView> getIncomingOffers(int userId) {
        String sql =
            "SELECT to2.offer_id, to2.offered_at, to2.status, " +
            "       offerer.username AS offerer_name, " +
            "       t.trade_id, " +
            "       lc.name AS listed_card_name, lc.rarity AS listed_rarity, lc.value AS listed_value, lc.type AS listed_type, " +
            "       oc.name AS offered_card_name, oc.rarity AS offered_rarity, oc.value AS offered_value, oc.type AS offered_type, " +
            "       oc.image_path AS offered_img " +
            "FROM trade_offers to2 " +
            "JOIN trades t ON to2.trade_id = t.trade_id " +
            "JOIN users offerer ON to2.offered_by = offerer.user_id " +
            "JOIN pokemon_cards lc ON t.card_id = lc.card_id " +
            "JOIN pokemon_cards oc ON to2.offered_card = oc.card_id " +
            "WHERE t.offered_by = ? AND to2.status = 'pending' " +
            "ORDER BY to2.offered_at DESC";

        List<TradeOfferView> list = new ArrayList<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TradeOfferView v = new TradeOfferView();
                    v.offerId          = rs.getInt   ("offer_id");
                    v.tradeId          = rs.getInt   ("trade_id");
                    v.offererName      = rs.getString("offerer_name");
                    v.listedCardName   = rs.getString("listed_card_name");
                    v.listedRarity     = rs.getString("listed_rarity");
                    v.listedValue      = rs.getDouble("listed_value");
                    v.offeredCardName  = rs.getString("offered_card_name");
                    v.offeredRarity    = rs.getString("offered_rarity");
                    v.offeredValue     = rs.getDouble("offered_value");
                    v.offeredCardType  = rs.getString("offered_type");
                    v.offeredCardImg   = rs.getString("offered_img");
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            System.err.println("[TradeDAO.getIncomingOffers] " + e.getMessage());
        }
        return list;
    }

    // ═══════════════════════════════════════════════
    //  PRIVATE HELPERS (used within transactions)
    // ═══════════════════════════════════════════════

    private void removeFromInventory(Connection conn, int userId, int cardId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM user_inventory WHERE user_id = ? AND card_id = ?")) {
            ps.setInt(1, userId);
            ps.setInt(2, cardId);
            ps.executeUpdate();
        }
    }

    private void addToInventory(Connection conn, int userId, int cardId, String via) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT IGNORE INTO user_inventory (user_id, card_id, obtained_via) VALUES (?, ?, ?)")) {
            ps.setInt   (1, userId);
            ps.setInt   (2, cardId);
            ps.setString(3, via);
            ps.executeUpdate();
        }
    }

    // ═══════════════════════════════════════════════
    //  RESULT SET MAPPER
    // ═══════════════════════════════════════════════

    private TradeListingView mapListing(ResultSet rs) throws SQLException {
        TradeListingView v  = new TradeListingView();
        v.tradeId           = rs.getInt   ("trade_id");
        v.listedBy          = rs.getInt   ("offered_by");
        v.listerUsername    = rs.getString("lister_name");
        v.listedAt          = rs.getTimestamp("listed_at");

        PokeModel card    = new PokeModel();
        card.setCardId      (rs.getInt        ("card_id"));
        card.setCardCode    (rs.getString     ("card_code"));
        card.setName        (rs.getString     ("name"));
        card.setType        (rs.getString     ("type"));
        card.setRarity      (rs.getString     ("rarity"));
        card.setConditionState(rs.getString   ("condition_state"));
        card.setValue       (rs.getBigDecimal ("value"));
        card.setImagePath   (rs.getString     ("image_path"));
        v.card = card;
        return v;
    }

    // ═══════════════════════════════════════════════
    //  VIEW MODELS (inner classes for JSP binding)
    // ═══════════════════════════════════════════════

    /** Represents a single trade listing row for the marketplace view. */
    public static class TradeListingView {
        public int         tradeId;
        public int         listedBy;
        public String      listerUsername;
        public Timestamp   listedAt;
        public String      status;
        public PokeModel card;

        public String getRarityCss() {
            if (card == null) return "common";
            return card.getRarityCssClass();
        }
    }

    /** Represents an incoming trade offer for the owner's review. */
    public static class TradeOfferView {
        public int    offerId;
        public int    tradeId;
        public String offererName;
        public String listedCardName;
        public String listedRarity;
        public double listedValue;
        public String offeredCardName;
        public String offeredRarity;
        public double offeredValue;
        public String offeredCardType;
        public String offeredCardImg;
    }
}
