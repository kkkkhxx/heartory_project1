/* Copyright (C) 2025 Wissawachit rungruang - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import javax.swing.JLabel;
import java.awt.Dimension;
import java.awt.event.MouseEvent;
import java.lang.reflect.Field;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;


public class MinesAdapterLosePathTest {

    // ===== constants ต้องสอดคล้องกับ Board =====
    private static final int N_ROWS = 16;
    private static final int N_COLS = 16;
    private static final int ALL_CELLS = N_ROWS * N_COLS;

    private static final int COVER_FOR_CELL = 10;
    private static final int MINE_CELL = 9;
    private static final int COVERED_MINE_CELL = MINE_CELL + COVER_FOR_CELL; // 19
    private static final int COVERED_NUMBER = COVER_FOR_CELL + 1;            // 11
    private static final int COVERED_ZERO   = COVER_FOR_CELL;                 // 10

    private Board board;
    private int[] field;

    private static int idx(int r, int c) { return r * N_COLS + c; }

    private static void setPrivateField(Object target, String name, Object value) throws Exception {
        Field f = target.getClass().getDeclaredField(name);
        f.setAccessible(true);
        f.set(target, value);
    }
    private static Object getPrivateField(Object target, String name) throws Exception {
        Field f = target.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.get(target);
    }

    @BeforeEach
    void setUp() throws Exception {
        board = new Board(new JLabel());

        // ทำทุกช่องเป็น "ศูนย์ปิด" (=10)
        field = new int[ALL_CELLS];
        Arrays.fill(field, COVER_FOR_CELL);

        setPrivateField(board, "field", field);
        setPrivateField(board, "allCells", ALL_CELLS);
        setPrivateField(board, "inGame", true);

        // ตรวจ preferred size เพื่อคำนวณ CELL_SIZE
        Dimension pref = board.getPreferredSize();
        assertNotNull(pref, "Preferred size ต้องไม่เป็น null");
        assertTrue(pref.width > 0 && pref.height > 0, "Preferred size ต้องมากกว่า 0");
    }

    // ===== helpers =====
    private int cellSize() {
        return (board.getPreferredSize().width - 1) / N_COLS;
    }
    private MouseEvent makeClick(int r, int c, int button) {
        int s = cellSize();
        int x = c * s + s / 2;
        int y = r * s + s / 2;
        return new MouseEvent(
                board,
                MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(),
                0,
                x, y,
                1,
                false,
                button
        );
    }
    private void installField() throws Exception {
        setPrivateField(board, "field", field);
    }
    private void putCoveredMine(int r, int c) {
        Arrays.fill(field, COVER_FOR_CELL);
        field[idx(r, c)] = COVERED_MINE_CELL;
    }
    private void putCoveredNumber(int r, int c) {
        Arrays.fill(field, COVER_FOR_CELL);
        field[idx(r, c)] = COVERED_NUMBER;
    }
    private void putCoveredZero(int r, int c) {
        Arrays.fill(field, COVER_FOR_CELL);
        field[idx(r, c)] = COVERED_ZERO;
    }

    // ===== MBCC: Base case C1 =====
    @Test
    @DisplayName("C1 (Base): Left + CoveredMine + Center(2,3) + inGame=true => Lose & open 9")
    void C1_base_left_click_on_covered_mine_center_loses() throws Exception {
        int r = 2, c = 3, mineIndex = idx(r, c);
        putCoveredMine(r, c);
        installField();

        assertTrue(board.getMouseListeners().length > 0, "ควรมี MouseListener ที่ถูก add แล้ว");
        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON1));

        boolean inGame = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        assertFalse(inGame, "ต้องแพ้: inGame=false");
        assertEquals(MINE_CELL, after[mineIndex], "ช่องเหมืองต้องถูกเปิดเป็น 9");
    }

    // ===== MBCC: C2 เปลี่ยน Mouse=Right =====
    @Test
    @DisplayName("C2: Right + CoveredMine + Center => ไม่แพ้ & ไม่เปิดเป็น 9")
    void C2_right_click_on_covered_mine_center_no_lose() throws Exception {
        int r = 2, c = 3, mineIndex = idx(r, c);
        putCoveredMine(r, c);
        installField();

        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON3));

        boolean inGame = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        assertTrue(inGame, "คลิกขวาไม่ควรแพ้");
        assertNotEquals(MINE_CELL, after[mineIndex], "ไม่ควรเปิดเป็น 9 ด้วยคลิกขวา");
    }

    // ===== MBCC: C3 เปลี่ยน Target=CoveredNumber =====
    @Test
    @DisplayName("C3: Left + CoveredNumber(=11) + Center => ไม่แพ้ & ไม่เปิดเป็น 9")
    void C3_left_click_on_covered_number_center_no_lose() throws Exception {
        int r = 2, c = 3, target = idx(r, c);
        putCoveredNumber(r, c);
        installField();

        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON1));

        boolean inGame = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        assertTrue(inGame, "คลิกเลขปิดไม่ควรแพ้");
        assertNotEquals(MINE_CELL, after[target], "เลขไม่ควรถูกเปิดเป็น 9");
    }

    // ===== MBCC: C4 เปลี่ยน Target=CoveredZero =====
    @Test
    @DisplayName("C4: Left + CoveredZero(=10) + Center => ไม่แพ้ & ไม่เปิดเป็น 9")
    void C4_left_click_on_covered_zero_center_no_lose() throws Exception {
        int r = 2, c = 3, target = idx(r, c);
        putCoveredZero(r, c);
        installField();

        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON1));

        boolean inGame = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        assertTrue(inGame, "คลิกศูนย์ปิดไม่ควรแพ้");
        assertNotEquals(MINE_CELL, after[target], "ศูนย์ไม่ควรถูกเปิดเป็น 9");
    }

    // ===== MBCC: C5 เปลี่ยน Location=Edge =====
    @Test
    @DisplayName("C5: Left + CoveredMine + Edge(0,5) => Lose & open 9 (ตรวจ mapping ขอบ)")
    void C5_left_click_on_covered_mine_edge_loses() throws Exception {
        int r = 0, c = 5, mineIndex = idx(r, c);
        putCoveredMine(r, c);
        installField();

        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON1));

        boolean inGame = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        assertFalse(inGame, "ต้องแพ้เมื่อคลิกเหมืองริมขอบ");
        assertEquals(MINE_CELL, after[mineIndex], "ต้องเปิดเป็น 9");
    }

    // ===== MBCC: C6 เปลี่ยน Location=Corner =====
    @Test
    @DisplayName("C6: Left + CoveredMine + Corner(0,0) => Lose & open 9 (ตรวจ mapping มุม)")
    void C6_left_click_on_covered_mine_corner_loses() throws Exception {
        int r = 0, c = 0, mineIndex = idx(r, c);
        putCoveredMine(r, c);
        installField();

        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON1));

        boolean inGame = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        assertFalse(inGame, "ต้องแพ้เมื่อคลิกเหมืองมุม");
        assertEquals(MINE_CELL, after[mineIndex], "ต้องเปิดเป็น 9");
    }

    // ===== MBCC: C7 เปลี่ยน inGame=false =====
    @Test
    @DisplayName("C7: Left + CoveredMine + Center แต่ inGame=false => รีสตาร์ตเกม (newGame)")
    void C7_left_click_on_covered_mine_center_when_game_over_restart_game() throws Exception {
        int r = 2, c = 3;
        int clickIndex = idx(r, c);

        // ใส่เหมืองไว้เดิม เพื่อยืนยันว่าเรามีสถานะก่อนรีสตาร์ต
        putCoveredMine(r, c);
        installField();

        // ทำให้เกมจบก่อนคลิก
        setPrivateField(board, "inGame", false);

        // เก็บ reference field เดิมไว้ เพื่อตรวจว่าหลังคลิกมีการรีอินิทจริง
        int[] before = (int[]) getPrivateField(board, "field");

        // คลิกซ้าย
        board.getMouseListeners()[0].mousePressed(makeClick(r, c, MouseEvent.BUTTON1));

        boolean inGameAfter = (boolean) getPrivateField(board, "inGame");
        int[] after = (int[]) getPrivateField(board, "field");

        // 1) ควรเริ่มเกมใหม่แล้ว
        assertTrue(inGameAfter, "เมื่อ inGame=false แล้วคลิกซ้าย ควรรีสตาร์ตเกม (inGame=true)");

        // 2) ฟิลด์ควรถูกรีอินิท (อาจเป็นอ็อบเจ็กต์ใหม่ หรืออย่างน้อยค่าตำแหน่งที่คลิกไม่จำเป็นต้องเท่าเดิม)
        //    ใช้การตรวจแบบหลวม ๆ: อ็อบเจ็กต์ field เปลี่ยน หรือ เนื้อหาเปลี่ยน
        boolean objectChanged = before != after;
        boolean contentChanged = !Arrays.equals(before, after);
        assertTrue(objectChanged || contentChanged, "คาดว่ามีการรีอินิทกระดานหลังรีสตาร์ต");

        // 3) ค่าที่ช่องที่คลิกหลังรีสตาร์ตไม่ควร assert เป็น 9/19 เพราะสุ่มเหมืองใหม่
        //    ตรวจแบบอนุรักษ์นิยมว่า "มันเป็นสถานะที่ถูกต้องของช่องปิด" (>= 10) หรือ "เปิดเลข" (<=9) ก็ได้ทั้งคู่
        //    แต่เพื่อหลีกเลี่ยง false-negative เลือกตรวจแค่ว่า 'after' มีขนาดถูกต้อง
        assertEquals(ALL_CELLS, after.length, "ความยาว field หลังรีสตาร์ตต้องถูกต้อง");
    }
}
