package com.pokemuse.dao;

import com.pokemuse.config.DBConfig;
import com.pokemuse.model.PokeModel;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class CardDao {

    //  CREATE

    public boolean addCard(PokeModel card) {
        String sql = "INSERT INTO pokemon_cards "
                   + "(card_code, name, pokedex_number, type, rarity, condition_state, "
                   + " value, image_path, description, catch_rate, created_by) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString (1, card.getCardCode().toUpperCase());
            ps.setString (2, card.getName());
            ps.setInt (3, card.getPokedexNumber());
            ps.setString (4, card.getType());
            ps.setString (5, card.getRarity());
            ps.setString (6, card.getConditionState());
            ps.setBigDecimal(7, card.getValue());
            ps.setString (8, card.getImagePath());
            ps.setString (9, card.getDescription());
            ps.setInt (10, card.getCatchRate());
            ps.setInt (11, card.getCreatedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CardDAO.addCard] " + e.getMessage());
            return false;
        }
    }

    //  READ — single

    public PokeModel getCardById(int cardId) {
        String sql = "SELECT * FROM pokemon_cards WHERE card_id = ?";
        try (Connection conn = DBConfig.getConnection();
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

    public PokeModel getCardByCode(String cardCode) {
        String sql = "SELECT * FROM pokemon_cards WHERE card_code = ?";
        try (Connection conn = DBConfig.getConnection();
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

    //  READ — all / filtered

    public List<PokeModel> getAllCards() {
        return getCardsWithFilter(null, null, null, "card_id", "ASC");
    }

    public List<PokeModel> getCardsWithFilter(String nameFilter, String typeFilter,
                                                 String rarityFilter, String orderBy,
                                                 String direction) {
        String safeOrder = switch (orderBy != null ? orderBy : "card_id") {
            case "name", "value", "rarity", "type", "condition_state" -> orderBy;
            default -> "card_id";
        };
        String safeDir = "DESC".equalsIgnoreCase(direction) ? "DESC" : "ASC";

        StringBuilder sql = new StringBuilder(
            "SELECT * FROM pokemon_cards WHERE is_available = 1");
        List<Object> params = new ArrayList<>();

        if (nameFilter   != null && !nameFilter.isBlank())   { sql.append(" AND name LIKE ?");   params.add("%" + nameFilter.trim() + "%"); }
        if (typeFilter   != null && !typeFilter.isBlank())   { sql.append(" AND type = ?");       params.add(typeFilter.trim()); }
        if (rarityFilter != null && !rarityFilter.isBlank()) { sql.append(" AND rarity = ?");     params.add(rarityFilter.trim()); }
        sql.append(" ORDER BY ").append(safeOrder).append(" ").append(safeDir);

        List<PokeModel> cards = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) cards.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CardDAO.getCardsWithFilter] " + e.getMessage());
        }
        return cards;
    }

    public int getTotalCardCount() {
        String sql = "SELECT COUNT(*) FROM pokemon_cards WHERE is_available = 1";
        try (Connection conn = DBConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getTotalCardCount] " + e.getMessage());
        }
        return 0;
    }

    //  UPDATE

    public boolean updateCard(PokeModel card) {
        String sql = "UPDATE pokemon_cards SET "
                   + "name = ?, pokedex_number = ?, type = ?, rarity = ?, "
                   + "condition_state = ?, value = ?, image_path = ?, "
                   + "description = ?, catch_rate = ? "
                   + "WHERE card_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString    (1,  card.getName());
            ps.setInt       (2,  card.getPokedexNumber());
            ps.setString    (3,  card.getType());
            ps.setString    (4,  card.getRarity());
            ps.setString    (5,  card.getConditionState());
            ps.setBigDecimal(6,  card.getValue());
            ps.setString    (7,  card.getImagePath());
            ps.setString    (8,  card.getDescription());
            ps.setInt       (9,  card.getCatchRate());
            ps.setInt       (10, card.getCardId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[CardDAO.updateCard] " + e.getMessage());
            return false;
        }
    }

    //  DELETE / RESTORE

    public boolean deleteCard(int cardId) {
        String sql = "UPDATE pokemon_cards SET is_available = 0 WHERE card_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[CardDAO.deleteCard] " + e.getMessage());
            return false;
        }
    }

    public boolean restoreCard(int cardId) {
        String sql = "UPDATE pokemon_cards SET is_available = 1 WHERE card_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[CardDAO.restoreCard] " + e.getMessage());
            return false;
        }
    }

    public boolean cardCodeExists(String cardCode) {
        String sql = "SELECT COUNT(*) FROM pokemon_cards WHERE card_code = ?";
        try (Connection conn = DBConfig.getConnection();
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

    public BigDecimal getTotalCollectionValue() {
        String sql = "SELECT COALESCE(SUM(value),0) FROM pokemon_cards WHERE is_available=1";
        try (Connection conn = DBConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getBigDecimal(1);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getTotalCollectionValue] " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    public PokeModel getMostValuableCard() {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available=1 ORDER BY value DESC LIMIT 1";
        try (Connection conn = DBConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getMostValuableCard] " + e.getMessage());
        }
        return null;
    }

    public PokeModel getMostRareCard() {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available=1 "
                   + "ORDER BY FIELD(rarity,'Legendary','Epic','Rare','Common'), "
                   + "FIELD(condition_state,'Mint','Near Mint','Good','Fair','Poor') LIMIT 1";
        try (Connection conn = DBConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getMostRareCard] " + e.getMessage());
        }
        return null;
    }

    public Map<String, Integer> getRarityDistribution() {
        String sql = "SELECT rarity, COUNT(*) AS cnt FROM pokemon_cards "
                   + "WHERE is_available=1 GROUP BY rarity";
        Map<String, Integer> result = new HashMap<>();
        try (Connection conn = DBConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) result.put(rs.getString("rarity"), rs.getInt("cnt"));
        } catch (SQLException e) {
            System.err.println("[CardDAO.getRarityDistribution] " + e.getMessage());
        }
        return result;
    }

    //  RANDOM (for catch + booster)

    public PokeModel getRandomCard() {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available=1 ORDER BY RAND() LIMIT 1";
        try (Connection conn = DBConfig.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[CardDAO.getRandomCard] " + e.getMessage());
        }
        return null;
    }

    public PokeModel getRandomCardByRarity(String rarity) {
        String sql = "SELECT * FROM pokemon_cards WHERE is_available=1 AND rarity=? ORDER BY RAND() LIMIT 1";
        try (Connection conn = DBConfig.getConnection();
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

    //  SEARCHING — Linear, Binary, Hash

    public List<PokeModel> linearSearchByName(String name, List<PokeModel> cards) {
        List<PokeModel> results = new ArrayList<>();
        String q = name.toLowerCase().trim();
        for (PokeModel card : cards) {
            if (card.getName().toLowerCase().contains(q)) results.add(card);
        }
        return results;
    }

    public List<PokeModel> binarySearchByValue(BigDecimal target, List<PokeModel> sorted) {
        List<PokeModel> results = new ArrayList<>();
        int lo = 0, hi = sorted.size() - 1;
        while (lo <= hi) {
            int mid = (lo + hi) / 2;
            int cmp = sorted.get(mid).getValue().compareTo(target);
            if (cmp == 0) {
                results.add(sorted.get(mid));
                int l = mid - 1;
                while (l >= 0 && sorted.get(l).getValue().compareTo(target) == 0) results.add(sorted.get(l--));
                int r = mid + 1;
                while (r < sorted.size() && sorted.get(r).getValue().compareTo(target) == 0) results.add(sorted.get(r++));
                break;
            } else if (cmp < 0) lo = mid + 1;
            else                  hi = mid - 1;
        }
        return results;
    }

    public PokeModel hashSearchById(int cardId, List<PokeModel> cards) {
        Map<Integer, PokeModel> map = new HashMap<>();
        for (PokeModel c : cards) map.put(c.getCardId(), c);
        return map.get(cardId);
    }

    //  SORTING — Insertion, Selection, Merge

    public void insertionSortByValue(List<PokeModel> cards) {
        for (int i = 1; i < cards.size(); i++) {
            PokeModel key = cards.get(i);
            int j = i - 1;
            while (j >= 0 && cards.get(j).getValue().compareTo(key.getValue()) > 0) {
                cards.set(j + 1, cards.get(j)); j--;
            }
            cards.set(j + 1, key);
        }
    }

    public void selectionSortByName(List<PokeModel> cards) {
        int n = cards.size();
        for (int i = 0; i < n - 1; i++) {
            int min = i;
            for (int j = i + 1; j < n; j++) {
                if (cards.get(j).getName().compareToIgnoreCase(cards.get(min).getName()) < 0) min = j;
            }
            if (min != i) { PokeModel tmp = cards.get(i); cards.set(i, cards.get(min)); cards.set(min, tmp); }
        }
    }

    public List<PokeModel> mergeSortByRarity(List<PokeModel> cards) {
        if (cards.size() <= 1) return new ArrayList<>(cards);
        int mid = cards.size() / 2;
        List<PokeModel> left  = mergeSortByRarity(cards.subList(0, mid));
        List<PokeModel> right = mergeSortByRarity(cards.subList(mid, cards.size()));
        return merge(left, right);
    }

    private List<PokeModel> merge(List<PokeModel> l, List<PokeModel> r) {
        List<PokeModel> res = new ArrayList<>();
        int i = 0, j = 0;
        while (i < l.size() && j < r.size()) {
            if (rank(l.get(i)) >= rank(r.get(j))) res.add(l.get(i++));
            else res.add(r.get(j++));
        }
        while (i < l.size()) res.add(l.get(i++));
        while (j < r.size()) res.add(r.get(j++));
        return res;
    }

    private int rank(PokeModel c) {
        return switch (c.getRarity()) {
            case PokeModel.RARITY_LEGENDARY -> 4;
            case PokeModel.RARITY_EPIC -> 3;
            case PokeModel.RARITY_RARE -> 2;
            default -> 1;
        };
    }

    //  RESULT SET MAPPER — includes pokedex_number

    private PokeModel mapRow(ResultSet rs) throws SQLException {
        PokeModel card = new PokeModel();
        card.setCardId (rs.getInt ("card_id"));
        card.setCardCode (rs.getString ("card_code"));
        card.setName (rs.getString ("name"));
        card.setPokedexNumber (rs.getInt ("pokedex_number")); // NEW
        card.setType (rs.getString ("type"));
        card.setRarity (rs.getString ("rarity"));
        card.setConditionState(rs.getString ("condition_state"));
        card.setValue (rs.getBigDecimal ("value"));
        card.setImagePath (rs.getString ("image_path"));
        card.setDescription (rs.getString ("description"));
        card.setCatchRate (rs.getInt ("catch_rate"));
        card.setAvailable (rs.getInt ("is_available") == 1);
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) card.setCreatedAt(ts.toLocalDateTime());
        card.setCreatedBy(rs.getInt("created_by"));
        return card;
    }
}
