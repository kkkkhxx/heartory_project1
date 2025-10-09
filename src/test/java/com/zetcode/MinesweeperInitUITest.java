// src/test/java/com/zetcode/MinesweeperInitUITest.java
package com.zetcode;

import org.junit.jupiter.api.Test;

import javax.swing.*;
import java.awt.*;
import java.awt.event.AWTEventListener;
import java.awt.event.WindowEvent;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static javax.swing.SwingUtilities.invokeAndWait;

public class MinesweeperInitUITest {

    @Test
    void initUI_buildsCompleteUI_and_packedByEffect() throws Exception {
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

    @Test
    void main_uses_invokeLater_and_sets_frame_visible() throws Exception {
        // วิธี test: ดักเหตุการณ์เปิดหน้าต่าง เพื่อยืนยันว่า UI ถูกสร้างบน EDT และถูก setVisible(true)
        CountDownLatch opened = new CountDownLatch(1);          // expect: จะนับลงเมื่อหน้าต่างถูกเปิด
        boolean[] createdOnEDT = new boolean[1];                // expect: true ถ้าอีเวนต์มาจาก EDT
        Minesweeper[] holder = new Minesweeper[1];              // วิธี test: เก็บอ้างอิงเฟรมที่ถูกสร้าง

        AWTEventListener listener = e -> {
            if (e.getID() == WindowEvent.WINDOW_OPENED) {       // วิธี test: สนใจเฉพาะตอนหน้าต่างถูกเปิด
                Window w = ((WindowEvent) e).getWindow();
                if (w instanceof Minesweeper m) {
                    holder[0] = m;                              // วิธี test: เก็บอ้างอิงเฟรม
                    createdOnEDT[0] = SwingUtilities.isEventDispatchThread(); // expect: ต้องเป็น EDT
                    opened.countDown();                         // expect: แจ้งว่ามีการเปิดหน้าต่างแล้ว
                }
            }
        };

        Toolkit.getDefaultToolkit().addAWTEventListener(listener, AWTEvent.WINDOW_EVENT_MASK);
        try {
            // วิธี test: เรียก main() ซึ่งด้านในใช้ EventQueue.invokeLater(..) สร้างและแสดงเฟรม
            Minesweeper.main(new String[0]);

            // expect: ภายในเวลาที่กำหนด ต้องมีหน้าต่าง Minesweeper ถูกเปิด
            assertTrue(opened.await(3, TimeUnit.SECONDS));

            // expect: เฟรมถูกสร้างบน EDT
            assertTrue(createdOnEDT[0]);

            // expect: เฟรมถูก setVisible(true)
            assertNotNull(holder[0]);
            assertTrue(holder[0].isVisible());

            // เก็บกวาด
            holder[0].dispose();
        } finally {
            Toolkit.getDefaultToolkit().removeAWTEventListener(listener);
        }
    }
}
