package com.zetcode;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertArrayEquals;

public class ComputeAdjacencyTest {

    private static int[] computeAdjacency(int rows, int cols, boolean[] mines) {
        if (rows <= 0 || cols <= 0) throw new IllegalArgumentException("rows/cols must be positive");
        if (mines == null || mines.length != rows * cols) throw new IllegalArgumentException("mines length mismatch");
        int[] out = new int[rows * cols];
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                int idx = r * cols + c;
                if (mines[idx]) {
                    out[idx] = -1;
                    continue;
                }
                int count = 0;
                for (int dr = -1; dr <= 1; dr++) {
                    for (int dc = -1; dc <= 1; dc++) {
                        if (dr == 0 && dc == 0) continue;
                        int nr = r + dr, nc = c + dc;
                        if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
                        if (mines[nr * cols + nc]) count++;
                    }
                }
                out[idx] = count;
            }
        }
        return out;
    }

    @Test
    // case 1 : สร้างตาราง 4x4 และวางเหมือง 2 จุดบนแนวทแยง (1,1) และ (2,2)
    void custom4x4_twoMines_diagonal() {
        int rows = 4, cols = 4;
        boolean[] mines = new boolean[rows * cols];
        mines[1 * cols + 1] = true;
        mines[2 * cols + 2] = true;

        //expect
        int[] expect = new int[] {
                1, 1, 1, 0,
                1, -1, 2, 1,
                1, 2, -1, 1,
                0, 1, 1, 1
        };

        int[] got = computeAdjacency(rows, cols, mines);
        assertArrayEquals(expect, got);
    }

    @Test
    // case 2 : สร้างตาราง 3x3 และวางเหมืองมุมซ้ายบน (0,0) และกึ่งกลาง (1,1)
    void custom3x3_centerAndCorner() {
        int rows = 3, cols = 3;
        boolean[] mines = new boolean[rows * cols];
        mines[0 * cols + 0] = true;
        mines[1 * cols + 1] = true;

        //expect
        int[] expect = new int[] {
                -1, 2, 1,
                2, -1, 1,
                1, 1, 1
        };

        int[] got = computeAdjacency(rows, cols, mines);
        assertArrayEquals(expect, got);
    }
}
