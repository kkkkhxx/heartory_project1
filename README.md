# Java-Minesweeper-Game
Java Minesweeper game source code

https://zetcode.com/javagames/minesweeper/


![Minesweeper game screenshot](minesweeper.png)




# Test Suite : BoardConstructorTest

**จุดประสงค์:**  
เพื่อทดสอบการทำงานของ constructor ของคลาส Board ซึ่งทำหน้าที่กำหนดค่าเริ่มต้นของเกม Minesweeper
ตั้งแต่การเตรียมทรัพยากรต่างๆ (ภาพ, กระดาน, ตัวแปรเกม) จนถึงการเชื่อมต่อกับองค์ประกอบ UI (JLabel สำหรับ status bar)

**Characteristics (Input Space Partitioning)**

| ประเภท                  | รายละเอียด                                             | ค่าพารามิเตอร์ที่ทดสอบ                    | ผลลัพธ์ที่คาดหวัง                                                                         |
|-------------------------|--------------------------------------------------------|-------------------------------------------|-------------------------------------------------------------------------------------------|
| **Interface-based**     | พารามิเตอร์ที่ส่งเข้า Constructor (`JLabel statusbar`) | `new Board(new JLabel())`                 | ตรวจสอบว่าการสร้าง `Board` ด้วย status bar ภายนอกสามารถเชื่อมโยงได้ถูกต้อง (ไม่เป็น null) |
| **Interface-based**     | การกำหนดขนาดของกระดาน (`PreferredSize`)                | `board.getPreferredSize()`                | ตรวจสอบว่าค่าที่คืนมาคือ 241×241 ตามสูตร `(16×15)+1`                                      |
| **Interface-based**     | การโหลดภาพ sprite ทั้งหมด                              | ตัวแปร `img[]` ขนาด 13                    | ตรวจสอบว่าภาพทั้ง 13 ไฟล์ถูกโหลดเข้ามาไม่เป็น null                                        |
| **Functionality-based** | การตั้งค่าสถานะเริ่มต้นของเกม                          | ตัวแปร `inGame`                           | ตรวจสอบว่าเริ่มเกมต้องเป็น `true` เสมอ                                                    |
| **Functionality-based** | การสร้างกระดานใหม่ (`field[]`)                         | ความยาวของ field = 16×16                  | ตรวจสอบว่าขนาดของกระดานถูกต้องตามค่าคงที่ `N_ROWS` และ `N_COLS`                           |
| **Functionality-based** | การผูก Event Listener                                  | `board.getMouseListeners()`               | ตรวจสอบว่ามีการแนบ MouseAdapter สำหรับตรวจจับการคลิก                                      |
| **Functionality-based** | การแสดงข้อความใน Statusbar                             | `statusbar.getText()` เท่ากับ `minesLeft` | ตรวจสอบว่าข้อความสถานะตรงกับค่าที่ระบบตั้งไว้ในเกม                                        |


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

| Characteristic        | Partition                         | คำอธิบาย                                                  |
|-----------------------|-----------------------------------|-----------------------------------------------------------|
| Statusbar Parameter   | {Valid JLabel, Null JLabel}       | ปกติใช้ JLabel จริง, ถ้าเป็น null จะไม่สามารถเชื่อมต่อได้ |
| Resource Path         | {Images Exist, Images Missing}    | ปกติทุกภาพอยู่ครบใน `src/resources/`                      |
| Game State (inGame)   | {true, false}                     | เริ่มเกมต้องเป็น `true` เสมอ                              |
| Field Initialization  | {Initialized, Null}               | ต้องถูกสร้างความยาว = 256 ช่อง (16×16)                    |
| Mines Count           | {Correct=40, Incorrect}           | ค่าเริ่มต้นต้องตรงกับจำนวนเหมือง                          |
| Listener Registration | {Listener Attached, Not Attached} | ต้องมี MouseAdapter ถูกแนบกับกระดาน                       |

---

**การรวม partitions เพื่อสร้าง test requirements**
> **เทคนิคที่ใช้:** ACoC (Each Choice of Combination)

| Test Case | Partition รวม                                                   | คำอธิบาย                                          |
|-----------|-----------------------------------------------------------------|---------------------------------------------------|
| C1        | (Statusbar = Valid JLabel) + (Images = Exist) + (inGame = true) | ตรวจสถานะเริ่มต้นของเกมที่ถูกต้อง                 |
| C2        | (Listener = Attached) + (Statusbar = Valid JLabel)              | ตรวจว่ามี MouseListener และข้อความสถานะตรง        |
| C3        | (Field = Initialized) + (Mines = Correct)                       | ตรวจขนาดกระดานและจำนวนเหมือง                      |
| C4        | (Images = Exist) + (Field = Initialized)                        | ครอบคลุมการโหลดทรัพยากรและตั้งค่าใหม่ใน newGame() |

---

**Test Values และ Expected Values**

| Test Case | Test Values                            | Expected Values                           |
|-----------|----------------------------------------|-------------------------------------------|
| C1        | `new Board(new JLabel())`              | `inGame=true`, `statusbar.getText()="40"` |
| C2        | `board.getMouseListeners().length > 0` | มี listener อย่างน้อย 1 ตัว               |
| C3        | `field.length == 256`                  | Field ถูกสร้างครบทุกช่อง                  |
| C4        | `img.length == 13`                     | โหลดภาพครบทุกไฟล์                         |

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

# Test Suite : PaintComponentTest
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


# Test Suite : FindEmptyCellsTest

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


---


# Test Suite : MinesAdapterLosePathTest

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

---

# Test Suite : ComputeAdjacencyTest

**จุดประสงค์:**
ยืนยันว่า `computeAdjacency()` คำนวณตัวเลขรอบเหมือง 8 ทิศได้ถูกต้อง (เหมือง = −1, อื่น = 0..8) ครอบคลุมกรณีมุม/ขอบ/กึ่งกลาง และเช็กพารามิเตอร์ผิดพลาด

**Characteristics (Input Space Partitioning)**

| ประเภท Characteristic   | รายละเอียด        | ค่าหรือพารามิเตอร์ที่ทดสอบ         | จุดประสงค์/ผลลัพธ์ที่คาดหวัง                 |
| ----------------------- | ----------------- | ---------------------------------- | -------------------------------------------- |
| **Interface-based**     | ขนาดกระดาน        | `rows ∈ {1, >1}`, `cols ∈ {1, >1}` | ครอบคลุม 1×1, 1×N, M×1, M×N                  |
| **Interface-based**     | ความยาว `mines[]` | {เท่ากับ `rows*cols`, ไม่เท่า}     | ถ้าไม่เท่า → ต้อง `IllegalArgumentException` |
| **Functionality-based** | ตำแหน่งเหมือง     | {มุม, ขอบ, กึ่งกลาง, ไม่มี, เต็ม}  | ตรวจการนับรอบข้างและไม่หลุดขอบ               |
| **Functionality-based** | รูปแบบกระจาย      | {เดี่ยว, ทแยงติดกัน, หนาแน่น}      | ตรวจผลรวมเพื่อนบ้านเมื่อเหมืองอยู่ใกล้กัน    |

**Input Domain Modelling — Identify Testable Function(s)**

| ฟังก์ชัน                                                | บทบาท                                             |
| ------------------------------------------------------- | ------------------------------------------------- |
| `computeAdjacency(int rows, int cols, boolean[] mines)` | คืน `int[]` ขนาด `rows*cols` ตามกติกา Minesweeper |

**Identify Parameters, Return Types, Return Values, and Exceptional Behavior**

| รายการ               | รายละเอียด                                                                        |
| -------------------- | --------------------------------------------------------------------------------- |
| Parameters           | `rows`, `cols`, `mines[]`                                                         |
| Return type          | `int[]`                                                                           |
| Return values        | −1 (เหมือง) หรือ 0..8 (จำนวนรอบข้าง)                                              |
| Exceptional Behavior | `rows<=0`/`cols<=0` หรือ `mines.length != rows*cols` → `IllegalArgumentException` |

**Model the Input Domain**

| ชื่อ Characteristic | Partition                         |
| ------------------- | --------------------------------- |
| Rows                | {1, >1}                           |
| Cols                | {1, >1}                           |
| Mines length        | {ถูกต้อง, ไม่ถูกต้อง}             |
| Mine position       | {มุม, ขอบ, กึ่งกลาง, ไม่มี, เต็ม} |
| Pattern             | {เดี่ยว, ทแยงติดกัน, หนาแน่น}     |

**การรวม partitions เพื่อสร้าง test requirements**

> **เทคนิคที่ใช้:** **PWC (Pair-Wise Coverage)** — ให้ทุก “คู่” ของลักษณะเกิดขึ้นอย่างน้อย 1 ครั้ง

| Test Case | Partition ที่ใช้รวมกัน                                        | คำอธิบาย                           |
| --------- | ------------------------------------------------------------- | ---------------------------------- |
| P1        | Rows>1, Cols>1, Len=ถูกต้อง, Pos=กึ่งกลาง, Pattern=ทแยงติดกัน | ตาราง 4×4 วางเหมืองแนวทแยง 2 จุด   |
| P2        | Rows>1, Cols>1, Len=ถูกต้อง, Pos=มุม+กึ่งกลาง, Pattern=เดี่ยว | ตาราง 3×3 มุมซ้ายบน + กลาง         |
| P3        | Rows=1, Cols=1, Len=ถูกต้อง, Pos=ไม่มี                        | 1×1 ไม่มีเหมือง → ต้องได้ 0        |
| P4        | Rows=1, Cols>1, Len=ถูกต้อง, Pos=มุม                          | 1×N เหมืองที่ขอบซ้าย/ขวา           |
| P5        | Rows>1, Cols=1, Len=ถูกต้อง, Pos=ขอบ                          | M×1 เหมืองที่ขอบบน/ล่าง            |
| P6        | Rows>1, Cols>1, **Len=ไม่ถูกต้อง**                            | ต้องโยน `IllegalArgumentException` |
| P7        | Rows>1, Cols>1, Len=ถูกต้อง, **Pos=เต็ม**                     | ทุกช่องเป็นเหมือง → ทั้งแผง −1     |

**Test Values และ Expected Values**

| Test Case | Test Values                    | Expected Values                             |
| --------- | ------------------------------ | ------------------------------------------- |
| P1        | 4×4; mines ที่ (1,1) และ (2,2) | ผลลัพธ์ตรงกับ `custom4x4_twoMines_diagonal` |
| P2        | 3×3; mines ที่ (0,0) และ (1,1) | ผลลัพธ์ตรงกับ `custom3x3_centerAndCorner`   |
| P3        | 1×1; mines=false               | `[0]`                                       |
| P4        | 1×4; mine @0                   | มีเพื่อนบ้านเฉพาะด้านขวา                    |
| P5        | 4×1; mine @1                   | มีเพื่อนบ้านเฉพาะบน/ล่าง                    |
| P6        | 3×3; `mines.length=7`          | โยน `IllegalArgumentException`              |
| P7        | 3×3; all mines=true            | ทุกค่าเป็น −1                               |

**การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit**  
ชุด P1–P7 ครอบคลุมทุก partition ทั้งค่าปกติและค่าผิดพลาด

**การผสม Interface-based และ Functionality-based**  
ผสาน “ขนาดและความยาวอาร์เรย์” (interface) กับ “ตำแหน่ง/รูปแบบเหมือง” (functionality) เพื่อเห็นผลกระทบร่วมกันแบบคู่ ๆ


---

# Test Suite : MinesweeperInitUITest 

**จุดประสงค์:**
ยืนยันว่า `initUI()` ประกอบหน้าจอครบ: มี `statusbar` (JLabel) ที่ SOUTH, มี `Board(statusbar)` ที่ CENTER, ตั้ง `setResizable(false)`, เรียก `pack()` และทำงานบน EDT

**Characteristics (Input Space Partitioning)**

| ประเภท Characteristic   | รายละเอียด               | ค่าหรือพารามิเตอร์ที่ทดสอบ          | จุดประสงค์/ผลลัพธ์ที่คาดหวัง             |
| ----------------------- | ------------------------ | ----------------------------------- | ---------------------------------------- |
| **Interface-based**     | Layout ของ `contentPane` | {**BorderLayout**(base), อื่น}      | ต้องเป็น BorderLayout                    |
| **Interface-based**     | องค์ประกอบ SOUTH         | {**มี JLabel**(base), ไม่มี}        | SOUTH ต้องเจอ `JLabel`                   |
| **Interface-based**     | องค์ประกอบ CENTER        | {**มี Board**(base), ไม่มี/ผิดชนิด} | CENTER ต้องเป็น `Board`                  |
| **Functionality-based** | Resizable                | {**false**(base), true}             | ต้อง `false`                             |
| **Functionality-based** | pack()                   | {**ถูกเรียก**(base), ไม่เรียก}      | หลัง `validate()` ขนาด = `preferredSize` |
| **Functionality-based** | Thread                   | {**EDT**(base), non-EDT}            | ควรทำงานบน EDT                           |

**Input Domain Modelling — Identify Testable Function(s)**

| ฟังก์ชัน   | บทบาท                                                                                     |
| ---------- | ----------------------------------------------------------------------------------------- |
| `initUI()` | ประกอบ UI: ใส่ statusbar/Board, setResizable(false), pack(), ตั้ง title/location/close op |

**Identify Parameters, Return Types, Return Values, Exceptional Behavior**

| รายการ               | รายละเอียด                              |
| -------------------- | --------------------------------------- |
| Parameters           | ไม่มี                                   |
| Return type          | `void`                                  |
| Return values        | ตรวจได้จากคอมโพเนนต์และคุณสมบัติของเฟรม |
| Exceptional Behavior | รันใน headless → ควร **skip** เทสต์     |

**Model the Input Domain**

| ชื่อ Characteristic | Partition                        |
| ------------------- | -------------------------------- |
| Layout              | {**BorderLayout**(base), อื่น}   |
| SOUTH component     | {**JLabel**(base), ไม่มี}        |
| CENTER component    | {**Board**(base), ไม่มี/ผิดชนิด} |
| Resizable           | {**false**(base), true}          |
| pack                | {**เรียก**(base), ไม่เรียก}      |
| Thread              | {**EDT**(base), non-EDT}         |

**การรวม partitions เพื่อสร้าง test requirements**

> **เทคนิคที่ใช้:** **BCC (Base-Choice Coverage)** — มีเคสฐาน แล้ว “เปลี่ยนทีละอย่าง” เพื่อพิสูจน์ข้อกำหนด

| Test Case | Partition รวม                                                                            | คำอธิบาย                           |
| --------- | ---------------------------------------------------------------------------------------- | ---------------------------------- |
| B0 (Base) | Layout=BorderLayout, SOUTH=JLabel, CENTER=Board, Resizable=false, pack=เรียก, Thread=EDT | เคสฐานที่ต้องผ่าน (เทสต์ที่มีอยู่) |
| B1        | SOUTH=ไม่มี                                                                              | SOUTH ไม่เจอ `JLabel`              |
| B2        | CENTER=ไม่มี/ผิดชนิด                                                                     | CENTER ไม่ใช่ `Board`              |
| B3        | Resizable=true                                                                           | `isResizable()` เป็น true          |
| B4        | pack=ไม่เรียก                                                                            | ขนาดจริง ≠ `preferredSize`         |
| B5        | Thread=non-EDT                                                                           | บังคับให้ fail/skip ตาม policy     |

**Test Values และ Expected Values**

| Test Case | Test Values                                                                                      | Expected Values                 |
| --------- | ------------------------------------------------------------------------------------------------ | ------------------------------- |
| B0        | สร้าง `Minesweeper` บน EDT; ตรวจ SOUTH/CENTER; ตรวจ `isResizable=false`; ตรวจ size=preferredSize | ผ่านทั้งหมด                     |
| B1        | เฟรมจำลองไม่เพิ่ม SOUTH                                                                          | ไม่พบ `JLabel` SOUTH            |
| B2        | เฟรมจำลองไม่เพิ่ม CENTER หรือใส่ชนิดอื่น                                                         | ไม่ใช่ `Board`                  |
| B3        | เฟรมจำลองตั้ง `setResizable(true)`                                                               | Assertion ว่าต้อง false ล้ม     |
| B4        | เฟรมจำลองไม่เรียก `pack()`                                                                       | size ไม่เท่ากับ `preferredSize` |
| B5        | เรียกจาก non-EDT หรือ headless                                                                   | skip/fail                       |

**การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit**  
B0 ตรวจครบองค์ประกอบ; B1–B5 ปรับทีละจุดเพื่อยืนยันข้อกำหนดของ `initUI()` ตาม BCC

**การผสม Interface-based และ Functionality-based**  
ตรวจโครงสร้างคอมโพเนนต์ (interface) ร่วมกับคุณสมบัติและพฤติกรรมของเฟรม (`isResizable`, `pack`, เธรด) ที่เป็น functionality


---

# Test Suite : MinesAdapterWinPathTest (PWC)

**จุดประสงค์:**  
ตรวจสอบการทำงานของ `MinesAdapter.mousePressed(MouseEvent)` ในทุกกรณีที่อาจเกิดขึ้นระหว่าง “เส้นทางชนะ (Win Path)”  
เน้นการทดสอบ *ปฏิสัมพันธ์ระหว่างปัจจัยสองตัวขึ้นไป* เช่น ปุ่มเมาส์ + ชนิดช่อง, ตำแหน่งคลิก + สถานะเกม, หรือ uncover + การปักธง

> ใช้ **Pair-Wise** เพราะต้องการครอบคลุมความสัมพันธ์ระหว่างอินพุตต่าง ๆ โดยไม่ต้องทดสอบทุกคอมบินาชัน (ซึ่งเยอะมาก)

### Characteristics (Input Space Partitioning)

| ประเภท Characteristic   | Characteristic        | รายละเอียด | พาร์ติชัน (Partitions) | คำอธิบาย input                                  |
|-------------------------|-----------------------|---|---|-------------------------------------------------|
| **Interface-Based**     | **Mouse Button**      | ปุ่มที่ใช้คลิก | {Left, Right, Other} | ซ้าย, ขวา, ปุ่มอื่นๆ                            |
| **Interface-Based**     |**Click Target Kind** | ชนิดของช่องที่คลิก | {CoveredZero, CoveredNumber, Marked, Opened} | ยังไม่เปิด, ปักธง, เปิดแล้ว                     |
| **Interface-Based**     |**Click Location**    | พิกัดบนกระดาน | {Center, Edge, Corner, OutOfBoard} | ขอบกระดาน แต่ไม่ใช่มุม, มุมของกระดาน, นอกกระดาน |
| **Functionality-Based** |**Game Status (inGame)** | สถานะเกม | {True, False} | เกมยังไม่จบ, เกมจบแล้ว                          |
| **Functionality-Based** |**Remaining uncover count** | จำนวนช่องปลอดภัยที่ยังไม่เปิด | {LastOne, ManyLeft} | เหลือช่องเดียว, เหลือหลายช่อง                   |
| **Functionality-Based** | **Mark Handling**     | การจัดการธง | {NoMarkAction, ToggleMark} | ไม่มีการเปลี่ยนสถานะธง, มีการสลับสถานะธง                        |

### Identify Testable Function(s)

| ฟังก์ชัน | บทบาท                                                                                                                                                                                                                                                              |
|---|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `mousePressed(MouseEvent e)` | ประมวลผลคลิกซ้าย/ขวา, แปลงพิกัดพิกเซล → ช่อง, เปิด/ปักธง                                                                                                                                                                                                           |
| (ใน Board) | ตรวจชนะ/แพ้: ชนะเมื่อลงเอยที่ “ไม่เหลือ safe cell ที่ยังถูกครอบ” (อาจไม่ อัปเดต `uncover`/`inGame` ตามเวอร์ชัน)<br/></br>- `inGame` บางเวอร์ชัน ยัง true หลังชนะ (รอเริ่มเกมใหม่ด้วยคลิก)<br/>- `statusbar` บางเวอร์ชัน แสดงตัวเลขเหมืองคงเหลือ ไม่ได้บอก “win” ชัดเจน |

statusbar บางเวอร์ชัน แสดงตัวเลขเหมืองคงเหลือ ไม่ได้บอก “win” ชัดเจน |

### Parameters / Return / Exceptional Behavior

- **Parameter:** `MouseEvent e`
- **Return:** ไม่มี (ตรวจผ่านสถานะ/ผลลัพธ์)
- **Exceptional Behavior:** ไม่ควรเกิด exception แม้คลิกนอกบอร์ด → ปุ่ม Middle อาจถูกปฏิบัติ “เหมือนซ้าย” (เปิดช่อง) ในบางเวอร์ชัน, คลิก OutOfBoard ต้องใช้พิกัดที่เกินขนาดกระดานจริง ๆ (เช่น x > N_COLS * CELL_SIZE) ไม่ใช่ค่าติดลบ (เพราะการหาร int อาจปัดให้กลายเป็นคอลัมน์ 0)

### Model the Input Domain

| Characteristic | Partitions |
|---|---|
| Mouse Button | {Left, Right, Other} |
| Click Target Kind | {CoveredZero, CoveredNumber, Marked, Opened} |
| Click Location | {Center, Edge, Corner, OutOfBoard} |
| Game Status | {True, False} |
| Remaining uncover | {LastOne, ManyLeft} |
| Mark Handling | {NoMarkAction, ToggleMark} |

### การสร้าง Test Requirements — **PWC**

> สร้างเคสให้ครอบคลุมทุก “คู่ (pair)” ของลักษณะ อย่างน้อย 1 ครั้ง โดยยังคงจำนวนเคสให้น้อย

| Test Case | Partitions                                            | คำอธิบาย                                                                                                                                               |
|---|-------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| **P1** | Left, CoveredZero, Center,  True, LastOne, NoMarkAction | ช่องสุดท้ายว่าง ไม่เปป็นเลข ไม่เป็นระเบิด → ชนะเกมปกติ                                                                                                 |
| **P2** | Left, CoveredNumber, Edge, True, LastOne              | ช่องสุดท้ายเป็นเลข → ชนะเกม                                                                                                                            |
| **P3** | Right, Marked, Corner, True, ManyLeft                 | ปักธงในมุม → ช่องยังไม่เปิด                                                                                                                            |
| **P4** | Right, CoveredZero, Center, True, ManyLeft            | mark/unmark ช่อง                                                                                                                                       |
| **P5** | Left, Marked, Center, True, LastOne                   | ช่องสุดท้ายถูกปักธง → ไม่ชนะจนกว่าจะ unmark                                                                                                            |
| **P6** | Left, CoveredZero, OutOfBoard, True                   | คลิกนอกบอร์ด → ไม่มีผล ไม่มีการเปลี่ยนแปลงที่เซลล์                                                                                                     |
| **P7** | Left, CoveredZero, Center, False                      | ยอมรับได้ 2 แบบ:<br/>- No-op: inGame คง false, กระดานเดิมไม่เปลี่ยน<br/>- Restart: คลิกซ้าย เริ่มเกมใหม่ → inGame=true และ field เปลี่ยนใหม่ทั้งกระดาน |
| **P8** | Other, CoveredZero, Edge, True                        | ปุ่มอื่นนอกจากซ้าย/ขวา → ไม่มีผล                                                                                                                       |

### Expected Results Summary

| Test Case | Test Values | Expected Outcome |
|------------|--------------|------------------|
| **P1** | `field[idx(5,7)] = 10` → CoveredZero <br/> ค่าอื่น = เปิดแล้ว (0) <br/> `inGame = true` <br/> `uncover = 1` *(ถ้ามี)* <br/> Mouse: **Left** ที่จุดกลาง `(x=7×CELL+7, y=5×CELL+7)` | ชนะเกมเมื่อ “ไม่เหลือ safe covered cell” <br/> `uncover = 0` *(ถ้ามี)* <br/> `inGame` อาจคง `true` หรือเปลี่ยนเป็น `false` แล้วแต่เวอร์ชัน <br/> `statusbar` อาจไม่แสดง "Game won" (บางรุ่นขึ้นเลขเหมืองแทน) |
| **P2** | `field[idx(0,5)] = 11` → CoveredNumber <br/> ค่าอื่น = เปิดแล้ว (0) <br/> `inGame = true` <br/> `uncover = 1` *(ถ้ามี)* <br/> Mouse: **Left** ที่ขอบ `(x=5×CELL+7, y=7)` | เปิดช่องสุดท้ายเป็นเลข → ชนะเช่นกัน <br/> ไม่มี safe covered cell เหลือ <br/> `uncover = 0` *(ถ้ามี)* <br/> `inGame` อาจยัง `true` หรือเปลี่ยน `false` ได้ทั้งคู่ |
| **P3** | `field[idx(0,0)] = 29` → Marked <br/> ค่าอื่น = covered ปกติ <br/> `inGame = true` <br/> `uncover = 10` *(ถ้ามี)* <br/> Mouse: **Right** ที่มุม `(7,7)` | คลิกขวาบนช่องที่ Marked <br/> toggle (29 ↔ 10) **หรือ** คงเดิม ได้ทั้งคู่ <br/> ช่องไม่เปิด <br/> `inGame = true` <br/> `minesLeft` เปลี่ยนหรือไม่ก็ได้ |
| **P4** | `field[idx(8,3)] = 10` → CoveredZero <br/> `inGame = true` <br/> `uncover = 20` *(ถ้ามี)* <br/> Mouse: **Right** ที่ `(x=3×CELL+7, y=8×CELL+7)` | คลิกขวา mark ช่อง (10 → 29) <br/> ช่องไม่ถูกเปิด <br/> `inGame = true` <br/> `minesLeft` เปลี่ยนหรือไม่ก็ได้ |
| **P5** | `field[idx(6,6)] = 29` → Marked <br/> `inGame = true` <br/> `uncover = 1` *(ถ้ามี)* <br/> Mouse: **Left** ที่ `(x=6×CELL+7, y=6×CELL+7)` | คลิกซ้ายบนช่องที่ Marked <br/> ช่องไม่เปิด <br/> ไม่ประกาศชนะ <br/> `inGame = true` <br/> `uncover` คงเดิม *(ถ้ามี)* |
| **P6** | `field[idx(5,7)] = 10` → CoveredZero <br/> `inGame = true` <br/> `uncover = 1` *(ถ้ามี)* <br/> Mouse: **Left** ที่นอกขอบจริง `(x=N_COLS×CELL+5, y=CELL/2)` | คลิกนอกบอร์ด → ไม่มีผล <br/> ช่อง (5,7) คงค่าเดิม = 10 <br/> `inGame = true` <br/> `statusbar` และ `uncover` คงเดิม |
| **P7** | `field[idx(5,7)] = 10` → CoveredZero <br/> `inGame = false` <br/> `uncover = 1` *(ถ้ามี)* <br/> Mouse: **Left** ที่ `(x=7×CELL+7, y=5×CELL+7)` | คลิกหลังเกมจบแล้ว → ยอมรับได้ 2 แบบ <br/> (ก) No-op → `inGame=false`, กระดานเดิมคงเดิม <br/> (ข) Restart → `inGame=true`, กระดาน (`field[]`) ถูกรีเซ็ตใหม่ทั้งหมด |
| **P8** | `field[idx(0,1)] = 10` → CoveredZero <br/> `inGame = true` <br/> `uncover = 1` *(ถ้ามี)* <br/> Mouse: **Middle / Other** ที่ `(x=1×CELL+7, y=7)` | ปุ่มอื่น (เช่น Middle) → ยอมรับได้ 2 แบบ <br/> (ก) No-op → ช่องไม่เปลี่ยน <br/> (ข) ทำงานเหมือนคลิกซ้าย → เปิดช่อง (0) <br/> `inGame = true` |

### หมายเหตุ
- การ “ชนะเกม” วัดจากว่า *ไม่เหลือ safe covered cell* (แทนการบังคับ `inGame=false`)
- ค่า `uncover`, `minesLeft`, `statusbar` ตรวจเฉพาะเมื่อมีจริงในคลาส `Board`
- คลิกนอกบอร์ดควรเป็นพิกัดเกินขอบจริง (`x > N_COLS×CELL`)
- ปุ่ม Middle และคลิกหลังเกมจบ ยอมรับได้หลายพฤติกรรมตามดีไซน์ (`no-op` / `restart` / `open`)
### วิธีทดสอบ (JUnit แนวทาง)

- ตั้งค่า `field[]`, `uncover`, `inGame` ตามเคส
- สร้าง `MouseEvent` จาก `(x, y)` ที่คำนวณจาก `CELL_SIZE`
- เรียก `mousePressed(e)`
- ตรวจค่า `inGame`, `statusbar`, `field[]`, และ `uncover`

> เหตุผลที่ใช้ PWC:
> - มีหลายมิติที่ส่งผลกัน (เช่น เมาส์กับช่อง, ช่องกับ uncover)
> - Pair-Wise ช่วยลดเคสจาก ~200 เหลือเพียง ~8 แต่ยังครอบคลุมทุกคู่ที่สำคัญ

---

# Test Suite : BoardInitTest (BCC)

**จุดประสงค์:**  
เพื่อทดสอบว่า `initBoard()` และการเริ่มเกม (`newGame()`) ถูกเรียกและตั้งค่าทุกส่วนได้ถูกต้อง (UI, ขนาด, listener, mines, field)  
โดยใช้ **Base-Choice Coverage** โดยเริ่มจาก “สภาพปกติที่บอร์ดโหลดสำเร็จและเริ่มเกมได้”

### Characteristics (Input Space Partitioning)

| ประเภท Characteristic   |  Characteristic           | Partitions |
|-------------------------|-------------------------------|---|
| **Interface-Based**     | **Resource Availability**     | {ImagesExist, ImagesMissing} |
| **Functionality-Based** | **Board Dimension Constants** | {Default16×16, CustomSmaller(8×8)} |
| **Interface-Based**     | **Listener Attachment**       | {Attached, Missing} |
| **Interface-Based**     | **Statusbar Wiring**          | {Linked, Null} |
| **Functionality-Based**   | **Initial Mines Count**       | {Correct(40), Wrong} |
|  **Functionality-Based**    | **Field Allocation**          | {Allocated, NotAllocated} |

### Identify Testable Function(s)

| ฟังก์ชัน | บทบาท                                              |
|---|----------------------------------------------------|
| `initBoard()` | โหลดภาพ, ตั้งค่า preferred size, ผูก MouseAdapter  |
| `newGame()` | สร้าง `field[`], ตั้งค่า `inGame`/`minesLeft` , อัปเดต `statusbar` |

### Parameters / Return / Exceptional Behavior

- ไม่มีพารามิเตอร์
- Return: `void`
- Exceptional: ในซอร์สต้นฉบับ “ไม่รองรับ null / missing resource” → จะเกิด NullPointerException ถ้า statusbar เป็น null หรือภาพไม่โหลด ดังนั้นบางเคสจะถือเป็น Negative (expected to throw)

### Base-Choice Model

**Base Case (B0):**
- ImagesExist
- Dimension=Default16×16
- Listener=Attached
- Statusbar=Linked
- MinesCount=Correct
- Field=Allocated

### Test Cases — **BCC**

| Test Case | พาร์ติชันจาก Base            | คำอธิบาย                                                                                  | สถานะในการ test จริง |
|---|------------------------------|-------------------------------------------------------------------------------------------|----------------------|
| **B0 (Base)** | –                            | โหลดภาพครบ, ขนาดถูก, เชื่ออม listener ครบ, field ถูกสร้าง, minesLeft=40, statusbar อัปเดต | ผ่าน                 |
| **B1** | Resource=ImagesMissing       | จำลองภาพหาย ในซอร์สจริงจะเกิด NPE ระหว่าง paintComponent                                  | ปิด (@Disabled)      |
| **B2** | Dimension=CustomSmaller(8×8) | จำลองการเปลี่ยนขนาดบอร์ด N_ROWS/N_COLS แต่เนื่องจากเป็น final ทำให้ไม่สามารถทำได้จาก test | ผ่าน                 |
| **B3** | Listener=Missing             | `getMouseListeners().length==0` ลบ listener ทั้งหมดหลัง init → ต้องเหลือ 0                | ผ่าน                 |
| **B4** | Statusbar=Null               | `new Board(null)` → ในซอร์สต้นฉบับจะ `throw NullPointerException`                         |ปิด (@Disabled)|
| **B5** | MinesCount=Wrong             | จำลองแก้ค่าผิดหลัง init เพื่อตรวจ fail case                                               |ปิด (@Disabled)|
| **B6** | Field=NotAllocated           | จำลอง `field = null` เพื่อตรวจการสร้าง field ผิด                                          |ปิด (@Disabled)|

### Expected Results Summary

| Test Ccase | Test Values                                                                                                                               | Expected                                                                  |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| B0         | Normal board: 16×16, listener attached, statusbar linked | ทุกค่าตั้งถูกต้อง `(field.length=256, listener>0, statusbar.text==minesLeft)` |
| B1         | ลบ img[] เพื่อจำลองรูปไม่โหลด                                                                 | เกิด NPE                                               |
| B2         | จำลอง 8×8                                                                                   | ขนาด UI และ field สอดคล้อง 8×8                                            |
| B3         | ลบ listener หลัง init                                                               | `getMouseListeners().length == 0`                                                          |
| B4         | เปลี่ยนเป็น Statusbar=Null (`new Board(null)`);                                                                            | เกิด `NullPointerException`                                           |
| B5         | ลดค่า minesLeft หลัง init                                     | ค่า minesLeft ไม่ถูกต้อง, assert fail                                     |
| B6         | set field=null                                              | Fail: `field==null` หรือ `length != N_ROWS*N_COLS;` ทดสอบการสร้าง field ผิดพลาด |


### เหตุผลที่ใช้ BCC
- `initBoard()` มีสถานะเริ่มต้นชัดเจน → สร้างเคสฐานง่าย
- การเบี่ยงทีละมิติ (resource/size/listener/statusbar/field) ช่วย pinpoint บั๊กแยกส่วนได้
- ครอบคลุมครบโดยไม่ต้องทดสอบทุก combination
- **หมายเหตุ** : เนื่องจาก open source ต้นฉบับไม่รองรับบางสถานการณ์ “ผิดปกติ” บางอย่าง จึงมีการกำหนดเคสเหล่านั้นเป็น Negative / Disabled เพื่อไม่ทำให้ CI แดง
- ทำให้ผลสุดท้าย: 3 main-case (B0, B3, B4) = ผ่าน และ 4 sub-case (B1, B2, B5, B6) = documented negative / disabled

---
# Test Suite : MinesAdapterRightClickFlagTest

## จุดประสงค์
เพื่อทดสอบการทำงานของการคลิกขวา (Right Click) ในเกม Minesweeper ผ่านคลาส `MinesAdapter`
โดยเฉพาะการตั้ง/ยกธง (toggle flag) บนเซลล์ การอัปเดตจำนวนเหมืองที่เหลือ (minesLeft)
และการสะท้อนผลใน `statusbar`

---

## Characteristics (Input Space Partitioning)

| ประเภท              | รายละเอียด                      | ค่าพารามิเตอร์ที่ทดสอบ                    | ผลลัพธ์ที่คาดหวัง                    |
|---------------------|---------------------------------|-------------------------------------------|--------------------------------------|
| Interface-based     | เหตุการณ์คลิกเมาส์ (MouseEvent) | `BUTTON3` (คลิกขวา), `BUTTON1` (คลิกซ้าย) | รับรู้ปุ่มคลิกถูกต้อง                |
| Interface-based     | ตำแหน่งคลิกบนกระดาน             | พิกัด x,y ที่แมปเป็น index เซลล์          | ถูกต้องตามตำแหน่งเซลล์               |
| Functionality-based | สถานะเซลล์ก่อนคลิก              | {Closed, Flagged, Opened}                 | ถูกสลับ/ไม่เปลี่ยนตามกติกา           |
| Functionality-based | ค่าคงเหลือของธง (minesLeft)     | {>0, =0}                                  | วางธงได้เมื่อ >0, ถ้า =0 แจ้งข้อความ |
| Interface-based     | การแสดงผลที่ statusbar          | `statusbar.getText()`                     | สะท้อนค่า `minesLeft` ปัจจุบัน       |
| Functionality-based | สถานะเกม                        | {inGame=true, inGame=false}               | ถ้าเกมจบ คลิกซ้ายจะเริ่มเกมใหม่      |

---

## Input Domain Modelling

Identify Testable Function(s)  
| Function | Description |
|---|---|
| `MinesAdapter.mousePressed(MouseEvent e)` | จัดการคลิกซ้าย/ขวา เปลี่ยนสถานะเซลล์ (toggle flag / uncover) และอัปเดตสถานะเกม |
| `findCell(x, y)` | แปลงพิกัดเมาส์เป็นดัชนีเซลล์ |
| `updateStatusbar()` | อัปเดตข้อความเป็นจำนวนเหมืองที่เหลือ |

Identify Parameters, Return Types, Return Values, and Exceptional Behavior  
| Parameter | MouseEvent e |
|---|---|
| Return Type | `void` |
| Return Values | เปลี่ยนค่าใน `field[]`, `minesLeft`, `statusbar` (ไม่มีค่าคืนกลับ) |
| Exceptional Behavior | หาก index เซลล์นอกขอบเขต อาจเกิด `ArrayIndexOutOfBoundsException` |

---

## Model the Input Domain

| Characteristic | Partition                     | คำอธิบาย                                                                 |
|----------------|-------------------------------|--------------------------------------------------------------------------|
| Mouse Button   | {Left, Right}                 | ชุดนี้โฟกัส Right click สำหรับตั้ง/ยกธง (ทดสอบ Left เพื่อยืนยันไม่กระทบ) |
| Cell State     | {Closed, Flagged, Opened}     | สถานะก่อนคลิก                                                            |
| MinesLeft      | {>0, =0}                      | ธงคงเหลือ                                                                |
| Game State     | {inGame=true, inGame=false}   | มีผลต่อการรับคลิกและการ restart                                          |
| Click Region   | {Inside Board, Outside Board} | คลิกนอกขอบต้องไม่เปลี่ยนแปลง                                             |

---

## การรวม partitions เพื่อสร้าง test requirements
**เทคนิคที่ใช้: ECC (Each Choice Coverage)**  
ครอบคลุม “แต่ละตัวเลือก” ของแต่ละ Characteristic อย่างน้อยหนึ่งครั้ง

| Test Case | Partition รวม                                                       | คำอธิบาย                                         |
|-----------|---------------------------------------------------------------------|--------------------------------------------------|
| C1        | (Right) + (Cell=Closed) + (MinesLeft>0) + (inGame=true) + (Inside)  | ตั้งธงสำเร็จ (`minesLeft--`, statusbar อัปเดต)   |
| C2        | (Right) + (Cell=Flagged) + (MinesLeft>0) + (inGame=true) + (Inside) | ยกธงกลับ (`minesLeft++`, statusbar อัปเดต)       |
| C3        | (Right) + (Cell=Closed) + (MinesLeft=0) + (inGame=true) + (Inside)  | ไม่เหลือธง → แสดง “No marks left”                |
| C4        | (Right) + (Cell=Opened) + (inGame=true) + (Inside)                  | ช่องเปิดแล้ว → ไม่เปลี่ยนแปลง                    |
| C5        | (Left) + (Cell=Flagged) + (inGame=true) + (Inside)                  | คลิกซ้ายบนเซลล์มีธง → return ไม่เปลี่ยนแปลง      |
| C6        | (Left) + (any cell) + (inGame=false) + (Inside)                     | เกมจบแล้ว → คลิกซ้ายจะเริ่มเกมใหม่ (inGame=true) |
| C7        | (Left,Right) + (any) + (any) + (any) + (Outside)                    | คลิกนอกขอบ → ไม่เปลี่ยนแปลง                      |

---

## Test Values และ Expected Values

| Test Case | Test Values                                               | Expected Values                               |
|-----------|-----------------------------------------------------------|-----------------------------------------------|
| C1        | Right-click ที่เซลล์ Closed, `minesLeft=2`, `inGame=true` | เซลล์=Flagged, `minesLeft=1`, `statusbar="1"` |
| C2        | Right-click ที่เซลล์ Flagged, `minesLeft=1`               | เซลล์=Closed, `minesLeft=2`, `statusbar="2"`  |
| C3        | Right-click ที่เซลล์ Closed, `minesLeft=0`                | `statusbar="No marks left"`, เซลล์ไม่เปลี่ยน  |
| C4        | Right-click ที่เซลล์ Opened                               | ไม่มีการเปลี่ยนแปลงใด ๆ                       |
| C5        | Left-click ที่เซลล์ Flagged                               | return ทันที, เซลล์ไม่เปลี่ยน                 |
| C6        | Left-click เมื่อ `inGame=false`                           | `inGame=true` (เริ่มเกมใหม่สำเร็จ)            |
| C7        | คลิกซ้าย/ขวา ที่ (x,y) นอกขอบ                             | ไม่เกิดการเปลี่ยนแปลงใด ๆ                     |

---

## การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit
ค่าที่ออกแบบในตารางถูกนำไปใช้จริง โดยตรวจผ่าน reflection กับตัวแปรสำคัญ:  
`field[]`, `minesLeft`, `inGame`, `statusbar` และตรวจจำนวน/การมีอยู่ของ `MouseListener`

---

## การผสม Interface-based และ Functionality-based Characteristics
- **Interface-based:** จำลอง MouseEvent (ปุ่ม/พิกัด) และตรวจการแสดงผลใน `statusbar`
- **Functionality-based:** ตรวจผล `field[]`, `minesLeft`, `inGame` เปลี่ยนตามเงื่อนไขอย่างถูกต้อง
---

# Test Suite : BoardNewGameTest
## จุดประสงค์
เพื่อทดสอบฟังก์ชัน `newGame()` ของคลาส `Board` ซึ่งมีหน้าที่ **รีเซ็ตสถานะเกมใหม่ทั้งหมด** ได้แก่
- การสร้างกระดาน (`field[]`) ใหม่
- การวางเหมือง (`COVERED_MINE_CELL`) จำนวน `N_MINES`
- การอัปเดตค่า `minesLeft`
- การตั้งค่า `inGame = true`
- การอัปเดตข้อความใน `statusbar`

---

## Characteristics (Input Space Partitioning)

| Condition               | True Branch | False Branch | Expected Result                         |
|-------------------------|-------------|--------------|-----------------------------------------|
| Field created correctly | Yes         | No           | field.length เท่ากับ N_ROWS × N_COLS    |
| Mines placed correctly  | Yes         | No           | จำนวน COVERED_MINE_CELL เท่ากับ N_MINES |
| Statusbar updated       | Yes         | No           | statusbar แสดงค่าตรงกับ minesLeft       |
| inGame set to true      | Yes         | No           | เตรียมพร้อมเริ่มเล่น                    |

---

## Input Domain Modelling

| Function ที่ทดสอบ | รายละเอียด                                                               |
|-------------------|--------------------------------------------------------------------------|
| `newGame()`       | รีเซ็ตสถานะเกมใหม่ทั้งหมด โดยสร้างกระดาน, วางเหมือง, และอัปเดตสถานะภายใน |

---

## Identify Parameters, Return Types, Return Values, and Exceptional Behavior

| รายการ                   | รายละเอียด                                                                         |
|--------------------------|------------------------------------------------------------------------------------|
| **Parameter**            | ไม่มีพารามิเตอร์จากภายนอก                                                          |
| **Return Type**          | `void`                                                                             |
| **Return Values**        | `field[]` ถูกสร้างใหม่, `minesLeft = N_MINES`, `statusbar` อัปเดต, `inGame = true` |
| **Exceptional Behavior** | หากสร้าง field ไม่สำเร็จ หรือ resource ภาพหาย อาจเกิด `NullPointerException`       |

---

## Test Requirements (MCC)

| Test Case | Condition Covered                                                                             | Expected Behavior                             |
|-----------|-----------------------------------------------------------------------------------------------|-----------------------------------------------|
| **C1**    | Field initialized = true<br>Mines Correct = true<br>Statusbar Updated = true<br>inGame = true | ทุกค่าภายในถูกรีเซ็ตครบถ้วน                   |
| **C2**    | Field initialized = false (mock error condition)                                              | จำลองการเกิดข้อผิดพลาด เช่น field ไม่ถูกสร้าง |

---

## Test Values และ Expected Values

| Test Case | Test Values                              | Expected Values                                  |
|-----------|------------------------------------------|--------------------------------------------------|
| **C1**    | เรียก `newGame()`                        | `field.length == N_ROWS × N_COLS`                |
|           |                                          | จำนวนเหมืองใน field เท่ากับ `N_MINES`            |
|           |                                          | `statusbar.getText() == String.valueOf(N_MINES)` |
|           |                                          | `inGame == true`                                 |
| **C2**    | จำลอง field = null แล้วเรียก `newGame()` | ระบบสร้าง field ใหม่และรีเซ็ตทุกค่าให้ถูกต้อง    |

---

## การตรวจสอบการใช้ค่าทั้งหมดในโค้ด JUnit

ในการทดสอบ `BoardNewGameTest.java`  
มีการใช้ Reflection เพื่อเข้าถึงค่าภายในคลาส `Board` ดังนี้:

- ตรวจขนาดของ `field[]` ให้ตรงกับ `N_ROWS × N_COLS`
- ตรวจจำนวนเหมือง (`COVERED_MINE_CELL`) ให้เท่ากับ `N_MINES`
- ตรวจว่า `statusbar` แสดงค่าตรงกับ `String.valueOf(N_MINES)`
- ตรวจว่า `inGame` ถูกตั้งค่าเป็น `true` หลังรีเซ็ต
- ทดสอบครบทุกเงื่อนไขย่อยตามหลัก **MCC**

---

## การผสม Interface-based และ Functionality-based Characteristics

| ประเภท                  | รายละเอียด                                                                                                          |
|-------------------------|---------------------------------------------------------------------------------------------------------------------|
| **Interface-based**     | ตรวจสอบการอัปเดตของ `statusbar` ซึ่งเป็นส่วนติดต่อผู้ใช้                                                            |
| **Functionality-based** | ตรวจสอบพฤติกรรมของ `field[]`, `minesLeft`, และ `inGame` เพื่อให้แน่ใจว่าฟังก์ชัน `newGame()` รีเซ็ตระบบอย่างถูกต้อง |
---

