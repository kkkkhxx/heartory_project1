/* Copyright (C) 2025 Supawich Thompad - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

// src/test/java/com/zetcode/MinesweeperInitUITest.java
package com.zetcode;

import org.junit.jupiter.api.Test;

import javax.swing.*;
import java.awt.*;

import static org.junit.jupiter.api.Assertions.*;
import static javax.swing.SwingUtilities.invokeAndWait;
import static org.junit.jupiter.api.Assumptions.assumeFalse;

public class MinesweeperInitUITest {

    @Test
    void initUI_buildsCompleteUI_and_packedByEffect() throws Exception {
        // วิธี test: ข้ามถ้าเป็นสภาพแวดล้อม headless (เช่น CI ที่ไม่มีจอแสดงผล)
        assumeFalse(GraphicsEnvironment.isHeadless(), "Headless environment – skip UI test");

        invokeAndWait(() -> {
            // วิธี test: สร้างกรอบเกม (เรียก initUI ในคอนสตรัคเตอร์)
            Minesweeper frame = new Minesweeper();

            // expect: setResizable(false)
            assertFalse(frame.isResizable());

            // วิธี test: ตรวจว่าใช้ BorderLayout
            LayoutManager lm = frame.getContentPane().getLayout();
            assertTrue(lm instanceof BorderLayout);
            BorderLayout bl = (BorderLayout) lm;

            // วิธี test: SOUTH ต้องเป็น JLabel (statusbar)
            Component south = bl.getLayoutComponent(BorderLayout.SOUTH);
            assertNotNull(south);                 // expect: มี component ที่ SOUTH
            assertTrue(south instanceof JLabel);  // expect: เป็น JLabel

            // วิธี test: CENTER ต้องเป็น Board
            Component center = bl.getLayoutComponent(BorderLayout.CENTER);
            assertNotNull(center);                // expect: มี component ที่ CENTER
            assertTrue(center instanceof Board);  // expect: เป็น Board

            // วิธี test: ยืนยันว่า pack() เกิดขึ้นโดย “ผลลัพธ์”
            // หลัง pack แล้ว ขนาด contentPane ควรเท่ากับ preferredSize ของมัน
            Dimension pref = frame.getContentPane().getPreferredSize();
            Dimension actual = frame.getContentPane().getSize();
            frame.validate();
            actual = frame.getContentPane().getSize();

            // expect: ขนาด > 0 และเท่ากับ preferredSize (แปลว่า pack สำเร็จ)
            assertTrue(actual.width > 0 && actual.height > 0);
            assertEquals(pref.width, actual.width);
            assertEquals(pref.height, actual.height);

            frame.dispose();
        });
    }
}
