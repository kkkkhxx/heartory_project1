/* Copyright (C) 2025 Kemisara Anankamongkol - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */
package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.swing.*;
import java.awt.*;
import java.awt.image.BufferedImage;

import static org.junit.jupiter.api.Assertions.*;

public class PaintComponentTest {

    private JLabel statusbar;
    private Board board;
    private Graphics2D g;

    @BeforeEach
    void setup() {
        statusbar = new JLabel();
        board = new Board(statusbar);

        // ใช้กราฟิกแบบ headless
        BufferedImage image = new BufferedImage(400, 400, BufferedImage.TYPE_INT_ARGB);
        g = image.createGraphics();
    }

    // 1) ชนะเกม: uncover == 0 && inGame
    @Test
    void testGameWonStatusDisplayed() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        // ทุกช่องเปิดแล้ว (0)
        for (int i = 0; i < field.length; i++) field[i] = 0;

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, true);

        board.paintComponent(g);
        assertEquals("Game won", statusbar.getText(), "Statusbar should show 'Game won'");
    }

    // 2) แพ้เกม: inGame=true แล้วเจอ mine ระหว่างวาด
    @Test
    void testGameLostStatusDisplayed() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        field[0] = 9; // MINE_CELL
        fieldF.set(board, field);

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, true);

        board.paintComponent(g);
        assertEquals("Game lost", statusbar.getText(), "Statusbar should show 'Game lost'");
    }

    // 3) ไม่อยู่ในเกม: ทดสอบ 3 แขนงแรก (MINE/ MARK/ WRONG_MARK)
    @Test
    void testSpriteSelectionMineMarkWrongMark_whenNotInGame() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        field[0] = 19; // COVERED_MINE_CELL -> DRAW_MINE
        field[1] = 29; // MARKED_MINE_CELL  -> DRAW_MARK
        field[2] = 20; // > COVERED_MINE_CELL -> DRAW_WRONG_MARK
        fieldF.set(board, field);

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, false);

        board.paintComponent(g);

        // เมื่อไม่อยู่ในเกม paint() จะสรุปเป็น "Game lost"
        assertEquals("Game lost", statusbar.getText());
    }

    // 4) ไม่อยู่ในเกม: แขนงสุดท้ายของ !inGame (cell > MINE_CELL -> DRAW_COVER)
    @Test
    void testSpriteSelectionCover_whenNotInGame() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        field[0] = 15; // > MINE_CELL (=9) แต่ไม่เกิน COVERED_MINE_CELL (=19)
        fieldF.set(board, field);

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, false);

        board.paintComponent(g);

        // ยังเป็น "Game lost" ตามเงื่อนไขท้ายเมธอด
        assertEquals("Game lost", statusbar.getText());
    }

    // 5) inGame=true แล้วเจอ mine ระหว่างวาด (ย้ำแขนง if แรก)
    @Test
    void testInGameTrueThenHitMineDuringPainting() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        field[0] = 9; // mine
        fieldF.set(board, field);

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, true);

        board.paintComponent(g);

        boolean inGameAfter = inGameF.getBoolean(board);
        assertFalse(inGameAfter, "Should set inGame=false after hitting a mine");
        assertEquals("Game lost", statusbar.getText());
    }

    // 6) ยังเล่นอยู่: inGame=true และ uncover>0 -> ไม่ใช่ won/lost
    @Test
    void testStillPlayingNotWonOrLost() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        // ให้ทุกช่องเป็นค่า > MINE_CELL (เช่น 15) เพื่อวาดเป็น COVER และนับ uncover > 0
        for (int i = 0; i < field.length; i++) field[i] = 15;
        fieldF.set(board, field);

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, true);

        board.paintComponent(g);

        // ยังไม่ควรเป็น won/lost (statusbar ปกติจะเป็นตัวเลข minesLeft จาก newGame)
        assertNotEquals("Game won", statusbar.getText());
        assertNotEquals("Game lost", statusbar.getText());
    }

    // 7) แขนง inGame: cell > COVERED_MINE_CELL -> วาด MARK (ยังเล่นอยู่)
    @Test
    void testInGameMarkedCellDrawsMarkBranch() throws Exception {
        var fieldF = Board.class.getDeclaredField("field");
        fieldF.setAccessible(true);
        int[] field = (int[]) fieldF.get(board);

        field[0] = 29; // MARKED_MINE_CELL (> COVERED_MINE_CELL)
        fieldF.set(board, field);

        var inGameF = Board.class.getDeclaredField("inGame");
        inGameF.setAccessible(true);
        inGameF.setBoolean(board, true);

        board.paintComponent(g);

        // ยังไม่ใช่สถานะจบเกม
        assertNotEquals("Game won", statusbar.getText());
        assertNotEquals("Game lost", statusbar.getText());
    }
}
