package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.JLabel;
import java.awt.Dimension;
import java.awt.event.MouseEvent;
import java.lang.reflect.Field;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

public class MinesAdapterLosePathTest {

    // ค่าคงที่ตามคลาส Board (ไม่ expose จึงคำนวณ/กำหนดเอง)
    private static final int N_ROWS = 16;
    private static final int N_COLS = 16;
    private static final int ALL_CELLS = N_ROWS * N_COLS;

    private static final int COVER_FOR_CELL = 10;
    private static final int MINE_CELL = 9;
    private static final int COVERED_MINE_CELL = MINE_CELL + COVER_FOR_CELL; // 19

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

        // ทำทุกช่องเป็น "ศูนย์ปิด" (=10)
        field = new int[ALL_CELLS];
        Arrays.fill(field, COVER_FOR_CELL);

        // วาง “เหมืองปิด” 1 จุด (เลือกตำแหน่งที่คลิกง่าย เช่น (2,3))
        int mineR = 2, mineC = 3;
        field[idx(mineR, mineC)] = COVERED_MINE_CELL;

        // ใส่ค่าเข้า Board ด้วย reflection
        setPrivateField(board, "field", field);
        setPrivateField(board, "allCells", ALL_CELLS);
        setPrivateField(board, "inGame", true);

        // ให้บอร์ดมี preferred size ตามคลาสจริง (เพื่อคำนวณ CELL_SIZE จากขนาด)
        // Board.initBoard() ตั้งไว้แล้ว แต่เราเรียกอีกรอบให้ชัวร์
        Dimension pref = board.getPreferredSize();
        assertNotNull(pref, "Preferred size ต้องไม่เป็น null");
        assertTrue(pref.width > 0 && pref.height > 0, "Preferred size ต้องมีขนาดมากกว่า 0");
    }

    @Test
    void leftClickOnCoveredMine_causesLose_andOpensMineCell() throws Exception {
        // ระบุจุดเหมืองเดียวกับ setUp
        int mineR = 2, mineC = 3;
        int mineIndex = idx(mineR, mineC);

        // คำนวณ CELL_SIZE จาก preferred size:
        // width = N_COLS * CELL_SIZE + 1  =>  CELL_SIZE = (width - 1) / N_COLS
        int cellSize = (board.getPreferredSize().width - 1) / N_COLS;

        // สร้างพิกัดพิกเซลให้ตก “กลางช่อง” (หลีกเลี่ยงขอบ)
        int x = mineC * cellSize + cellSize / 2;
        int y = mineR * cellSize + cellSize / 2;

        // สร้าง MouseEvent แบบ "คลิกซ้าย"
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

        // ส่ง event เข้า mouse listener ตัวแรก (คือ Board$MinesAdapter)
        assertTrue(board.getMouseListeners().length > 0, "ควรมี MouseListener ที่ถูก add แล้ว");
        board.getMouseListeners()[0].mousePressed(press);

        // ตรวจ inGame ต้อง false (แพ้)
        boolean inGame = (boolean) getPrivateField(board, "inGame");
        assertFalse(inGame, "คลิกเหมืองต้องแพ้: inGame ควรเป็น false");

        // ตรวจค่าช่องที่คลิก ต้องถูกเปิดเป็น MINE_CELL (=9)
        int[] after = (int[]) getPrivateField(board, "field");
        assertEquals(MINE_CELL, after[mineIndex],
                "ช่องเหมืองหลังคลิกต้องถูกเปิด (ค่าควรเท่ากับ 9)");
    }
}
