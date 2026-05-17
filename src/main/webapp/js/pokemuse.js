/**
 * Handles all client-side interactivity:
 *  Live clock update
 *  Toast notifications
 *  Confetti animation on catch success
 *  Pokéball throw + shake animation
 *  Booster pack reveal with staggered animations
 *  Live AJAX card search
 *  Quest progress tab switching
 */

/*  
   1. CLOCK — updates every minute
 */
function updateClock() {
  const now = new Date();
  const hh  = String(now.getHours()).padStart(2, '0');
  const mm  = String(now.getMinutes()).padStart(2, '0');
  const timeStr = hh + ':' + mm;
  document.querySelectorAll('.js-clock').forEach(el => {
    el.textContent = timeStr;
  });
}
updateClock();
setInterval(updateClock, 30000);

/*  
   2. TOAST NOTIFICATIONS
 */
function showToast(message, isError = false) {
  // Remove any existing toast first
  const old = document.querySelector('.toast');
  if (old) old.remove();

  const toast = document.createElement('div');
  toast.className = 'toast' + (isError ? ' error' : '');
  toast.innerHTML = (isError ? '⚠️' : '✅') + ' ' + message;
  document.body.appendChild(toast);

  // Auto-remove after 3 seconds
  setTimeout(() => { if (toast.parentNode) toast.remove(); }, 3200);
}

/*  
   3. CONFETTI — fires on successful Pokémon catch
 */
function spawnConfetti() {
  const colours = ['#ffd700', '#cc1a1a', '#4fc3f7', '#4caf50', '#b06ef5', '#ff8c00'];
  const count = 34;

  for (let i = 0; i < count; i++) {
    const piece = document.createElement('div');
    piece.className = 'confetti-piece';
    piece.style.cssText = `
      left: ${25 + Math.random() * 50}%;
      top:  ${15 + Math.random() * 35}%;
      background: ${colours[Math.floor(Math.random() * colours.length)]};
      animation-duration: ${0.8 + Math.random() * 1.2}s;
      animation-delay:    ${Math.random() * 0.5}s;
      transform: rotate(${Math.random() * 360}deg);
      border-radius: ${Math.random() > 0.5 ? '50%' : '2px'};
      width:  ${5 + Math.random() * 6}px;
      height: ${5 + Math.random() * 6}px;
    `;
    document.body.appendChild(piece);
    setTimeout(() => piece.remove(), 2800);
  }
}

/*  
   4. CATCH MECHANIC — full animation sequence
   Called from catch.jsp form submission intercept
 */
const CatchSystem = {

  currentPokemon: null, // {name, rarity, catchRate} — set from JSP EL
  state: 'idle',        // idle | encountered | shaking | done

  /**
   * Starts the throw-and-shake animation, then submits
   * the hidden catch form to the server.
   */
  throwBall() {
    if (this.state !== 'encountered') return;
    this.state = 'thrown';

    const ball   = document.getElementById('pokeball-throw');
    const result = document.getElementById('catch-result');
    const wild   = document.getElementById('wild-circle');
    if (!ball) return;

    // Disable button to prevent double-throw
    ball.style.pointerEvents = 'none';
    ball.classList.add('throwing');

    // After throw animation reaches the Pokémon
    setTimeout(() => {
      ball.classList.remove('throwing');
      ball.classList.add('shaking');
      this.state = 'shaking';
    }, 950);

    // After 3 shakes — show result from server response
    // The actual result is determined server-side and stored in a data attribute
    setTimeout(() => {
      ball.classList.remove('shaking');
      this.state = 'done';

      const caught = ball.dataset.caught === 'true';
      if (caught) {
        if (result) { result.className = 'catch-result catch-success'; result.style.display = 'block'; }
        if (wild)   { wild.style.transition = 'all 0.3s'; wild.style.transform = 'scale(0)'; wild.style.opacity = '0'; }
        spawnConfetti();
        showToast((ball.dataset.pokemonName || 'Pokémon') + ' was caught! 🎉');
      } else {
        if (result) { result.className = 'catch-result catch-fail'; result.style.display = 'block'; }
        if (wild)   { wild.style.animation = 'flee 0.6s ease forwards'; }
        setTimeout(() => {
          if (wild) { wild.style.animation = ''; wild.style.transform = ''; wild.style.opacity = ''; }
        }, 700);
      }

      // Re-enable encounter button
      const encounterBtn = document.getElementById('encounter-btn');
      if (encounterBtn) encounterBtn.disabled = false;
    }, 1400 + 3 * 400);
  },

  /**
   * Resets the arena state for a new encounter.
   * Called when the server returns a new wild Pokémon.
   */
  resetArena() {
    const wild   = document.getElementById('wild-circle');
    const result = document.getElementById('catch-result');
    const ball   = document.getElementById('pokeball-throw');
    if (result) { result.style.display = 'none'; result.className = 'catch-result'; }
    if (wild)   { wild.style.transform = ''; wild.style.opacity = ''; wild.style.animation = ''; }
    if (ball)   { ball.style.pointerEvents = ''; ball.classList.remove('throwing', 'shaking'); }
    this.state = 'encountered';
  }
};

/* Wire up the throw button if it exists on the page */
document.addEventListener('DOMContentLoaded', () => {
  const throwBtn = document.getElementById('pokeball-throw');
  if (throwBtn) {
    throwBtn.addEventListener('click', () => {
      if (CatchSystem.state === 'encountered') {
        // Submit the catch form — server calculates shake results
        const form = document.getElementById('catch-form');
        if (form) {
          CatchSystem.throwBall();
          // Delay form submission until animation starts
          setTimeout(() => form.submit(), 200);
        }
      }
    });
  }
});

/*  
   5. BOOSTER PACK — client-side reveal animation
   Actual card data comes from the server response.
   This function animates cards that were already injected
   into .revealed-area by the JSP.
 */
function animateRevealedCards() {
  document.querySelectorAll('.revealed-card').forEach((card, i) => {
    card.style.opacity = '0';
    card.style.animationDelay = (i * 0.18) + 's';
    card.style.animationFillMode = 'forwards';
  });
}

document.addEventListener('DOMContentLoaded', () => {
  const revealArea = document.querySelector('.revealed-area');
  if (revealArea && revealArea.children.length > 0) {
    animateRevealedCards();
  }
});

/*  
   6. PACK SELECTOR — visual selection state
 */
function selectPack(type, el) {
  document.querySelectorAll('.pack-card').forEach(c => c.classList.remove('selected'));
  el.classList.add('selected');

  // Update the hidden input on the pack form
  const packInput = document.getElementById('pack-type-input');
  if (packInput) packInput.value = type;
}

/*  
   7. LIVE SEARCH — debounced AJAX card search
   Sends request to /cards?search=... and replaces grid
 */
let searchTimer = null;

function liveSearch(inputEl) {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(() => {
    const query    = inputEl.value.trim();
    const rarity   = document.getElementById('filter-rarity')  ? document.getElementById('filter-rarity').value  : '';
    const type     = document.getElementById('filter-type')    ? document.getElementById('filter-type').value    : '';
    const sortBy   = document.getElementById('sort-by')        ? document.getElementById('sort-by').value        : '';
    const grid     = document.getElementById('card-grid');
    if (!grid) return;

    const ctx  = document.querySelector('body').dataset.ctx || '';
    const url  = `${ctx}/cards?search=${encodeURIComponent(query)}&rarity=${encodeURIComponent(rarity)}&type=${encodeURIComponent(type)}&sort=${encodeURIComponent(sortBy)}&ajax=true`;

    fetch(url)
      .then(r => r.text())
      .then(html => { grid.innerHTML = html; })
      .catch(() => {/* silently fail — full page still works */});
  }, 320);
}

/*  
   8. QUEST TAB SWITCHING (client-side, no reload)
 */
function switchQuestTab(tabBtn, type) {
  // Update tab active states
  document.querySelectorAll('.js-quest-tab').forEach(b => b.classList.remove('active'));
  tabBtn.classList.add('active');

  // Show/hide quest items by data-type
  document.querySelectorAll('.quest-item[data-type]').forEach(item => {
    item.style.display = (item.dataset.type === type) ? 'flex' : 'none';
  });
}

/*  
   9. CONFIRM DIALOGS for destructive actions
 */
function confirmDelete(formId, pokemonName) {
  if (confirm('Delete "' + pokemonName + '" from the museum? This cannot be undone (but can be undone via the Undo stack).')) {
    document.getElementById(formId).submit();
  }
}

function confirmRemoveInventory(formId, pokemonName) {
  if (confirm('Remove "' + pokemonName + '" from your inventory?')) {
    document.getElementById(formId).submit();
  }
}

/*  
   10. SIDEBAR TAB ACTIVE STATE
    Highlights the correct sidebar tab based on current URL
 */
document.addEventListener('DOMContentLoaded', () => {
  const path = window.location.pathname;
  document.querySelectorAll('.sidebar-tab[data-path]').forEach(tab => {
    if (path.includes(tab.dataset.path)) {
      tab.classList.add('active');
    }
  });
  
  // Responsive topbar hamburger: inject button and wire toggle behavior
  const topbar = document.querySelector('.topbar');
  if (topbar) {
    // Only add once
    if (!topbar.querySelector('.topbar-hamburger')) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'topbar-hamburger';
      btn.setAttribute('aria-label', 'Toggle navigation');
      btn.innerHTML = '<span class="bar"></span>';
      // Append the hamburger to the end of the topbar so flex placement and margin rules work consistently
      topbar.appendChild(btn);

      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        topbar.classList.toggle('open');
      });

      // Close menu when clicking outside
      document.addEventListener('click', (e) => {
        if (!topbar.classList.contains('open')) return;
        if (!topbar.contains(e.target)) topbar.classList.remove('open');
      }, true);

      // Close menu when resizing beyond breakpoint
      window.addEventListener('resize', () => {
        if (window.innerWidth > 900 && topbar.classList.contains('open')) topbar.classList.remove('open');
      });
    }
  }
});

/*  
   11. IMAGE PREVIEW — for admin add/edit card form
 */
function previewImage(input) {
  const preview = document.getElementById('img-preview');
  if (!preview || !input.files || !input.files[0]) return;
  const reader = new FileReader();
  reader.onload = e => { preview.src = e.target.result; preview.style.display = 'block'; };
  reader.readAsDataURL(input.files[0]);
}

/*  
   12. PAGE-LOAD ANIMATION — stagger card entries
 */
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.poke-card').forEach((card, i) => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(16px)';
    card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    setTimeout(() => {
      card.style.opacity = '1';
      card.style.transform = 'translateY(0)';
    }, 40 + i * 40);
  });
});
