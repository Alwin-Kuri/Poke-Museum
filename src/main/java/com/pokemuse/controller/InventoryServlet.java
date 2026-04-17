package com.pokemuse.controller;

import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.InventoryDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {

    private final InventoryDao InventoryDao = new InventoryDao();
    private final CardDao      CardDao      = new CardDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);

        List<PokeModel> myCards = InventoryDao.getUserInventory(userId);
        int totalCards = CardDao.getTotalCardCount();

        req.setAttribute("myCards",     myCards);
        req.setAttribute("totalMuseum", totalCards);
        req.setAttribute("ownedCount",  myCards.size());

        req.getRequestDispatcher("/WEB-INF/pages/inventory.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;
        int userId = SessionUtil.getUserId(req);
        String action = req.getParameter("action");
        int cardId;

        try {
            cardId = Integer.parseInt(req.getParameter("cardId"));
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/inventory?error=invalid");
            return;
        }

        if ("add".equals(action)) {
            String via = req.getParameter("via");
            if (via == null || via.isBlank()) via = "browse";
            boolean added = InventoryDao.addToInventory(userId, cardId, via);
            if (added) {
                PokeModel card = CardDao.getCardById(cardId);
                String name = card != null ? card.getName() : "Card";
                res.sendRedirect(req.getContextPath() + "/home?success="
                    + java.net.URLEncoder.encode(name + " added to inventory! 🎉", "UTF-8"));
            } else {
                res.sendRedirect(req.getContextPath() + "/home?error=alreadyOwned");
            }

        } else if ("remove".equals(action)) {
            InventoryDao.removeFromInventory(userId, cardId);
            res.sendRedirect(req.getContextPath() + "/inventory?success=removed");

        } else {
            res.sendRedirect(req.getContextPath() + "/inventory");
        }
    }
}
