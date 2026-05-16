package com.pokemuse.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Quest {

    public static final String TYPE_DAILY  = "daily";
    public static final String TYPE_WEEKLY  = "weekly";
    public static final String TYPE_PERMANENT = "permanent";

    private int questId;
    private String title;
    private String description;
    private String questType;
    private String actionType;
    private int targetCount;
    private String rewardType;
    private int rewardValue;
    private int rewardCardId;
    private boolean active;

    //Default constructor
    public Quest() {}

    //Getters Setters

    public int getQuestId()                  { return questId; }
    public void setQuestId(int questId)      { this.questId = questId; }

    public String getTitle()                 { return title; }
    public void setTitle(String title)       { this.title = title; }

    public String getDescription()           { return description; }
    public void setDescription(String desc)  { this.description = desc; }

    public String getQuestType()             { return questType; }
    public void setQuestType(String type)    { this.questType = type; }

    public String getActionType()            { return actionType; }
    public void setActionType(String action) { this.actionType = action; }

    public int getTargetCount()              { return targetCount; }
    public void setTargetCount(int count)    { this.targetCount = count; }

    public String getRewardType()            { return rewardType; }
    public void setRewardType(String type)   { this.rewardType = type; }

    public int getRewardValue()              { return rewardValue; }
    public void setRewardValue(int val)      { this.rewardValue = val; }

    public int getRewardCardId()             { return rewardCardId; }
    public void setRewardCardId(int id)      { this.rewardCardId = id; }

    public boolean isActive()               { return active; }
    public void setActive(boolean active)   { this.active = active; }

    /** Returns a Pokémon-themed emoji for the quest icon based on type. */
    public String getQuestEmoji() {
        return switch (actionType) {
            case "catch"          -> "🎯";
            case "login"          -> "📅";
            case "open_pack"      -> "📦";
            case "add_inventory"  -> "🃏";
            case "trade"          -> "🔄";
            case "build_deck"     -> "🗂️";
            case "streak"         -> "🔥";
            case "catch_legendary"-> "⭐";
            case "daily_complete" -> "✅";
            default               -> "🎮";
        };
    }
}
