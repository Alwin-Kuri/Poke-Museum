package com.pokemuse.controller;

import com.pokemuse.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import org.json.*;

/**
 * PokedexServlet.java — Controller
 * Integrates the PokeAPI (https://pokeapi.co/api/v2)
 * to fetch full Pokémon data for the detail popup.
 *
 * API Used: PokeAPI v2-  completely free, no key
 *
 * GET /pokedex?name=charizard -> full stats + abilities + flavour text
 * GET /pokedex?id=6  -> same but by Pokédex number
 *
 * Two endpoints called per request:
 *   1. https://pokeapi.co/api/v2/pokemon/{name}
 *      -> sprites, types, stats, abilities, height, weight
 *   2. https://pokeapi.co/api/v2/pokemon-species/{name}
 *      -> flavour text (Pokédex entry), generation, habitat
 *
 * Response modes:
 *   ?ajax=true -> returns raw JSON string (for JS fetch calls)
 *   default ->forwards to pokedex.jsp with model attributes

 */
@WebServlet("/pokedex")
public class PokedexServlet extends HttpServlet {

    private static final String POKE_API_BASE    = "https://pokeapi.co/api/v2/pokemon/";
    private static final String SPECIES_API_BASE = "https://pokeapi.co/api/v2/pokemon-species/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;

        // Accept either ?name=charizard or ?id=6
        String name = req.getParameter("name");
        String id   = req.getParameter("id");

        // Need at least one identifier
        if ((name == null || name.isBlank()) && (id == null || id.isBlank())) {
            res.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Use name if provided, otherwise use the numeric id
        String identifier = (name != null && !name.isBlank())
            ? name.trim().toLowerCase()
            : id.trim();

        // Fetch from PokeAPI
        JSONObject pokeData    = null;
        JSONObject speciesData = null;
        String     errorMsg    = null;

        try {
            String pokeJson    = httpGet(POKE_API_BASE    + identifier);
            String speciesJson = httpGet(SPECIES_API_BASE + identifier);
            pokeData    = new JSONObject(pokeJson);
            speciesData = new JSONObject(speciesJson);
        } catch (Exception e) {
            errorMsg = "Could not load Pokédex data: " + e.getMessage();
            System.err.println("[PokedexServlet] " + e.getMessage());
        }

        // Parse and extract the data we need
        if (pokeData != null) {
            try {
                // Basic info
                req.setAttribute("pokeName",   capitalise(pokeData.getString("name")));
                req.setAttribute("pokeId",     pokeData.getInt("id"));
                req.setAttribute("pokeHeight", pokeData.getInt("height") / 10.0 + "m");
                req.setAttribute("pokeWeight", pokeData.getInt("weight") / 10.0 + "kg");

                // Official artwork sprite
                String sprite = pokeData
                    .getJSONObject("sprites")
                    .getJSONObject("other")
                    .getJSONObject("official-artwork")
                    .optString("front_default", "");
                req.setAttribute("pokeSpriteUrl", sprite);

                // Types  e.g. ["Fire", "Flying"]
                JSONArray typesArr = pokeData.getJSONArray("types");
                StringBuilder types = new StringBuilder();
                for (int i = 0; i < typesArr.length(); i++) {
                    if (i > 0) types.append(" / ");
                    types.append(capitalise(
                        typesArr.getJSONObject(i)
                                .getJSONObject("type")
                                .getString("name")));
                }
                req.setAttribute("pokeTypes", types.toString());

                // Base stats  (hp, attack, defense, sp-atk, sp-def, speed)
                JSONArray statsArr = pokeData.getJSONArray("stats");
                for (int i = 0; i < statsArr.length(); i++) {
                    JSONObject s    = statsArr.getJSONObject(i);
                    int  baseStat   = s.getInt("base_stat");
                    String statName = s.getJSONObject("stat").getString("name");
                    switch (statName) {
                        case "hp"              -> req.setAttribute("statHp",    baseStat);
                        case "attack"          -> req.setAttribute("statAtk",   baseStat);
                        case "defense"         -> req.setAttribute("statDef",   baseStat);
                        case "special-attack"  -> req.setAttribute("statSpAtk", baseStat);
                        case "special-defense" -> req.setAttribute("statSpDef", baseStat);
                        case "speed"           -> req.setAttribute("statSpd",   baseStat);
                    }
                }

                // Abilities (first 2)
                JSONArray abilitiesArr = pokeData.getJSONArray("abilities");
                StringBuilder abilities = new StringBuilder();
                for (int i = 0; i < Math.min(2, abilitiesArr.length()); i++) {
                    if (i > 0) abilities.append(", ");
                    abilities.append(capitalise(
                        abilitiesArr.getJSONObject(i)
                                    .getJSONObject("ability")
                                    .getString("name")
                                    .replace("-", " ")));
                }
                req.setAttribute("pokeAbilities", abilities.toString());

                // Base experience
                req.setAttribute("pokeBaseExp", pokeData.optInt("base_experience", 0));

            } catch (JSONException e) {
                System.err.println("[PokedexServlet.parsePokeData] " + e.getMessage());
            }
        }

        // Parse species data (flavour text + generation) ─
        if (speciesData != null) {
            try {
                // Find first English flavour text entry
                JSONArray flavorEntries = speciesData.getJSONArray("flavor_text_entries");
                String flavorText = "";
                for (int i = 0; i < flavorEntries.length(); i++) {
                    JSONObject entry = flavorEntries.getJSONObject(i);
                    if ("en".equals(entry.getJSONObject("language").getString("name"))) {
                        flavorText = entry.getString("flavor_text")
                                         .replace("\n", " ")
                                         .replace("\f", " ");
                        break;
                    }
                }
                req.setAttribute("pokeFlavorText", flavorText);

                // Generation name  e.g. "generation-i" → "Generation I"
                String gen = speciesData
                    .getJSONObject("generation")
                    .getString("name")
                    .replace("generation-", "Generation ")
                    .toUpperCase();
                req.setAttribute("pokeGeneration", gen);

                // Capture rate (raw number 0-255)
                req.setAttribute("pokeCaptureRate", speciesData.optInt("capture_rate", 0));

                // Habitat (may be null in API)
                if (!speciesData.isNull("habitat")) {
                    req.setAttribute("pokeHabitat",
                        capitalise(speciesData.getJSONObject("habitat").getString("name")));
                }

            } catch (JSONException e) {
                System.err.println("[PokedexServlet.parseSpeciesData] " + e.getMessage());
            }
        }

        req.setAttribute("pokeError", errorMsg);

        // AJAX mode — return JSON string
        if ("true".equals(req.getParameter("ajax"))) {
            res.setContentType("application/json;charset=UTF-8");
            JSONObject json = buildJsonResponse(req);
            res.getWriter().write(json.toString());
            return;
        }

        // Normal mode — forward to JSP
        req.getRequestDispatcher("/WEB-INF/pages/pokedex.jsp").forward(req, res);
    }

    // Build JSON object from request attributes
    private JSONObject buildJsonResponse(HttpServletRequest req) {
        JSONObject json = new JSONObject();
        String[] attrs = {
            "pokeName","pokeId","pokeHeight","pokeWeight",
            "pokeSpriteUrl","pokeTypes","pokeFlavorText",
            "pokeGeneration","pokeCaptureRate","pokeHabitat",
            "pokeAbilities","pokeBaseExp",
            "statHp","statAtk","statDef","statSpAtk","statSpDef","statSpd",
            "pokeError"
        };
        for (String attr : attrs) {
            Object val = req.getAttribute(attr);
            if (val != null) json.put(attr, val);
        }
        return json;
    }

    // HTTP GET helper 
    private String httpGet(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(8000);
        conn.setRequestProperty("Accept", "application/json");

        int status = conn.getResponseCode();
        InputStream stream = (status >= 200 && status < 300)
            ? conn.getInputStream()
            : conn.getErrorStream();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            if (status >= 400) {
                throw new IOException("HTTP " + status + " from PokeAPI: " + sb);
            }
            return sb.toString();
        } finally {
            conn.disconnect();
        }
    }

    private String capitalise(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }
}