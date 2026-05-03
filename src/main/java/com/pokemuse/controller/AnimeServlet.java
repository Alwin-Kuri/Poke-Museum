package com.pokemuse.controller;

import com.pokemuse.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import org.json.*;

/**
 * AnimeServlet.java — Controller
 * ─────────────────────────────────────────────────────
 * Integrates the YouTube Data API v3 to fetch and display
 * Pokémon anime episodes inside PokéMuseum.
 *
 * API Used   : YouTube Data API v3
 * Endpoint   : https://www.googleapis.com/youtube/v3/search
 * Auth       : API Key (no OAuth needed — public data only)
 * Quota cost : 100 units per search request (free tier = 10,000/day)
 *
 * GET  /anime             → show episode browser with default results
 * GET  /anime?q=xyz       → search episodes by keyword
 * GET  /anime?season=XY   → filter by season name
 * GET  /anime?videoId=xxx → show a specific video in the player
 *
 * How the API integration works:
 *   1. Servlet builds a URL to the YouTube search endpoint
 *   2. Sends an HTTP GET request with the API key + query params
 *   3. Parses the JSON response to extract video IDs + metadata
 *   4. Stores results as a List<Map> in request scope
 *   5. JSP renders the results using JSTL c:forEach
 *
 * Author : Alwin Maharjan | CS5003NI
 */
@WebServlet("/anime")
public class AnimeServlet extends HttpServlet {

    // ── YouTube API Configuration ──────────────────────
    // Replace YOUR_API_KEY with your actual key from Google Cloud Console
    // Steps to get a key:
    //   1. Go to https://console.cloud.google.com/
    //   2. Create a project → Enable APIs → YouTube Data API v3
    //   3. Credentials → Create API Key → copy the key
    //   4. Paste it below (or load from a properties file for security)
    private static final String API_KEY        = "AIzaSyBVX649X59_-XYWVpdo1ChZNPZbZBgkPxc";

    // The official Pokémon YouTube channel ID
    // This ensures we only get official Pokémon content
    private static final String POKEMON_CHANNEL_ID = "UCFctpiB_Hnlk3ejWfHqSm6Q";

    // Number of results per page
    private static final int    MAX_RESULTS    = 12;

    // Base YouTube API endpoint
    private static final String YT_SEARCH_URL  =
        "https://www.googleapis.com/youtube/v3/search";
    private static final String YT_VIDEO_URL   =
        "https://www.googleapis.com/youtube/v3/videos";

    // Season filter options shown in the UI
    private static final String[][] SEASONS = {
        { "all",        "All Episodes"          },
        { "Indigo+League+pokemon+anime",   "Season 1 – Indigo League"    },
        { "Orange+Islands+pokemon+anime",  "Season 2 – Orange Islands"   },
        { "Johto+pokemon+anime",           "Season 3-5 – Johto"          },
        { "Hoenn+pokemon+anime",           "Season 6-8 – Hoenn"          },
        { "Sinnoh+pokemon+anime",          "Season 10-13 – Sinnoh"       },
        { "Unova+pokemon+anime",           "Season 14-16 – Unova"        },
        { "Kalos+pokemon+anime",           "Season 17-19 – Kalos"        },
        { "Alola+pokemon+anime",           "Season 20-22 – Alola"        },
        { "Journeys+pokemon+anime",        "Season 23-25 – Journeys"     },
        { "Horizons+pokemon+anime",        "Season 26 – Horizons"        },
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Require login to access
        if (SessionUtil.requireLogin(req, res)) return;

        String searchQuery = req.getParameter("q");
        String season      = req.getParameter("season");
        String videoId     = req.getParameter("videoId");
        String videoTitle  = req.getParameter("videoTitle");

        // Build the search query string
        String query;
        if (searchQuery != null && !searchQuery.isBlank()) {
            query = "Pokemon anime " + searchQuery.trim();
        } else if (season != null && !season.equals("all") && !season.isBlank()) {
            query = season.replace("+", " ");
        } else {
            // Default: fetch popular Pokémon anime episodes
            query = "Pokemon anime episode official";
        }

        // Fetch results from YouTube API
        List<Map<String, String>> videos = new ArrayList<>();
        String apiError = null;

        try {
            videos = fetchYouTubeVideos(query);
        } catch (Exception e) {
            apiError = "Could not load videos: " + e.getMessage();
            System.err.println("[AnimeServlet] YouTube API error: " + e.getMessage());
        }

        // Pass data to JSP
        req.setAttribute("videos",       videos);
        req.setAttribute("seasons",      SEASONS);
        req.setAttribute("searchQuery",  searchQuery != null ? searchQuery : "");
        req.setAttribute("activeSeason", season      != null ? season      : "all");
        req.setAttribute("activeVideoId",    videoId);
        req.setAttribute("activeVideoTitle", videoTitle);
        req.setAttribute("apiError",     apiError);
        req.setAttribute("resultCount",  videos.size());

        req.getRequestDispatcher("/WEB-INF/pages/anime.jsp").forward(req, res);
    }

    // ══════════════════════════════════════════════════
    //  YouTube API Call — fetches video metadata
    // ══════════════════════════════════════════════════

    /**
     * Calls the YouTube Data API v3 search endpoint.
     * Returns a list of video maps, each containing:
     *   videoId, title, description, thumbnail, channelTitle, publishedAt
     *
     * API endpoint used:
     *   GET https://www.googleapis.com/youtube/v3/search
     *     ?part=snippet
     *     &q={query}
     *     &type=video
     *     &maxResults=12
     *     &key={API_KEY}
     *     &videoCategoryId=1  (Film & Animation — narrows to anime content)
     *     &order=relevance
     */
    private List<Map<String, String>> fetchYouTubeVideos(String query)
            throws IOException {

        // URL-encode the query
        String encodedQuery = URLEncoder.encode(query, StandardCharsets.UTF_8);

        // Build the full API URL
        String apiUrl = YT_SEARCH_URL
            + "?part=snippet"
            + "&q=" + encodedQuery
            + "&type=video"
            + "&maxResults=" + MAX_RESULTS
            + "&key=" + API_KEY
            + "&order=relevance"
            + "&relevanceLanguage=en"
            + "&safeSearch=strict";

        // Make the HTTP GET request
        String jsonResponse = httpGet(apiUrl);

        // Parse the JSON response
        return parseSearchResponse(jsonResponse);
    }

    /**
     * Sends an HTTP GET request and returns the response body as a String.
     * Uses java.net.HttpURLConnection (no extra libraries needed).
     */
    private String httpGet(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(8000);
        conn.setRequestProperty("Accept", "application/json");

        int status = conn.getResponseCode();

        // Read response stream
        InputStream stream = (status >= 200 && status < 300)
            ? conn.getInputStream()
            : conn.getErrorStream();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            return sb.toString();
        } finally {
            conn.disconnect();
        }
    }

    /**
     * Parses the YouTube search API JSON response.
     * Extracts: videoId, title, description, thumbnail URL,
     *           channel name, publish date.
     *
     * YouTube search response structure:
     * {
     *   "items": [
     *     {
     *       "id": { "videoId": "abc123" },
     *       "snippet": {
     *         "title": "...",
     *         "description": "...",
     *         "thumbnails": { "high": { "url": "..." } },
     *         "channelTitle": "...",
     *         "publishedAt": "2023-01-01T00:00:00Z"
     *       }
     *     }
     *   ]
     * }
     */
    private List<Map<String, String>> parseSearchResponse(String json) {
        List<Map<String, String>> videos = new ArrayList<>();

        try {
            JSONObject root  = new JSONObject(json);

            // Check for API error in response
            if (root.has("error")) {
                JSONObject error = root.getJSONObject("error");
                String message = error.optString("message", "Unknown API error");
                throw new RuntimeException("YouTube API error: " + message);
            }

            JSONArray items = root.optJSONArray("items");
            if (items == null) return videos;

            for (int i = 0; i < items.length(); i++) {
                JSONObject item    = items.getJSONObject(i);
                JSONObject idObj   = item.optJSONObject("id");
                JSONObject snippet = item.optJSONObject("snippet");

                if (idObj == null || snippet == null) continue;

                String videoId = idObj.optString("videoId", "");
                if (videoId.isEmpty()) continue; // skip non-video results

                // Extract thumbnail — prefer high quality, fall back to default
                String thumbnail = "";
                JSONObject thumbs = snippet.optJSONObject("thumbnails");
                if (thumbs != null) {
                    if (thumbs.has("high")) {
                        thumbnail = thumbs.getJSONObject("high").optString("url", "");
                    } else if (thumbs.has("medium")) {
                        thumbnail = thumbs.getJSONObject("medium").optString("url", "");
                    } else if (thumbs.has("default")) {
                        thumbnail = thumbs.getJSONObject("default").optString("url", "");
                    }
                }

                // Format publish date (2023-04-15T12:00:00Z → Apr 15, 2023)
                String rawDate    = snippet.optString("publishedAt", "");
                String pubDate    = rawDate.length() >= 10 ? rawDate.substring(0, 10) : rawDate;

                // Truncate long descriptions
                String desc = snippet.optString("description", "");
                if (desc.length() > 140) desc = desc.substring(0, 137) + "...";

                // Build the video metadata map
                Map<String, String> video = new LinkedHashMap<>();
                video.put("videoId",      videoId);
                video.put("title",        snippet.optString("title", "Unknown Title"));
                video.put("description",  desc);
                video.put("thumbnail",    thumbnail);
                video.put("channelTitle", snippet.optString("channelTitle", ""));
                video.put("publishedAt",  pubDate);
                video.put("embedUrl",     "https://www.youtube.com/embed/" + videoId
                                          + "?autoplay=1&rel=0&modestbranding=1");
                video.put("watchUrl",     "https://www.youtube.com/watch?v=" + videoId);

                videos.add(video);
            }
        } catch (JSONException e) {
            System.err.println("[AnimeServlet.parseSearchResponse] JSON parse error: " + e.getMessage());
        }

        return videos;
    }
}
