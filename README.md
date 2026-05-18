# PokéMuseum

**Digital Pokemon Card Museum and Collection Management System**

---

## Overview

PokéMuseum is a full-stack dynamic web application built on Jakarta EE (Java Servlets, JSP, JSTL) with a MySQL relational database backend. The system operates as a digital Pokémon card museum where administrators manage a curated card catalogue and registered users collect, catch, trade, and battle with cards through an engagement-driven platform.

The application demonstrates:

- Strict Model-View-Controller architecture with DAO pattern
- Role-based access control enforced at session, servlet, and filter levels
- Three sorting algorithms (Insertion Sort, Selection Sort, Merge Sort)
- Three searching algorithms (Linear Search, Binary Search, Hash Search)
- Session-based LIFO undo stack for admin delete recovery
- External REST API integration (PokeAPI, Jikan API, YouTube Data API v3)
- Transactional card trading with full rollback support
- Booster pack simulator with rarity-weighted probability
- PDF export using iTextPDF 5.5.x

---

## Technology Stack

| Layer        | Technology                              |
|--------------|-----------------------------------------|
| Language     | Java 17                                 |
| Web Layer    | Jakarta Servlet 5.0, JSP 3.0, JSTL 1.2 |
| Server       | Apache Tomcat 10.1.x                    |
| Database     | MySQL 8.0                               |
| Password     | BCrypt (jBCrypt 0.4)                    |
| PDF Export   | iTextPDF 5.5.13                         |
| JSON Parsing | org.json 20231013                       |
| Frontend     | HTML5, CSS3, Vanilla JavaScript         |
| APIs         | PokeAPI v2, Jikan API v4, YouTube v3    |

---

## Prerequisites

Before running the project, ensure the following software is installed on your machine.

### Required Software

| Software        | Version   | Download                                              |
|-----------------|-----------|-------------------------------------------------------|
| JDK             | 17 or 21  | https://adoptium.net/temurin/releases/                |
| Apache Tomcat   | 10.1.x    | https://tomcat.apache.org/download-10.cgi             |
| XAMPP           | Latest    | https://www.apachefriends.org/download.html           |
| Eclipse IDE     | 2023+     | https://www.eclipse.org/downloads/packages/           |

Eclipse must be the **Enterprise Java and Web Developers** edition. The standard Java IDE edition does not include Dynamic Web Project support or Tomcat integration.

---

## Required JAR Files

Download all six JAR files and place them in `src/main/webapp/WEB-INF/lib/`.

| JAR File                        | Purpose                        | Download Link                                                                                  |
|---------------------------------|--------------------------------|------------------------------------------------------------------------------------------------|
| mysql-connector-j-8.x.x.jar    | MySQL JDBC Driver              | https://dev.mysql.com/downloads/connector/j/                                                   |
| jbcrypt-0.4.jar                 | BCrypt password hashing        | https://mvnrepository.com/artifact/org.mindrot/jbcrypt/0.4                                     |
| jstl-1.2.jar                    | JSTL tag library API           | https://mvnrepository.com/artifact/javax.servlet/jstl/1.2                                      |
| standard-1.1.2.jar              | JSTL implementation            | https://mvnrepository.com/artifact/taglibs/standard/1.1.2                                      |
| itextpdf-5.5.13.jar             | PDF generation                 | https://mvnrepository.com/artifact/com.itextpdf/itextpdf/5.5.13                               |
| json-20231013.jar               | JSON parsing for API calls     | https://mvnrepository.com/artifact/org.json/json/20231013                                      |

**Note:** Both `jstl-1.2.jar` and `standard-1.1.2.jar` are required together. JSTL tags will not resolve in JSP pages if either one is missing.

On each mvnrepository.com page, scroll to the **Files** section and click the `.jar` download link directly.

---

## API Keys and Security

### YouTube Data API v3

The anime page uses the YouTube Data API v3 for video search. This requires a free API key from Google Cloud Console.

Steps to obtain a key:

1. Go to https://console.cloud.google.com/
2. Create a new project or select an existing one
3. Navigate to APIs and Services > Library
4. Search for "YouTube Data API v3" and click Enable
5. Navigate to APIs and Services > Credentials
6. Click Create Credentials > API Key
7. Copy the generated key

Once you have the key, open the following file and replace the placeholder:

```
src/main/java/com/pokemuse/controller/AnimeServlet.java
```

Find this line:

```java
private static final String YT_API_KEY = "YOUR_YOUTUBE_API_KEY_HERE";
```

Replace `YOUR_YOUTUBE_API_KEY_HERE` with your actual API key.

**Security warning:** Never commit your real API key to a public repository. The `.gitignore` file in this project excludes common secrets files. Before pushing to GitHub, verify the placeholder is restored in `AnimeServlet.java`. The free tier provides 10,000 quota units per day, where each search request costs 100 units.

### PokeAPI and Jikan API

Both PokeAPI (https://pokeapi.co) and Jikan API (https://api.jikan.moe/v4) require no authentication. No keys or registration are needed. Both APIs are called directly from `PokedexServlet.java` and `AnimeServlet.java` using `java.net.HttpURLConnection`.

---

## Database Setup

### Step 1 — Start MySQL

Open XAMPP Control Panel and click Start next to MySQL. Confirm the green status indicator appears.

### Step 2 — Open phpMyAdmin

Navigate to http://localhost/phpmyadmin in your browser.

### Step 3 — Create the Database

Click the SQL tab and run:

```sql
CREATE DATABASE pokemuse_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Step 4 — Import the Schema

1. Select `pokemuse_db` from the left sidebar
2. Click the Import tab
3. Click Choose File and select `pokemuse_db.sql` from the project root
4. Click Go

This creates all sixteen tables and inserts the twenty seed Pokémon cards, two default user accounts, and eighteen quests.

### Step 5 — Run the Migration Script

The migration script adds the `pokedex_number` column required for PokeAPI sprite loading and corrects the catch rates for all seed cards.

1. Select `pokemuse_db` from the left sidebar
2. Click the SQL tab
3. Open `migration_api_changes.sql` from the project root and paste its contents
4. Click Go


---

## Eclipse Project Setup

### Step 1 — Create Dynamic Web Project

1. Open Eclipse
2. File > New > Dynamic Web Project
3. Set Project name to `PokeMuseum`
4. Under Target runtime, click New Runtime
5. Select Apache Tomcat v10.1 and point it to your Tomcat installation directory
6. Click Next twice
7. On the Web Module screen, set Content directory to `src/main/webapp`
8. Check Generate web.xml deployment descriptor
9. Click Finish

### Step 2 — Configure Java Source

1. Right-click the project > Build Path > Configure Build Path
2. Under Source tab, add `src/main/java` as a source folder if not already present
3. Click Apply and Close

### Step 3 — Copy Project Files

Copy the project files into the correct locations within Eclipse:

```
src/main/java/                  <-- all .java files preserving package structure
src/main/webapp/css/            <-- vortex.css
src/main/webapp/js/             <-- pokemuse.js
src/main/webapp/images/cards/   <-- any card images
src/main/webapp/index.jsp
src/main/webapp/WEB-INF/web.xml
src/main/webapp/WEB-INF/lib/    <-- all six JAR files
src/main/webapp/WEB-INF/pages/  <-- all JSP files
```

### Step 4 — Verify Deployment Assembly

1. Right-click project > Properties > Deployment Assembly
2. Confirm the following mappings exist:

| Source               | Deploy Path     |
|----------------------|-----------------|
| src/main/java        | WEB-INF/classes |
| src/main/webapp      | /               |
| WEB-INF/lib          | WEB-INF/lib     |

If `src/main/webapp` is missing, click Add > Folder > select `src/main/webapp` > set Deploy Path to `/`.

### Step 5 — Add Tomcat Server

1. Window > Show View > Servers
2. In the Servers panel, right-click > New > Server
3. Select Apache > Tomcat v10.1 Server
4. Click Next, add `PokeMuseum` to Configured projects
5. Click Finish

---

## Verify Database Connection

Open `src/main/java/com/pokemuse/config/DBConfig.java` and confirm the credentials match your local MySQL setup:

```java
private static final String URL      = "jdbc:mysql://localhost:3306/pokemuse_db"
                                     + "?useSSL=false"
                                     + "&serverTimezone=UTC"
                                     + "&allowPublicKeyRetrieval=true"
                                     + "&characterEncoding=UTF-8";
private static final String USERNAME = "root";
private static final String PASSWORD = "";   // default XAMPP MySQL password is blank
```

If you have set a MySQL root password in XAMPP, update `PASSWORD` accordingly.

---

## Running the Application

### Start the Application

1. In Eclipse, right-click the project in Project Explorer
2. Run As > Run on Server
3. Select the Tomcat 10.1 server configured earlier
4. Check Always use this server when running this project
5. Click Finish

Eclipse will compile the project, deploy it to Tomcat, and open the application in the built-in browser or your default browser.

### Access the Application

| URL                                              | Description             |
|--------------------------------------------------|-------------------------|
| http://localhost:8080/PokeMuseum/                | Root (redirects to home)|
| http://localhost:8080/PokeMuseum/login           | Login page              |
| http://localhost:8080/PokeMuseum/register        | Registration page       |
| http://localhost:8080/PokeMuseum/home            | User home (login req.)  |
| http://localhost:8080/PokeMuseum/admin/dashboard | Admin dashboard         |

### Verify Static Resources

With the server running, open the following URL directly in your browser:

```
http://localhost:8080/PokeMuseum/css/vortex.css
```

If raw CSS text is displayed, static resource serving is working correctly. If a 404 error or HTML page is returned, review the web.xml DefaultServlet mappings and the Deployment Assembly configuration.

---

## Troubleshooting

### CSS and JavaScript Not Loading

The AuthFilter intercepts all requests including static file requests. The web.xml includes explicit DefaultServlet mappings for `/css/*`, `/js/*`, and `/images/*` that must appear before the filter mapping. Verify your `web.xml` contains:

```xml
<servlet>
    <servlet-name>default</servlet-name>
    <servlet-class>org.apache.catalina.servlets.DefaultServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>/css/*</url-pattern>
</servlet-mapping>
<servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>/js/*</url-pattern>
</servlet-mapping>
<servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>/images/*</url-pattern>
</servlet-mapping>
```

After updating web.xml, do Project > Clean in Eclipse, then restart Tomcat.

### HTTP 404 on JSP Pages

All JSP files must be inside `src/main/webapp/WEB-INF/pages/`. Files inside WEB-INF cannot be accessed directly via URL — they are only reachable through Servlet forwarding. If a JSP is placed outside WEB-INF, it will be accessible directly but will bypass authentication checks.

### Quests Showing Empty

Run the following SQL in phpMyAdmin to manually initialise quest progress for all users:

```sql
INSERT IGNORE INTO user_quest_progress (user_id, quest_id, reset_date)
SELECT
    u.user_id,
    q.quest_id,
    CASE q.quest_type
        WHEN 'daily'  THEN DATE_ADD(CURDATE(), INTERVAL 1 DAY)
        WHEN 'weekly' THEN DATE_ADD(CURDATE(), INTERVAL (9 - DAYOFWEEK(CURDATE())) DAY)
        ELSE NULL
    END
FROM users u
CROSS JOIN quests q
WHERE q.is_active = 1;
```

### Pokémon Images Not Showing

Run the migration script `migration_api_changes.sql` in phpMyAdmin. This adds the `pokedex_number` column to the `pokemon_cards` table. Without this column, all cards fall back to emoji display.

### YouTube API Not Returning Results

Confirm the API key in `AnimeServlet.java` is a valid YouTube Data API v3 key, not a Maps or other Google API key. The key must have YouTube Data API v3 enabled in the Google Cloud Console. If no key is configured, the Jikan episode list tab still functions fully — only the YouTube video search tab requires a key.

### JSTL Tags Not Resolving (Showing as Plain Text)

Both `jstl-1.2.jar` and `standard-1.1.2.jar` must be present in `WEB-INF/lib/`. Check that both files exist. If JSTL tags still do not resolve, right-click the project > Properties > Java Build Path > Libraries and verify both JARs appear under Web App Libraries.

### Account Locked After Failed Logins

Log in as admin and navigate to http://localhost:8080/PokeMuseum/admin/users. Find the locked account and click the Unlock button. Alternatively, run the following SQL directly:

```sql
UPDATE users SET is_locked = 0, failed_attempts = 0 WHERE username = 'your_username';
```

---

## Project Structure

```
PokeMuseum/
├── src/main/java/com/pokemuse/
│   ├── config/
│   │   └── DBConfig.java
│   ├── controller/
│   │   ├── AdminDashboardServlet.java
│   │   ├── AdminUserServlet.java
│   │   ├── AnimeServlet.java
│   │   ├── BoosterPackServlet.java
│   │   ├── CardServlet.java
│   │   ├── CatchServlet.java
│   │   ├── DeckServlet.java
│   │   ├── ExportPdfServlet.java
│   │   ├── ForgotPasswordServlet.java
│   │   ├── HomeServlet.java
│   │   ├── InventoryServlet.java
│   │   ├── LoginServlet.java
│   │   ├── LogoutServlet.java
│   │   ├── PokedexServlet.java
│   │   ├── QuestServlet.java
│   │   ├── RegisterServlet.java
│   │   ├── TradeServlet.java
│   │   └── UndoStack.java
│   ├── dao/
│   │   ├── CardDAO.java
│   │   ├── DeckDAO.java
│   │   ├── InventoryDAO.java
│   │   ├── TradeDAO.java
│   │   └── UserDAO.java
│   ├── model/
│   │   ├── PokeModel.java
│   │   ├── Quest.java
│   │   ├── User.java
│   │   └── UserQuestProgress.java
│   └── util/
│       ├── AuthFilter.java
│       ├── PasswordUtil.java
│       ├── SessionUtil.java
│       └── ValidationUtil.java
├── src/main/webapp/
│   ├── css/
│   │   └── vortex.css
│   ├── js/
│   │   └── pokemuse.js
│   ├── images/
│   │   └── cards/
│   ├── index.jsp
│   └── WEB-INF/
│       ├── web.xml
│       ├── lib/
│       │   ├── mysql-connector-j-8.x.x.jar
│       │   ├── jbcrypt-0.4.jar
│       │   ├── jstl-1.2.jar
│       │   ├── standard-1.1.2.jar
│       │   ├── itextpdf-5.5.13.jar
│       │   └── json-20231013.jar
│       └── pages/
│           ├── admin-dashboard.jsp
│           ├── admin-users.jsp
│           ├── anime.jsp
│           ├── booster.jsp
│           ├── card-add.jsp
│           ├── card-edit.jsp
│           ├── cards.jsp
│           ├── catch.jsp
│           ├── deck.jsp
│           ├── error404.jsp
│           ├── error500.jsp
│           ├── forgot-password.jsp
│           ├── home.jsp
│           ├── inventory.jsp
│           ├── landing.jsp
│           ├── login.jsp
│           ├── pokedex.jsp
│           ├── quests.jsp
│           ├── register.jsp
│           ├── trade.jsp
│           └── fragments/
│               └── card-grid.jsp
├── pokemuse_db.sql
├── migration_api_changes.sql
├── .gitignore
└── README.md
```

---

## External APIs Used

| API           | Base URL                            | Auth Required | Purpose                                 |
|---------------|-------------------------------------|---------------|-----------------------------------------|
| PokeAPI v2    | https://pokeapi.co/api/v2           | None          | Pokemon sprites, stats, species data    |
| Jikan API v4  | https://api.jikan.moe/v4            | None          | Anime episode lists, metadata, scores   |
| YouTube v3    | https://googleapis.com/youtube/v3   | API Key       | Video search and embed for anime page   |

PokeAPI sprite CDN base URL used for card images:
```
https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{pokedex_number}.png
```

---

## Security Notes

- Passwords are hashed using BCrypt with work factor 10 via jBCrypt
- Accounts are locked after 5 consecutive failed login attempts
- All user input is sanitised through ValidationUtil.sanitise() before use
- All JSP output uses JSTL c:out for automatic HTML entity escaping to prevent XSS
- All SQL queries use PreparedStatement to prevent SQL injection
- The ORDER BY column in getCardsWithFilter() is whitelisted via switch expression to prevent injection through sort parameters
- JSP files are stored inside WEB-INF/pages/ making them inaccessible by direct URL
- The AuthFilter enforces authentication on all non-public paths at the URL level
- Never commit API keys to version control — see the Security section above

---

## Tested Environment

This application was developed and tested on the following environment:

- Windows 11
- JDK 17.0.x (Eclipse Temurin)
- Apache Tomcat 10.1.36
- MySQL 8.0.x via XAMPP 8.2.x
- Eclipse IDE 2024-03 for Enterprise Java and Web Developers
- Google Chrome 124 and Firefox 125

---

## License

This project is submitted as academic coursework for CS5003NI at Islington College / London Metropolitan University. It is not licensed for commercial use. All Pokémon names, images, and related intellectual property are owned by The Pokemon Company International and Nintendo.
