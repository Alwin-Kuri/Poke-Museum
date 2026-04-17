<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PokéMuseum – Home</title>
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/poke.css">
  <style>/*
 * vortex.css — PokéMuseum Master Stylesheet
 * ─────────────────────────────────────────────────────
 * Pokémon Vortex-inspired design:
 *   • Black/charcoal backgrounds
 *   • Blood-red navigation with angled clip-path buttons
 *   • Pokéball card circles
 *   • Vertical sidebar tabs (rotated text)
 *   • Bottom chatbar strip
 *   • Oxanium monospace for headers
 *   • Rarity colour system (Common→Legendary)
 *
 * Author  : Alwin Maharjan | CS5003NI
 * ─────────────────────────────────────────────────────
 */

/* ═══════════════════════════════════════════════════════
   0. GOOGLE FONTS IMPORT
═══════════════════════════════════════════════════════ */
@import url('https://fonts.googleapis.com/css2?family=Oxanium:wght@400;500;600;700;800&family=Nunito:wght@400;500;600;700;800&display=swap');

/* ═══════════════════════════════════════════════════════
   1. DESIGN TOKENS
═══════════════════════════════════════════════════════ */
:root {
  /* Backgrounds */
  --bg:           #1a1a1a;
  --bg-deep:      #111111;
  --bg-panel:     #242424;
  --bg-card:      #2c2c2c;
  --bg-card2:     #323232;
  --nav:          #1e1e1e;

  /* Brand colours */
  --red:          #cc1a1a;
  --red-dark:     #8a0f0f;
  --red-light:    #e02020;
  --red-glow:     rgba(204,26,26,0.25);

  /* Accent colours */
  --gold:         #ffd700;
  --blue:         #4fc3f7;
  --teal:         #00bfa5;
  --green:        #4caf50;
  --purple:       #9c27b0;
  --orange:       #ff8c00;

  /* Text */
  --white:        #f0f0f0;
  --text:         #dddddd;
  --text-dim:     #999999;
  --text-dark:    #555555;

  /* Borders */
  --border:       #3a3a3a;
  --border-red:   rgba(204,26,26,0.5);
  --border-gold:  rgba(255,215,0,0.35);

  /* Rarity colours */
  --rar-com:      #78c87a;
  --rar-rare:     #4fc3f7;
  --rar-epic:     #b06ef5;
  --rar-leg:      #ffd700;
  --rar-com-bg:   rgba(120,200,122,0.12);
  --rar-rare-bg:  rgba(79,195,247,0.12);
  --rar-epic-bg:  rgba(176,110,245,0.12);
  --rar-leg-bg:   rgba(255,215,0,0.12);

  /* Layout */
  --topbar-h:     52px;
  --sub-bar-h:    30px;
  --chatbar-h:    36px;
  --sidebar-w:    30px;
  --radius:       4px;
  --radius-lg:    8px;
}

/* ═══════════════════════════════════════════════════════
   2. RESET & BASE
═══════════════════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { height: 100%; scroll-behavior: smooth; }

body {
  font-family: 'Nunito', sans-serif;
  background: var(--bg-deep);
  color: var(--text);
  min-height: 100vh;
  font-size: 14px;
  line-height: 1.5;
  display: flex;
  flex-direction: column;
}

a  { text-decoration: none; color: inherit; }
ul { list-style: none; }
button { cursor: pointer; font-family: 'Nunito', sans-serif; border: none; }
input, select, textarea { font-family: 'Nunito', sans-serif; }
img { max-width: 100%; }

/* Scrollbar */
::-webkit-scrollbar               { width: 6px; height: 6px; }
::-webkit-scrollbar-track         { background: var(--bg); }
::-webkit-scrollbar-thumb         { background: var(--red-dark); border-radius: 3px; }
::-webkit-scrollbar-thumb:hover   { background: var(--red); }

/* ═══════════════════════════════════════════════════════
   3. TOPBAR — Exact Vortex DNA
═══════════════════════════════════════════════════════ */
.topbar {
  background: var(--nav);
  border-bottom: 3px solid var(--red);
  display: flex;
  align-items: center;
  height: var(--topbar-h);
  padding: 0 16px;
  position: sticky;
  top: 0;
  z-index: 1000;
  flex-shrink: 0;
  gap: 0;
}

.topbar-logo {
  font-family: 'Oxanium', monospace;
  font-size: 20px;
  font-weight: 800;
  color: var(--white);
  letter-spacing: -0.5px;
  white-space: nowrap;
  margin-right: 20px;
}
.topbar-logo span { color: var(--red); }

/* Left meta strip (username, trades, messages) */
.topbar-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 11px;
  color: var(--text-dim);
  margin-right: auto;
}
.topbar-meta a,
.topbar-meta span { color: var(--text-dim); transition: color 0.2s; }
.topbar-meta a:hover { color: var(--white); }
.topbar-meta strong { color: var(--white); }
.user-online-dot {
  display: inline-block;
  width: 7px; height: 7px;
  border-radius: 50%;
  background: var(--green);
  margin-right: 5px;
}

/* Nav buttons — angled clip-path like Vortex */
.topbar-nav {
  display: flex;
  gap: 3px;
  margin-left: auto;
}
.nav-btn {
  background: var(--red);
  color: var(--white);
  padding: 7px 20px;
  font-family: 'Oxanium', monospace;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.8px;
  text-transform: uppercase;
  cursor: pointer;
  transition: background 0.15s;
  clip-path: polygon(8px 0%, 100% 0%, calc(100% - 8px) 100%, 0% 100%);
  border: none;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
}
.nav-btn:hover   { background: var(--red-light); }
.nav-btn.active  { background: var(--red-dark); box-shadow: inset 0 -2px 0 rgba(0,0,0,0.5); }

/* Right icons (Discord, logout) */
.topbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-left: 14px;
}
.topbar-icon-link {
  color: var(--text-dim);
  font-size: 11px;
  font-weight: 700;
  transition: color 0.2s;
}
.topbar-icon-link:hover { color: var(--blue); }

.streak-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: rgba(255,140,0,0.12);
  border: 1px solid rgba(255,140,0,0.3);
  border-radius: 12px;
  padding: 3px 10px;
  font-family: 'Oxanium', monospace;
  font-size: 11px;
  font-weight: 800;
  color: var(--orange);
}

.logout-btn {
  background: none;
  border: none;
  color: var(--text-dim);
  font-size: 18px;
  padding: 4px 8px;
  cursor: pointer;
  transition: color 0.2s;
  line-height: 1;
}
.logout-btn:hover { color: var(--red); }

/* ═══════════════════════════════════════════════════════
   4. SUB-TOPBAR (info strip below nav)
═══════════════════════════════════════════════════════ */
.sub-topbar {
  background: #161616;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 4px 16px;
  font-size: 11px;
  color: var(--text-dim);
  height: var(--sub-bar-h);
  flex-shrink: 0;
}
.sub-topbar .coins-display {
  margin-left: auto;
  font-family: 'Oxanium', monospace;
  font-weight: 800;
  color: var(--gold);
  font-size: 12px;
}

/* ═══════════════════════════════════════════════════════
   5. PAGE LAYOUT — sidebar + main
═══════════════════════════════════════════════════════ */
.page-layout {
  display: flex;
  flex: 1;
  overflow: hidden;
  min-height: 0;
}

/* ═══════════════════════════════════════════════════════
   6. SIDEBAR — Vortex vertical tabs
═══════════════════════════════════════════════════════ */
.sidebar {
  width: var(--sidebar-w);
  background: var(--red-dark);
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px 0;
  gap: 3px;
  flex-shrink: 0;
  border-right: 1px solid var(--red);
  z-index: 100;
}
.sidebar-tab {
  writing-mode: vertical-rl;
  text-orientation: mixed;
  transform: rotate(180deg);
  background: var(--red);
  color: var(--white);
  font-family: 'Oxanium', monospace;
  font-size: 9px;
  font-weight: 800;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  padding: 10px 5px;
  cursor: pointer;
  transition: background 0.15s;
  width: 26px;
  text-align: center;
  border: none;
  border-radius: 2px;
  text-decoration: none;
  display: block;
}
.sidebar-tab:hover  { background: var(--red-light); }
.sidebar-tab.active { background: #111; color: var(--red); }

/* ═══════════════════════════════════════════════════════
   7. MAIN CONTENT AREA
═══════════════════════════════════════════════════════ */
.main-content {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  background: var(--bg);
  display: flex;
  flex-direction: column;
}

/* ═══════════════════════════════════════════════════════
   8. SECTION HEADER — red gradient bar (Vortex signature)
═══════════════════════════════════════════════════════ */
.section-header {
  background: linear-gradient(90deg, var(--red) 0%, var(--red-dark) 100%);
  padding: 10px 18px;
  font-family: 'Oxanium', monospace;
  font-size: 14px;
  font-weight: 700;
  color: var(--white);
  letter-spacing: 0.5px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
}
.section-header .header-tabs {
  display: flex;
  gap: 2px;
}
.header-tab {
  background: rgba(0,0,0,0.3);
  border: none;
  color: rgba(255,255,255,0.65);
  padding: 4px 14px;
  font-family: 'Oxanium', monospace;
  font-size: 11px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.15s;
  text-decoration: none;
  display: inline-block;
}
.header-tab:hover  { background: rgba(0,0,0,0.5); color: var(--white); }
.header-tab.active { background: rgba(0,0,0,0.65); color: var(--white); }

/* ═══════════════════════════════════════════════════════
   9. POKÉMON CARD GRID
═══════════════════════════════════════════════════════ */
.poke-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 12px;
  padding: 16px;
}
.poke-grid-5 { grid-template-columns: repeat(5, 1fr); }
.poke-grid-6 { grid-template-columns: repeat(6, 1fr); }

.poke-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border);
  transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
  cursor: pointer;
  position: relative;
}
.poke-card:hover {
  transform: translateY(-3px);
  border-color: var(--red);
  box-shadow: 0 6px 20px rgba(0,0,0,0.5), 0 0 12px var(--red-glow);
}
.poke-card.legendary { border-color: rgba(255,215,0,0.25); }
.poke-card.legendary:hover { border-color: var(--gold); box-shadow: 0 6px 20px rgba(0,0,0,0.5), 0 0 16px rgba(255,215,0,0.3); }
.poke-card.epic       { border-color: rgba(176,110,245,0.25); }
.poke-card.rare       { border-color: rgba(79,195,247,0.25); }

/* Pokéball image area */
.card-img-area {
  padding: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-panel);
  position: relative;
}
.pokeball-bg {
  width: 88px; height: 88px;
  border-radius: 50%;
  background: radial-gradient(circle at 38% 38%, #3a3a3a, #1a1a1a);
  border: 3px solid #444;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  flex-shrink: 0;
}
.pokeball-bg::before {
  content: '';
  position: absolute;
  top: 50%; left: 0; right: 0;
  height: 2px;
  background: #444;
  transform: translateY(-50%);
}
.pokeball-bg::after {
  content: '';
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  width: 18px; height: 18px;
  border-radius: 50%;
  background: #555;
  border: 2px solid #666;
  z-index: 2;
}
/* Pokémon image inside the ball */
.card-poke-img {
  position: relative;
  z-index: 3;
  width: 64px;
  height: 64px;
  object-fit: contain;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.8));
}
.card-poke-emoji {
  font-size: 38px;
  position: relative;
  z-index: 3;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.8));
  line-height: 1;
}

/* Rarity badge */
.rar-badge {
  position: absolute;
  top: 8px; right: 8px;
  font-size: 8px;
  font-weight: 800;
  font-family: 'Oxanium', monospace;
  letter-spacing: 0.8px;
  padding: 2px 7px;
  border-radius: 10px;
  text-transform: uppercase;
}
.rar-common    { background: var(--rar-com-bg);  color: var(--rar-com);  border: 1px solid rgba(120,200,122,0.3); }
.rar-rare      { background: var(--rar-rare-bg); color: var(--rar-rare); border: 1px solid rgba(79,195,247,0.3); }
.rar-epic      { background: var(--rar-epic-bg); color: var(--rar-epic); border: 1px solid rgba(176,110,245,0.3); }
.rar-legendary { background: var(--rar-leg-bg);  color: var(--rar-leg);  border: 1px solid rgba(255,215,0,0.4); }

/* Card name + type */
.card-name-bar {
  background: var(--bg-card2);
  padding: 6px 10px 4px;
  font-weight: 800;
  font-size: 12px;
  color: var(--white);
  text-align: center;
  line-height: 1.3;
}
.card-type-tag {
  font-size: 9px;
  color: var(--text-dim);
  font-weight: 600;
  display: block;
  margin-top: 2px;
}

/* Card stats row */
.card-stats-row {
  padding: 5px 10px;
  background: var(--bg-card2);
  border-top: 1px solid var(--border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 10px;
  color: var(--text-dim);
}
.card-val {
  color: var(--gold);
  font-weight: 800;
  font-family: 'Oxanium', monospace;
  font-size: 11px;
}

/* Card action buttons */
.card-actions {
  display: flex;
  gap: 4px;
  padding: 5px 7px;
  background: var(--bg-card);
  border-top: 1px solid var(--border);
}
.card-btn {
  flex: 1;
  background: var(--red);
  border: none;
  color: var(--white);
  font-size: 9px;
  font-weight: 800;
  font-family: 'Oxanium', monospace;
  padding: 5px 4px;
  border-radius: 3px;
  cursor: pointer;
  transition: background 0.15s;
  letter-spacing: 0.3px;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.card-btn:hover         { background: var(--red-light); }
.card-btn.ghost {
  background: rgba(255,255,255,0.07);
  color: var(--text-dim);
  border: 1px solid var(--border);
}
.card-btn.ghost:hover   { background: rgba(255,255,255,0.12); color: var(--white); }
.card-btn.danger        { background: rgba(204,26,26,0.15); color: #ff6b6b; border: 1px solid rgba(204,26,26,0.3); }
.card-btn.danger:hover  { background: rgba(204,26,26,0.3); }

/* ═══════════════════════════════════════════════════════
   10. TRADE CARD GRID
═══════════════════════════════════════════════════════ */
.trade-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(175px, 1fr));
  gap: 12px;
  padding: 14px;
}
.trade-card {
  background: var(--bg-panel);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
  overflow: hidden;
  transition: transform 0.2s, border-color 0.2s;
}
.trade-card:hover { transform: translateY(-2px); border-color: var(--red); }
.trade-card-top {
  background: var(--bg-card);
  padding: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}
.trade-ball {
  width: 80px; height: 80px;
  border-radius: 50%;
  background: radial-gradient(circle at 35% 35%, #3a3a3a, #1a1a1a);
  border: 2px solid #444;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}
.trade-ball::before { content:''; position:absolute; top:50%; left:0; right:0; height:2px; background:#555; transform:translateY(-50%); }
.trade-ball::after  { content:''; position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); width:14px; height:14px; border-radius:50%; background:#555; border:2px solid #666; z-index:2; }
.trade-ball img,
.trade-ball .ball-emoji { position:relative; z-index:3; font-size:32px; }
.trade-ball img { width:50px; height:50px; object-fit:contain; }
.trade-info { padding: 10px 12px; }
.trade-name { font-weight:800; font-size:13px; color:var(--white); margin-bottom:2px; }
.trade-meta { font-size:10px; color:var(--text-dim); margin-bottom:8px; }
.listed-by  { font-size:9px; color:var(--text-dark); margin-top:8px; }
.listed-by span { color:var(--red); font-weight:700; }

/* ═══════════════════════════════════════════════════════
   11. SEARCH ROW
═══════════════════════════════════════════════════════ */
.search-row {
  display: flex;
  gap: 8px;
  padding: 10px 14px;
  background: var(--bg-panel);
  border-bottom: 1px solid var(--border);
  align-items: center;
  flex-wrap: wrap;
  flex-shrink: 0;
}
.search-input, .filter-select {
  padding: 7px 11px;
  background: var(--bg-deep);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--white);
  font-size: 12px;
  outline: none;
  transition: border-color 0.2s;
}
.search-input      { flex: 1; min-width: 160px; }
.search-input:focus, .filter-select:focus { border-color: var(--red); }
.search-input::placeholder { color: var(--text-dark); }
.filter-select option { background: var(--bg-deep); }
.search-btn {
  background: var(--red);
  border: none;
  color: var(--white);
  padding: 7px 14px;
  border-radius: var(--radius);
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s;
}
.search-btn:hover { background: var(--red-light); }

/* ═══════════════════════════════════════════════════════
   12. ADMIN TABLE
═══════════════════════════════════════════════════════ */
.data-table {
  width: 100%;
  border-collapse: collapse;
}
.data-table th {
  background: #1a1a1a;
  color: var(--text-dim);
  font-size: 10px;
  font-weight: 700;
  font-family: 'Oxanium', monospace;
  letter-spacing: 0.8px;
  text-transform: uppercase;
  padding: 9px 14px;
  text-align: left;
  border-bottom: 2px solid var(--red-dark);
  white-space: nowrap;
}
.data-table td {
  padding: 10px 14px;
  border-bottom: 1px solid var(--border);
  font-size: 12px;
  color: var(--text);
  vertical-align: middle;
}
.data-table tr:hover td { background: rgba(255,255,255,0.02); }
.td-name   { font-weight: 700; color: var(--white); }
.td-gold   { color: var(--gold); font-weight: 800; font-family: 'Oxanium', monospace; }
.td-dim    { color: var(--text-dim); font-size: 11px; }
.td-actions { display: flex; gap: 5px; }
.tbl-btn   { padding:3px 10px; border:none; border-radius:3px; font-size:10px; font-weight:700; font-family:'Oxanium',monospace; cursor:pointer; transition:all 0.15s; }
.tbl-edit  { background:rgba(79,195,247,0.15); color:var(--blue); }
.tbl-edit:hover { background:rgba(79,195,247,0.25); }
.tbl-del   { background:rgba(204,26,26,0.15); color:#ff6b6b; }
.tbl-del:hover  { background:rgba(204,26,26,0.25); }
.tbl-view  { background:rgba(76,175,80,0.15); color:var(--green); }
.tbl-view:hover { background:rgba(76,175,80,0.25); }

/* ═══════════════════════════════════════════════════════
   13. METRICS CARDS (Admin Dashboard)
═══════════════════════════════════════════════════════ */
.admin-metrics {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  padding: 14px;
}
.admin-metric {
  background: var(--bg-panel);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 14px 16px;
  border-top: 2px solid var(--red-dark);
}
.am-icon { font-size: 22px; margin-bottom: 8px; display: block; }
.am-val  { font-family: 'Oxanium', monospace; font-size: 22px; font-weight: 800; color: var(--white); display: block; }
.am-lbl  { font-size: 10px; color: var(--text-dim); text-transform: uppercase; letter-spacing: 0.6px; margin-top: 3px; }
.am-sub  { font-size: 10px; color: var(--teal); margin-top: 6px; font-weight: 700; }

/* Stat strip (home page) */
.stat-strip {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  background: #161616;
  border-bottom: 1px solid var(--border);
  flex-shrink: 0;
}
.stat-cell {
  padding: 13px 16px;
  border-right: 1px solid var(--border);
  text-align: center;
}
.stat-cell:last-child { border-right: none; }
.stat-val { font-family: 'Oxanium', monospace; font-size: 22px; font-weight: 800; color: var(--red); display: block; }
.stat-lbl { font-size: 9px; color: var(--text-dark); text-transform: uppercase; letter-spacing: 0.8px; }

/* ═══════════════════════════════════════════════════════
   14. PROGRESS BAR
═══════════════════════════════════════════════════════ */
.progress-wrap { }
.progress-meta {
  display: flex;
  justify-content: space-between;
  font-size: 10px;
  color: var(--text-dim);
  margin-bottom: 4px;
}
.progress-bar {
  height: 6px;
  background: var(--border);
  border-radius: 3px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--red), var(--red-light));
  border-radius: 3px;
  transition: width 0.6s ease;
}
.progress-fill.green { background: linear-gradient(90deg, #2e7d32, var(--green)); }
.progress-fill.blue  { background: linear-gradient(90deg, #0277bd, var(--blue)); }
.progress-fill.gold  { background: linear-gradient(90deg, #e65100, var(--gold)); }

/* ═══════════════════════════════════════════════════════
   15. QUEST ITEMS
═══════════════════════════════════════════════════════ */
.quest-list { display: flex; flex-direction: column; }
.quest-item {
  background: var(--bg-panel);
  border-bottom: 1px solid var(--border);
  padding: 13px 16px;
  display: flex;
  align-items: center;
  gap: 14px;
  transition: background 0.15s;
}
.quest-item:hover { background: var(--bg-card); }
.quest-icon {
  width: 42px; height: 42px;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
  border: 2px solid var(--border);
}
.qi-daily   { background:rgba(79,195,247,0.1);  border-color:rgba(79,195,247,0.3); }
.qi-weekly  { background:rgba(176,110,245,0.1); border-color:rgba(176,110,245,0.3); }
.qi-achieve { background:rgba(255,215,0,0.1);   border-color:rgba(255,215,0,0.3); }
.qi-done    { background:rgba(76,175,80,0.1);   border-color:rgba(76,175,80,0.3); }
.quest-info { flex: 1; min-width: 0; }
.quest-title { font-weight: 800; font-size: 13px; color: var(--white); margin-bottom: 2px; }
.quest-desc  { font-size: 11px; color: var(--text-dim); margin-bottom: 5px; }
.quest-reward {
  display: inline-flex; align-items: center; gap: 4px;
  background: rgba(255,215,0,0.08);
  border: 1px solid rgba(255,215,0,0.2);
  border-radius: 10px;
  padding: 2px 8px;
  font-size: 9px; font-weight: 700;
  color: var(--gold);
  font-family: 'Oxanium', monospace;
}
.quest-right { min-width: 140px; text-align: right; }
.quest-done-label { font-size: 11px; color: var(--green); font-weight: 800; }
.quest-claim-btn {
  background: var(--green);
  border: none;
  color: var(--white);
  font-family: 'Oxanium', monospace;
  font-size: 10px; font-weight: 800;
  padding: 5px 14px;
  border-radius: 3px;
  cursor: pointer;
  margin-top: 5px;
}
.quest-claim-btn:disabled { background: var(--text-dark); cursor: default; }

/* Type tag badges */
.tag {
  display: inline-block;
  padding: 1px 7px;
  border-radius: 2px;
  font-size: 8px; font-weight: 800;
  font-family: 'Oxanium', monospace;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  margin-left: 5px;
}
.tag-daily   { background:rgba(79,195,247,0.15);  color:var(--blue);     border:1px solid rgba(79,195,247,0.3); }
.tag-weekly  { background:rgba(176,110,245,0.15); color:var(--rar-epic); border:1px solid rgba(176,110,245,0.3); }
.tag-achieve { background:rgba(255,215,0,0.15);   color:var(--gold);     border:1px solid rgba(255,215,0,0.3); }

/* ═══════════════════════════════════════════════════════
   16. BOOSTER PACK CARDS
═══════════════════════════════════════════════════════ */
.pack-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
  padding: 14px;
}
.pack-card {
  background: var(--bg-panel);
  border: 2px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 20px 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
}
.pack-card:hover { transform: translateY(-3px); border-color: var(--red); box-shadow: 0 6px 20px rgba(0,0,0,0.5), 0 0 14px var(--red-glow); }
.pack-card.selected { border-color: var(--red); background: rgba(204,26,26,0.06); }
.pack-icon { font-size: 44px; display: block; margin-bottom: 10px; }
.pack-name { font-family: 'Oxanium', monospace; font-size: 15px; font-weight: 800; color: var(--white); margin-bottom: 5px; }
.pack-desc { font-size: 11px; color: var(--text-dim); line-height: 1.5; margin-bottom: 12px; }
.pack-odds-row { display:flex; justify-content:space-between; font-size:10px; padding:2px 0; }
.pack-odds-lbl { color: var(--text-dim); }

.revealed-area {
  display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;
  padding: 14px;
  background: var(--bg-deep);
  border-top: 1px solid var(--border);
}
.revealed-card {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  width: 115px; text-align: center;
  padding: 12px 8px;
  animation: slideUp 0.4s ease forwards;
  opacity: 0;
}
.revealed-card.legendary { border-color: rgba(255,215,0,0.5); background:rgba(255,215,0,0.04); }
.revealed-card.epic       { border-color: rgba(176,110,245,0.4); }
.revealed-card.rare       { border-color: rgba(79,195,247,0.35); }
.rev-emoji { font-size: 36px; display: block; margin-bottom: 6px; }
.rev-name  { font-size: 10px; font-weight: 800; color: var(--white); margin-bottom: 3px; }
.rev-rarity { font-size: 8px; font-weight: 800; font-family: 'Oxanium', monospace; text-transform: uppercase; letter-spacing: 0.8px; }

/* ═══════════════════════════════════════════════════════
   17. CATCH ARENA
═══════════════════════════════════════════════════════ */
.catch-arena {
  background: var(--bg-panel);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  margin: 14px;
  overflow: hidden;
}
.catch-scene {
  min-height: 280px;
  background: linear-gradient(180deg, #0d1a0d 0%, #1a2a1a 50%, #2a3a2a 100%);
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 28px 50px;
  position: relative;
  overflow: hidden;
}
.catch-scene::after {
  content: '';
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 50px;
  background: linear-gradient(transparent, rgba(0,0,0,0.4));
}
.wild-display { display:flex; flex-direction:column; align-items:center; gap:10px; }
.wild-circle {
  width: 130px; height: 130px;
  border-radius: 50%;
  background: radial-gradient(circle at 35% 35%, #2a3a2a, #0d1a0d);
  border: 3px solid #3a5a3a;
  display: flex; align-items: center; justify-content: center;
  font-size: 64px;
  position: relative;
  box-shadow: 0 4px 24px rgba(0,0,0,0.6);
  transition: all 0.3s;
}
.wild-name   { font-family:'Oxanium',monospace; font-size:18px; font-weight:800; color:var(--white); }
.wild-rarity { font-size:11px; font-weight:800; }

.throw-zone { display:flex; flex-direction:column; align-items:center; gap:12px; }
.throw-hint { font-size:11px; color:rgba(255,255,255,0.4); text-align:center; }

.pokeball-throw {
  width: 54px; height: 54px;
  border-radius: 50%;
  background: linear-gradient(180deg, var(--red) 50%, #222 50%);
  border: 3px solid #333;
  cursor: pointer;
  position: relative;
  box-shadow: 0 4px 14px rgba(0,0,0,0.6);
  transition: transform 0.2s, box-shadow 0.2s;
}
.pokeball-throw:hover { transform:scale(1.1); box-shadow:0 0 20px var(--red-glow); }
.pokeball-throw::before { content:''; position:absolute; top:50%; left:0; right:0; height:3px; background:#333; transform:translateY(-50%); }
.pokeball-throw::after  { content:''; position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); width:12px; height:12px; border-radius:50%; background:#eee; border:2px solid #333; }

.catch-controls {
  padding: 12px 16px;
  background: var(--bg-deep);
  border-top: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 12px;
}
.catch-hint { font-size:11px; color:var(--text-dim); }
.catch-result {
  font-family: 'Oxanium', monospace;
  font-size: 18px; font-weight: 800;
  text-align: center;
  padding: 8px 20px;
  border-radius: var(--radius);
  display: none;
}
.catch-success { color: var(--gold); background:rgba(255,215,0,0.1); border:1px solid rgba(255,215,0,0.3); display:block; }
.catch-fail    { color: #ff6b6b;    background:rgba(204,26,26,0.1);  border:1px solid var(--border-red); display:block; }

/* ═══════════════════════════════════════════════════════
   18. CHATBAR (Vortex bottom strip)
═══════════════════════════════════════════════════════ */
.chatbar {
  height: var(--chatbar-h);
  background: var(--nav);
  border-top: 1px solid var(--border);
  display: flex;
  align-items: center;
  padding: 0 12px;
  gap: 12px;
  flex-shrink: 0;
  margin-top: auto;
}
.chatbar-icon { font-size: 15px; }
.online-dot   { width:7px; height:7px; border-radius:50%; background:var(--green); flex-shrink:0; }
.chatbar-label { font-size: 11px; color: var(--text-dim); display:flex; align-items:center; gap:5px; }
.chatbar-right { margin-left:auto; display:flex; align-items:center; gap:14px; }
.clock-display {
  font-family: 'Oxanium', monospace;
  font-size: 12px; font-weight: 700;
  color: var(--gold);
  display: flex; align-items: center; gap: 5px;
}
.coins-display {
  font-family: 'Oxanium', monospace;
  font-size: 12px; font-weight: 700;
  color: var(--gold);
}

/* ═══════════════════════════════════════════════════════
   19. FORMS & INPUTS
═══════════════════════════════════════════════════════ */
.form-card {
  background: var(--bg-panel);
  border: 1px solid var(--border);
  border-top: 3px solid var(--red);
  border-radius: var(--radius);
  padding: 28px 32px;
  max-width: 480px;
  width: 100%;
}
.form-group { margin-bottom: 14px; }
.form-label {
  display: block;
  font-size: 10px;
  font-weight: 700;
  font-family: 'Oxanium', monospace;
  color: var(--text-dim);
  letter-spacing: 1px;
  text-transform: uppercase;
  margin-bottom: 5px;
}
.form-control {
  width: 100%;
  padding: 9px 12px;
  background: var(--bg-deep);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--white);
  font-size: 13px;
  outline: none;
  transition: border-color 0.2s;
}
.form-control:focus { border-color: var(--red); }
.form-control::placeholder { color: var(--text-dark); }
.form-control option { background: var(--bg-deep); }
.form-error {
  font-size: 11px;
  color: #ff6b6b;
  margin-top: 4px;
  display: flex;
  align-items: center;
  gap: 4px;
}
.form-hint { font-size: 10px; color: var(--text-dim); margin-top: 3px; }

/* ═══════════════════════════════════════════════════════
   20. BUTTONS
═══════════════════════════════════════════════════════ */
.btn-red {
  background: var(--red);
  color: var(--white);
  border: none;
  padding: 9px 22px;
  font-family: 'Oxanium', monospace;
  font-size: 12px; font-weight: 700;
  letter-spacing: 0.5px;
  border-radius: var(--radius);
  cursor: pointer;
  transition: background 0.15s, transform 0.1s;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  text-decoration: none;
}
.btn-red:hover  { background: var(--red-light); }
.btn-red:active { transform: scale(0.97); }

.btn-ghost {
  background: transparent;
  color: var(--text-dim);
  border: 1px solid var(--border);
  padding: 9px 22px;
  font-family: 'Oxanium', monospace;
  font-size: 12px; font-weight: 700;
  border-radius: var(--radius);
  cursor: pointer;
  transition: all 0.15s;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  text-decoration: none;
}
.btn-ghost:hover { border-color: var(--red); color: var(--white); }

.btn-sm { padding: 5px 14px; font-size: 10px; }
.btn-lg { padding: 13px 36px; font-size: 14px; }
.btn-full { width: 100%; justify-content: center; }

/* ═══════════════════════════════════════════════════════
   21. LOGIN PAGE SPECIFIC
═══════════════════════════════════════════════════════ */
.login-page {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  background: var(--bg-deep);
}
.login-card {
  background: var(--bg-panel);
  border: 1px solid var(--border);
  border-top: 3px solid var(--red);
  border-radius: var(--radius);
  width: 380px;
  overflow: hidden;
  animation: slideUp 0.4s ease;
}
.login-header {
  background: linear-gradient(135deg, var(--red-dark), #111);
  padding: 26px 28px 18px;
  text-align: center;
}
.login-pokeball {
  width: 58px; height: 58px;
  border-radius: 50%;
  background: linear-gradient(180deg, var(--red) 50%, #222 50%);
  border: 3px solid #333;
  margin: 0 auto 12px;
  position: relative;
}
.login-pokeball::before { content:''; position:absolute; top:50%; left:0; right:0; height:3px; background:#333; transform:translateY(-50%); }
.login-pokeball::after  { content:''; position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); width:14px; height:14px; border-radius:50%; background:#eee; border:3px solid #333; }
.login-title { font-family:'Oxanium',monospace; font-size:20px; font-weight:800; color:var(--white); }
.login-sub   { font-size:11px; color:rgba(255,255,255,0.45); margin-top:3px; }
.login-body  { padding: 22px 26px 26px; }
.role-tabs   { display:grid; grid-template-columns:1fr 1fr; background:var(--bg-deep); border-radius:var(--radius); padding:3px; margin-bottom:18px; gap:3px; }
.role-tab    { padding:8px; border:none; border-radius:2px; font-family:'Oxanium',monospace; font-size:11px; font-weight:700; cursor:pointer; background:transparent; color:var(--text-dim); transition:all 0.2s; letter-spacing:0.5px; }
.role-tab.active { background:var(--red); color:var(--white); }
.login-footer { text-align:center; margin-top:14px; font-size:11px; color:var(--text-dark); }
.login-footer a { color:var(--red); font-weight:700; }
.login-divider { height:1px; background:var(--border); margin:16px 0; }
.alert-error {
  background: rgba(204,26,26,0.12);
  border: 1px solid var(--border-red);
  border-radius: var(--radius);
  padding: 9px 12px;
  font-size: 12px;
  color: #ff6b6b;
  margin-bottom: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.alert-success {
  background: rgba(76,175,80,0.12);
  border: 1px solid rgba(76,175,80,0.3);
  border-radius: var(--radius);
  padding: 9px 12px;
  font-size: 12px;
  color: var(--green);
  margin-bottom: 14px;
}

/* ═══════════════════════════════════════════════════════
   22. HERO (landing page)
═══════════════════════════════════════════════════════ */
.hero {
  position: relative;
  min-height: 380px;
  background: var(--bg-panel);
  border-bottom: 3px solid var(--red);
  display: flex;
  align-items: center;
  overflow: hidden;
  flex-shrink: 0;
}
.hero-grid-bg {
  position: absolute; inset: 0;
  background:
    repeating-linear-gradient(0deg, rgba(255,255,255,0.015) 0px, rgba(255,255,255,0.015) 1px, transparent 1px, transparent 32px),
    repeating-linear-gradient(90deg, rgba(255,255,255,0.015) 0px, rgba(255,255,255,0.015) 1px, transparent 1px, transparent 32px);
  pointer-events: none;
}
.hero-vignette {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse at 28% 50%, transparent 28%, rgba(17,17,17,0.82) 100%);
}
.hero-content {
  position: relative; z-index: 2;
  padding: 56px 56px;
  max-width: 580px;
}
.hero-eyebrow {
  display: inline-flex; align-items: center; gap: 8px;
  background: rgba(204,26,26,0.13);
  border: 1px solid var(--border-red);
  border-radius: 2px;
  padding: 3px 12px;
  font-family: 'Oxanium', monospace;
  font-size: 9px; font-weight: 700;
  color: var(--red);
  letter-spacing: 2px; text-transform: uppercase;
  margin-bottom: 18px;
}
.hero-title {
  font-family: 'Oxanium', monospace;
  font-size: 54px; font-weight: 800;
  line-height: 1.05;
  color: var(--white);
  text-shadow: 0 2px 20px rgba(0,0,0,0.8);
  margin-bottom: 6px;
}
.hero-title .red { color: var(--red); }
.hero-sub  { font-size: 14px; color: var(--text-dim); margin-bottom: 26px; line-height: 1.6; max-width: 420px; }
.hero-btns { display: flex; gap: 10px; }
.hero-pokemons {
  position: absolute;
  right: 36px; top: 50%;
  transform: translateY(-50%);
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  pointer-events: none;
}
.hero-poke {
  width: 76px; height: 76px;
  border-radius: 50%;
  background: var(--bg-card);
  border: 2px solid var(--border);
  display: flex; align-items: center; justify-content: center;
  font-size: 32px;
  animation: fadeIn 0.5s ease forwards;
  opacity: 0;
  transition: border-color 0.3s;
}
.hero-poke:nth-child(1) { animation-delay: 0.1s; }
.hero-poke:nth-child(2) { animation-delay: 0.2s; }
.hero-poke:nth-child(3) { animation-delay: 0.3s; }
.hero-poke:nth-child(4) { animation-delay: 0.4s; }
.hero-poke:nth-child(5) { animation-delay: 0.5s; }
.hero-poke:nth-child(6) { animation-delay: 0.6s; }
.hero-poke:nth-child(7) { animation-delay: 0.7s; }
.hero-poke:nth-child(8) { animation-delay: 0.8s; }
.hero-poke:nth-child(9) { animation-delay: 0.9s; }

/* ═══════════════════════════════════════════════════════
   23. TOAST NOTIFICATIONS
═══════════════════════════════════════════════════════ */
.toast {
  position: fixed;
  bottom: 55px; right: 18px;
  background: var(--bg-panel);
  border: 1px solid var(--green);
  border-left: 4px solid var(--green);
  border-radius: var(--radius);
  padding: 11px 18px;
  font-size: 13px; font-weight: 700;
  color: var(--white);
  z-index: 9999;
  animation: slideUp 0.3s ease, fadeOut 0.4s ease 2.6s forwards;
  display: flex; align-items: center; gap: 10px;
  max-width: 320px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.5);
}
.toast.error { border-color: var(--red); border-left-color: var(--red); }

/* ═══════════════════════════════════════════════════════
   24. CONFETTI
═══════════════════════════════════════════════════════ */
.confetti-piece {
  position: fixed;
  width: 8px; height: 8px;
  border-radius: 2px;
  pointer-events: none;
  z-index: 9999;
  animation: confettiFall 1.6s ease forwards;
}

/* ═══════════════════════════════════════════════════════
   25. UTILITY CLASSES
═══════════════════════════════════════════════════════ */
.mt-8  { margin-top: 8px; }
.mt-14 { margin-top: 14px; }
.mb-8  { margin-bottom: 8px; }
.mb-14 { margin-bottom: 14px; }
.p-14  { padding: 14px; }
.p-16  { padding: 16px; }
.flex-row  { display: flex; align-items: center; gap: 10px; }
.flex-end  { margin-left: auto; }
.text-center { text-align: center; }
.text-right  { text-align: right; }
.text-gold   { color: var(--gold); font-weight: 800; font-family: 'Oxanium', monospace; }
.text-red    { color: var(--red); }
.text-green  { color: var(--green); }
.text-dim    { color: var(--text-dim); font-size: 11px; }
.text-bold   { font-weight: 800; }
.mono        { font-family: 'Oxanium', monospace; }
.divider     { height: 1px; background: var(--border); }
.table-wrap  { overflow-x: auto; }
.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-dark);
}
.empty-state .empty-icon { font-size: 40px; margin-bottom: 12px; display: block; }
.empty-state p { font-size: 13px; }

/* ═══════════════════════════════════════════════════════
   26. KEYFRAME ANIMATIONS
═══════════════════════════════════════════════════════ */
@keyframes slideUp {
  from { transform: translateY(24px); opacity: 0; }
  to   { transform: translateY(0);    opacity: 1; }
}
@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.85); }
  to   { opacity: 1; transform: scale(1); }
}
@keyframes fadeOut {
  from { opacity: 1; }
  to   { opacity: 0; pointer-events: none; }
}
@keyframes pulse-red {
  0%,100% { box-shadow: 0 0 0 rgba(204,26,26,0); }
  50%      { box-shadow: 0 0 18px var(--red-glow); }
}
@keyframes throwBall {
  0%   { transform: translate(0,0) rotate(0deg); }
  40%  { transform: translate(170px,-110px) rotate(360deg); }
  70%  { transform: translate(300px,-18px) rotate(500deg); }
  100% { transform: translate(300px,38px) rotate(540deg); }
}
@keyframes shake {
  0%,100% { transform: rotate(0deg); }
  15%     { transform: rotate(-18deg); }
  30%     { transform: rotate(18deg); }
  50%     { transform: rotate(-13deg); }
  65%     { transform: rotate(13deg); }
  80%     { transform: rotate(-7deg); }
  92%     { transform: rotate(7deg); }
}
@keyframes caught {
  0%   { transform: scale(1); box-shadow: 0 0 0 rgba(255,215,0,0); }
  50%  { transform: scale(1.18); box-shadow: 0 0 40px rgba(255,215,0,0.7); }
  100% { transform: scale(1); box-shadow: 0 0 16px rgba(255,215,0,0.3); }
}
@keyframes flee {
  0%   { transform: translate(0,0) scale(1); opacity:1; }
  100% { transform: translate(140px,-70px) scale(0.2); opacity:0; }
}
@keyframes confettiFall {
  0%   { transform: translateY(-20px) rotate(0deg); opacity:1; }
  100% { transform: translateY(220px) rotate(720deg); opacity:0; }
}

/* ═══════════════════════════════════════════════════════
   27. RESPONSIVE — basic mobile adjustments
═══════════════════════════════════════════════════════ */
@media (max-width: 900px) {
  .hero-pokemons { display: none; }
  .hero-title    { font-size: 38px; }
  .admin-metrics { grid-template-columns: repeat(2, 1fr); }
  .poke-grid-6   { grid-template-columns: repeat(3, 1fr); }
  .pack-grid     { grid-template-columns: 1fr; }
  .topbar-meta   { display: none; }
}
@media (max-width: 600px) {
  .hero-content  { padding: 30px 20px; }
  .hero-title    { font-size: 28px; }
  .admin-metrics { grid-template-columns: 1fr; }
  .poke-grid     { grid-template-columns: repeat(2, 1fr); }
  .stat-strip    { grid-template-columns: repeat(2, 1fr); }
  .topbar-nav .nav-btn { padding: 7px 12px; font-size: 10px; }
}
  </style>
  <%-- data-ctx used by pokemuse.js for AJAX URLs --%>
  <body data-ctx="${pageContext.request.contextPath}">
</head>
<body data-ctx="${pageContext.request.contextPath}">

  <div class="topbar">
    <a href="${pageContext.request.contextPath}/home" class="topbar-logo">
      Pokémon <span>Museum</span>
    </a>

    <%-- Meta strip — user info --%>
    <div class="topbar-meta">
      <span><span class="user-online-dot"></span>
        <c:out value="${sessionScope.loggedInUser.username}"/>
      </span>
      <span>🔄 Trades <strong>0</strong></span>
      <span>📨 Messages <strong>0</strong></span>
    </div>

    <%-- Nav buttons --%>
    <nav class="topbar-nav">
      <a href="${pageContext.request.contextPath}/home"
         class="nav-btn active">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/quests"
         class="nav-btn">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"
         class="nav-btn">CATCH</a>
      <a href="${pageContext.request.contextPath}/trade"
         class="nav-btn">TRADE</a>
      <a href="${pageContext.request.contextPath}/booster"
         class="nav-btn">PACKS</a>
    </nav>

    <div class="topbar-right">
      <%-- Login streak badge --%>
      <c:if test="${sessionScope.loggedInUser.loginStreak > 0}">
        <span class="streak-badge">
          🔥 <c:out value="${sessionScope.loggedInUser.loginStreak}"/>
        </span>
      </c:if>
      <a href="${pageContext.request.contextPath}/logout"
         class="logout-btn" title="Logout">⇥</a>
    </div>
  </div>

  <%-- Sub-bar: coins --%>
  <div class="sub-topbar">
    <span>Welcome back, <strong><c:out value="${sessionScope.loggedInUser.username}"/></strong>!</span>
    <span class="coins-display">
      🪙 <c:out value="${sessionScope.loggedInUser.coins}"/> PokéCoins
    </span>
  </div>


  <div class="page-layout">

    <%-- Sidebar tabs --%>
    <nav class="sidebar">
      <a href="${pageContext.request.contextPath}/home"
         class="sidebar-tab active" data-path="/home">EXPLORE</a>
      <a href="${pageContext.request.contextPath}/inventory"
         class="sidebar-tab" data-path="/inventory">MY CARDS</a>
      <a href="${pageContext.request.contextPath}/quests"
         class="sidebar-tab" data-path="/quests">QUESTS</a>
      <a href="${pageContext.request.contextPath}/catch"
         class="sidebar-tab" data-path="/catch">CATCH</a>
    </nav>

    <%-- Main content --%>
    <main class="main-content">

      <%-- Toast messages from redirects--%>
      <c:if test="${not empty param.success}">
        <script>
          document.addEventListener('DOMContentLoaded', () => {
            showToast('<c:out value="${param.success}"/>');
          });
        </script>
      </c:if>

      <%-- Stats strip--%>
      <div class="stat-strip">
        <div class="stat-cell">
          <span class="stat-val"><c:out value="${totalCards}"/></span>
          <div class="stat-lbl">Cards in Museum</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val">
            $<fmt:formatNumber value="${totalValue}" maxFractionDigits="0"/>
          </span>
          <div class="stat-lbl">Total Value</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val">
            <c:out value="${sessionScope.loggedInUser.loginStreak}"/>
          </span>
          <div class="stat-lbl">Day Streak</div>
        </div>
        <div class="stat-cell">
          <span class="stat-val">
            <c:out value="${sessionScope.loggedInUser.coins}"/>
          </span>
          <div class="stat-lbl">PokéCoins</div>
        </div>
      </div>

      <%-- Featured Cards section--%>
      <div class="section-header">
        ✦ Featured Cards
        <a href="${pageContext.request.contextPath}/cards"
           style="font-size:11px;opacity:0.75;">View All →</a>
      </div>

      <%-- Search + filter row --%>
      <div class="search-row">
        <input type="text" id="live-search" class="search-input"
               placeholder="Search Pokémon by name..."
               oninput="liveSearch(this)">
        <select id="filter-rarity" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value="">All Rarities</option>
          <option value="Common">Common</option>
          <option value="Rare">Rare</option>
          <option value="Epic">Epic</option>
          <option value="Legendary">Legendary</option>
        </select>
        <select id="filter-type" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value="">All Types</option>
          <option value="Fire">🔥 Fire</option>
          <option value="Water">🌊 Water</option>
          <option value="Electric">⚡ Electric</option>
          <option value="Psychic">🔮 Psychic</option>
          <option value="Grass">🌿 Grass</option>
          <option value="Dragon">🐉 Dragon</option>
          <option value="Ghost">👻 Ghost</option>
          <option value="Normal">⭕ Normal</option>
          <option value="Fighting">🥊 Fighting</option>
          <option value="Fairy">🌸 Fairy</option>
        </select>
        <select id="sort-by" class="filter-select"
                onchange="liveSearch(document.getElementById('live-search'))">
          <option value="">Sort: Value ↓</option>
          <option value="value_asc">Sort: Value ↑</option>
          <option value="name">Sort: Name A–Z</option>
          <option value="rarity">Sort: Rarity</option>
        </select>
        <button class="search-btn"
                onclick="liveSearch(document.getElementById('live-search'))">🔍</button>
      </div>

      <%-- Card grid — replaced by AJAX live search --%>
      <div id="card-grid" class="poke-grid">

        <%-- c:forEach over featuredCards set by HomeServlet --%>
        <c:choose>
          <c:when test="${empty featuredCards}">
            <div class="empty-state" style="grid-column:1/-1;">
              <span class="empty-icon">📭</span>
              <p>No cards in the museum yet. Admin needs to add some!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="card" items="${featuredCards}">
              <div class="poke-card ${card.rarityCssClass}">

                <%-- Pokéball image area --%>
                <div class="card-img-area">
                  <div class="pokeball-bg">
                    <c:choose>
                      <c:when test="${not empty card.imagePath}">
                        <img class="card-poke-img"
                             src="${pageContext.request.contextPath}/images/<c:out value='${card.imagePath}'/>"
                             alt="<c:out value='${card.name}'/>">
                      </c:when>
                      <c:otherwise>
                        <%-- Fallback emoji by type --%>
                        <span class="card-poke-emoji">
                          <c:choose>
                            <c:when test="${card.type eq 'Fire'}">🔥</c:when>
                            <c:when test="${card.type eq 'Water'}">🌊</c:when>
                            <c:when test="${card.type eq 'Electric'}">⚡</c:when>
                            <c:when test="${card.type eq 'Psychic'}">🔮</c:when>
                            <c:when test="${card.type eq 'Grass'}">🌿</c:when>
                            <c:when test="${card.type eq 'Dragon'}">🐉</c:when>
                            <c:when test="${card.type eq 'Ghost'}">👻</c:when>
                            <c:when test="${card.type eq 'Fairy'}">🌸</c:when>
                            <c:when test="${card.type eq 'Fighting'}">🥊</c:when>
                            <c:otherwise>🃏</c:otherwise>
                          </c:choose>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <%-- Rarity badge --%>
                  <span class="rar-badge rar-${card.rarityCssClass}">
                    <c:out value="${card.rarity}"/>
                  </span>
                </div>

                <%-- Card name + type --%>
                <div class="card-name-bar">
                  <c:out value="${card.name}"/>
                  <span class="card-type-tag">
                    <c:out value="${card.type}"/> · <c:out value="${card.conditionState}"/>
                  </span>
                </div>

                <%-- Stats row --%>
                <div class="card-stats-row">
                  <span><c:out value="${card.conditionState}"/></span>
                  <span class="card-val">
                    $<fmt:formatNumber value="${card.value}" minFractionDigits="2" maxFractionDigits="2"/>
                  </span>
                </div>

                <%-- Action button: Add to Inventory --%>
                <div class="card-actions">
                  <form method="post"
                        action="${pageContext.request.contextPath}/inventory"
                        style="flex:1;">
                    <input type="hidden" name="action"  value="add">
                    <input type="hidden" name="cardId"  value="${card.cardId}">
                    <input type="hidden" name="via"     value="browse">
                    <button type="submit" class="card-btn">+ Inventory</button>
                  </form>
                </div>

              </div><%-- /poke-card --%>
            </c:forEach>
          </c:otherwise>
        </c:choose>

      </div><%-- /card-grid --%>

    </main>
  </div><%-- /page-layout --%>

  <%-- Chatbar --%>
  <div class="chatbar">
    <span class="chatbar-icon">🏛️</span>
    <span>🇳🇵</span>
    <span class="chatbar-label">
      <span class="online-dot"></span> Chat (0)
    </span>
    <div class="chatbar-right">
      <span class="coins-display">
        🪙 <c:out value="${sessionScope.loggedInUser.coins}"/>
      </span>
      <span class="clock-display">🕐 <span class="js-clock">--:--</span></span>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/js/pokemuse.js"></script>
</body>
</html>
