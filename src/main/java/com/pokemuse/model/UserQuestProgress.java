package com.pokemuse.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class UserQuestProgress {

    private int progressId;
    private int userId;
    private int questId;
    private int  currentCount;
    private boolean completed;
    private boolean claimed;
    private LocalDate resetDate;
    private LocalDateTime completedAt;
    private LocalDateTime claimedAt;

    // Joined from Quest table for display convenience
    private Quest         quest;

    public UserQuestProgress() {}

    // Getters Setters 

    public int getProgressId()                    { return progressId; }
    public void setProgressId(int progressId)     { this.progressId = progressId; }

    public int getUserId()                        { return userId; }
    public void setUserId(int userId)             { this.userId = userId; }

    public int getQuestId()                       { return questId; }
    public void setQuestId(int questId)           { this.questId = questId; }

    public int getCurrentCount()                  { return currentCount; }
    public void setCurrentCount(int currentCount) { this.currentCount = currentCount; }

    public boolean isCompleted()                  { return completed; }
    public void setCompleted(boolean completed)   { this.completed = completed; }

    public boolean isClaimed()                    { return claimed; }
    public void setClaimed(boolean claimed)       { this.claimed = claimed; }

    public LocalDate getResetDate()               { return resetDate; }
    public void setResetDate(LocalDate resetDate) { this.resetDate = resetDate; }

    public LocalDateTime getCompletedAt()         { return completedAt; }
    public void setCompletedAt(LocalDateTime t)   { this.completedAt = t; }

    public LocalDateTime getClaimedAt()           { return claimedAt; }
    public void setClaimedAt(LocalDateTime t)     { this.claimedAt = t; }

    public Quest getQuest()                       { return quest; }
    public void setQuest(Quest quest)             { this.quest = quest; }

    /**
     * Progress percentage as an integer (0–100).
     * Used to render the width of the quest progress bar in JSP.
     */
    public int getProgressPercent() {
        if (quest == null || quest.getTargetCount() == 0) return 0;
        int pct = (int) ((currentCount / (double) quest.getTargetCount()) * 100);
        return Math.min(pct, 100);
    }

    /** Convenience: readable "2 / 5" progress string for display. */
    public String getProgressLabel() {
        if (quest == null) return currentCount + " / ?";
        return currentCount + " / " + quest.getTargetCount();
    }
}
