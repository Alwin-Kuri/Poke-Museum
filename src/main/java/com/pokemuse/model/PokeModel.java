package com.pokemuse.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PokeModel {
    // ── Rarity constants — avoids magic strings ────────────
    public static final String RARITY_COMMON    = "Common";
    public static final String RARITY_RARE      = "Rare";
    public static final String RARITY_EPIC      = "Epic";
    public static final String RARITY_LEGENDARY = "Legendary";

    // ── Condition constants ────────────────────────────────
    public static final String COND_MINT       = "Mint";
    public static final String COND_NEAR_MINT  = "Near Mint";
    public static final String COND_GOOD       = "Good";
    public static final String COND_FAIR       = "Fair";
    public static final String COND_POOR       = "Poor";

    // ── Fields ─────────────────────────────────────────────
    private int           cardId;
    private String        cardCode;          // e.g. "PC001"
    private String        name;
    private String        type;              // Fire, Water, Electric …
    private String        rarity;
    private String        conditionState;
    private BigDecimal    value;
    private String        imagePath;         // relative path, e.g. "cards/charizard.png"
    private String        description;
    private int           catchRate;         // 1–255
    private boolean       available;
    private LocalDateTime createdAt;
    private int           createdBy;         // user_id of the admin who added it

    // ── Constructors ───────────────────────────────────────

    /** Default constructor for DAO mapping. */
    public PokeModel() {}

    /** Constructor for admin add-card form submissions. */
    public PokeModel(String cardCode, String name, String type,
                       String rarity, String conditionState, BigDecimal value,
                       String imagePath, String description, int catchRate) {
        this.cardCode       = cardCode;
        this.name           = name;
        this.type           = type;
        this.rarity         = rarity;
        this.conditionState = conditionState;
        this.value          = value;
        this.imagePath      = imagePath;
        this.description    = description;
        this.catchRate      = catchRate;
        this.available      = true;
    }

    // ── Getters & Setters ──────────────────────────────────

    public int getCardId()                          { return cardId; }
    public void setCardId(int cardId)               { this.cardId = cardId; }

    public String getCardCode()                     { return cardCode; }
    public void setCardCode(String cardCode)        { this.cardCode = cardCode; }

    public String getName()                         { return name; }
    public void setName(String name)                { this.name = name; }

    public String getType()                         { return type; }
    public void setType(String type)                { this.type = type; }

    public String getRarity()                       { return rarity; }
    public void setRarity(String rarity)            { this.rarity = rarity; }

    public String getConditionState()               { return conditionState; }
    public void setConditionState(String cond)      { this.conditionState = cond; }

    public BigDecimal getValue()                    { return value; }
    public void setValue(BigDecimal value)          { this.value = value; }

    public String getImagePath()                    { return imagePath; }
    public void setImagePath(String imagePath)      { this.imagePath = imagePath; }

    public String getDescription()                  { return description; }
    public void setDescription(String desc)         { this.description = desc; }

    public int getCatchRate()                       { return catchRate; }
    public void setCatchRate(int catchRate)         { this.catchRate = catchRate; }

    public boolean isAvailable()                    { return available; }
    public void setAvailable(boolean available)     { this.available = available; }

    public LocalDateTime getCreatedAt()             { return createdAt; }
    public void setCreatedAt(LocalDateTime t)       { this.createdAt = t; }

    public int getCreatedBy()                       { return createdBy; }
    public void setCreatedBy(int createdBy)         { this.createdBy = createdBy; }

    // ── Utility helpers ────────────────────────────────────

    /**
     * Returns the catch probability as a decimal (0.0 – 1.0)
     * using the simplified formula: catchRate / 255.0
     * Used by CatchServlet for the shake-check calculation.
     */
    public double getCatchProbability() {
        return Math.min(catchRate / 255.0, 1.0);
    }

    /**
     * Returns a CSS class name matching the rarity for frontend styling.
     * Matches the badge classes in the HTML prototype (badge-legendary etc.)
     */
    public String getRarityCssClass() {
        return switch (rarity) {
            case RARITY_LEGENDARY -> "legendary";
            case RARITY_EPIC      -> "epic";
            case RARITY_RARE      -> "rare";
            default               -> "common";
        };
    }

    /**
     * Returns a formatted currency string, e.g. "$420.00"
     */
    public String getFormattedValue() {
        return value != null ? "$" + String.format("%.2f", value) : "$0.00";
    }

    @Override
    public String toString() {
        return "PokemonCard{id=" + cardId + ", code='" + cardCode
             + "', name='" + name + "', rarity='" + rarity + "', value=" + value + "}";
    }
}
