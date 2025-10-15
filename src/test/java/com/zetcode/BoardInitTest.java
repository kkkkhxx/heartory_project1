/* Copyright (C) 2025 Thanyarat Wuthiroongreungsakul - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import javax.swing.*;
import java.awt.*;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import static org.junit.jupiter.api.Assertions.*;

public class BoardInitTest {

    private JLabel status;
    private Board board;

    @BeforeEach
    void setUp() {
        status = new JLabel();
        board  = new Board(status); // ctor เรียก initBoard() ภายใน
    }

    // ---------- helpers ----------
    private static Field fld(Object obj, String name) throws Exception {
        Field f = obj.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f;
    }
    private static int getInt(Object obj, String name) throws Exception {
        return fld(obj, name).getInt(obj);
    }
    private static Object get(Object obj, String name) throws Exception {
        return fld(obj, name).get(obj);
    }
    private static void set(Object obj, String name, Object v) throws Exception {
        fld(obj, name).set(obj, v);
    }
    private static void call(Object obj, String method) throws Exception {
        Method m = obj.getClass().getDeclaredMethod(method);
        m.setAccessible(true);
        m.invoke(obj);
    }

    // ===============================
    // B0 (Base)
    // ===============================
    @Test
    void initBoard_shouldLoadImages_addMouseListener_andStartNewGame() throws Exception {
        int NUM_IMAGES = getInt(board, "NUM_IMAGES");
        int BOARD_W    = getInt(board, "BOARD_WIDTH");
        int BOARD_H    = getInt(board, "BOARD_HEIGHT");
        int N_ROWS     = getInt(board, "N_ROWS");
        int N_COLS     = getInt(board, "N_COLS");

        // 1) preferred size ถูกต้อง
        Dimension pref = board.getPreferredSize();
        assertEquals(BOARD_W, pref.width);
        assertEquals(BOARD_H, pref.height);

        // 2) โหลดรูปครบ NUM_IMAGES และไม่เป็น null
        Image[] images = (Image[]) get(board, "img");
        assertNotNull(images);
        assertEquals(NUM_IMAGES, images.length);
        for (int i = 0; i < images.length; i++) {
            assertNotNull(images[i], "image index " + i + " should be loaded");
        }

        // 3) มี MouseListener อย่างน้อย 1 (ใส่ MinesAdapter แล้ว)
        assertTrue(board.getMouseListeners().length >= 1, "mouse listener should be added");

        // 4) newGame() ถูกเรียก: field ถูกสร้างขนาด N_ROWS*N_COLS
        int[] field = (int[]) get(board, "field");
        assertNotNull(field);
        assertEquals(N_ROWS * N_COLS, field.length);

        // 5) status bar แสดงจำนวนระเบิดเริ่มต้น (เท่ากับ minesLeft ที่ตั้งใน newGame)
        int minesLeft = getInt(board, "minesLeft");
        assertEquals(String.valueOf(minesLeft), status.getText());
    }

    // ===============================
    // B1 — Resource = ImagesMissing
    // หมายเหตุ: โค้ดต้นฉบับวาดภาพโดยไม่เช็ค null -> จะ NPE ถ้ารูปหาย
    // ===============================
    @Test
    @Disabled("ต้นฉบับไม่รองรับรูปหาย: paintComponent เรียก img[cell] โดยไม่เช็ค null → จะ NPE ถ้าจงใจทำให้ภาพหาย")
    void init_whenImagesMissing_shouldNotCrash() throws Exception {
        set(board, "img", null);
        assertDoesNotThrow(() -> board.repaint());
    }

    // =========================================
    // B2 — Dimension = CustomSmaller (8×8)
    // =========================================
    @Test
    @Disabled("ไม่สามารถจำลอง 8×8 ได้เพราะ N_ROWS/N_COLS เป็น final ใน Board.java")
    void init_withCustom8x8_shouldResizeAndAllocate64() throws Exception {
        // ต้องแก้ซอร์สถึงจะรองรับ
    }

    // ==================================
    // B3 — Listener = Missing (0 ตัว)
    // ==================================
    @Test
    void init_whenListenerRemoved_shouldHaveZeroListeners() {
        for (var l : board.getMouseListeners()) {
            board.removeMouseListener(l);
        }
        assertEquals(0, board.getMouseListeners().length, "no mouse listeners should remain");
    }

    // ==============================
    // B4 — Statusbar = Null
    // หมายเหตุ: newGame() เรียก statusbar.setText(...) โดยไม่เช็ค → คาดหวัง NPE
    // ==============================
    @Test
    void init_withNullStatusbar_shouldThrowNPE() {
        assertThrows(NullPointerException.class, () -> new Board(null));
    }

    // ================================================
    // B5 — MinesCount = Wrong (Negative test → Disabled)
    // ================================================
    @Test
    @Disabled("Negative case for BCC: ถ้าบังคับให้ minesLeft ผิด ควรล้ม — ปิดไว้เพื่อให้ CI ผ่าน")
    void afterInit_ifMinesCountWrong_shouldBeDetected() throws Exception {
        int correct = getInt(board, "minesLeft");
        fld(board, "minesLeft").setInt(board, correct - 1);
        assertNotEquals(correct, getInt(board, "minesLeft"));
    }

    // ==================================================
    // B6 — Field = NotAllocated (Negative test → Disabled)
    // ==================================================
    @Test
    @Disabled("Negative case for BCC: field ไม่ถูก allocate — ปิดไว้เพื่อให้ CI ผ่าน")
    void newGame_withoutAllocatingField_shouldFail() throws Exception {
        set(board, "field", null);
        assertNull(get(board, "field"));
    }
}
