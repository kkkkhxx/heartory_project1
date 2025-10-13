# Java-Minesweeper-Game
Java Minesweeper game source code

https://zetcode.com/javagames/minesweeper/


![Minesweeper game screenshot](minesweeper.png)




### Test Suite : BoardConstructorTest

**จุดประสงค์:**  
เพื่อทดสอบการทำงานของ constructor ของคลาส Board ซึ่งทำหน้าที่กำหนดค่าเริ่มต้นของเกม Minesweeper
ตั้งแต่การเตรียมทรัพยากรต่างๆ (ภาพ, กระดาน, ตัวแปรเกม) จนถึงการเชื่อมต่อกับองค์ประกอบ UI (JLabel สำหรับ status bar)

**Characteristics (Input Space Partitioning)**

| ประเภท | รายละเอียด | ค่าพารามิเตอร์ที่ทดสอบ | ผลลัพธ์ที่คาดหวัง |
|------------------------|------------------------------------------------------|------------------------|---------------------|
| **Interface-based** | พารามิเตอร์ที่ส่งเข้า Constructor (`JLabel statusbar`) | `new Board(new JLabel())` | ตรวจสอบว่าการสร้าง `Board` ด้วย status bar ภายนอกสามารถเชื่อมโยงได้ถูกต้อง (ไม่เป็น null) |
| **Interface-based** | การกำหนดขนาดของกระดาน (`PreferredSize`)              | `board.getPreferredSize()` | ตรวจสอบว่าค่าที่คืนมาคือ 241×241 ตามสูตร `(16×15)+1` |
| **Interface-based** | การโหลดภาพ sprite ทั้งหมด                            | ตัวแปร `img[]` ขนาด 13 | ตรวจสอบว่าภาพทั้ง 13 ไฟล์ถูกโหลดเข้ามาไม่เป็น null |
| **Functionality-based** | การตั้งค่าสถานะเริ่มต้นของเกม                        | ตัวแปร `inGame`        | ตรวจสอบว่าเริ่มเกมต้องเป็น `true` เสมอ |
| **Functionality-based** | การสร้างกระดานใหม่ (`field[]`)                       | ความยาวของ field = 16×16 | ตรวจสอบว่าขนาดของกระดานถูกต้องตามค่าคงที่ `N_ROWS` และ `N_COLS` |
| **Functionality-based** | การผูก Event Listener                                | `board.getMouseListeners()` | ตรวจสอบว่ามีการแนบ MouseAdapter สำหรับตรวจจับการคลิก |
| **Functionality-based** | การแสดงข้อความใน Statusbar                           | `statusbar.getText()` เท่ากับ `minesLeft` | ตรวจสอบว่าข้อความสถานะตรงกับค่าที่ระบบตั้งไว้ในเกม |


**Input Domain Modelling:**  
**Identify Testable Function(s)**
ฟังก์ชันที่ถูกทดสอบในชุดนี้คือ **Constructor ของคลาส `Board(JLabel statusbar)`**  
ซึ่งภายในจะเรียกใช้เมธอด `initBoard()` และ `newGame()` เพื่อกำหนดค่าพื้นฐานของเกม
| `Board(JLabel)` | สร้างอ็อบเจ็กต์กระดานเกมและเชื่อมกับ status bar |
| `initBoard()` | โหลดภาพ, ตั้งค่า UI, เพิ่ม MouseListener |
| `newGame()` | รีเซ็ตค่าเกม เช่น `field[]`, `inGame`, `minesLeft` |

---

**Identify Parameters, Return Types, Return Values, and Exceptional Behavior**
| **Parameter** | `JLabel statusbar` (องค์ประกอบ GUI สำหรับแสดงข้อความสถานะ) |
| **Return Type** | -|
| **Return Values** | ตัวแปรภายใน `Board` ถูกตั้งค่า เช่น `inGame=true`, `minesLeft=40`, `field[]` ถูกสร้าง, โหลดภาพครบ, และ `statusbar` แสดงข้อความ |
| **Exceptional Behavior** | หากภาพใน `src/resources/` หายหรือ `JLabel` เป็น `null` อาจเกิด `NullPointerException` |

---

**Model the Input Domain**

|Characteristic | Partition | คำอธิบาย |
|--------------------|------------|------------|
| Statusbar Parameter | {Valid JLabel, Null JLabel} | ปกติใช้ JLabel จริง, ถ้าเป็น null จะไม่สามารถเชื่อมต่อได้ |
| Resource Path | {Images Exist, Images Missing} | ปกติทุกภาพอยู่ครบใน `src/resources/` |
| Game State (inGame) | {true, false} | เริ่มเกมต้องเป็น `true` เสมอ |
| Field Initialization | {Initialized, Null} | ต้องถูกสร้างความยาว = 256 ช่อง (16×16) |
| Mines Count | {Correct=40, Incorrect} | ค่าเริ่มต้นต้องตรงกับจำนวนเหมือง |
| Listener Registration | {Listener Attached, Not Attached} | ต้องมี MouseAdapter ถูกแนบกับกระดาน |

---

**การรวม partitions เพื่อสร้าง test requirements**
> **เทคนิคที่ใช้:** ACoC (Each Choice of Combination)

| Test Case | Partition รวม | คำอธิบาย |
|--------|--------------------------------------------------------------|------------|
| C1 | (Statusbar = Valid JLabel) + (Images = Exist) + (inGame = true) | ตรวจสถานะเริ่มต้นของเกมที่ถูกต้อง |
| C2 | (Listener = Attached) + (Statusbar = Valid JLabel)           | ตรวจว่ามี MouseListener และข้อความสถานะตรง |
| C3 | (Field = Initialized) + (Mines = Correct)                    | ตรวจขนาดกระดานและจำนวนเหมือง |
| C4 | (Images = Exist) + (Field = Initialized)                     | ครอบคลุมการโหลดทรัพยากรและตั้งค่าใหม่ใน newGame() |

---

**Test Values และ Expected Values**

| Test Case | Test Values | Expected Values |
|--------|--------------|----------------|
| C1 | `new Board(new JLabel())` | `inGame=true`, `statusbar.getText()="40"` |
| C2 | `board.getMouseListeners().length > 0` | มี listener อย่างน้อย 1 ตัว |
| C3 | `field.length == 256` | Field ถูกสร้างครบทุกช่อง |
| C4 | `img.length == 13` | โหลดภาพครบทุกไฟล์ |

---

**การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit**
ค่าที่ออกแบบในตาราง (e) ถูกนำไปใช้จริงในโค้ด JUnit ผ่าน reflection เช่น  
`inGame`, `field[]`, `img[]`, `minesLeft`, `statusbar` → ถูก assert ทุกค่า  
ไม่มีค่าใดที่ไม่ได้ใช้

---

**การผสม Interface-based และ Functionality-based Characteristics**
การทดสอบในชุดนี้ผสมการตรวจ “อินพุตจากผู้ใช้/GUI” (interface-based) และ “พฤติกรรมภายในเกม” (functionality-based)  
เช่น ตรวจการเชื่อม `JLabel` กับสถานะในเกม, ตรวจ MouseListener, และตรวจค่าใน statusbar พร้อมกัน

---

### Test Suite : PaintComponentTest
**จุดประสงค์:**  
เพื่อทดสอบการทำงานของ **`paintComponent(Graphics g)`**  
ซึ่งรับผิดชอบในการวาด cell, ตรวจการชนะ/แพ้ของเกม และอัปเดตข้อความใน `statusbar`  
รวมถึงตรวจว่าการเลือก sprite (COVER, MARK, MINE, WRONG_MARK) ถูกต้อง

**Characteristics (Input Space Partitioning)**

| ประเภท | รายละเอียด | ค่าพารามิเตอร์ที่ทดสอบ | ผลลัพธ์ที่คาดหวัง |
|----------|-------------|----------------|-------------------|
| **Interface-based** | Graphics object | ใช้ BufferedImage.createGraphics() | จำลองการวาดโดยไม่เปิด GUI |
| **Interface-based** | Field values | {0, 9, 15, 19, 20, 29} | จำลองสถานะ cell   |
| **Functionality-based** | inGame | {true, false} | ตรวจ logic การแสดงผล |
| **Functionality-based** | uncover | {0, >0} | ตรวจ logic การชนะ |
| **Functionality-based** | sprite | {DRAW_MINE, DRAW_MARK, DRAW_WRONG_MARK, DRAW_COVER} | ตรวจ mapping sprite |

---

**Input Domain Modelling:**  
**Identify Testable Function(s)**
| `paintComponent(Graphics g)` | วาด cell, ตรวจสถานะ, เปลี่ยนข้อความ “Game won/lost” |

--- 
**Identify Parameters, Return Types, Return Values, Exceptional Behavior**
| **Parameter** | Graphics g |
| **Return Type** | void |
| **Return Values** | ไม่มี แต่มีผลต่อข้อความใน `statusbar` |
| **Exceptional Behavior** | หาก `img[cell]` เป็น null อาจเกิด NPE |

---
**Model the Input Domain**

| Characteristic | Partition | คำอธิบาย |
|----------------|------------|----------|
| `field[]` | {0, 9, 15, 19, 20, 29} | จำลองช่องแต่ละแบบ |
| `inGame` | {true, false} | ตรวจ logic จบเกม |
| `uncover` | {0, >0} | ตรวจกรณีชนะ |
| `Graphics` | {valid object} | จำลองพื้นที่วาดภาพ |

**การรวม partitions เพื่อสร้าง test requirements**
> **เทคนิค:** ECC (Each Choice Coverage)

| Test Case | Partition รวม | คำอธิบาย |
|-----|---------------|-----------|
| C1 | field=0, inGame=true | เกมชนะ (Game Won) |
| C2 | field=9, inGame=true | เกมแพ้ (Game Lost) |
| C3 | field={19,20,29}, inGame=false | !inGame (MINE/MARK/WRONG_MARK) |
| C4 | field=15, inGame=false | !inGame (DRAW_COVER) |
| C5 | field=9, inGame=true | เจอ mine ระหว่างวาด |
| C6 | field=15, inGame=true | uncover>0 (ยังเล่นอยู่) |
| C7 | field=29, inGame=true | MARK ระหว่างเล่น |

---
**Test Values และ Expected Values**

| Test Case | Test Values | Expected Values |
|-----|--------|------------|
| C1 | field=0, inGame=true | “Game won” |
| C2 | field=9, inGame=true | “Game lost” |
| C3 | field={19,20,29}, inGame=false | “Game lost” |
| C4 | field=15, inGame=false | “Game lost” |
| C5 | field=9, inGame=true | inGame=false, “Game lost” |
| C6 | field=15, inGame=true | ไม่มี “Game won/lost” |
| C7 | field=29, inGame=true | วาด MARK, ยังเล่นอยู่ |

---
**การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit**
ทุกค่า field[], inGame ถูกใช้จริง  
ตรวจผลลัพธ์ statusbar ทุกกรณี 
ครบทั้ง True/False branches และทุก sprite condition

---
**การผสม Interface-based และ Functionality-based Characteristics**
ใช้ Graphics จำลอง (interface) ตรวจข้อความใน statusbar (functionality) 
เซ็ตค่า field[] ด้วย reflection เพื่อกระตุ้น logic ภายใน (functionality) 


## Test Suite : FindEmptyCellsTest

**จุดประสงค์:**  
ทดสอบเมธอด (private) `find_empty_cells(int start)` ของคลาส `Board` ซึ่งเป็นแกน “flood-fill” ของ Minesweeper: เมื่อเปิดเซลล์ศูนย์ต้องลามเปิดศูนย์ติดกัน และเปิดเลขขอบเขตที่ติดกับศูนย์ (แต่เลขไม่ลามต่อ) พร้อมกับการกันขอบ/กันมุมให้ถูกต้อง และต้อง **ไม่ไปเปิดเหมือง**

---

**Characteristics (Input Space Partitioning)**

| ประเภท Characteristic | รายละเอียด (Characteristic Description) | ค่าหรือพารามิเตอร์ที่ทดสอบ | จุดประสงค์/ผลลัพธ์ที่คาดหวัง |
|------------------------|------------------------------------------|-------------------------------|--------------------------------|
| **Interface-based** | จุดเริ่มต้น (`start` index) | {Center, TopEdge, BottomEdge, LeftEdge, RightEdge, NearCorners} | กระตุ้นเงื่อนไขขอบ/นอกขอบ/ทแยงให้ครบทุกทิศ |
| **Functionality-based** | สถานะช่องรอบ ๆ ฝั่ง W/N | {AlreadyOpened(≤9), CoveredNumber(=11), CoveredZero(=10)} | ยิงทั้ง false-branch (เปิดแล้ว) และ true-branch (เลข/ศูนย์) |
| **Functionality-based** | สถานะช่องรอบ ๆ ฝั่ง E/NE | {AlreadyOpened(≤9), CoveredNumber(=11)} | ยิงเส้นทาง “เปิดเลขไม่ลาม” กับ “เปิดแล้วคงเดิม” |
| **Functionality-based** | สถานะช่องรอบ ๆ ฝั่ง SW/SE | {CoveredZero(=10)→Expand, CoveredNumber(=11)→NoExpand} | ยิงพฤติกรรม “ลาม (ศูนย์)” vs “หยุด (เลข)” |
| **Functionality-based (คงที่ร่วม)** | ความปลอดภัยของเหมือง | `(0,0)=19` | เหมืองต้องยังปิดอยู่เสมอหลังการทำงาน |

---

**Input Domain Modelling:**  
**Identify Testable Function(s)**  
ฟังก์ชันที่ถูกทดสอบในชุดนี้คือ **`find_empty_cells(int start)`** (เรียกผ่าน reflection) ภายใน `Board`  
| `find_empty_cells(int)` | เปิดเซลล์เริ่ม และทำ flood‑fill ไปยังศูนย์ที่ติดกัน พร้อมเปิดเลขขอบเขตที่ติดศูนย์ |

---

**Identify Parameters, Return Types, Return Values, and Exceptional Behavior**  
| **Parameter** | `start` (ดัชนีเซลล์ 0..255 ของตาราง 16×16) |
| **Return Type** | ไม่มี (void) |
| **Return Values (ผลลัพธ์ที่สังเกตได้)** | ค่าใน `field[]` ของจุดเริ่มและเพื่อนบ้านถูกเปลี่ยน: ศูนย์ถูกเปิดเป็น `0`, เลขถูกเปิดเป็นค่าเลขจริง (เช่น `1`), ศูนย์ติดกันขยายต่อ |
| **Exceptional Behavior** | ไม่คาดหวัง exception หาก `start` อยู่ในช่วงและ guard ขอบทำงานถูกต้อง |

---

**Model the Input Domain**

| ประเภท Characteristic | ชื่อ Characteristic | Partition | คำอธิบาย |
|------------------------|--------------------|-----------|-----------|
| **Interface-based** | Start Position (`start`) | {Center, TopEdge, BottomEdge, LeftEdge, RightEdge, NearCorners} | จุดเริ่มเปิดช่องเพื่อกระตุ้น guard/ขอบต่าง ๆ |
| **Interface-based** | Neighbor Sets Provided | {Set W/N, Set E/NE, Set SW/SE, Default(=10)} | ถ้าไม่ได้เซ็ต เพื่อนบ้านจะเป็นค่าเริ่ม `10` ทั้งกระดาน (`Arrays.fill`) |
| **Functionality-based** | W/N State | {AlreadyOpened(≤9), CoveredNumber(=11), CoveredZero(=10)} | ใช้ยิง false vs true branch |
| **Functionality-based** | E/NE State | {AlreadyOpened(≤9), CoveredNumber(=11)} | เปิดเลขแล้วไม่ลาม / เปิดแล้วคงเดิม |
| **Functionality-based** | SW/SE State | {CoveredZero(=10)→Expand, CoveredNumber(=11)→No‑Expand} | ศูนย์ลาม vs เลขหยุด |
| **Functionality-based** | Mine Safety | {Covered(=19)} | เหมือง `(0,0)` ต้องยังปิดอยู่เสมอ |

**ค่าคงที่:** `COVER_FOR_CELL=10`, `MINE_CELL=9`, `COVERED_MINE_CELL=19`, `EMPTY_CELL=0`  
ขนาดกระดาน 16×16: `N_ROWS=N_COLS=16`, `allCells=256`

---

**การรวม partitions เพื่อสร้าง test requirements**
> **เทคนิคที่ใช้:** **ACoC (All‑Combinations Coverage)**  
จากโมเดลนี้รวมได้ 6×3×2×2 = 72 TR — ด้านล่างคัด 4 เคสหลักที่ตรงกับโค้ด JUnit จริง

| Test Case | Partition ที่ใช้รวมกัน | คำอธิบาย |
|--------|-------------------------|-----------|
| C1 | (Start=Center) + (W/N=AlreadyOpened) + (E/NE=CoveredNumber) + (SW/SE=CoveredZero→Expand) | ยิงเส้นทางด้านในครบ: opened‑stay, เปิดเลขไม่ลาม, ศูนย์ลาม |
| C2 | (Start=TopEdge) + (W/N=Default=10) + (E/NE=Default=10) + (SW/SE=Default=10) | ยิง guard ขอบบน ไม่หลุด index; ลามเท่าที่ขอบอนุญาต |
| C3 | (Start=BottomEdge) + (W/N/E/NE/SW/SE=Default=10) | ยิง guard ขอบล่าง ไม่หลุด index |
| C4 | (Start=NearCorners) + (W/N/E/NE/SW/SE=Default=10) | ยิง guard มุม/ทแยงแบบรวบรัดหลายจุดในลูปเดียว |

> หมายเหตุ: ค่า “Default” มาจาก `Arrays.fill(field, 10)` ใน `@BeforeEach`

---

**Test Values และ Expected Values**

| Test Case | Test Values | Expected Values |
|--------|--------------|----------------|
| C1 | เปิด start: `field[s]=10; field[s]-=10` → `0`;<br>ตั้งเพื่อนบ้าน: `W=0`, `N=1` (opened), `E=11`, `NE=11` (เลขปิด), `SW=10`, `SE=10` (ศูนย์ปิด); คงเหมือง `(0,0)=19` | `a[s]==0`; `W/N` คงเดิม (0,1); `E/NE` เปิดเป็นเลขจริง (เช่น `1`); `SW/SE` เปิดเป็น `0` และ **ขยาย**; `(0,0)==19` |
| C2 | `start=(0,8)`; เปิด start เป็น `0`; เพื่อนบ้านรอบ ๆ ค่าดีฟอลต์ `10`; `(0,0)=19` | `a[s]==0`; guard ทิศเหนือไม่หลุด index; `(0,0)==19` |
| C3 | `start=(15,8)`; เปิด start เป็น `0`; เพื่อนบ้านดีฟอลต์ `10`; `(0,0)=19` | `a[s]==0`; guard ทิศใต้ไม่หลุด index; `(0,0)==19` |
| C4 | start หลายชุดใกล้มุม: `(0,5)`, `(0,14)`, `(15,1)`, `(15,14)`; เปิดแต่ละ start เป็น `0`; เพื่อนบ้านดีฟอลต์ `10`; `(0,0)=19` | `a[s]==0` ทุก start; guard มุม/ทแยงทำงานถูกต้อง; `(0,0)==19` |

---

**การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit**  
ค่าที่ออกแบบถูกใช้จริงผ่าน reflection: เซ็ต `field[]`, `allCells`, `inGame`; เปิด `start`; กำหนดเพื่อนบ้านบางทิศ; ตรวจผล `field[]` และยืนยัน `(0,0)==19` ว่าเหมืองยังปิด

---

**การผสม Interface‑based และ Functionality‑based Characteristics**  
เทสต์ผสม “ตำแหน่งเริ่ม” (interface‑based) กับ “สถานะช่องรอบ ๆ” (functionality‑based) เพื่อครอบคลุมทั้งเส้นทางลาม/หยุดและ guard ของขอบ/มุม โดยยังคงความปลอดภัยของเหมือง





## Test Suite : MinesAdapterLosePathTest

**จุดประสงค์:**  
ทดสอบการทำงานของ `MinesAdapter.mousePressed(MouseEvent)` (ผ่าน `board.getMouseListeners()[0].mousePressed(e)`) ว่าเมื่อ **คลิกซ้าย** บนช่องที่เป็น **เหมืองแบบปิด** จะเกิดเส้นทางแพ้ของเกม Minesweeper อย่างถูกต้อง ได้แก่ `inGame` เปลี่ยนเป็น `false` และช่องที่คลิกถูกเปิดเป็น `MINE_CELL (=9)` โดยการคำนวณพิกัดพิกเซล → เซลล์ด้วย `CELL_SIZE` ต้องแม่นยำ และไม่กระทบเหมืองตำแหน่งอื่น

**Characteristics (Input Space Partitioning)**

| ประเภท Characteristic | รายละเอียด (Characteristic Description) | ค่าหรือพารามิเตอร์ที่ทดสอบ | จุดประสงค์/ผลลัพธ์ที่คาดหวัง |
|------------------------|------------------------------------------|-------------------------------|--------------------------------|
| **Interface-based** | ปุ่มเมาส์ที่คลิก | {Left, Right, Other} | เส้นทางแพ้ต้องเกิดเฉพาะ **Left** |
| **Interface-based** | ชนิดช่องเป้าหมายที่ถูกคลิก | {CoveredMine(=19), CoveredNumber(=11), CoveredZero(=10)} | ตรวจว่าแพ้เฉพาะ **CoveredMine** กรณีอื่นไม่แพ้ |
| **Interface-based** | ตำแหน่งช่องเหมือง (พิกัดบนกระดาน) | {Center, Edge, Corner} | ตรวจความถูกต้องของ mapping พิกเซล→เซลล์ทั้งกลาง/ขอบ/มุม |
| **Functionality-based** | สถานะเริ่มต้นของเกม | {inGame=true, inGame=false} | ถ้าเกมจบ (`false`) คลิกไม่ควรทำให้เกิดแพ้ซ้ำ |
| **Functionality-based** | ความปลอดภัยของเหมืองอื่น ๆ | (ตรึงเหมืองอื่นให้ปิดอยู่) | ไม่ควรถูกเปิดโดยอ้อมจากเหตุการณ์นี้ |

**Input Domain Modelling:**  
**Identify Testable Function(s)**  
ฟังก์ชันที่ถูกทดสอบในชุดนี้คือ **`MinesAdapter.mousePressed(MouseEvent)`** ผ่าน MouseListener ของ `Board`  
| `mousePressed(MouseEvent)` | แปลงพิกัดพิกเซล → ดัชนีเซลล์ และประมวลผลคลิกซ้าย/ขวาตามกติกา |
| การคำนวณตำแหน่งเซลล์ | ใช้ `CELL_SIZE` จาก `getPreferredSize()` เพื่อคำนวณ `(r,c)` จาก `(x,y)` |
| การอัปเดตสถานะเกม | เปลี่ยนค่า `inGame` และปรับ `field[]` ตามผลของการคลิก |

---

**Identify Parameters, Return Types, Return Values, and Exceptional Behavior**  
| **Parameter** | `MouseEvent e` (ตำแหน่งพิกเซล, ปุ่มเมาส์, click count) |
| **Return Type** | ไม่มี (void) |
| **Return Values (ผลลัพธ์ที่สังเกตได้)** | `inGame` เปลี่ยนเป็น `false` เมื่อคลิกซ้ายบน `CoveredMine`; ช่องที่คลิกถูกเปิดเป็น `MINE_CELL (=9)` |
| **Exceptional Behavior** | ไม่คาดหวัง exception หาก `MouseListener` ถูกผูกและขนาดบอร์ดถูกต้อง |

---

**Model the Input Domain**

| ประเภท Characteristic | ชื่อ Characteristic | Partition | คำอธิบาย |
|------------------------|--------------------|-----------|-----------|
| **Interface-based** | Mouse Button | {Left, Right, Other} | กำหนดเส้นทางแพ้เฉพาะ Left |
| **Interface-based** | Click Target Kind | {CoveredMine(=19), CoveredNumber(=11), CoveredZero(=10)} | ชนิดช่อง ณ ตำแหน่งที่คลิก |
| **Interface-based** | Mine Location | {Center, Edge, Corner} | ใช้ตรวจ mapping พิกเซล→เซลล์ในบริบทต่าง ๆ |
| **Functionality-based** | Game State (inGame) | {true, false} | เกมเล่นอยู่/จบแล้ว |
| **Functionality-based** | Other Mines Safety | {Covered} | เหมืองตำแหน่งอื่นยังปิดอยู่เสมอ |

---

**การรวม partitions เพื่อสร้าง test requirements**
> **เทคนิคที่ใช้:** MBCC (Multiple Base Choice Coverage)

| Test Case | Partition ที่ใช้รวมกัน | คำอธิบาย |
|--------|-------------------------|-----------|
| C1 (Base) | (Mouse=Left) + (Target=CoveredMine) + (Location=Center) + (inGame=true) | ฐานหลัก: คลิกซ้ายโดนเหมืองกลางกระดาน → ต้องแพ้ |
| C2 | (Mouse=Left) + (Target=CoveredMine) + (Location=Edge) + (inGame=true) | เบี่ยงจากฐาน: ทดสอบ mapping ใกล้ขอบ ยังแพ้ถูกต้อง |
| C3 | (Mouse=Right) + (Target=CoveredMine) + (Location=Center) + (inGame=true) | เบี่ยงจากฐาน: คลิกขวาโดนเหมือง **ไม่ควรแพ้** |
| C4 | (Mouse=Left) + (Target=CoveredMine) + (Location=Center) + (inGame=false) | เบี่ยงจากฐาน: เกมจบแล้ว คลิกไม่ควรเปลี่ยนสถานะ |

---

**Test Values และ Expected Values**

| Test Case | Test Values | Expected Values |
|--------|--------------|----------------|
| C1 | ตั้ง `field[idx(2,3)]=19` (CoveredMine); สร้าง `MouseEvent` ปุ่ม **Left** ที่พิกัดกลางเซลล์ (2,3); `inGame=true` | `inGame=false`; `field[idx(2,3)]=9` (เปิดเหมือง); ไม่มีผลข้างเคียงกับเหมืองอื่น |
| C2 | ตั้ง `field[idx(0,5)]=19`; สร้าง `MouseEvent` ปุ่ม **Left** ที่พิกัดกลางเซลล์ (0,5); `inGame=true` | `inGame=false`; `field[idx(0,5)]=9`; mapping ขอบถูกต้อง |
| C3 | ตั้ง `field[idx(2,3)]=19`; สร้าง `MouseEvent` ปุ่ม **Right** ที่พิกัดกลางเซลล์ (2,3); `inGame=true` | **ไม่แพ้** (`inGame=true`); ค่าใน `field` ไม่ถูกเปิดเป็น 9 |
| C4 | ตั้ง `field[idx(2,3)]=19`; สร้าง `MouseEvent` ปุ่ม **Left** ที่พิกัดกลางเซลล์ (2,3); `inGame=false` | **ไม่แพ้** (`inGame=false` คงเดิม); ไม่ควรเปิดเป็น 9 |

---

**การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit**  
ค่าที่ออกแบบในตารางถูกใช้จริงในยูนิตเทสต์ เช่น การตั้ง `field[]` ให้เป็น `10` ทั้งกระดาน, วาง `CoveredMine (=19)` ณ จุดทดสอบ, คำนวณ `CELL_SIZE` จาก `getPreferredSize()` เพื่อสร้าง `MouseEvent` ที่ตำแหน่งกลางเซลล์, ตรวจ `inGame` และค่าเซลล์หลังคลิก

---

**การผสม Interface-based และ Functionality-based Characteristics**  
การทดสอบชุดนี้ผสมทั้งมุมมองผู้ใช้ (ปุ่มคลิก, ตำแหน่งที่คลิก, ชนิดช่อง) กับพฤติกรรมภายใน (สถานะเกม, การเปลี่ยนค่า `field[]`) เพื่อยืนยันเส้นทางแพ้และกรณีไม่แพ้ตามกติกา Minesweeper





