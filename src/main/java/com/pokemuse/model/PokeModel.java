package com.pokemuse.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PokeModel {

    // Rarity constants
    public static final String RARITY_COMMON = "Common";
    public static final String RARITY_RARE = "Rare";
    public static final String RARITY_EPIC = "Epic";
    public static final String RARITY_LEGENDARY = "Legendary";

    // Condition constants
    public static final String COND_MINT = "Mint";
    public static final String COND_NEAR_MINT = "Near Mint";
    public static final String COND_GOOD = "Good";
    public static final String COND_FAIR = "Fair";
    public static final String COND_POOR = "Poor";

    // PokeAPI sprite base URLs
    // Official high-res artwork (used on card detail pages, catch screen)
    private static final String SPRITE_OFFICIAL =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/";

    // Small default sprite (used in compact grids)
    private static final String SPRITE_DEFAULT =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/";

    // REST API endpoint for full Pokémon data
    private static final String API_BASE =
        "https://pokeapi.co/api/v2/pokemon/";

    private int cardId;
    private String cardCode;
    private String name;
    private int pokedexNumber;// National Dex number for api config
    private String type;
    private String rarity;
    private String conditionState;
    private BigDecimal value;
    private String imagePath;// kept for admin-uploaded images for new pokemon add
    private String description;
    private int catchRate;
    private boolean available;
    private LocalDateTime createdAt;
    private int createdBy;

    public PokeModel() {}

    public PokeModel(String cardCode, String name, String type,
                       String rarity, String conditionState, BigDecimal value,
                       String imagePath, String description, int catchRate) {
        this.cardCode = cardCode;
        this.name = name;
        this.type = type;
        this.rarity = rarity;
        this.conditionState = conditionState;
        this.value = value;
        this.imagePath = imagePath;
        this.description = description;
        this.catchRate = catchRate;
        this.available = true;
    }

    // PokeAPI URL helpers

    /**
     * Returns the official high-resolution artwork URL from PokeAPI.
     * Used on: catch screen, card detail page, inventory.
     * Example: .../official-artwork/6.png  (Charizard)
     *
     * Falls back to locally uploaded image if no pokedex number set.
     */
    public String getPokeApiSpriteUrl() {
        if (pokedexNumber > 0) {
            return SPRITE_OFFICIAL + pokedexNumber + ".png";
        }
        // Fallback to admin-uploaded image if available
        if (imagePath != null && !imagePath.isEmpty()) {
            return "images/" + imagePath;
        }
        return "";
    }

    /**
     * Returns the small default sprite URL (64x64)
     * Used on: card grids, inventory compact view.
     * Example: .../sprites/pokemon/6.png
     */
    public String getPokeApiThumbnailUrl() {
        if (pokedexNumber > 0) {
            return SPRITE_DEFAULT + pokedexNumber + ".png";
        }
        return getPokeApiSpriteUrl();
    }

    /**
     * Returns the PokeAPI REST endpoint for this Pokemon
     * Used by PokedexServlet to fetch stats, abilities, moves
     * Example: https://pokeapi.co/api/v2/pokemon/6
     */
    public String getPokeApiDataUrl() {
        if (pokedexNumber > 0) {
            return API_BASE + pokedexNumber;
        }
        if (name != null && !name.isEmpty()) {
            return API_BASE + name.toLowerCase();
        }
        return "";
    }

    /**
     * Returns true if this card has a known Pokedex number and can therefore use PokeAPI sprites + data
     */
    public boolean hasPokeApiData() {
        return pokedexNumber > 0;
    }

    //Existing utility methods

    // single check with boosted probability (feels right) instead of 3 different catch attempts with lower probability
    // catchRate 190 (Pikachu) -> 74.5% catch chance
    // catchRate  45 (Common)  -> 52%   catch chance 
    // catchRate   3 (Legendary) ->  4.7% catch chance
    public double getCatchProbability() {
    	if (catchRate <= 0) return 0.05; //5% minimum
    	return Math.min(catchRate / 255.0, 1.0);
    }

    public String getRarityCssClass() {
        return switch (rarity) {
            case RARITY_LEGENDARY -> "legendary";
            case RARITY_EPIC      -> "epic";
            case RARITY_RARE      -> "rare";
            default               -> "common";
        };
    }

    public String getFormattedValue() {
        return value != null ? "$" + String.format("%.2f", value) : "$0.00";
    }

    // Getters setters

    public int getCardId() { return cardId; }
    public void setCardId(int cardId) { this.cardId = cardId; }

    public String getCardCode() { return cardCode; }
    public void setCardCode(String cardCode) { this.cardCode = cardCode; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getPokedexNumber() { return pokedexNumber; }
    public void setPokedexNumber(int n) { this.pokedexNumber = n; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getRarity() { return rarity; }
    public void setRarity(String rarity) { this.rarity = rarity; }

    public String getConditionState() { return conditionState; }
    public void setConditionState(String cond) { this.conditionState = cond; }

    public BigDecimal getValue() { return value; }
    public void setValue(BigDecimal value) { this.value = value; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getDescription() { return description; }
    public void setDescription(String desc) { this.description = desc; }

    public int getCatchRate() { return catchRate; }
    public void setCatchRate(int catchRate) { this.catchRate = catchRate; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime t) { this.createdAt = t; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    @Override
    public String toString() {
        return "PokemonCard{id=" + cardId + ", code='" + cardCode
             + "', name='" + name + "', dex=" + pokedexNumber
             + ", rarity='" + rarity + "', value=" + value + "}";
    }
}
