package com.pokemuse.controller;

import com.pokemuse.dao.DeckDao;
import com.pokemuse.dao.DeckDao.DeckView;
import com.pokemuse.dao.InventoryDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * DeckServlet.java 
 * GET  /deck  ->deck builder page
 * POST /deck?action=create  ->create a new deck
 * POST /deck?action=rename  ->rename a deck
 * POST /deck?action=delete  ->delete a deck
 * POST /deck?action=addCard  ->add card to deck
 * POST /deck?action=removeCard->remove card from deck
 */
@WebServlet("/deck")
public class DeckServlet extends HttpServlet {

    private final DeckDao      deckDao      = new DeckDao();
    private final InventoryDao inventoryDao = new InventoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);

        List<DeckView>    myDecks    = deckDao.getUserDecks(userId);
        List<PokeModel> myInventory = inventoryDao.getUserInventory(userId);

        req.setAttribute("myDecks",    myDecks);
        req.setAttribute("myInventory", myInventory);
        req.setAttribute("deckCount",  deckDao.getDeckCount(userId));
        req.setAttribute("maxDecks",   3);

        req.getRequestDispatcher("/WEB-INF/pages/deck.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);
        String action = req.getParameter("action");

        switch (action == null ? "" : action) {

            case "create" -> {
                if (deckDao.getDeckCount(userId) >= 3) {
                    redirect(req, res, "/deck?error=maxDecks");
                    return;
                }
                String name = ValidationUtil.sanitise(req.getParameter("deckName"));
                int deckId = deckDao.createDeck(userId, name.isEmpty() ? "My Deck" : name);
                if (deckId > 0) redirect(req, res, "/deck?success=created&deckId=" + deckId);
                else            redirect(req, res, "/deck?error=createFailed");
            }

            case "rename" -> {
                int deckId    = parseId(req.getParameter("deckId"));
                String newName = ValidationUtil.sanitise(req.getParameter("deckName"));
                if (newName.length() > 100) newName = newName.substring(0, 100);
                boolean ok = deckDao.renameDeck(deckId, userId, newName);
                redirect(req, res, ok ? "/deck?success=renamed" : "/deck?error=renameFailed");
            }

            case "delete" -> {
                int deckId = parseId(req.getParameter("deckId"));
                boolean ok = deckDao.deleteDeck(deckId, userId);
                redirect(req, res, ok ? "/deck?success=deleted" : "/deck?error=deleteFailed");
            }

            case "addCard" -> {
                int deckId = parseId(req.getParameter("deckId"));
                int cardId = parseId(req.getParameter("cardId"));
                if (!inventoryDao.ownsCard(userId, cardId)) {
                    redirect(req, res, "/deck?error=notOwned");
                    return;
                }
                boolean ok = deckDao.addCardToDeck(deckId, userId, cardId);
                if (ok) redirect(req, res, "/deck?success=cardAdded&deckId=" + deckId);
                else    redirect(req, res, "/deck?error=deckFull");
            }

            case "removeCard" -> {
                int deckId = parseId(req.getParameter("deckId"));
                int cardId = parseId(req.getParameter("cardId"));
                boolean ok = deckDao.removeCardFromDeck(deckId, userId, cardId);
                redirect(req, res, ok ? "/deck?success=cardRemoved&deckId=" + deckId
                                      : "/deck?error=removeFailed");
            }

            default -> redirect(req, res, "/deck");
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
