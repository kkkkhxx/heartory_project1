/* Copyright (C) 2025 Kemisara Anankamongkol - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */
package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.*;
import java.awt.*;
import java.lang.reflect.Field;

import static org.junit.jupiter.api.Assertions.*;

public class BoardConstructorTest {

    private JLabel statusbar;
    private Board board;

    @BeforeEach
    void setup() {
        statusbar = new JLabel();
        board = new Board(statusbar);
    }

    //Case 1: ตรวจการสร้าง Board สำเร็จ
    @Test
    void testBoardIsCreatedSuccessfully() {
        assertNotNull(board, "Board object should be created");
        assertNotNull(statusbar, "Statusbar should not be null");
    }

    // Case 2: ตรวจสถานะเริ่มเกม
    @Test
    void testInGameStartsTrue() throws Exception {
        var inGameField = Board.class.getDeclaredField("inGame");
        inGameField.setAccessible(true);
        boolean inGame = inGameField.getBoolean(board);
        assertTrue(inGame, "Board should start in game mode");
    }

    // Case 3: ตรวจขนาดของกระดานที่ตั้งไว้ใน initBoard()
    @Test
    void testPreferredSizeIsCorrect() {
        Dimension size = board.getPreferredSize();
        assertEquals(241, size.width, "Board width should be 241 px");
        assertEquals(241, size.height, "Board height should be 241 px");
    }

    // Case 4: ตรวจว่ามี MouseListener ถูกแนบไว้
    @Test
    void testMouseListenerIsAttached() {
        assertTrue(board.getMouseListeners().length > 0,
                "A mouse listener should be attached in constructor/initBoard");
    }

    // Case 5: ตรวจข้อความสถานะ (จำนวนที่เหลือ)
    @Test
    void testStatusbarShowsMinesCountAfterConstruction() throws Exception {
        var minesLeftField = Board.class.getDeclaredField("minesLeft");
        minesLeftField.setAccessible(true);
        int minesLeft = minesLeftField.getInt(board);
        assertEquals(Integer.toString(minesLeft), statusbar.getText(),
                "Statusbar should display current minesLeft after construction/newGame");
    }

    // Case 6: ตรวจว่าโหลดภาพครบ 13 ไฟล์ใน initBoard()
    @Test
    void testImagesAreLoadedCorrectly() throws Exception {
        var imgField = Board.class.getDeclaredField("img");
        imgField.setAccessible(true);
        Image[] images = (Image[]) imgField.get(board);
        assertEquals(13, images.length, "There should be 13 images loaded for the board");
        for (Image img : images) {
            assertNotNull(img, "All image assets should be loaded successfully");
        }
    }

    // Case 7: ตรวจว่า field ถูกสร้างหลังจาก newGame() ถูกเรียกจาก constructor
    @Test
    void testFieldInitializedAfterConstructor() throws Exception {
        Field fieldArray = Board.class.getDeclaredField("field");
        fieldArray.setAccessible(true);
        int[] field = (int[]) fieldArray.get(board);
        assertNotNull(field, "Field array should be initialized after Board construction");
        assertEquals(16 * 16, field.length, "Field size should equal total cells (N_ROWS * N_COLS)");
    }
}
