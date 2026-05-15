package com.pokemuse.controller;

import com.pokemuse.config.DBConfig;
import com.pokemuse.dao.UserDao;
import com.pokemuse.model.Quest;
import com.pokemuse.model.UserQuestProgress;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/quests")
public class QuestServlet extends HttpServlet {

    private final UserDao UserDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);

        // Initialise missing progress records for this user
        initUserQuestProgress(userId);

        // Load all three categories
        req.setAttribute("dailyQuests",   getQuestProgress(userId, Quest.TYPE_DAILY));
        req.setAttribute("weeklyQuests",  getQuestProgress(userId, Quest.TYPE_WEEKLY));
        req.setAttribute("achievements",  getQuestProgress(userId, Quest.TYPE_PERMANENT));

        req.getRequestDispatcher("/WEB-INF/pages/quests.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);
        String action = req.getParameter("action");

        if ("claim".equals(action)) {
            int questId;
            try {
                questId = Integer.parseInt(req.getParameter("questId"));
            } catch (NumberFormatException e) {
                res.sendRedirect(req.getContextPath() + "/quests?error=invalid");
                return;
            }
            claimReward(userId, questId, req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/quests");
        }
    }

    // Load progress joined with quest definitions
    private List<UserQuestProgress> getQuestProgress(int userId, String type) {
        String sql =
            "SELECT uqp.*, q.title, q.description, q.quest_type, q.action_type, " +
            "       q.target_count, q.reward_type, q.reward_value, q.is_active " +
            "FROM user_quest_progress uqp " +
            "JOIN quests q ON uqp.quest_id = q.quest_id " +
            "WHERE uqp.user_id = ? AND q.quest_type = ? AND q.is_active = 1 " +
            "ORDER BY uqp.is_completed DESC, uqp.current_count DESC";

        List<UserQuestProgress> list = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserQuestProgress p = new UserQuestProgress();
                    p.setProgressId  (rs.getInt    ("progress_id"));
                    p.setUserId      (userId);
                    p.setQuestId     (rs.getInt    ("quest_id"));
                    p.setCurrentCount(rs.getInt    ("current_count"));
                    p.setCompleted   (rs.getBoolean("is_completed"));
                    p.setClaimed     (rs.getBoolean("is_claimed"));

                    Quest q = new Quest();
                    q.setQuestId    (rs.getInt    ("quest_id"));
                    q.setTitle      (rs.getString ("title"));
                    q.setDescription(rs.getString ("description"));
                    q.setQuestType  (rs.getString ("quest_type"));
                    q.setActionType (rs.getString ("action_type"));
                    q.setTargetCount(rs.getInt    ("target_count"));
                    q.setRewardType (rs.getString ("reward_type"));
                    q.setRewardValue(rs.getInt    ("reward_value"));
                    q.setActive     (rs.getBoolean("is_active"));
                    p.setQuest(q);

                    list.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("[QuestServlet.getQuestProgress] " + e.getMessage());
        }
        return list;
    }

    // Create progress rows for any quests not yet tracked
    private void initUserQuestProgress(int userId) {
        String sql =
            "INSERT IGNORE INTO user_quest_progress (user_id, quest_id, reset_date) " +
            "SELECT ?, quest_id, " +
            "  CASE quest_type " +
            "    WHEN 'daily'  THEN CURDATE() + INTERVAL 1 DAY " +
            "    WHEN 'weekly' THEN NEXT_DAY(CURDATE(), 'MONDAY') " +
            "    ELSE NULL " +
            "  END " +
            "FROM quests WHERE is_active = 1";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[QuestServlet.initUserQuestProgress] " + e.getMessage());
        }
    }

    // Claim reward: add coins to user, mark quest claimed ─
    private void claimReward(int userId, int questId,
                              HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        // Verify quest is completed and not yet claimed
        String check = "SELECT q.reward_type, q.reward_value, uqp.is_completed, uqp.is_claimed " +
                       "FROM user_quest_progress uqp JOIN quests q ON uqp.quest_id = q.quest_id " +
                       "WHERE uqp.user_id = ? AND uqp.quest_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(check)) {
            ps.setInt(1, userId);
            ps.setInt(2, questId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    res.sendRedirect(req.getContextPath() + "/quests?error=notFound");
                    return;
                }
                if (!rs.getBoolean("is_completed") || rs.getBoolean("is_claimed")) {
                    res.sendRedirect(req.getContextPath() + "/quests?error=notClaimable");
                    return;
                }
                String rewardType  = rs.getString("reward_type");
                int    rewardValue = rs.getInt   ("reward_value");

                // Grant reward
                if ("coins".equals(rewardType)) {
                    UserDao.updateCoins(userId, rewardValue);
                }
                // Pack rewards, badge rewards handled in Phase 4
            }
        } catch (SQLException e) {
            System.err.println("[QuestServlet.claimReward] " + e.getMessage());
            res.sendRedirect(req.getContextPath() + "/quests?error=claimFailed");
            return;
        }

        // Mark as claimed
        String mark = "UPDATE user_quest_progress " +
                      "SET is_claimed = 1, claimed_at = NOW() " +
                      "WHERE user_id = ? AND quest_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(mark)) {
            ps.setInt(1, userId);
            ps.setInt(2, questId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[QuestServlet.claimReward mark] " + e.getMessage());
        }

        res.sendRedirect(req.getContextPath() + "/quests?success=claimed");
    }
}
