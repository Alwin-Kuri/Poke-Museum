package com.pokemuse.controller;

import com.pokemuse.dao.InventoryDao;
import com.pokemuse.dao.TradeDao;
import com.pokemuse.dao.TradeDao.TradeListingView;
import com.pokemuse.dao.TradeDao.TradeOfferView;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * TradeServlet.java — Controller
 * GET /trade -trading marketplace home
 * GET /trade?tab=mine -my listed cards
 * GET /trade?tab=offers  -incoming offers on my listings
 * POST /trade?action=list -list a card for trading
 * POST /trade?action=cancel -cancel my listing
 * POST /trade?action=offer -make an offer on someone's listing
 * POST /trade?action=accept -accept an incoming offer
 * POST /trade?action=reject - reject an incoming offer
 */
@WebServlet("/trade")
public class TradeServlet extends HttpServlet {

    private final TradeDao     tradeDao     = new TradeDao();
    private final InventoryDao inventoryDao = new InventoryDao();

    // ── GET: load marketplace view
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);

        String tab = req.getParameter("tab");
        if (tab == null) tab = "home";

        // All open listings from other trainers
        List<TradeListingView> openListings = tradeDao.getOpenListings(userId);
        // My own listings
        List<TradeListingView> myListings   = tradeDao.getMyListings(userId);
        // Offers I have received on my listings
        List<TradeOfferView>   myOffers     = tradeDao.getIncomingOffers(userId);
        // My inventory — for the "make offer" modal (only cards not already listed)
        List<PokeModel>      myInventory  = inventoryDao.getUserInventory(userId);

        req.setAttribute("openListings", openListings);
        req.setAttribute("myListings",   myListings);
        req.setAttribute("myOffers",     myOffers);
        req.setAttribute("myInventory",  myInventory);
        req.setAttribute("activeTab",    tab);
        req.setAttribute("openCount",    tradeDao.getOpenListingCount());

        req.getRequestDispatcher("/WEB-INF/pages/trade.jsp").forward(req, res);
    }

    // ── POST: handle all trade actions
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);
        String action = req.getParameter("action");

        switch (action == null ? "" : action) {

            case "list" -> {
                int cardId = parseId(req.getParameter("cardId"));
                if (cardId < 1 || !inventoryDao.ownsCard(userId, cardId)) {
                    redirect(req, res, "/trade?error=notOwned");
                    return;
                }
                int tradeId = tradeDao.listCard(userId, cardId);
                if (tradeId > 0) redirect(req, res, "/trade?tab=mine&success=listed");
                else             redirect(req, res, "/trade?error=listFailed");
            }

            case "cancel" -> {
                int tradeId = parseId(req.getParameter("tradeId"));
                boolean ok = tradeDao.cancelListing(tradeId, userId);
                redirect(req, res, ok ? "/trade?tab=mine&success=cancelled"
                                      : "/trade?error=cancelFailed");
            }

            case "offer" -> {
                int tradeId    = parseId(req.getParameter("tradeId"));
                int offeredCard = parseId(req.getParameter("offeredCardId"));
                if (offeredCard < 1 || !inventoryDao.ownsCard(userId, offeredCard)) {
                    redirect(req, res, "/trade?error=notOwned");
                    return;
                }
                int offerId = tradeDao.makeOffer(tradeId, userId, offeredCard);
                if (offerId > 0) redirect(req, res, "/trade?success=offerSent");
                else             redirect(req, res, "/trade?error=offerFailed");
            }

            case "accept" -> {
                int offerId = parseId(req.getParameter("offerId"));
                boolean ok = tradeDao.acceptOffer(offerId, userId);
                redirect(req, res, ok ? "/trade?tab=offers&success=tradeComplete"
                                      : "/trade?error=acceptFailed");
            }

            case "reject" -> {
                int offerId = parseId(req.getParameter("offerId"));
                boolean ok = tradeDao.rejectOffer(offerId, userId);
                redirect(req, res, ok ? "/trade?tab=offers&success=rejected"
                                      : "/trade?error=rejectFailed");
            }

            default -> redirect(req, res, "/trade");
        }
    }

    private int parseId(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }

    private void redirect(HttpServletRequest req, HttpServletResponse res, String path)
            throws IOException {
        res.sendRedirect(req.getContextPath() + path);
    }
}
