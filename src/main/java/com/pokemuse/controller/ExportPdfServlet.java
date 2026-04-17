package com.pokemuse.controller;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.pokemuse.dao.CardDao;
import com.pokemuse.dao.InventoryDao;
import com.pokemuse.model.PokeModel;
import com.pokemuse.model.User;
import com.pokemuse.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * ExportPdfServlet.java — Controller
 * ─────────────────────────────────────────────────────
 * GET /export/pdf?type=inventory → exports user's inventory as PDF
 * GET /export/pdf?type=catalogue → exports full museum catalogue (admin)
 *
 * Uses iTextPDF 5.5.x (itextpdf-5.5.13.jar in WEB-INF/lib).
 *
 * The PDF is styled to look like a professional card album:
 *   • Cover page with museum logo + trainer name
 *   • Card table with rarity-colored rows
 *   • Summary statistics footer
 *
 * Author : Alwin Maharjan | CS5003NI
 */
@WebServlet("/export/pdf")
public class ExportPdfServlet extends HttpServlet {

    private final InventoryDao inventoryDao = new InventoryDao();
    private final CardDao      cardDao      = new CardDao();

    // iTextPDF font and colour constants
    private static final BaseColor RED_DARK   = new BaseColor(138, 15, 15);
    private static final BaseColor RED_LIGHT  = new BaseColor(204, 26, 26);
    private static final BaseColor DARK_BG    = new BaseColor(26, 26, 26);
    private static final BaseColor GOLD       = new BaseColor(255, 215, 0);
    private static final BaseColor LIGHT_GREY = new BaseColor(245, 245, 245);
    private static final BaseColor MID_GREY   = new BaseColor(220, 220, 220);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (SessionUtil.requireLogin(req, res)) return;

        User user      = SessionUtil.getUser(req);
        String type    = req.getParameter("type");
        boolean isAdmin = user.isAdmin();

        List<PokeModel> cards;
        String title;
        String filename;

        if ("catalogue".equals(type) && isAdmin) {
            cards    = cardDao.getAllCards();
            title    = "PokéMuseum – Full Card Catalogue";
            filename = "pokemuse_catalogue.pdf";
        } else {
            cards    = inventoryDao.getUserInventory(user.getUserId());
            title    = "PokéMuseum – " + user.getUsername() + "'s Collection";
            filename = "pokemuse_collection_" + user.getUsername() + ".pdf";
        }

        // Set response headers for PDF download
        res.setContentType("application/pdf");
        res.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try {
            Document doc = new Document(PageSize.A4, 36, 36, 50, 36);
            PdfWriter writer = PdfWriter.getInstance(doc, res.getOutputStream());
            doc.open();

            // ── Cover / header ───────────────────────────
            Font titleFont  = new Font(Font.FontFamily.HELVETICA, 22, Font.BOLD,
                                       new BaseColor(255, 255, 255));
            Font subFont    = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL,
                                       new BaseColor(180, 180, 180));
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD,
                                       new BaseColor(255, 255, 255));
            Font cellFont   = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL,
                                       new BaseColor(40, 40, 40));
            Font rarityFont = new Font(Font.FontFamily.HELVETICA, 8, Font.BOLD);

            // Dark header banner
            PdfPTable headerTable = new PdfPTable(1);
            headerTable.setWidthPercentage(100);
            PdfPCell headerCell = new PdfPCell(new Phrase(title + "\n\n" +
                "Trainer: " + user.getUsername() + "  |  " +
                "Total Cards: " + cards.size() + "  |  " +
                "Generated: " + java.time.LocalDate.now(), titleFont));
            headerCell.setBackgroundColor(DARK_BG);
            headerCell.setPadding(16);
            headerCell.setBorder(Rectangle.NO_BORDER);
            headerTable.addCell(headerCell);
            doc.add(headerTable);

            doc.add(Chunk.NEWLINE);

            if (cards.isEmpty()) {
                doc.add(new Paragraph("Your inventory is empty.", cellFont));
                doc.close();
                return;
            }

            // ── Card table ───────────────────────────────
            PdfPTable table = new PdfPTable(6);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{ 1.2f, 2.5f, 1.5f, 1.5f, 1.5f, 1.5f });

            String[] headers = { "Code", "Name", "Type", "Rarity", "Condition", "Value" };
            for (String h : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
                cell.setBackgroundColor(RED_DARK);
                cell.setPadding(6);
                cell.setBorderColor(RED_LIGHT);
                table.addCell(cell);
            }

            // Rarity colours for rows
            BigDecimal totalValue = BigDecimal.ZERO;
            boolean alt = false;
            for (PokeModel card : cards) {
                BaseColor rowBg = alt ? LIGHT_GREY : new BaseColor(255, 255, 255);
                alt = !alt;

                addCell(table, card.getCardCode(),       cellFont, rowBg);
                addCell(table, card.getName(),           cellFont, rowBg);
                addCell(table, card.getType(),           cellFont, rowBg);

                // Rarity cell with colour
                BaseColor rarColor = getRarityColor(card.getRarity());
                Font rf = new Font(Font.FontFamily.HELVETICA, 8, Font.BOLD, rarColor);
                PdfPCell rarCell = new PdfPCell(new Phrase(card.getRarity(), rf));
                rarCell.setBackgroundColor(rowBg);
                rarCell.setPadding(5);
                rarCell.setBorderColor(MID_GREY);
                table.addCell(rarCell);

                addCell(table, card.getConditionState(), cellFont, rowBg);
                addCell(table, "$" + String.format("%.2f", card.getValue()), cellFont, rowBg);

                if (card.getValue() != null) totalValue = totalValue.add(card.getValue());
            }
            doc.add(table);

            // ── Summary footer ───────────────────────────
            doc.add(Chunk.NEWLINE);
            Font summaryFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD,
                                        new BaseColor(60, 60, 60));
            doc.add(new Paragraph(
                "Total Cards: " + cards.size() +
                "   |   Total Value: $" + String.format("%.2f", totalValue) +
                "   |   PokéMuseum — Digital Card Museum",
                summaryFont));

            doc.close();

        } catch (DocumentException e) {
            System.err.println("[ExportPdfServlet] PDF generation error: " + e.getMessage());
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                          "Failed to generate PDF.");
        }
    }

    /** Adds a plain text cell to the PDF table. */
    private void addCell(PdfPTable table, String text, Font font, BaseColor bg) {
        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "—", font));
        cell.setBackgroundColor(bg);
        cell.setPadding(5);
        cell.setBorderColor(MID_GREY);
        table.addCell(cell);
    }

    /** Maps rarity string to an iTextPDF colour for the table row. */
    private BaseColor getRarityColor(String rarity) {
        return switch (rarity) {
            case "Legendary" -> new BaseColor(180, 120, 0);   // dark gold
            case "Epic"      -> new BaseColor(110, 50, 180);  // purple
            case "Rare"      -> new BaseColor(30, 100, 180);  // blue
            default          -> new BaseColor(40, 120, 40);   // green
        };
    }
}
