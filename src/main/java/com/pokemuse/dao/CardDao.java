 package com.pokemuse.dao;

import com.pokemuse.config.DbConfig;
import com.pokemuse.model.PokeModel;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class CardDao {

    /**
     * Inserts a new Pokemon card into the museum catalogue
     * @return true if the insert succeeded, false otherwise
     */
    public boolean addCard(PokeModel card) {
        String sql = "INSERT INTO pokemon_cards "
                   + "(card_code, name, type, rarity, condition_state, value, image_path, description, catch_rate, created_by) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString    (1, card.getCardCode().toUpperCase());
            ps.setString    (2, card.getName());
            ps.setString    (3, card.getType());
            ps.setString    (4, card.getRarity());
            ps.setString    (5, card.getConditionState());
            ps.setBigDecimal(6, card.getValue());
            ps.setString    (7, card.getImagePath());
            ps.setString    (8, card.getDescription());
            ps.setInt       (9, card.getCatchRate());
            ps.setInt       (10, card.getCreatedBy());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[CardDAO.addCard] " + e.getMessage());
            return false;
        }
    }

    //  READ — single card

    // Returns a card by its primary key or null if not found
    public PokeModel getCardById(int cardId) {
        String sql = "SELECT * FROM pokemon_cards WHERE card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getCardById] " + e.getMessage());
        }
        return null;
    }

    // Returns a card by its unique card_code or null if not found
    public PokeModel getCardByCode(String cardCode) {
        String sql = "SELECT * FROM pokemon_cards WHERE card_code = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cardCode.toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getCardByCode] " + e.getMessage());
        }
        return null;
    }

    //  READ — all cards

    /**
     * Returns all cards in the catalogue, ordered by card_id ascending.
     * Used as the base list for client-side sorting algorithms.
     */
    public List<PokeModel> getAllCards() {
        return getCardsWithFilter(null, null, null, "card_id", "ASC");
    }

    /**
     * Returns cards with optional filtering and DB-level ordering.
     * @param nameFilter   partial name match (SQL LIKE) — null to skip
     * @param typeFilter   exact type match — null to skip
     * @param rarityFilter exact rarity match — null to skip
     * @param orderBy      column name for ORDER BY (validated below)
     * @param direction    "ASC" or "DESC"
     */
    public List<PokeModel> getCardsWithFilter(String nameFilter, String typeFilter,
                                                 String rarityFilter, String orderBy,
                                                 String direction) {
        // Whitelist order columns to prevent injection via orderBy param
        String safeOrder = switch (orderBy != null ? orderBy : "card_id") {
            case "name", "value", "rarity", "type", "condition_state" -> orderBy;
            default -> "card_id";
        };
        String safeDir = "DESC".equalsIgnoreCase(direction) ? "DESC" : "ASC";

        StringBuilder sql = new StringBuilder(
            "SELECT * FROM pokemon_cards WHERE is_available = 1"
        );
        List<Object> params = new ArrayList<>();

        if (nameFilter != null && !nameFilter.isBlank()) {
            sql.append(" AND name LIKE ?");
            params.add("%" + nameFilter.trim() + "%");
        }
        if (typeFilter != null && !typeFilter.isBlank()) {
            sql.append(" AND type = ?");
            params.add(typeFilter.trim());
        }
        if (rarityFilter != null && !rarityFilter.isBlank()) {
            sql.append(" AND rarity = ?");
            params.add(rarityFilter.trim());
        }
        sql.append(" ORDER BY ").append(safeOrder).append(" ").append(safeDir);

        List<PokeModel> cards = new ArrayList<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) cards.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getCardsWithFilter] " + e.getMessage());
        }
        return cards;
    }

    /**
     * Returns cards with pagination support.
     * @param page     page number (1-based)
     * @param pageSize number of cards per page
     */
    public List<PokeModel> getCardsPaged(int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        String sql = "SELECT * FROM pokemon_cards WHERE is_available = 1 "
                   + "ORDER BY card_id ASC LIMIT ? OFFSET ?";
        List<PokeModel> cards = new ArrayList<>();
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) cards.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getCardsPaged] " + e.getMessage());
        }
        return cards;
    }

    /** Returns the total number of available cards (for pagination). */
    public int getTotalCardCount() {
        String sql = "SELECT COUNT(*) FROM pokemon_cards WHERE is_available = 1";
        try (Connection conn = DbConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getTotalCardCount] " + e.getMessage());
        }
        return 0;
    }

    //  UPDATE
    /**
     * Updates an existing card's details.
     * @return true if exactly one row was updated.
     */
    public boolean updateCard(PokeModel card) {
        String sql = "UPDATE pokemon_cards SET "
                   + "name = ?, type = ?, rarity = ?, condition_state = ?, "
                   + "value = ?, image_path = ?, description = ?, catch_rate = ? "
                   + "WHERE card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString    (1, card.getName());
            ps.setString    (2, card.getType());
            ps.setString    (3, card.getRarity());
            ps.setString    (4, card.getConditionState());
            ps.setBigDecimal(5, card.getValue());
            ps.setString    (6, card.getImagePath());
            ps.setString    (7, card.getDescription());
            ps.setInt       (8, card.getCatchRate());
            ps.setInt       (9, card.getCardId());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[CardDAO.updateCard] " + e.getMessage());
            return false;
        }
    }

    //  DELETE (soft delete - sets is_available = 0)

    /**
     * Soft-deletes a card (marks is_available = 0).
     * The card is pushed to the undo stack in CardServlet.
     * @return true if the card was marked unavailable.
     */
    public boolean deleteCard(int cardId) {
        String sql = "UPDATE pokemon_cards SET is_available = 0 WHERE card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[CardDAO.deleteCard] " + e.getMessage());
            return false;
        }
    }

    /**
     * Restores a soft-deleted card (undo delete).
     * Called when admin pops from the undo stack.
     */
    public boolean restoreCard(int cardId) {
        String sql = "UPDATE pokemon_cards SET is_available = 1 WHERE card_id = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[CardDAO.restoreCard] " + e.getMessage());
            return false;
        }
    }

    //  DUPLICATE CHECK
    // Returns true if a card_code already exists (any availability)
    public boolean cardCodeExists(String cardCode) {
        String sql = "SELECT COUNT(*) FROM pokemon_cards WHERE card_code = ?";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cardCode.toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.cardCodeExists] " + e.getMessage());
        }
        return false;
    }

    //  ADMIN DASHBOARD AGGREGATES
    /** Returns the sum of all card values in the catalogue 
     */
    public BigDecimal getTotalCollectionValue() {
        String sql = "SELECT COALESCE(SUM(value), 0) FROM pokemon_cards WHERE is_available = 1";
        try (Connection conn = DbConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            if (rs.next()) return rs.getBigDecimal(1);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getTotalCollectionValue] " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    // Returns the most valuable card
    public PokeModel getMostValuableCard() {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available = 1 "
                   + "ORDER BY value DESC LIMIT 1";
        try (Connection conn = DbConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getMostValuableCard] " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns the rarest card.
     * Tie-breaker: Legendary → Epic → Rare → Common.
     * Secondary tie-breaker: condition (Mint first).
     */
    public PokeModel getMostRareCard() {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available = 1 "
                   + "ORDER BY FIELD(rarity,'Legendary','Epic','Rare','Common'), "
                   + "FIELD(condition_state,'Mint','Near Mint','Good','Fair','Poor') LIMIT 1";
        try (Connection conn = DbConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getMostRareCard] " + e.getMessage());
        }
        return null;
    }

    // Returns count breakdown by rarity for the heatmap chart
    public Map<String, Integer> getRarityDistribution() {
        String sql = "SELECT rarity, COUNT(*) as cnt FROM pokemon_cards "
                   + "WHERE is_available = 1 GROUP BY rarity";
        Map<String, Integer> result = new HashMap<>();
        try (Connection conn = DbConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            while (rs.next()) {
                result.put(rs.getString("rarity"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getRarityDistribution] " + e.getMessage());
        }
        return result;
    }

    //  SEARCHING - Linear (name), Binary (value), Hash (id)
    /**
     * LINEAR SEARCH — by partial name match.
     * O(n) — iterates through all cards.
     * Best for partial/fuzzy name lookups.
     *
     * @param name partial name to search for
     * @param cards the pre-loaded list to search in (avoids extra DB round-trip)
     */
    public List<PokeModel> linearSearchByName(String name, List<PokeModel> cards) {
        List<PokeModel> results = new ArrayList<>();
        String query = name.toLowerCase().trim();
        for (PokeModel card : cards) {
            if (card.getName().toLowerCase().contains(query)) {
                results.add(card);
            }
        }
        return results;
    }

    /**
     * BINARY SEARCH — by exact value.
     * O(log n) — requires the list to be sorted by value first.
     * Call insertionSortByValue() before this.
     *
     * @param targetValue the exact value to find
     * @param sortedCards a list sorted ascending by value
     * @return list of matching cards (multiple cards can share the same value)
     */
    public List<PokeModel> binarySearchByValue(BigDecimal targetValue,
                                                  List<PokeModel> sortedCards) {
        List<PokeModel> results = new ArrayList<>();
        int lo = 0, hi = sortedCards.size() - 1;

        while (lo <= hi) {
            int mid = (lo + hi) / 2;
            int cmp = sortedCards.get(mid).getValue().compareTo(targetValue);
            if (cmp == 0) {
                // Found — expand left and right to collect all matches
                results.add(sortedCards.get(mid));
                int left = mid - 1;
                while (left >= 0 && sortedCards.get(left).getValue().compareTo(targetValue) == 0) {
                    results.add(sortedCards.get(left--));
                }
                int right = mid + 1;
                while (right < sortedCards.size() && sortedCards.get(right).getValue().compareTo(targetValue) == 0) {
                    results.add(sortedCards.get(right++));
                }
                break;
            } else if (cmp < 0) {
                lo = mid + 1;
            } else {
                hi = mid - 1;
            }
        }
        return results;
    }

    /**
     * HASH SEARCH — by card_id using a HashMap for O(1) average lookup.
     * Pre-builds a HashMap from the provided list.
     * Ideal for looking up a card by known ID instantly.
     *
     * @param cardId      the ID to look up
     * @param cards       the list to build the hash map from
     * @return the matching card, or null if not found
     */
    public PokeModel hashSearchById(int cardId, List<PokeModel> cards) {
        Map<Integer, PokeModel> hashMap = new HashMap<>();
        for (PokeModel card : cards) {
            hashMap.put(card.getCardId(), card);
        }
        return hashMap.get(cardId);
    }

    //  SORTING - Insertion (value), Selection (name), Merge (rarity)
    /**
     * INSERTION SORT — by value (ascending).
     * O(n²) worst case, O(n) for nearly sorted data.
     * Modifies the list in-place.
     *
     * @param cards the list to sort
     */
    public void insertionSortByValue(List<PokeModel> cards) {
        for (int i = 1; i < cards.size(); i++) {
            PokeModel key = cards.get(i);
            int j = i - 1;
            while (j >= 0 && cards.get(j).getValue().compareTo(key.getValue()) > 0) {
                cards.set(j + 1, cards.get(j));
                j--;
            }
            cards.set(j + 1, key);
        }
    }

    /**
     * SELECTION SORT - by name (A to Z).
     * O(n2) - finds the minimum element in each pass.
     * Modifies the list in-place.
     *
     * @param cards the list to sort
     */
    public void selectionSortByName(List<PokeModel> cards) {
        int n = cards.size();
        for (int i = 0; i < n - 1; i++) {
            int minIdx = i;
            for (int j = i + 1; j < n; j++) {
                if (cards.get(j).getName().compareToIgnoreCase(cards.get(minIdx).getName()) < 0) {
                    minIdx = j;
                }
            }
            if (minIdx != i) {
                PokeModel temp = cards.get(i);
                cards.set(i, cards.get(minIdx));
                cards.set(minIdx, temp);
            }
        }
    }

    /**
     * MERGE SORT — by rarity (Legendary → Epic → Rare → Common).
     * O(n log n) — efficient divide-and-conquer.
     * Returns a new sorted list (does not modify original).
     *
     * @param cards the list to sort
     * @return a new list sorted by rarity descending
     */
    public List<PokeModel> mergeSortByRarity(List<PokeModel> cards) {
        if (cards.size() <= 1) return new ArrayList<>(cards);

        int mid = cards.size() / 2;
        List<PokeModel> left  = mergeSortByRarity(cards.subList(0, mid));
        List<PokeModel> right = mergeSortByRarity(cards.subList(mid, cards.size()));

        return merge(left, right);
    }

    // Merge step for mergeSortByRarity
    private List<PokeModel> merge(List<PokeModel> left, List<PokeModel> right) {
        List<PokeModel> result = new ArrayList<>();
        int i = 0, j = 0;
        while (i < left.size() && j < right.size()) {
            if (rarityRank(left.get(i)) >= rarityRank(right.get(j))) {
                result.add(left.get(i++));
            } else {
                result.add(right.get(j++));
            }
        }
        while (i < left.size())  result.add(left.get(i++));
        while (j < right.size()) result.add(right.get(j++));
        return result;
    }

    /** Maps rarity string to a numeric rank for sorting (higher = rarer). */
    private int rarityRank(PokeModel card) {
        return switch (card.getRarity()) {
            case PokeModel.RARITY_LEGENDARY -> 4;
            case PokeModel.RARITY_EPIC      -> 3;
            case PokeModel.RARITY_RARE      -> 2;
            default                           -> 1;
        };
    }

    //  RANDOM CARD - for Catch and Booster systems
    /**
     * Returns a random available card (for wild Pokemon encounters)
     * SQL ORDER BY RAND() is acceptable for small catalogues
     */
    public PokeModel getRandomCard() {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available = 1 ORDER BY RAND() LIMIT 1";
        try (Connection conn = DbConfig.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getRandomCard] " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns a random card matching the given rarity
     * Used by BoosterPackService for rarity weighted pulls
     */
    public PokeModel getRandomCardByRarity(String rarity) {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available = 1 AND rarity = ? "
                   + "ORDER BY RAND() LIMIT 1";
        try (Connection conn = DbConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rarity);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getRandomCardByRarity] " + e.getMessage());
        }
        return null;
    }


    /**
     * Maps a ResultSet row to a PokeModel object.
     * All DAO query methods call this to avoid repetition.
     */
    private PokeModel mapRow(ResultSet rs) throws SQLException {
        PokeModel card = new PokeModel();
        card.setCardId        (rs.getInt        ("card_id"));
        card.setCardCode      (rs.getString     ("card_code"));
        card.setName          (rs.getString     ("name"));
        card.setType          (rs.getString     ("type"));
        card.setRarity        (rs.getString     ("rarity"));
        card.setConditionState(rs.getString     ("condition_state"));
        card.setValue         (rs.getBigDecimal ("value"));
        card.setImagePath     (rs.getString     ("image_path"));
        card.setDescription   (rs.getString     ("description"));
        card.setCatchRate     (rs.getInt        ("catch_rate"));
        card.setAvailable     (rs.getInt        ("is_available") == 1);

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) card.setCreatedAt(ts.toLocalDateTime());
        card.setCreatedBy(rs.getInt("created_by"));
        return card;
    }
}
