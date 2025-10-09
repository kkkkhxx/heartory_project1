/* Copyright (C) 2025 - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;

/**
 * Test suite รวมทุก unit test class ในโปรเจกต์
 * เพื่อให้สามารถรันการทดสอบทั้งหมดได้พร้อมกันในครั้งเดียว
 */
@Suite
@SelectClasses({
        BoardConstructorTest.class,
        BoardInitTest.class,
        BoardNewGameTest.class,
        ComputeAdjacencyTest.class,
        FindEmptyCellsTest.class,
        MinesAdapterLosePathTest.class,
        MinesAdapterRightClickFlagTest.class,
        MinesAdapterWinPathTest.class,
        MinesweeperInitUITest.class,
        PaintComponentTest.class
})
public class AllTestsSuite {
    // ไม่มีเมธอดใด ๆ — ใช้สำหรับรวมและรันทุกเทสพร้อมกันเท่านั้น
}
