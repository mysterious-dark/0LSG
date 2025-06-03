## Thiết Kế Hệ Thống Combat Dựa Trên Arknights - Chủ Đề Hệ Điều Hành

### 1. Tổng Quan

Trò chơi là một tựa chiến thuật thời gian thực theo phong cách tower defense giống Arknights, kết hợp chủ đề hệ điều hành máy tính. Người chơi vào vai Quản trị viên hệ thống, triển khai các "tiến trình" (operator) là những chương trình hoặc script để bảo vệ hệ thống khỏi các cuộc tấn công của virus, malware hoặc lỗi hệ thống.

### 2. Hệ Thống Chiến Đấu

#### 2.1 Dạng Bản Đồ

* **Bản đồ có lưới ô (grid) với đường đi định sẵn** cho kẻ địch (path-based), các tiến trình được triển khai tại các ô hợp lệ.
* **Ô đặc biệt**: RAM Bank (hồi CPU), Firewall Zone (tăng DEF), Corruption Zone (giảm sát thương).

#### 2.2 CPU Cycles (Tương đương DP trong Arknights)

* Tăng theo thời gian.
* Dùng để triển khai tiến trình hoặc thi triển kỹ năng đặc biệt.

#### 2.3 Tiến Trình (Operator)

Mỗi tiến trình là một "unit" có class, kỹ năng và thuộc tính riêng:

| Loại    | Vai trò                        | Ví dụ script   |
| ------- | ------------------------------ | -------------- |
| Blocker | Chặn và chống địch             | firewall.sh    |
| Sniper  | Gây sát thương xa đơn mục tiêu | kill-9.sh      |
| Caster  | Gây sát thương AoE             | rm-rf.sh       |
| Healer  | Hồi phục HP cho đồng minh      | sudo-reboot.sh |
| Support | Buff, debuff                   | chmod+x.sh     |
| Scout   | Tăng tầm nhìn, soi địch        | grep.sh        |

#### 2.4 Kỹ Năng Lệnh OS

Mỗi tiến trình có một hoặc nhiều kỹ năng, tiêu hao CPU, hồi theo thời gian:

| Lệnh        | Hiệu ứng                                   | CPU | Hồi chiêu |
| ----------- | ------------------------------------------ | --- | --------- |
| kill -9     | Kết liễu địch yếu máu                      | 5   | 3 lượt    |
| sudo reboot | Hồi 50% HP cho đồng minh                   | 4   | 4 lượt    |
| chmod +x    | Buff 20% sát thương cho đồng minh (2 lượt) | 3   | 3 lượt    |
| rm -rf      | Gây sát thương diện rộng (30%)             | 6   | 4 lượt    |
| grep        | Lộ vị trí địch trong phạm vi               | 2   | 0 lượt    |
| top         | Hiện thông số kẻ địch                      | 2   | 2 lượt    |

### 3. Cơ Chế Gameplay

* Kẻ địch xuất hiện theo đợt (wave), đi theo đường định sẵn.
* Người chơi có thể **triển khai / rút tiến trình** tùy lúc, miễn đủ CPU.
* **Kỹ năng** có thể được kích hoạt tự động hoặc thủ công.
* Mỗi tiến trình có giới hạn block (1-3 tùy loại).

### 4. Giao Diện Người Dùng

* **UI kỹ năng**: Hiển thị theo dạng icon command line.
* **Thanh CPU**: Hiện lượng CPU hiện tại & tốc độ hồi.
* **Log hệ thống**: Hiển thị các sự kiện như deploy, skill dùng, địch chết...

### 5. Chiến Thuật Gợi Ý

* **Kết hợp lệnh**: Buff trước khi tung kill -9.
* **Chiếm ô chiến lược**: Đặt tiến trình tại vị trí có Firewall hoặc RAM.
* **Điều phối CPU**: Không spam hết CPU, giữ lại cho phản ứng tình huống khẩn.

### 6. Mục Tiêu

* Mang lại trải nghiệm chiến thuật thời gian thực có chiều sâu.
* Giao diện dễ tiếp cận, phù hợp cả trẻ em và người yêu công nghệ.
* Không pay-to-win, thưởng hợp lý, khuyến khích học hỏi lệnh máy tính.

### 7. Hướng Triển Khai

* Ưu tiên mobile và PC.
* Phát triển từng bước: đầu tiên với 6-8 tiến trình cơ bản, 1 bản đồ mẫu.
* Sau đó mở rộng class mới, bản đồ đặc biệt, hệ thống nâng cấp chuyên sâu.
