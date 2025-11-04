/* Copyright (C) 2025 Wissawachit rungruang - All Rights Reserved
 * You may use, distribute and modify this code under the terms of the MIT license.
 */

package com.zetcode;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Named;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import javax.swing.JLabel;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.*;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

@TestInstance(Lifecycle.PER_CLASS)
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

    // ===== พาร์ทิชันสถานะเพื่อนบ้าน =====
    enum NeighborState {
        OPENED(0),          // <=9 : ใช้ 0 เพื่อความเรียบง่าย
        COVERED_ZERO(10),   // 10
        COVERED_NUMBER(11); // 11

        final int cellValue;
        NeighborState(int v) { this.cellValue = v; }
    }

    // ===== ตำแหน่งเริ่มต้นสำหรับสร้าง ACOC แยกชุด =====
    enum StartCase {
        CENTER(8, 8, new Dir[]{Dir.N, Dir.E, Dir.S, Dir.W}),
        EDGE_TOP(0, 8, new Dir[]{Dir.E, Dir.S, Dir.W}),
        CORNER_TR(0, N_COLS - 1, new Dir[]{Dir.S, Dir.W});

        final int r, c;
        final Dir[] applicableDirs;
        StartCase(int r, int c, Dir[] ds) { this.r = r; this.c = c; this.applicableDirs = ds; }
    }

    enum Dir { N, E, S, W }

    private static int neighborIndex(int r, int c, Dir d) {
        switch (d) {
            case N: return idx(r - 1, c);
            case E: return idx(r, c + 1);
            case S: return idx(r + 1, c);
            case W: return idx(r, c - 1);
        }
        throw new IllegalArgumentException();
    }

    @BeforeEach
    void setUp() throws Exception {
        board = new Board(new JLabel());

        // กระดานเริ่มต้น: ปิดทั้งหมด (=10)
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

    // ===== สร้างคอมบิเนชันแบบคาร์ทีเซียนสำหรับ ACOC (ตามทิศที่มีอยู่จริง) =====
    private static List<List<NeighborState>> cartesian(NeighborState[] domain, int k) {
        List<List<NeighborState>> res = new ArrayList<>();
        backtrack(res, new ArrayList<>(), domain, k);
        return res;
    }
    private static void backtrack(List<List<NeighborState>> res, List<NeighborState> cur, NeighborState[] domain, int k) {
        if (cur.size() == k) { res.add(new ArrayList<>(cur)); return; }
        for (NeighborState s : domain) {
            cur.add(s);
            backtrack(res, cur, domain, k);
            cur.remove(cur.size() - 1);
        }
    }

    // ===== แหล่งข้อมูลพารามิเตอร์: (StartCase, รายการสถานะเพื่อนบ้านตามลำดับ applicableDirs) =====
    Stream<org.junit.jupiter.params.provider.Arguments> allCombinationsProvider() {
        List<org.junit.jupiter.params.provider.Arguments> args = new ArrayList<>();
        NeighborState[] domain = NeighborState.values();

        for (StartCase sc : StartCase.values()) {
            List<List<NeighborState>> combos = cartesian(domain, sc.applicableDirs.length);
            int i = 0;
            for (List<NeighborState> combo : combos) {
                String name = sc.name() + " #" + (++i) + " / " + combos.size();
                args.add(org.junit.jupiter.params.provider.Arguments.of(
                        Named.of(name, sc),
                        combo.toArray(new NeighborState[0])
                ));
            }
        }
        return args.stream();
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("allCombinationsProvider")
    @DisplayName("ACOC: ทุกคอมบิเนชันของสถานะเพื่อนบ้านตามตำแหน่งเริ่มต้น")
    void acoc_allNeighborCombinations_appliedPerStartCase(StartCase sc, NeighborState[] neighborStates) throws Exception {
        // --- เตรียมกระดานใหม่ (อิสระต่อแต่ละคอมบิเนชัน) ---
        Arrays.fill(field, COVER_FOR_CELL);
        field[idx(0,0)] = COVERED_MINE_CELL;
        for (int n : new int[]{ idx(0,1), idx(1,0), idx(1,1) }) field[n] = COVER_FOR_CELL + 1;
        setPrivateField(board, "field", field);

        int s = idx(sc.r, sc.c);

        // เปิด start ให้เป็นศูนย์ (จำลองผลหลังคลิกซ้ายที่เซลล์ศูนย์)
        field[s] = EMPTY_CELL;

        // ตั้งค่าสถานะเพื่อนบ้านตามคอมบิเนชัน ACOC (เฉพาะทิศที่ "มีอยู่จริง")
        for (int i = 0; i < sc.applicableDirs.length; i++) {
            Dir d = sc.applicableDirs[i];
            NeighborState st = neighborStates[i];
            int ni = neighborIndex(sc.r, sc.c, d);
            field[ni] = st.cellValue;
        }

        // ติดตั้งฟิลด์และยิงเมธอดจริง
        setPrivateField(board, "field", field);
        invokeFindEmpty(board, s);

        int[] a = (int[]) getPrivateField(board, "field");

        // --- ตรวจผลขั้นต่ำที่ต้องเป็นจริงสำหรับทุกคอมบิเนชัน ---
        // 1) start ต้องเปิดเป็น 0
        assertEquals(EMPTY_CELL, a[s], "start cell must remain EMPTY(0)");

        // 2) เหมืองเดิมต้องไม่ถูกเปิดโดยอุบัติเหตุ
        assertEquals(COVERED_MINE_CELL, a[idx(0,0)], "mine safety must hold");

        // 3) เพื่อนบ้านตามสถานะ:
        //    - OPENED(0)  : คงเป็นค่าที่เปิดอยู่แล้ว (ที่นี่ใช้ 0)
        //    - COVERED_NUMBER(11) -> เปิดเป็นเลข (อย่างน้อยต้อง <=9; ที่นี่ expect 1 ตามการตั้งค่าเบื้องต้น)
        //    - COVERED_ZERO(10)   -> เปิดเป็น 0 และอาจขยายต่อ (ไม่ assert พื้นที่ขยายทั้งหมดเพื่อไม่ผูกกับ implementation detail)
        for (int i = 0; i < sc.applicableDirs.length; i++) {
            Dir d = sc.applicableDirs[i];
            NeighborState st = neighborStates[i];
            int ni = neighborIndex(sc.r, sc.c, d);

            switch (st) {
                case OPENED:
                    assertTrue(a[ni] <= 9, "opened neighbor must remain opened (<=9)");
                    break;
                case COVERED_NUMBER:
                    // อย่างต่ำต้องถูกเปิดเป็นเลข (ที่นี่เราคาดหวัง 1 จากการตั้งค่าเลขรอบๆ แต่ถ้าคุณคำนวณจริงต่างออกไป ให้ปรับเป็น <=9)
                    assertTrue(a[ni] <= 9, "covered number must be revealed to a number (<=9)");
                    break;
                case COVERED_ZERO:
                    assertEquals(EMPTY_CELL, a[ni], "covered zero must become 0");
                    break;
            }
        }
    }
}
