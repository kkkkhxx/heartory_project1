# Java-Minesweeper-Game
Java Minesweeper game source code

https://zetcode.com/javagames/minesweeper/


![Minesweeper game screenshot](minesweeper.png)




### Test Suite : BoardConstructorTest

**จุดประสงค์:**  
เพื่อทดสอบการทำงานของ constructor ของคลาส Board ซึ่งทำหน้าที่กำหนดค่าเริ่มต้นของเกม Minesweeper
ตั้งแต่การเตรียมทรัพยากร (ภาพ, กระดาน, ตัวแปรเกม) ไปจนถึงการเชื่อมต่อกับองค์ประกอบ UI (JLabel สำหรับ status bar)

**Characteristics (Input Space Partitioning)**

| ประเภท Characteristic | รายละเอียด (Characteristic Description) | ค่าหรือพารามิเตอร์ที่ทดสอบ | จุดประสงค์/ผลลัพธ์ที่คาดหวัง |
|------------------------|------------------------------------------|-------------------------------|--------------------------------|
| **Interface-based** | พารามิเตอร์ที่ส่งเข้า Constructor (`JLabel statusbar`) | `new Board(new JLabel())` | ตรวจสอบว่าการสร้าง `Board` ด้วย status bar ภายนอกสามารถเชื่อมโยงได้ถูกต้อง (ไม่เป็น null) |
| **Interface-based** | การกำหนดขนาดของกระดาน (`PreferredSize`) | `board.getPreferredSize()` | ตรวจสอบว่าค่าที่คืนมาคือ 241×241 ตามสูตร `(16×15)+1` |
| **Interface-based** | การโหลดภาพ sprite ทั้งหมด | ตัวแปร `img[]` ขนาด 13 | ตรวจสอบว่าภาพทั้ง 13 ไฟล์ถูกโหลดเข้ามาไม่เป็น null |
| **Functionality-based** | การตั้งค่าสถานะเริ่มต้นของเกม | ตัวแปร `inGame` | ตรวจสอบว่าเริ่มเกมต้องเป็น `true` เสมอ |
| **Functionality-based** | การสร้างกระดานใหม่ (`field[]`) | ความยาวของ field = 16×16 | ตรวจสอบว่าขนาดของกระดานถูกต้องตามค่าคงที่ `N_ROWS` และ `N_COLS` |
| **Functionality-based** | การผูก Event Listener | `board.getMouseListeners()` | ตรวจสอบว่ามีการแนบ MouseAdapter สำหรับตรวจจับการคลิก |
| **Functionality-based** | การแสดงข้อความใน Statusbar | `statusbar.getText()` เท่ากับ `minesLeft` | ตรวจสอบว่าข้อความสถานะตรงกับค่าที่ระบบตั้งไว้ในเกม |


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
| **Return Type** | ไม่มี (constructor ไม่คืนค่า) |
| **Return Values (ผลลัพธ์ที่สังเกตได้)** | ตัวแปรภายใน `Board` ถูกตั้งค่า เช่น `inGame=true`, `minesLeft=40`, `field[]` ถูกสร้าง, โหลดภาพครบ, และ `statusbar` แสดงข้อความ |
| **Exceptional Behavior** | หากภาพใน `src/resources/` หายหรือ `JLabel` เป็น `null` อาจเกิด `NullPointerException` |

---

**Model the Input Domain**

| ประเภท Characteristic | ชื่อ Characteristic | Partition | คำอธิบาย |
|------------------------|--------------------|------------|------------|
| **Interface-based** | Statusbar Parameter | {Valid JLabel, Null JLabel} | ปกติใช้ JLabel จริง, ถ้าเป็น null จะไม่สามารถเชื่อมต่อได้ |
| **Interface-based** | Resource Path | {Images Exist, Images Missing} | ปกติทุกภาพอยู่ครบใน `src/resources/` |
| **Functionality-based** | Game State (inGame) | {true, false} | เริ่มเกมต้องเป็น `true` เสมอ |
| **Functionality-based** | Field Initialization | {Initialized, Null} | ต้องถูกสร้างความยาว = 256 ช่อง (16×16) |
| **Functionality-based** | Mines Count | {Correct=40, Incorrect} | ค่าเริ่มต้นต้องตรงกับจำนวนเหมือง |
| **Functionality-based** | Listener Registration | {Listener Attached, Not Attached} | ต้องมี MouseAdapter ถูกแนบกับกระดาน |

---

**การรวม partitions เพื่อสร้าง test requirements**
> **เทคนิคที่ใช้:** ACoC (Each Choice of Combination)

| Test Case | Partition ที่ใช้รวมกัน | คำอธิบาย |
|--------|-----------------------|------------|
| C1 | (Statusbar = Valid JLabel) + (Images = Exist) + (inGame = true) | ตรวจสถานะเริ่มต้นของเกมที่ถูกต้อง |
| C2 | (Listener = Attached) + (Statusbar = Valid JLabel) | ตรวจว่ามี MouseListener และข้อความสถานะตรง |
| C3 | (Field = Initialized) + (Mines = Correct) | ตรวจขนาดกระดานและจำนวนเหมือง |
| C4 | (Images = Exist) + (Field = Initialized) | ครอบคลุมการโหลดทรัพยากรและตั้งค่าใหม่ใน newGame() |

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

| ประเภท | รายละเอียด | ค่า/พารามิเตอร์ที่ทดสอบ | จุดประสงค์ |
|----------|-------------|----------------|--------------|
| **Interface-based** | Graphics object | ใช้ BufferedImage.createGraphics() | จำลองการวาดโดยไม่เปิด GUI |
| **Interface-based** | Field values | {0, 9, 15, 19, 20, 29} | จำลองสถานะ cell |
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

| Test Case | Input | Expected Output |
|-----|--------|-----------------|
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


---
