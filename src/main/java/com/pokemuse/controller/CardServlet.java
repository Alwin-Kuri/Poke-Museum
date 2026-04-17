package com.pokemuse.controller;

import com.pokemuse.dao.CardDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.util.SessionUtil;
import com.pokemuse.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/cards")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB before writing to disk
    maxFileSize       = 1024 * 1024 * 5,  // 5MB max per file
    maxRequestSize    = 1024 * 1024 * 10  // 10MB max request
)
public class CardServlet extends HttpServlet {

    private final CardDao cardDao = new CardDao();

    // GET
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Must be logged in to browse
        if (SessionUtil.requireLogin(req, res)) return;

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            // Admin only — show add card form
            if (SessionUtil.requireAdmin(req, res)) return;
            req.getRequestDispatcher("/WEB-INF/pages/card-add.jsp").forward(req, res);
            return;
        }

        if ("edit".equals(action)) {
            if (SessionUtil.requireAdmin(req, res)) return;
            int id = parseId(req.getParameter("id"));
            if (id < 1) { res.sendRedirect(req.getContextPath() + "/cards"); return; }
            PokeModel card = cardDao.getCardById(id);
            if (card == null) { res.sendRedirect(req.getContextPath() + "/cards"); return; }
            req.setAttribute("editCard", card);
            req.getRequestDispatcher("/WEB-INF/pages/card-edit.jsp").forward(req, res);
            return;
        }

        // Browse / search page
        String search  = ValidationUtil.sanitise(req.getParameter("search"));
        String rarity  = ValidationUtil.sanitise(req.getParameter("rarity"));
        String type    = ValidationUtil.sanitise(req.getParameter("type"));
        String sort    = ValidationUtil.sanitise(req.getParameter("sort"));

        // Resolve sort column
        String orderCol = switch (sort) {
            case "name"       -> "name";
            case "value_asc"  -> "value";
            case "rarity"     -> "rarity";
            default           -> "value";
        };
        String orderDir = "value_asc".equals(sort) ? "ASC" : "DESC";

        List<PokeModel> cards = cardDao.getCardsWithFilter(
            search.isEmpty() ? null : search,
            type.isEmpty()   ? null : type,
            rarity.isEmpty() ? null : rarity,
            orderCol, orderDir
        );

        req.setAttribute("cards",        cards);
        req.setAttribute("totalCards",   cardDao.getTotalCardCount());
        req.setAttribute("searchQuery",  search);
        req.setAttribute("filterRarity", rarity);
        req.setAttribute("filterType",   type);
        req.setAttribute("sortBy",       sort);

        // AJAX request -> return only the grid fragment
        if ("true".equals(req.getParameter("ajax"))) {
            req.getRequestDispatcher("/WEB-INF/pages/fragments/card-grid.jsp").forward(req, res);
            return;
        }

        req.getRequestDispatcher("/WEB-INF/pages/cards.jsp").forward(req, res);
    }

    // POST
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireAdmin(req, res)) return;

        String action = req.getParameter("action");

        switch (action == null ? "" : action) {
            case "add"    -> handleAdd(req, res);
            case "edit"   -> handleEdit(req, res);
            case "delete" -> handleDelete(req, res);
            case "undo"   -> handleUndo(req, res);
            default       -> res.sendRedirect(req.getContextPath() + "/cards");
        }
    }

    // ADD
    private void handleAdd(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String cardCode   = ValidationUtil.sanitise(req.getParameter("cardCode")).toUpperCase();
        String name       = ValidationUtil.sanitise(req.getParameter("name"));
        String type       = ValidationUtil.sanitise(req.getParameter("type"));
        String rarity     = ValidationUtil.sanitise(req.getParameter("rarity"));
        String condition  = ValidationUtil.sanitise(req.getParameter("conditionState"));
        String valueStr   = ValidationUtil.sanitise(req.getParameter("value"));
        String catchStr   = ValidationUtil.sanitise(req.getParameter("catchRate"));
        String description= ValidationUtil.sanitise(req.getParameter("description"));

        // Validate
        String err = ValidationUtil.validateCardCode(cardCode);
        if (err == null) err = ValidationUtil.validateCardName(name);
        if (err == null) err = ValidationUtil.validateCardValue(valueStr);
        if (err == null) err = ValidationUtil.validateCatchRate(catchStr);

        if (err != null) {
            req.setAttribute("errorMsg", err);
            req.getRequestDispatcher("/WEB-INF/pages/card-add.jsp").forward(req, res);
            return;
        }

        if (cardDao.cardCodeExists(cardCode)) {
            req.setAttribute("errorMsg", "Card code " + cardCode + " already exists.");
            req.getRequestDispatcher("/WEB-INF/pages/card-add.jsp").forward(req, res);
            return;
        }

        // Handle image upload
        String imagePath = handleImageUpload(req, cardCode);

        PokeModel card = new PokeModel(
            cardCode, name, type, rarity, condition,
            new BigDecimal(valueStr), imagePath, description,
            Integer.parseInt(catchStr)
        );
        card.setCreatedBy(SessionUtil.getUserId(req));

        if (cardDao.addCard(card)) {
            res.sendRedirect(req.getContextPath() + "/cards?success=added");
        } else {
            req.setAttribute("errorMsg", "Failed to add card. Please try again.");
            req.getRequestDispatcher("/WEB-INF/pages/card-add.jsp").forward(req, res);
        }
    }

    // EDIT
    private void handleEdit(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("cardId"));
        if (id < 1) { res.sendRedirect(req.getContextPath() + "/cards"); return; }

        PokeModel existing = cardDao.getCardById(id);
        if (existing == null) { res.sendRedirect(req.getContextPath() + "/cards"); return; }

        String name      = ValidationUtil.sanitise(req.getParameter("name"));
        String type      = ValidationUtil.sanitise(req.getParameter("type"));
        String rarity    = ValidationUtil.sanitise(req.getParameter("rarity"));
        String condition = ValidationUtil.sanitise(req.getParameter("conditionState"));
        String valueStr  = ValidationUtil.sanitise(req.getParameter("value"));
        String catchStr  = ValidationUtil.sanitise(req.getParameter("catchRate"));
        String desc      = ValidationUtil.sanitise(req.getParameter("description"));

        String err = ValidationUtil.validateCardName(name);
        if (err == null) err = ValidationUtil.validateCardValue(valueStr);
        if (err == null) err = ValidationUtil.validateCatchRate(catchStr);

        if (err != null) {
            req.setAttribute("errorMsg", err);
            req.setAttribute("editCard", existing);
            req.getRequestDispatcher("/WEB-INF/pages/card-edit.jsp").forward(req, res);
            return;
        }

        // Keep existing image unless a new one is uploaded
        String imagePath = handleImageUpload(req, existing.getCardCode());
        if (imagePath == null || imagePath.isBlank()) imagePath = existing.getImagePath();

        existing.setName(name);
        existing.setType(type);
        existing.setRarity(rarity);
        existing.setConditionState(condition);
        existing.setValue(new BigDecimal(valueStr));
        existing.setCatchRate(Integer.parseInt(catchStr));
        existing.setDescription(desc);
        existing.setImagePath(imagePath);

        if (cardDao.updateCard(existing)) {
            res.sendRedirect(req.getContextPath() + "/cards?success=updated");
        } else {
            req.setAttribute("errorMsg", "Update failed. Please try again.");
            req.setAttribute("editCard", existing);
            req.getRequestDispatcher("/WEB-INF/pages/card-edit.jsp").forward(req, res);
        }
    }

    // DELETE
    private void handleDelete(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        int id = parseId(req.getParameter("cardId"));
        if (id < 1) { res.sendRedirect(req.getContextPath() + "/cards"); return; }

        if (cardDao.deleteCard(id)) {
            // Push to session-based undo stack
            UndoStack.push(req.getSession(), id);
            res.sendRedirect(req.getContextPath() + "/cards?success=deleted");
        } else {
            res.sendRedirect(req.getContextPath() + "/cards?error=deleteFailed");
        }
    }

    // UNDO
    private void handleUndo(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        Integer lastDeletedId = UndoStack.pop(req.getSession());
        if (lastDeletedId != null && cardDao.restoreCard(lastDeletedId)) {
            res.sendRedirect(req.getContextPath() + "/cards?success=restored");
        } else {
            res.sendRedirect(req.getContextPath() + "/cards?error=nothingToUndo");
        }
    }

    // IMAGE UPLOAD
    private String handleImageUpload(HttpServletRequest req, String cardCode) {
        try {
            Part filePart = req.getPart("cardImage");
            if (filePart == null || filePart.getSize() == 0) return null;

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            if (fileName.isBlank()) return null;

            String ext = fileName.contains(".")
                    ? fileName.substring(fileName.lastIndexOf('.'))
                    : ".jpg";
            String saveName = cardCode + ext;

            // Save under webapp/images/cards/
            String uploadDir = getServletContext().getRealPath("/images/cards");
            Files.createDirectories(Paths.get(uploadDir));
            filePart.write(uploadDir + File.separator + saveName);

            return "cards/" + saveName;

        } catch (Exception e) {
            System.err.println("[CardServlet.handleImageUpload] " + e.getMessage());
            return null;
        }
    }

    private int parseId(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }
}
