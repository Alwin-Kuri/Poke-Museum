package com.pokemuse.controller;

import jakarta.servlet.http.HttpSession;
import java.util.ArrayDeque;
import java.util.Deque;

/**
 * UndoStack.java — Session-based Undo Delete Stack
 * Stores the IDs of recently soft-deleted cards in the admin's HTTP session, implementing a LIFO stack with a fixed capacity of 10 entries
 */
public class UndoStack {

    private static final String SESSION_KEY = "undoDeleteStack";
    private static final int    CAPACITY    = 10;

    /** Pushes a deleted card ID onto the admin's undo stack. */
    @SuppressWarnings("unchecked")
    public static void push(HttpSession session, int cardId) {
        Deque<Integer> stack = (Deque<Integer>) session.getAttribute(SESSION_KEY);
        if (stack == null) {
            stack = new ArrayDeque<>();
            session.setAttribute(SESSION_KEY, stack);
        }
        // Drop the oldest entry if at capacity
        if (stack.size() >= CAPACITY) {
            ((ArrayDeque<Integer>) stack).removeLast();
        }
        stack.push(cardId);
    }

    /** Pops the most recently deleted card ID, or null if empty. */
    @SuppressWarnings("unchecked")
    public static Integer pop(HttpSession session) {
        Deque<Integer> stack = (Deque<Integer>) session.getAttribute(SESSION_KEY);
        if (stack == null || stack.isEmpty()) return null;
        return stack.pop();
    }

    /** Peeks at the most recently deleted card ID without removing. */
    @SuppressWarnings("unchecked")
    public static Integer peek(HttpSession session) {
        Deque<Integer> stack = (Deque<Integer>) session.getAttribute(SESSION_KEY);
        if (stack == null || stack.isEmpty()) return null;
        return stack.peek();
    }

    /** Returns current stack size (for admin UI display). */
    @SuppressWarnings("unchecked")
    public static int size(HttpSession session) {
        Deque<Integer> stack = (Deque<Integer>) session.getAttribute(SESSION_KEY);
        return stack == null ? 0 : stack.size();
    }
}
