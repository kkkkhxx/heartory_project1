// src/test/java/com/zetcode/MinesAdapterWinPathTest.java
package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseEvent;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

public class MinesAdapterWinPathTest {

    private Object board; // com.zetcode.Board instance
    private JLabel statusbar;

    // -------- reflection helpers (tolerant) --------
    private static Field findFieldOrNull(Class<?> cls, String name) {
        Class<?> c = cls;
        while (c != null) {
            try { return c.getDeclaredField(name); }
            catch (NoSuchFieldException ignore) { c = c.getSuperclass(); }
        }
        return null;
    }
    private static Object tryGet(Object target, String name) throws Exception {
        Field f = findFieldOrNull(target.getClass(), name);
        if (f == null) return null;
        f.setAccessible(true);
        return f.get(target);
    }
    private static boolean trySet(Object target, String name, Object value) throws Exception {
        Field f = findFieldOrNull(target.getClass(), name);
        if (f == null) return false;
        f.setAccessible(true);
        f.set(target, value);
        return true;
    }
    private static int getIntFlexible(Object instanceOrClass, Class<?> klass, String name, Integer fallback) {
        try {
            Field f = findFieldOrNull(klass, name);
            if (f == null) { if (fallback != null) return fallback; throw new IllegalArgumentException("No int: "+name); }
            f.setAccessible(true);
            if (Modifier.isStatic(f.getModifiers())) return (int) f.get(null);
            return (int) f.get(instanceOrClass);
        } catch (Throwable t) {
            if (fallback != null) return fallback;
            throw new RuntimeException("Cannot resolve int constant: " + name, t);
        }
    }
    private static void setIfExists(Object target, String name, Object value) throws Exception {
        if (trySet(target, name, value)) return;
        if ("minesLeft".equals(name)) { trySet(target, "mines_left", value); return; }
        if ("mines_left".equals(name)) { trySet(target, "minesLeft", value); return; }
        // uncover หากไม่มีให้ข้าม
    }

    // -------- Board constants --------
    private int N_ROWS, N_COLS, CELL_SIZE, N_MINES;
    private int COVER_FOR_CELL, MARK_FOR_CELL, MINE_CELL, COVERED_MINE_CELL, MARKED_MINE_CELL;
    private int EMPTY_CELL; // 0
    private int ALL;

    @BeforeEach
    void setup() throws Exception {
        statusbar = new JLabel("");
        Class<?> boardCls = Class.forName("com.zetcode.Board");
        board = boardCls.getConstructor(JLabel.class).newInstance(statusbar);

        N_ROWS  = getIntFlexible(board, boardCls, "N_ROWS", null);
        N_COLS  = getIntFlexible(board, boardCls, "N_COLS", null);
        CELL_SIZE = getIntFlexible(board, boardCls, "CELL_SIZE", 15);
        N_MINES = getIntFlexible(board, boardCls, "N_MINES", 40);

        COVER_FOR_CELL = getIntFlexible(board, boardCls, "COVER_FOR_CELL", 10);
        MARK_FOR_CELL  = getIntFlexible(board, boardCls, "MARK_FOR_CELL", 10);
        MINE_CELL      = getIntFlexible(board, boardCls, "MINE_CELL", 9);
        EMPTY_CELL     = getIntFlexible(board, boardCls, "EMPTY_CELL", 0);

        int coveredMine = COVER_FOR_CELL + MINE_CELL;         // e.g., 19
        COVERED_MINE_CELL = getIntFlexible(board, boardCls, "COVERED_MINE_CELL", coveredMine);
        int markedMine = COVERED_MINE_CELL + MARK_FOR_CELL;   // e.g., 29
        MARKED_MINE_CELL  = getIntFlexible(board, boardCls, "MARKED_MINE_CELL", markedMine);

        ALL = N_ROWS * N_COLS;

        JFrame f = new JFrame();
        f.add((Component) board);
        f.pack();
    }

    // -------- utils --------
    private int idx(int r, int c) { return r * N_COLS + c; }

    private Point centerOf(int r, int c) {
        int x = c * CELL_SIZE + CELL_SIZE / 2;
        int y = r * CELL_SIZE + CELL_SIZE / 2;
        return new Point(x, y);
    }

    private Point outsideRight() {
        int x = N_COLS * CELL_SIZE + 5;       // ขวาเกินจริง
        int y = CELL_SIZE / 2;                // แถวแรก
        return new Point(x, y);
    }

    private void dispatchClick(Point p, int button) {
        Component comp = (Component) board;
        long when = System.currentTimeMillis();
        int mod = switch (button) {
            case MouseEvent.BUTTON1 -> MouseEvent.BUTTON1_DOWN_MASK;
            case MouseEvent.BUTTON3 -> MouseEvent.BUTTON3_DOWN_MASK;
            case MouseEvent.BUTTON2 -> MouseEvent.BUTTON2_DOWN_MASK;
            default -> 0;
        };
        MouseEvent e = new MouseEvent(comp, MouseEvent.MOUSE_PRESSED, when, mod, p.x, p.y, 1, false, button);
        comp.dispatchEvent(e);
    }

    private void setBoardState(int[] field, Boolean inGame, Integer minesLeft, Integer uncoverMaybe) throws Exception {
        assertTrue(trySet(board, "field", field), "Board.field missing");
        if (inGame != null) setIfExists(board, "inGame", inGame);
        if (minesLeft != null) { if (!trySet(board, "minesLeft", minesLeft)) trySet(board, "mines_left", minesLeft); }
        if (uncoverMaybe != null) { trySet(board, "uncover", uncoverMaybe); } // ไม่มีให้ข้าม
    }

    private Integer getIntOrNull(String name) throws Exception {
        Object v = tryGet(board, name);
        return (v instanceof Integer) ? (Integer) v : null;
    }

    private boolean anyCoveredSafe(int[] field) {
        for (int v : field) {
            boolean covered = v >= COVER_FOR_CELL;
            boolean isCoveredMine = (v == COVERED_MINE_CELL || v == MARKED_MINE_CELL);
            if (covered && !isCoveredMine) return true;
        }
        return false;
    }

    // ================== P1 ==================
    @Test
    void P1_left_onCoveredZero_lastOne_wins() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, EMPTY_CELL); // อื่น ๆ เปิดแล้ว
        int r=5,c=7;
        field[idx(r,c)] = COVER_FOR_CELL + EMPTY_CELL; // ช่องสุดท้าย
        setBoardState(field, true, N_MINES, null);

        dispatchClick(centerOf(r,c), MouseEvent.BUTTON1);

        int[] after = (int[]) tryGet(board, "field");
        assertNotNull(after);
        // เกณฑ์ชนะ: ไม่เหลือ safe cell
        assertFalse(anyCoveredSafe(after));

        Integer un = getIntOrNull("uncover");
        if (un != null) assertEquals(0, un);
    }

    // ================== P2 ==================
    @Test
    void P2_left_onCoveredNumber_lastOne_wins() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, EMPTY_CELL);
        int r=0,c=5;
        field[idx(r,c)] = COVER_FOR_CELL + 1; // ช่องสุดท้ายเป็นเลข
        setBoardState(field, true, N_MINES, null);

        dispatchClick(centerOf(r,c), MouseEvent.BUTTON1);

        int[] after = (int[]) tryGet(board, "field");
        assertNotNull(after);
        assertFalse(anyCoveredSafe(after));

        Integer un = getIntOrNull("uncover");
        if (un != null) assertEquals(0, un);
    }

    // ================== P3 ==================
    @Test
    void P3_right_onMarked_corner_noOpen_toggle() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, COVER_FOR_CELL + EMPTY_CELL);
        int r=0,c=0; // corner
        field[idx(r,c)] = COVER_FOR_CELL + MARK_FOR_CELL; // marked (safe)
        setBoardState(field, true, N_MINES, null);

        dispatchClick(centerOf(r,c), MouseEvent.BUTTON3);

        int v = ((int[]) tryGet(board,"field"))[idx(r,c)];
        assertTrue(v == COVER_FOR_CELL + EMPTY_CELL || v == COVER_FOR_CELL + MARK_FOR_CELL,
                "toggle หรือคง mark ตามดีไซน์ได้");
        Object ig = tryGet(board, "inGame");
        if (ig instanceof Boolean) assertTrue((Boolean) ig);
    }

    // ================== P4 ==================
    @Test
    void P4_right_onCoveredZero_markOnly_noOpen() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, COVER_FOR_CELL + EMPTY_CELL);
        int r=8,c=3;
        field[idx(r,c)] = COVER_FOR_CELL + EMPTY_CELL; // covered zero
        setBoardState(field, true, N_MINES, null);

        dispatchClick(centerOf(r,c), MouseEvent.BUTTON3);

        int v = ((int[]) tryGet(board,"field"))[idx(r,c)];
        assertEquals(COVER_FOR_CELL + MARK_FOR_CELL, v, "คลิกขวาควร mark ช่อง ไม่ควรเปิด");
    }

    // ================== P5 ==================
    @Test
    void P5_left_onMarked_lastOne_notWin_noOpen() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, COVER_FOR_CELL + EMPTY_CELL);
        int r=6,c=6;
        field[idx(r,c)] = COVER_FOR_CELL + MARK_FOR_CELL; // ช่องสุดท้ายแต่ถูก mark
        setBoardState(field, true, N_MINES, null);

        dispatchClick(centerOf(r,c), MouseEvent.BUTTON1);

        int v = ((int[]) tryGet(board,"field"))[idx(r,c)];
        assertEquals(COVER_FOR_CELL + MARK_FOR_CELL, v, "คลิกซ้ายที่ marked ไม่ควรเปิด");
        Object ig = tryGet(board, "inGame");
        if (ig instanceof Boolean) assertTrue((Boolean) ig);
    }

    // ================== P6 ==================
    @Test
    void P6_left_outOfBoard_noop() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, COVER_FOR_CELL + EMPTY_CELL);
        int r=5,c=7;
        field[idx(r,c)] = COVER_FOR_CELL + EMPTY_CELL;
        setBoardState(field, true, N_MINES, null);

        // คลิกนอกบอร์ด “จริง” (ขวาสุด)
        dispatchClick(outsideRight(), MouseEvent.BUTTON1);

        // ช่องเป้าหมายต้องไม่เปลี่ยน
        int v = ((int[]) tryGet(board,"field"))[idx(r,c)];
        assertEquals(COVER_FOR_CELL + EMPTY_CELL, v);
        Object ig = tryGet(board, "inGame");
        if (ig instanceof Boolean) assertTrue((Boolean) ig);
    }

    // ================== P7 ==================
    @Test
    void P7_left_afterGameOver_noop_or_restartDependingOnDesign() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, COVER_FOR_CELL + EMPTY_CELL);
        int r=5,c=7;
        int before = field[idx(r,c)];
        // ตั้งให้เกม “จบแล้ว”
        setBoardState(field, /*inGame*/ false, N_MINES, null);

        // คลิกซ้าย (บางรุ่น = เริ่มเกมใหม่)
        dispatchClick(centerOf(r,c), MouseEvent.BUTTON1);

        Object ig = tryGet(board, "inGame");
        int[] afterField = (int[]) tryGet(board, "field");
        assertNotNull(afterField);

        if (ig instanceof Boolean && (Boolean) ig) {
            // ยอมรับพฤติกรรมรีสตาร์ท: ต้องเปลี่ยนกระดานจากเดิม
            assertFalse(Arrays.equals(field, afterField), "คลิกหลังจบเกมแล้ว ถ้า inGame กลับเป็น true ควรเริ่มกระดานใหม่");
        } else {
            // ยอมรับพฤติกรรม no-op: inGame ควรยัง false
            if (ig instanceof Boolean) assertFalse((Boolean) ig);
            int v = afterField[idx(r,c)];
            assertEquals(before, v, "ถ้าไม่รีสตาร์ท ช่องเดิมควรคงค่าเดิม");
        }
    }

    // ================== P8 ==================
    @Test
    void P8_middleButton_noop_or_openDependingOnDesign() throws Exception {
        int[] field = new int[ALL];
        Arrays.fill(field, COVER_FOR_CELL + EMPTY_CELL);
        int r=0,c=1;
        int before = field[idx(r,c)];
        setBoardState(field, true, N_MINES, null);

        dispatchClick(centerOf(r,c), MouseEvent.BUTTON2);

        int v = ((int[]) tryGet(board,"field"))[idx(r,c)];
        // ยอมรับได้สองแบบ: รุ่นที่ปุ่มกลางนับเป็นซ้าย (เปิดเป็น 0) หรือ no-op (ยัง covered)
        boolean acceptable = (v == before) || (v == EMPTY_CELL);
        assertTrue(acceptable, "middle button อาจ no-op หรือเปิด (เทียบซ้าย) ตามดีไซน์");
        Object ig = tryGet(board, "inGame");
        if (ig instanceof Boolean) assertTrue((Boolean) ig);
    }
}
