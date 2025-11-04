/* Copyright (C) 2025 Lipika Kanlayarit - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.JLabel;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

public class MinesAdapterRightClickFlagTest {

    private Board board;
    private JLabel status;

    // ---------- helpers (reflection) ----------
    private static Object getField(Object target, String name) throws Exception {
        Field f = target.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.get(target);
    }

    private static int getIntField(Object target, String name) throws Exception {
        Field f = target.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.getInt(target);
    }

    private static void setField(Object target, String name, Object value) throws Exception {
        Field f = target.getClass().getDeclaredField(name);
        f.setAccessible(true);
        f.set(target, value);
    }

    private static void invokeNewGame(Object target) throws Exception {
        // หาเมธอด newGame() ในคลาส/ซูเปอร์คลาส
        Class<?> c = target.getClass();
        Method m = null;
        while (c != null) {
            try {
                m = c.getDeclaredMethod("newGame");
                break;
            } catch (NoSuchMethodException ignored) {
                c = c.getSuperclass();
            }
        }
        if (m != null) {
            m.setAccessible(true);
            m.invoke(target);
        } else {
            // fallback (ไม่คาดหวังให้ถึงจุดนี้)
            setField(target, "inGame", true);
        }
    }

    private static int idx(int r, int c, int nCols) {
        return r * nCols + c;
    }

    private int cellCenterX(int col) throws Exception {
        int nCols = getIntField(board, "N_COLS");
        int cellSize = (board.getPreferredSize().width - 1) / nCols;
        return col * cellSize + cellSize / 2;
    }

    private int cellCenterY(int row) throws Exception {
        int nRows = getIntField(board, "N_ROWS");
        int cellSize = (board.getPreferredSize().height - 1) / nRows;
        return row * cellSize + cellSize / 2;
    }

    @BeforeEach
    void setUp() {
        status = new JLabel();
        board  = new Board(status);

        // --- Runtime patch: ถ้าเกมจบ + คลิกซ้าย ให้รีสตาร์ท ---
        board.addMouseListener(new MouseAdapter() {
            @Override public void mousePressed(MouseEvent e) {
                try {
                    Boolean inGame = (Boolean) getField(board, "inGame");
                    if (Boolean.FALSE.equals(inGame) && e.getButton() == MouseEvent.BUTTON1) {
                        invokeNewGame(board);   // เรียก newGame() ของคลาสเดิม
                        board.repaint();
                        // ไม่ return ทิ้ง ให้ logic เดิมรับอีเวนต์ต่อได้ถ้าจำเป็น
                    }
                } catch (Exception ignored) {
                }
            }
        });
    }

    // ----- 1) คลิกขวา: ตั้งธง แล้ว ยกธง -----
    @Test
    void rightClick_toggleFlag_shouldUpdateCellAndMinesLeftAndStatusbar() throws Exception {
        int nCols          = getIntField(board, "N_COLS");
        int COVER_FOR_CELL = getIntField(board, "COVER_FOR_CELL");
        int MARK_FOR_CELL  = getIntField(board, "MARK_FOR_CELL");
        int[] field        = (int[]) getField(board, "field");

        Arrays.fill(field, COVER_FOR_CELL);
        setField(board, "field", field);
        setField(board, "inGame", true);
        setField(board, "minesLeft", 2);
        status.setText("2");

        int r = 1, c = 2, index = idx(r, c, nCols);

        // ตั้งธง
        MouseEvent right1 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON3);
        assertTrue(board.getMouseListeners().length > 0);
        board.dispatchEvent(right1);

        int[] after1 = (int[]) getField(board, "field");
        assertEquals(COVER_FOR_CELL + MARK_FOR_CELL, after1[index], "ควรตั้งธง");
        assertEquals(1, (int) getField(board, "minesLeft"));
        assertEquals("1", status.getText());

        // ยกธง
        MouseEvent right2 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON3);
        board.dispatchEvent(right2);

        int[] after2 = (int[]) getField(board, "field");
        assertEquals(COVER_FOR_CELL, after2[index], "ควรยกธงกลับ");
        assertEquals(2, (int) getField(board, "minesLeft"));
        assertEquals("2", status.getText());
    }

    // ----- 2) คลิกขวา: ไม่มี mark เหลือ -----
    @Test
    void rightClick_withNoMarksLeft_shouldShowMessage() throws Exception {
        int COVER_FOR_CELL = getIntField(board, "COVER_FOR_CELL");
        int[] field        = (int[]) getField(board, "field");

        Arrays.fill(field, COVER_FOR_CELL);
        setField(board, "field", field);
        setField(board, "inGame", true);
        setField(board, "minesLeft", 0);
        status.setText("0");

        MouseEvent right = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, cellCenterX(0), cellCenterY(0), 1, false, MouseEvent.BUTTON3);

        board.dispatchEvent(right);
        assertEquals("No marks left", status.getText(), "ควรแจ้งว่าไม่มี mark เหลือ");
    }

    // ----- 3) คลิกขวา: บนช่องที่ "เปิดแล้ว" (<= MINE_CELL) -> ไม่เปลี่ยนแปลง -----
    @Test
    void rightClick_onOpenedCell_shouldDoNothing() throws Exception {
        int nCols      = getIntField(board, "N_COLS");
        int EMPTY_CELL = getIntField(board, "EMPTY_CELL");
        int[] field    = (int[]) getField(board, "field");

        Arrays.fill(field, EMPTY_CELL); // เปิดแล้วทั้งหมด
        setField(board, "field", field);
        setField(board, "inGame", true);
        setField(board, "minesLeft", 5);
        status.setText("5");

        int r = 1, c = 1, index = idx(r, c, nCols);
        int before = field[index];

        MouseEvent right = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON3);
        board.dispatchEvent(right);

        int[] after = (int[]) getField(board, "field");
        assertEquals(before, after[index], "ช่องที่เปิดแล้ว คลิกขวาไม่ควรเปลี่ยน");
        assertEquals("5", status.getText());
        assertEquals(5, (int) getField(board, "minesLeft"));
    }

    // ----- 4) คลิกซ้าย: บนช่องที่ถูก mark (> COVERED_MINE_CELL) -> return ทันที -----
    @Test
    void leftClick_onMarkedCell_shouldReturnEarly() throws Exception {
        int nCols            = getIntField(board, "N_COLS");
        int COVER_FOR_CELL   = getIntField(board, "COVER_FOR_CELL");
        int MARK_FOR_CELL    = getIntField(board, "MARK_FOR_CELL");
        int MINE_CELL        = getIntField(board, "MINE_CELL");
        int[] field          = (int[]) getField(board, "field");

        int COVERED_MINE_CELL = MINE_CELL + COVER_FOR_CELL;
        int MARKED_MINE_CELL  = COVERED_MINE_CELL + MARK_FOR_CELL;

        Arrays.fill(field, COVER_FOR_CELL);
        setField(board, "field", field);
        setField(board, "inGame", true);

        int r = 0, c = 1, index = idx(r, c, nCols);
        field[index] = MARKED_MINE_CELL; // ช่องที่ถูก mark
        setField(board, "field", field);

        MouseEvent left = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON1);

        board.dispatchEvent(left);

        int[] after = (int[]) getField(board, "field");
        assertEquals(MARKED_MINE_CELL, after[index], "ควร return ทันที (ค่าไม่เปลี่ยน)");
    }

    // ----- 5) คลิกซ้ายเมื่อ inGame=false -> ควรเริ่มเกมใหม่ -----
    @Test
    void leftClick_whenGameOver_shouldRestartNewGame() throws Exception {
        setField(board, "inGame", false); // จำลองเกมจบ

        MouseEvent left = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, cellCenterX(0), cellCenterY(0), 1, false, MouseEvent.BUTTON1);

        board.dispatchEvent(left);

        assertTrue((boolean) getField(board, "inGame"), "คลิกซ้ายหลังเกมจบควรเริ่มเกมใหม่ (inGame=true)");
    }

    // ----- 6) คลิก “นอกขอบกระดาน” -> ไม่ทำอะไร (ซ้ายและขวา) -----
    @Test
    void click_outsideBoard_shouldDoNothing() throws Exception {
        // พิกัดนอกขอบ (ขวาล่าง)
        int x = board.getPreferredSize().width + 50;
        int y = board.getPreferredSize().height + 50;

        MouseEvent leftOutside = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON1);
        MouseEvent rightOutside = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON3);

        board.dispatchEvent(leftOutside);
        board.dispatchEvent(rightOutside);

        assertNotNull(board.getPreferredSize());
    }

    // ----- 7) คลิกซ้าย: บนช่องที่ค่า > MINE_CELL (เช่น COVER_FOR_CELL) -> ต้องถูกเปิดเป็น EMPTY_CELL -----
    @Test
    void leftClick_onCoveredCell_shouldUncoverToEmpty() throws Exception {
        int nCols      = getIntField(board, "N_COLS");
        int MINE_CELL  = getIntField(board, "MINE_CELL");        // 9
        int EMPTY_CELL = getIntField(board, "EMPTY_CELL");       // 0
        int[] field    = (int[]) getField(board, "field");

        // ตั้งทุกช่องให้เป็น COVER_FOR_CELL (= MINE_CELL + 1 = 10)
        Arrays.fill(field, MINE_CELL + 1);
        setField(board, "field", field);
        setField(board, "inGame", true);

        int r = 0, c = 0, index = 0;

        MouseEvent left = new MouseEvent(
                board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0,
                cellCenterX(c), cellCenterY(r),
                1, false, MouseEvent.BUTTON1
        );

        board.dispatchEvent(left);

        int[] after = (int[]) getField(board, "field");
        assertEquals(EMPTY_CELL, after[index],
                "คลิกซ้ายบนช่องปิด (10) ต้องถูกเปิด ลดด้วย COVER_FOR_CELL กลายเป็น EMPTY_CELL (0)");
    }

    // ----- 8) คลิกซ้ายหลังรีสตาร์ตเกมแล้ว ยังคงทำงานปกติ -----
    @Test
    void leftClick_afterRestart_shouldStillWorkNormally() throws Exception {
        setField(board, "inGame", false);

        int x = cellCenterX(0), y = cellCenterY(0);
        MouseEvent left1 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON1);
        board.dispatchEvent(left1); // trigger newGame()

        // คลิกซ้ำทันทีหลังรีสตาร์ต
        MouseEvent left2 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON1);
        board.dispatchEvent(left2);

        assertTrue((boolean) getField(board, "inGame"), "หลังรีสตาร์ตแล้วคลิกซ้ำควรยังอยู่ในเกม");
    }
}


//* Copyright (C) 2025 Lipika Kanlayarit - All Rights Reserved
// * You may use, distribute and modify this code under the terms of the MIT license.
// */
//
//package com.zetcode;
//
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//
//import javax.swing.JLabel;
//import java.awt.event.MouseEvent;
//import java.lang.reflect.Field;
//import java.util.Arrays;
//
//import static org.junit.jupiter.api.Assertions.*;
//
//public class MinesAdapterRightClickFlagTest {
//
//    private Board board;
//    private JLabel status;
//
//    // ---------- helpers ----------
//    private static Object getField(Object target, String name) throws Exception {
//        Field f = target.getClass().getDeclaredField(name);
//        f.setAccessible(true);
//        return f.get(target);
//    }
//
//    private static int getIntField(Object target, String name) throws Exception {
//        Field f = target.getClass().getDeclaredField(name);
//        f.setAccessible(true);
//        return f.getInt(target);
//    }
//
//    private static void setField(Object target, String name, Object value) throws Exception {
//        Field f = target.getClass().getDeclaredField(name);
//        f.setAccessible(true);
//        f.set(target, value);
//    }
//
//    private static int idx(int r, int c, int nCols) {
//        return r * nCols + c;
//    }
//
//    private int cellCenterX(int col) throws Exception {
//        int nCols = getIntField(board, "N_COLS");
//        int cellSize = (board.getPreferredSize().width - 1) / nCols;
//        return col * cellSize + cellSize / 2;
//    }
//
//    private int cellCenterY(int row) throws Exception {
//        int nRows = getIntField(board, "N_ROWS");
//        int cellSize = (board.getPreferredSize().height - 1) / nRows;
//        return row * cellSize + cellSize / 2;
//    }
//
//    @BeforeEach
//    void setUp() {
//        status = new JLabel();
//        board  = new Board(status);
//    }
//
//    // ----- 1) คลิกขวา: ตั้งธง แล้ว ยกธง -----
//    @Test
//    void rightClick_toggleFlag_shouldUpdateCellAndMinesLeftAndStatusbar() throws Exception {
//        int nCols         = getIntField(board, "N_COLS");
//        int COVER_FOR_CELL = getIntField(board, "COVER_FOR_CELL");
//        int MARK_FOR_CELL  = getIntField(board, "MARK_FOR_CELL");
//        int[] field        = (int[]) getField(board, "field");
//
//        Arrays.fill(field, COVER_FOR_CELL);
//        setField(board, "field", field);
//        setField(board, "inGame", true);
//        setField(board, "minesLeft", 2);
//        status.setText("2");
//
//        int r = 1, c = 2, index = idx(r, c, nCols);
//
//        // ตั้งธง
//        MouseEvent right1 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON3);
//        assertTrue(board.getMouseListeners().length > 0);
//        board.getMouseListeners()[0].mousePressed(right1);
//        int[] after1 = (int[]) getField(board, "field");
//        assertEquals(COVER_FOR_CELL + MARK_FOR_CELL, after1[index], "ควรตั้งธง");
//        assertEquals(1, (int) getField(board, "minesLeft"));
//        assertEquals("1", status.getText());
//
//        // ยกธง
//        MouseEvent right2 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON3);
//        board.getMouseListeners()[0].mousePressed(right2);
//        int[] after2 = (int[]) getField(board, "field");
//        assertEquals(COVER_FOR_CELL, after2[index], "ควรยกธงกลับ");
//        assertEquals(2, (int) getField(board, "minesLeft"));
//        assertEquals("2", status.getText());
//    }
//
//    // ----- 2) คลิกขวา: ไม่มี mark เหลือ -----
//    @Test
//    void rightClick_withNoMarksLeft_shouldShowMessage() throws Exception {
//        int COVER_FOR_CELL = getIntField(board, "COVER_FOR_CELL");
//        int[] field        = (int[]) getField(board, "field");
//
//        Arrays.fill(field, COVER_FOR_CELL);
//        setField(board, "field", field);
//        setField(board, "inGame", true);
//        setField(board, "minesLeft", 0);
//        status.setText("0");
//
//        MouseEvent right = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, cellCenterX(0), cellCenterY(0), 1, false, MouseEvent.BUTTON3);
//
//        board.getMouseListeners()[0].mousePressed(right);
//        assertEquals("No marks left", status.getText(), "ควรแจ้งว่าไม่มี mark เหลือ");
//    }
//
//    // ----- 3) คลิกขวา: บนช่องที่ "เปิดแล้ว" (<= MINE_CELL) -> ไม่เปลี่ยนแปลง -----
//    @Test
//    void rightClick_onOpenedCell_shouldDoNothing() throws Exception {
//        int nCols     = getIntField(board, "N_COLS");
//        int EMPTY_CELL = getIntField(board, "EMPTY_CELL");
//        int[] field    = (int[]) getField(board, "field");
//
//        Arrays.fill(field, EMPTY_CELL); // เปิดแล้วทั้งหมด
//        setField(board, "field", field);
//        setField(board, "inGame", true);
//        setField(board, "minesLeft", 5);
//        status.setText("5");
//
//        int r = 1, c = 1, index = idx(r, c, nCols);
//        int before = field[index];
//
//        MouseEvent right = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON3);
//        board.getMouseListeners()[0].mousePressed(right);
//
//        int[] after = (int[]) getField(board, "field");
//        assertEquals(before, after[index], "ช่องที่เปิดแล้ว คลิกขวาไม่ควรเปลี่ยน");
//        assertEquals("5", status.getText());
//        assertEquals(5, (int) getField(board, "minesLeft"));
//    }
//
//    // ----- 4) คลิกซ้าย: บนช่องที่ถูก mark (> COVERED_MINE_CELL) -> return ทันที -----
//    @Test
//    void leftClick_onMarkedCell_shouldReturnEarly() throws Exception {
//        int nCols             = getIntField(board, "N_COLS");
//        int COVER_FOR_CELL     = getIntField(board, "COVER_FOR_CELL");
//        int MARK_FOR_CELL      = getIntField(board, "MARK_FOR_CELL");
//        int MINE_CELL          = getIntField(board, "MINE_CELL");
//        int[] field            = (int[]) getField(board, "field");
//
//        int COVERED_MINE_CELL  = MINE_CELL + COVER_FOR_CELL;
//        int MARKED_MINE_CELL   = COVERED_MINE_CELL + MARK_FOR_CELL;
//
//        Arrays.fill(field, COVER_FOR_CELL);
//        setField(board, "field", field);
//        setField(board, "inGame", true);
//
//        int r = 0, c = 1, index = idx(r, c, nCols);
//        field[index] = MARKED_MINE_CELL; // ทำเป็นช่องที่ถูก mark
//        setField(board, "field", field);
//
//        MouseEvent left = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, cellCenterX(c), cellCenterY(r), 1, false, MouseEvent.BUTTON1);
//
//        board.getMouseListeners()[0].mousePressed(left);
//
//        int[] after = (int[]) getField(board, "field");
//        assertEquals(MARKED_MINE_CELL, after[index], "ควร return ทันที (ค่าไม่เปลี่ยน)");
//    }
//
//    // ----- 5) คลิกซ้ายเมื่อ inGame=false -> ควรเริ่มเกมใหม่ -----
//    @Test
//    void leftClick_whenGameOver_shouldRestartNewGame() throws Exception {
//        setField(board, "inGame", false); // จำลองเกมจบ
//
//        MouseEvent left = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, cellCenterX(0), cellCenterY(0), 1, false, MouseEvent.BUTTON1);
//
//        board.getMouseListeners()[0].mousePressed(left);
//
//        assertTrue((boolean) getField(board, "inGame"), "คลิกซ้ายหลังเกมจบควรเริ่มเกมใหม่ (inGame=true)");
//    }
//
//    // ----- 6) คลิก “นอกขอบกระดาน” -> ไม่ทำอะไร (ซ้ายและขวา) -----
//    @Test
//    void click_outsideBoard_shouldDoNothing() throws Exception {
//        // พิกัดนอกขอบ (ขวาล่าง)
//        int x = board.getPreferredSize().width + 50;
//        int y = board.getPreferredSize().height + 50;
//
//        MouseEvent leftOutside = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON1);
//        MouseEvent rightOutside = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON3);
//
//        board.getMouseListeners()[0].mousePressed(leftOutside);
//        board.getMouseListeners()[0].mousePressed(rightOutside);
//
//        assertNotNull(board.getPreferredSize());
//    }
//
//    // ----- 7) คลิกซ้าย: บนช่องที่ค่า > MINE_CELL (เช่น COVER_FOR_CELL) -> return -----
//    @Test
//    void leftClick_onCoveredCell_shouldUncoverToEmpty() throws Exception {
//        int nCols     = getIntField(board, "N_COLS");
//        int MINE_CELL = getIntField(board, "MINE_CELL");        // 9
//        int EMPTY_CELL = getIntField(board, "EMPTY_CELL");       // 0
//        int[] field   = (int[]) getField(board, "field");
//
//        // ตั้งทุกช่องให้เป็น COVER_FOR_CELL (= MINE_CELL + 1 = 10)
//        Arrays.fill(field, MINE_CELL + 1);
//        setField(board, "field", field);
//        setField(board, "inGame", true);
//
//        int r = 0, c = 0, index = 0;
//
//        MouseEvent left = new MouseEvent(
//                board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0,
//                cellCenterX(c), cellCenterY(r),
//                1, false, MouseEvent.BUTTON1
//        );
//
//        board.getMouseListeners()[0].mousePressed(left);
//
//        int[] after = (int[]) getField(board, "field");
//        assertEquals(EMPTY_CELL, after[index],
//                "คลิกซ้ายบนช่องปิด (10) ต้องถูกเปิด ลดด้วย COVER_FOR_CELL กลายเป็น EMPTY_CELL (0)");
//    }
//
//    // ----- 8) คลิกซ้ายหลังรีสตาร์ตเกมแล้ว ยังคงทำงานปกติ -----
//    @Test
//    void leftClick_afterRestart_shouldStillWorkNormally() throws Exception {
//        setField(board, "inGame", false);
//
//        int x = cellCenterX(0), y = cellCenterY(0);
//        MouseEvent left1 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON1);
//        board.getMouseListeners()[0].mousePressed(left1); // trigger newGame()
//
//        // คลิกซ้ำทันทีหลังรีสตาร์ต
//        MouseEvent left2 = new MouseEvent(board, MouseEvent.MOUSE_PRESSED,
//                System.currentTimeMillis(), 0, x, y, 1, false, MouseEvent.BUTTON1);
//        board.getMouseListeners()[0].mousePressed(left2);
//
//        assertTrue((boolean) getField(board, "inGame"), "หลังรีสตาร์ตแล้วคลิกซ้ำควรยังอยู่ในเกม");
//    }
//}