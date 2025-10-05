package com.zetcode;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;

import javax.swing.*;
import java.awt.*;
import java.lang.reflect.Field;

import static org.junit.jupiter.api.Assertions.*;

public class BoardInitTest {

    private JLabel status;
    private Board board;

    @BeforeEach
    void setUp() {
        status = new JLabel();
        board = new Board(status); // ctor เรียก initBoard() ภายใน
    }

    @Test
    void initBoard_shouldLoadImages_addMouseListener_andStartNewGame() throws Exception {
        Class<?> cls = board.getClass();

        // ---- สะท้อนค่าคงที่/ฟิลด์ที่ต้องเช็ค ----
        Field fNumImages = cls.getDeclaredField("NUM_IMAGES");
        Field fCellSize  = cls.getDeclaredField("CELL_SIZE");
        Field fRows      = cls.getDeclaredField("N_ROWS");
        Field fCols      = cls.getDeclaredField("N_COLS");
        Field fBoardW    = cls.getDeclaredField("BOARD_WIDTH");
        Field fBoardH    = cls.getDeclaredField("BOARD_HEIGHT");
        Field fImg       = cls.getDeclaredField("img");
        Field fField     = cls.getDeclaredField("field");
        Field fMinesLeft = cls.getDeclaredField("minesLeft");

        fNumImages.setAccessible(true);
        fCellSize.setAccessible(true);
        fRows.setAccessible(true);
        fCols.setAccessible(true);
        fBoardW.setAccessible(true);
        fBoardH.setAccessible(true);
        fImg.setAccessible(true);
        fField.setAccessible(true);
        fMinesLeft.setAccessible(true);

        int NUM_IMAGES = fNumImages.getInt(board);
        int CELL_SIZE  = fCellSize.getInt(board);
        int N_ROWS     = fRows.getInt(board);
        int N_COLS     = fCols.getInt(board);
        int BOARD_W    = fBoardW.getInt(board);
        int BOARD_H    = fBoardH.getInt(board);

        // 1) preferred size ถูกต้อง
        Dimension pref = board.getPreferredSize();
        assertEquals(BOARD_W, pref.width);
        assertEquals(BOARD_H, pref.height);

        // 2) โหลดรูปครบ 13 และไม่เป็น null
        Image[] images = (Image[]) fImg.get(board);
        assertNotNull(images);
        assertEquals(NUM_IMAGES, images.length);
        for (int i = 0; i < images.length; i++) {
            assertNotNull(images[i], "image index " + i + " should be loaded");
        }

        // 3) มี MouseListener อย่างน้อย 1 (ใส่ MinesAdapter แล้ว)
        assertTrue(board.getMouseListeners().length >= 1, "mouse listener should be added");

        // 4) newGame() ถูกเรียก: field ถูกสร้างขนาด N_ROWS*N_COLS
        int[] field = (int[]) fField.get(board);
        assertNotNull(field);
        assertEquals(N_ROWS * N_COLS, field.length);

        // 5) status bar แสดงจำนวนระเบิดเริ่มต้น (เท่ากับ minesLeft ที่ตั้งใน newGame)
        int minesLeft = fMinesLeft.getInt(board);
        assertEquals(String.valueOf(minesLeft), status.getText());
    }
}
