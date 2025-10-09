/* Copyright (C) 2025 Lipika Kanlayarit - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import javax.swing.JLabel;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;

class BoardNewGameTest {

    private JLabel status;
    private Board board;

    @BeforeEach
    void setUp() {
        status = new JLabel();
        board = new Board(status); // ctor เรียก newGame() อยู่แล้ว
    }

    @Test
    @DisplayName("newGame(): reset กระดาน วางเหมืองครบ อัปเดตสถานะ และ inGame=true")
    void newGame_shouldResetFieldSize_PlaceExactly40Mines_UpdateStatus() throws Exception {
        // เรียกอีกรอบให้แน่ใจว่าเป็น state เริ่มเกมใหม่
        invokeNoArg(board, "newGame");

        // --- อ่านค่าคงที่ (เป็น instance fields ใน Board) ---
        int N_ROWS = readInstanceInt(board, "N_ROWS");
        int N_COLS = readInstanceInt(board, "N_COLS");
        int N_MINES = readInstanceInt(board, "N_MINES");
        int COVERED_MINE_CELL = readInstanceInt(board, "COVERED_MINE_CELL");

        // --- อ่านกระดาน ---
        int[] field = (int[]) readInstance(board, "field");

        // นับจำนวนเหมือง
        long mineCount = Arrays.stream(field).filter(v -> v == COVERED_MINE_CELL).count();

        // สถานะ inGame
        boolean inGame = (boolean) readInstance(board, "inGame");

        // รวม assertions ไว้ด้วยกัน อ่านง่ายและรายงานครบ
        assertAll(
                // 1) field ต้องมีความยาว N_ROWS * N_COLS
                () -> assertEquals(N_ROWS * N_COLS, field.length, "field length ไม่ตรง N_ROWS*N_COLS"),

                // 2) ต้องวางเหมืองครบ N_MINES (ค่าของเหมือง = COVERED_MINE_CELL)
                () -> assertEquals(N_MINES, mineCount, "จำนวนเหมืองหลัง newGame() ไม่เท่ากับ N_MINES"),

                // 3) statusbar ต้องอัปเดตเป็นจำนวนเหมืองที่เหลือ เท่ากับ N_MINES
                () -> assertEquals(String.valueOf(N_MINES), status.getText(), "statusbar ไม่อัปเดตเป็นจำนวนเหมืองที่เหลือ"),

                // 4) เริ่มเกมต้อง inGame = true
                () -> assertTrue(inGame, "ควรเริ่มเกมในสถานะ inGame = true")
        );
    }

    // ---------- helpers ----------
    private static void invokeNoArg(Object target, String name) throws Exception {
        Method m = target.getClass().getDeclaredMethod(name);
        m.setAccessible(true);
        m.invoke(target);
    }

    private static Object readInstance(Object obj, String name) throws Exception {
        Field f = obj.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.get(obj);
    }

    private static int readInstanceInt(Object obj, String name) throws Exception {
        Field f = obj.getClass().getDeclaredField(name);
        f.setAccessible(true);
        return f.getInt(obj); // อ่านจาก instance ไม่ใช่ static
    }
}
