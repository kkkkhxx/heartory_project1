/* Copyright (C) 2025 Wissawachit rungruang - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.JLabel;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

class FindEmptyCellsTest {

    // ===== constants ต้องสอดคล้องกับ Board =====
    private static final int N_ROWS = 16;
    private static final int N_COLS = 16;
    private static final int ALL_CELLS = N_ROWS * N_COLS;

    private static final int COVER_FOR_CELL = 10;
    private static final int MINE_CELL = 9;
    private static final int COVERED_MINE_CELL = MINE_CELL + COVER_FOR_CELL; // 19
    private static final int EMPTY_CELL = 0;

    private Board board;
    private int[] field;

    private static int idx(int r, int c) { return r * N_COLS + c; }

    // ===== reflection helpers =====
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
    private static void invokeFindEmpty(Board b, int start) throws Exception {
        Method m = Board.class.getDeclaredMethod("find_empty_cells", int.class);
        m.setAccessible(true);
        m.invoke(b, start);
    }

    @BeforeEach
    void setUp() throws Exception {
        board = new Board(new JLabel());

        // กระดานเริ่มต้น: ศูนย์ปิดทั้งหมด
        field = new int[ALL_CELLS];
        Arrays.fill(field, COVER_FOR_CELL);

        // วางเหมืองที่ (0,0) และทำขอบเขตเป็นเลข 1 แบบปิด (=11)
        field[idx(0,0)] = COVERED_MINE_CELL;
        for (int n : new int[]{ idx(0,1), idx(1,0), idx(1,1) }) {
            field[n] = COVER_FOR_CELL + 1;
        }

        setPrivateField(board, "field", field);
        setPrivateField(board, "allCells", ALL_CELLS);
        setPrivateField(board, "inGame", true);
    }

    // 1) เคสกลางกระดาน: รวมทั้ง false-branch (เพื่อนบ้านเปิดอยู่แล้ว),
    //    true-branch แบบ "เปิดเลขแล้วไม่ขยาย", และ true-branch แบบ "ศูนย์แล้วขยาย"
    @Test
    void center_mixed_neighbors_cover_all_inner_paths() throws Exception {
        int r = 8, c = 8, s = idx(r, c);

        // เปิดจุดเริ่ม (จำลองคลิกซ้าย)
        field[s] = COVER_FOR_CELL; field[s] -= COVER_FOR_CELL;

        // false branches (เพื่อนบ้านเปิดอยู่แล้ว <=9)
        field[idx(r, c - 1)] = EMPTY_CELL; // W = 0
        field[idx(r - 1, c)] = 1;          // N = 1

        // true branch + ไม่ขยาย (เลข 1 ปิด = 11)
        field[idx(r, c + 1)] = COVER_FOR_CELL + 1;   // E
        field[idx(r - 1, c + 1)] = COVER_FOR_CELL + 1; // NE

        // true branch + ขยาย (ศูนย์ปิด = 10)
        field[idx(r + 1, c - 1)] = COVER_FOR_CELL;   // SW
        field[idx(r + 1, c + 1)] = COVER_FOR_CELL;   // SE

        setPrivateField(board, "field", field);
        invokeFindEmpty(board, s);

        int[] a = (int[]) getPrivateField(board, "field");
        assertEquals(EMPTY_CELL, a[s]);
        assertEquals(EMPTY_CELL, a[idx(r, c - 1)]);     // false-branch: คงเดิม
        assertEquals(1,           a[idx(r - 1, c)]);    // false-branch: คงเดิม
        assertEquals(1,           a[idx(r, c + 1)]);    // เปิดเลข 1
        assertEquals(1,           a[idx(r - 1, c + 1)]);// เปิดเลข 1
        assertEquals(EMPTY_CELL,  a[idx(r + 1, c - 1)]);// เปิดศูนย์+ขยาย
        assertEquals(EMPTY_CELL,  a[idx(r + 1, c + 1)]);// เปิดศูนย์+ขยาย
        assertEquals(COVERED_MINE_CELL, a[idx(0,0)]);   // เหมืองยังปิด
    }

    // 2) ขอบบน/ล่าง: boundary false ทั้ง N และ S
    @Test
    void top_boundary_false_up_center() throws Exception {
        int r = 0, c = 8, s = idx(r, c);
        field[s] = COVER_FOR_CELL; field[s] -= COVER_FOR_CELL;
        setPrivateField(board, "field", field);
        invokeFindEmpty(board, s);
        int[] a = (int[]) getPrivateField(board, "field");
        assertEquals(EMPTY_CELL, a[s]);
        assertEquals(COVERED_MINE_CELL, a[idx(0,0)]);
    }
    @Test
    void bottom_boundary_false_down_center() throws Exception {
        int r = N_ROWS - 1, c = 8, s = idx(r, c);
        field[s] = COVER_FOR_CELL; field[s] -= COVER_FOR_CELL;
        setPrivateField(board, "field", field);
        invokeFindEmpty(board, s);
        int[] a = (int[]) getPrivateField(board, "field");
        assertEquals(EMPTY_CELL, a[s]);
        assertEquals(COVERED_MINE_CELL, a[idx(0,0)]);
    }

    // 3) ปิดกลุ่มซ้าย/ขวา (outer if)
    @Test
    void leftmost_disables_left_group() throws Exception {
        int r = 8, c = 0, s = idx(r, c);
        field[s] = COVER_FOR_CELL; field[s] -= COVER_FOR_CELL;
        setPrivateField(board, "field", field);
        invokeFindEmpty(board, s);
        int[] a = (int[]) getPrivateField(board, "field");
        assertEquals(EMPTY_CELL, a[s]);
        assertEquals(COVERED_MINE_CELL, a[idx(0,0)]);
    }
    @Test
    void rightmost_disables_right_group() throws Exception {
        int r = 8, c = N_COLS - 1, s = idx(r, c);
        field[s] = COVER_FOR_CELL; field[s] -= COVER_FOR_CELL;
        setPrivateField(board, "field", field);
        invokeFindEmpty(board, s);
        int[] a = (int[]) getPrivateField(board, "field");
        assertEquals(EMPTY_CELL, a[s]);
        assertEquals(COVERED_MINE_CELL, a[idx(0,0)]);
    }

    // 4) มุม/ใกล้มุม: ยิง boundary false ของทแยงต่าง ๆ แบบสั้น ๆ
    @Test
    void corners_boundaries_false_compact() throws Exception {
        int[][] starts = {
                {0,5},            // up-left fail path active
                {0,N_COLS-2},     // up-right fail path active
                {N_ROWS-1,1},     // down-left fail path active
                {N_ROWS-1,N_COLS-2} // down-right fail path active
        };
        for (int[] rc : starts) {
            int s = idx(rc[0], rc[1]);
            // รีเซ็ตฟิลด์ให้เป็นสภาพเริ่ม (หลีกเลี่ยงอิทธิพลจากรอบก่อน)
            Arrays.fill(field, COVER_FOR_CELL);
            field[idx(0,0)] = COVERED_MINE_CELL;
            for (int n : new int[]{ idx(0,1), idx(1,0), idx(1,1) }) field[n] = COVER_FOR_CELL + 1;
            setPrivateField(board, "field", field);

            field[s] -= COVER_FOR_CELL; // เปิด start
            setPrivateField(board, "field", field);
            invokeFindEmpty(board, s);

            int[] a = (int[]) getPrivateField(board, "field");
            assertEquals(EMPTY_CELL, a[s]);
            assertEquals(COVERED_MINE_CELL, a[idx(0,0)]);
        }
    }
}
