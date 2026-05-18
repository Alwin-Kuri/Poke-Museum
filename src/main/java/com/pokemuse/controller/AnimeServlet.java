package com.pokemuse.controller;

import com.pokemuse.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.util.Properties;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import org.json.*;

/**
 * Combines TWO external APIs for the anime watch page:
 *
 *   1. JIKAN API v4 (https://api.jikan.moe/v4)
 *      -> No API key required. Free. Rate limit: 3 req/sec.
 *      -> Provides: episode titles, air dates, scores,
 *                  filler flags, anime synopsis, rating
 *      -> Used for: episode list, season metadata
 *
 *   2. YOUTUBE DATA API v3
 *      -> Requires API key (free tier: 10,000 units/day)
 *      -> Used for: finding video embeds by episode title
 *      -> Falls back gracefully if quota exceeded
 *
 * GET /anime -> default: Indigo League ep list
 * GET /anime?malId=527 -> specific anime by MAL ID
 * GET /anime?malId=527&page=2 -> paginated episode list
 * GET /anime?videoId=xxx -> play a specific YouTube video
 * GET /anime?search=pikachu -> search YouTube for episodes
 *
 * Author : Alwin Maharjan | CS5003NI
 */
@WebServlet("/anime")
public class AnimeServlet extends HttpServlet {

    // YouTube API config
    // Get your free key: https://console.cloud.google.com/
    // Enable: YouTube Data API v3
    // Create credentials: API Key
    private static final String YT_SEARCH   = "https://www.googleapis.com/youtube/v3/search";
    private static final int    YT_RESULTS  = 6;

    // Jikan API config
    // No key needed — just call it directly
    private static final String JIKAN_BASE  = "https://api.jikan.moe/v4";

    // Known Pokémon anime MAL IDs
    // These are the official MyAnimeList IDs for each series
    private static final Object[][] SEASONS = {
        { 527,   "Indigo League",          "Season 1" },
        { 2116,  "Orange Islands",         "Season 2" },
        { 569,   "Johto Journeys",         "Season 3" },
        { 568,   "Johto League Champions", "Season 4" },
        { 1572,  "Advanced (Hoenn)",       "Season 6" },
        { 1341,  "Diamond & Pearl",        "Season 10"},
        { 9142,  "Black & White",          "Season 14"},
        { 23037, "XY (Kalos)",             "Season 17"},
        { 34240, "Sun & Moon (Alola)",     "Season 20"},
        { 40856, "Journeys",               "Season 23"},
        { 55701, "Horizons",               "Season 26"},
    };

    // Default anime to show on first load
    private static final int DEFAULT_MAL_ID = 527;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;

        // Read request params 
        int    malId    = parseSafe(req.getParameter("malId"), DEFAULT_MAL_ID);
        int    page     = parseSafe(req.getParameter("page"), 1);
        String videoId  = req.getParameter("videoId");
        String vidTitle = req.getParameter("videoTitle");
        String ytSearch = req.getParameter("search");
        String activeTab= req.getParameter("tab") != null
                          ? req.getParameter("tab") : "episodes";

        // Jikan: fetch anime metadata 
        Map<String, Object> animeInfo = new HashMap<>();
        List<Map<String, Object>> episodes = new ArrayList<>();
        boolean hasNextPage = false;
        String jikanError = null;

        try {
            // Anime info (title, synopsis, rating, image)
            String infoJson = httpGet(JIKAN_BASE + "/anime/" + malId);
            JSONObject infoRoot = new JSONObject(infoJson);
            JSONObject data = infoRoot.optJSONObject("data");
            if (data != null) {
                animeInfo.put("title",    data.optString("title_english",
                                           data.optString("title", "Pokémon")));
                animeInfo.put("synopsis", trimText(data.optString("synopsis", ""), 300));
                animeInfo.put("episodes", data.optInt("episodes", 0));
                animeInfo.put("score",    data.optDouble("score", 0.0));
                animeInfo.put("status",   data.optString("status", ""));
                animeInfo.put("year",     data.optInt("year", 0));

                // Main image
                JSONObject images = data.optJSONObject("images");
                if (images != null) {
                    JSONObject jpg = images.optJSONObject("jpg");
                    if (jpg != null) {
                        animeInfo.put("imageUrl", jpg.optString("large_image_url", ""));
                    }
                }

                // Trailer YouTube ID from Jikan
                JSONObject trailer = data.optJSONObject("trailer");
                if (trailer != null) {
                    animeInfo.put("trailerId", trailer.optString("youtube_id", ""));
                }
            }
        } catch (Exception e) {
            jikanError = "Could not load anime info: " + e.getMessage();
            System.err.println("[AnimeServlet.fetchAnimeInfo] " + e.getMessage());
        }

        try {
            // Episode list — paginated (25 per page from Jikan)
            String epJson = httpGet(JIKAN_BASE + "/anime/" + malId
                                    + "/episodes?page=" + page);
            JSONObject epRoot = new JSONObject(epJson);
            JSONArray  epData = epRoot.optJSONArray("data");

            // Check pagination
            JSONObject pagination = epRoot.optJSONObject("pagination");
            if (pagination != null) {
                hasNextPage = pagination.optBoolean("has_next_page", false);
            }

            if (epData != null) {
                for (int i = 0; i < epData.length(); i++) {
                    JSONObject ep = epData.getJSONObject(i);
                    Map<String, Object> epMap = new LinkedHashMap<>();
                    epMap.put("malId",  ep.optInt("mal_id", 0));
                    epMap.put("title",  ep.optString("title", "Episode " + ep.optInt("mal_id")));
                    epMap.put("titleJp",ep.optString("title_japanese", ""));
                    epMap.put("aired",  formatDate(ep.optString("aired", "")));
                    epMap.put("score",  ep.optDouble("score", 0.0));
                    epMap.put("filler", ep.optBoolean("filler", false));
                    epMap.put("recap",  ep.optBoolean("recap", false));
                    episodes.add(epMap);
                }
            }
        } catch (Exception e) {
            System.err.println("[AnimeServlet.fetchEpisodes] " + e.getMessage());
        }

        // YouTube: search for videos
        String apiKey = loadApiKey(req);
        List<Map<String, String>> ytVideos = new ArrayList<>();
        String ytError = null;
        boolean ytConfigured = !apiKey.equals("YOUR_YOUTUBE_API_KEY_HERE");

        if (ytConfigured) {
            try {
                // Build search query
                String query = (ytSearch != null && !ytSearch.isBlank())
                    ? "Pokemon anime " + ytSearch
                    : "Pokemon " + animeInfo.getOrDefault("title", "anime") + " official";

                String ytJson = httpGet(YT_SEARCH
                    + "?part=snippet"
                    + "&q=" + URLEncoder.encode(query, StandardCharsets.UTF_8)
                    + "&type=video"
                    + "&maxResults=" + YT_RESULTS
                    + "&key=" + apiKey
                    + "&order=relevance"
                    + "&safeSearch=strict");

                JSONObject ytRoot = new JSONObject(ytJson);

                // Check for API error
                if (ytRoot.has("error")) {
                    ytError = ytRoot.getJSONObject("error").optString("message", "YouTube API error");
                } else {
                    JSONArray items = ytRoot.optJSONArray("items");
                    if (items != null) {
                        for (int i = 0; i < items.length(); i++) {
                            JSONObject item    = items.getJSONObject(i);
                            JSONObject idObj   = item.optJSONObject("id");
                            JSONObject snippet = item.optJSONObject("snippet");
                            if (idObj == null || snippet == null) continue;
                            String vid = idObj.optString("videoId", "");
                            if (vid.isEmpty()) continue;

                            String thumb = "";
                            JSONObject thumbs = snippet.optJSONObject("thumbnails");
                            if (thumbs != null && thumbs.has("high")) {
                                thumb = thumbs.getJSONObject("high").optString("url", "");
                            }

                            Map<String, String> v = new LinkedHashMap<>();
                            v.put("videoId",   vid);
                            v.put("title",     snippet.optString("title", ""));
                            v.put("thumbnail", thumb);
                            v.put("channel",   snippet.optString("channelTitle", ""));
                            v.put("published", formatDate(snippet.optString("publishedAt", "")));
                            ytVideos.add(v);
                        }
                    }
                }
            } catch (Exception e) {
                ytError = "YouTube search failed: " + e.getMessage();
                System.err.println("[AnimeServlet.YouTube] " + e.getMessage());
            }
        }

        // Set all attributes for JSP
        req.setAttribute("animeInfo",     animeInfo);
        req.setAttribute("episodes",      episodes);
        req.setAttribute("ytVideos",      ytVideos);
        req.setAttribute("seasons",       SEASONS);
        req.setAttribute("activeMalId",   malId);
        req.setAttribute("activePage",    page);
        req.setAttribute("hasNextPage",   hasNextPage);
        req.setAttribute("prevPage",      Math.max(1, page - 1));
        req.setAttribute("nextPage",      page + 1);
        req.setAttribute("activeVideoId", videoId);
        req.setAttribute("activeTitle",   vidTitle);
        req.setAttribute("activeTab",     activeTab);
        req.setAttribute("ytSearch",      ytSearch != null ? ytSearch : "");
        req.setAttribute("ytConfigured",  ytConfigured);
        req.setAttribute("jikanError",    jikanError);
        req.setAttribute("ytError",       ytError);

        req.getRequestDispatcher("/WEB-INF/pages/anime.jsp").forward(req, res);
    }

    // HTTP GET helper
    private String httpGet(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(8000);
        conn.setRequestProperty("Accept", "application/json");
        conn.setRequestProperty("User-Agent", "PokéMuseum/1.0 (Educational Project)");

        int status = conn.getResponseCode();
        InputStream stream = (status >= 200 && status < 300)
            ? conn.getInputStream()
            : conn.getErrorStream();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            if (status == 429) throw new IOException("Rate limited by API. Try again in a moment.");
            if (status >= 400) throw new IOException("HTTP " + status + ": " + sb);
            return sb.toString();
        } finally {
            conn.disconnect();
        }
    }

    // Helpers

    /** Trim text to maxLen chars, append ellipsis if truncated */
    private String trimText(String text, int maxLen) {
        if (text == null || text.length() <= maxLen) return text;
        return text.substring(0, maxLen).trim() + "...";
    }

    /** Format ISO date string to readable format */
    private String formatDate(String iso) {
        if (iso == null || iso.length() < 10) return "";
        return iso.substring(0, 10); // "2024-01-15"
    }
    
    /** Load YouTube API key from environment variable or config file */
    private String loadApiKey(HttpServletRequest req) {
        Properties props = new Properties();

        try (InputStream input =
                req.getServletContext().getResourceAsStream("/WEB-INF/secrets.properties")) {

            if (input == null) {
                System.err.println("secrets.properties NOT FOUND in WEB-INF");
                return "YOUR_YOUTUBE_API_KEY_HERE";
            }

            props.load(input);
            return props.getProperty("YT_API_KEY", "YOUR_YOUTUBE_API_KEY_HERE");

        } catch (IOException e) {
            System.err.println("Error loading API key: " + e.getMessage());
            return "YOUR_YOUTUBE_API_KEY_HERE";
        }
    }

    /** Safe integer parse with default */
    private int parseSafe(String s, int defaultVal) {
        if (s == null || s.isBlank()) return defaultVal;
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return defaultVal; }
    }
}