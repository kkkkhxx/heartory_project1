/* Copyright (C) 2025 Thanyarat Wuthiroongreungsakul - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.JLabel;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.lang.reflect.Field;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

public class MinesAdapterWinPathTest {

    // ค่าคงที่ตามเกม ZetCode
    private static final int N_ROWS = 16;
    private static final int N_COLS = 16;
    private static final int ALL_CELLS = N_ROWS * N_COLS;

    private static final int COVER_FOR_CELL = 10;
    private static final int MINE_CELL = 9;
    private static final int COVERED_MINE_CELL = MINE_CELL + COVER_FOR_CELL; // 19
    private static final int OPEN_EMPTY = 0; // ช่องเปิดแล้วและไม่มีเลข (0)

    private Board board;
    private int[] field;

    private static int idx(int r, int c) {
        return r * N_COLS + c;
    }

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

        // จัดฉาก: ให้ "ชนะได้ทันทีเมื่อเปิดช่องสุดท้าย"
        // ทุกช่องเปิดแล้ว (0) เหลือเพียง 1 ช่องที่ยังปิดอยู่และเป็น non-mine
        field = new int[ALL_CELLS];
        Arrays.fill(field, OPEN_EMPTY);

        int lastR = 1, lastC = 1; // ช่องสุดท้ายที่จะคลิก
        field[idx(lastR, lastC)] = COVER_FOR_CELL + 0; // ปิดอยู่ แต่ไม่ใช่เหมือง

        // ยัดค่าลงบอร์ดด้วย reflection
        setPrivateField(board, "field", field);
        setPrivateField(board, "allCells", ALL_CELLS);
        setPrivateField(board, "inGame", true);

        // ตรวจ preferred size (ใช้คำนวณขนาดเซลล์)
        Dimension pref = board.getPreferredSize();
        assertNotNull(pref, "Preferred size ต้องไม่เป็น null");
        assertTrue(pref.width > 0 && pref.height > 0, "Preferred size ต้องมีขนาดมากกว่า 0");
    }

    @Test
    void leftClickOnLastCoveredSafeCell_causesWin_andNoCoveredSafeCellsRemain() throws Exception {
        // ช่องที่จะคลิก (ต้องตรงกับ setUp)
        int lastR = 1, lastC = 1;
        int lastIndex = idx(lastR, lastC);

        // คำนวณขนาดเซลล์จาก preferred size: width = N_COLS * CELL_SIZE + 1
        int cellSize = (board.getPreferredSize().width - 1) / N_COLS;
        int x = lastC * cellSize + cellSize / 2;
        int y = lastR * cellSize + cellSize / 2;

        // คลิกซ้ายที่ช่องสุดท้าย
        MouseEvent press = new MouseEvent(
                board,
                MouseEvent.MOUSE_PRESSED,
                System.currentTimeMillis(),
                0,
                x, y,
                1,
                false,
                MouseEvent.BUTTON1
        );

        assertTrue(board.getMouseListeners().length > 0, "ควรมี MouseListener ที่ถูก add แล้ว");
        board.getMouseListeners()[0].mousePressed(press);

        // เรียกวาดหนึ่งเฟรม (paintComponent จะคำนวณจาก field ปัจจุบัน)
        BufferedImage img = new BufferedImage(
                board.getPreferredSize().width,
                board.getPreferredSize().height,
                BufferedImage.TYPE_INT_ARGB
        );
        Graphics2D g2 = img.createGraphics();
        try {
            board.paint(g2);
        } finally {
            g2.dispose();
        }

        // ---- ตรวจผล "ชนะ" (เวอร์ชันนี้ไม่ตั้ง inGame=false เมื่อชนะ จึงไม่เช็ค inGame) ----

        // 1) ช่องที่คลิกควรถูก "เปิด" แล้ว (ค่าต้องไม่เกิน MINE_CELL)
        int[] after = (int[]) getPrivateField(board, "field");
        assertTrue(after[lastIndex] <= MINE_CELL,
                "ช่องสุดท้ายควรถูกเปิด (ค่าไม่ควรมากกว่า " + MINE_CELL + ")");

        // 2) ต้องไม่เหลือ "ช่องปลอดภัยที่ยังปิดอยู่"
        int coveredSafe = 0;
        for (int v : after) {
            boolean covered = v > MINE_CELL;                 // มี +COVER_FOR_CELL
            boolean coveredMine = (v == COVERED_MINE_CELL);  // เหมืองที่ยังปิดอยู่ ไม่ถือเป็น safe
            if (covered && !coveredMine) coveredSafe++;
        }
        assertEquals(0, coveredSafe, "ต้องไม่เหลือ covered safe cell หลังชนะ");
    }
}
