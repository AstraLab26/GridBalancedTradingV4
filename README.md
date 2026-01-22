# Grid Balanced Trading V4 - MetaTrader 5

## 📋 Mô tả

**Grid Balanced Trading V4** là phiên bản nâng cấp của Expert Advisor (EA) cho MetaTrader 5 được thiết kế để thực hiện chiến lược giao dịch lưới (Grid Trading) với hệ thống cân bằng lưới tự động. EA tự động đặt các lệnh pending (Buy Limit, Buy Stop, Sell Limit, Sell Stop) tại các mức giá được xác định trước dựa trên khoảng cách lưới.

## 📌 Thông tin phiên bản

- **Tên file**: `GridBalancedTradingV4.mq5`
- **Phiên bản**: 4.00
- **Ngôn ngữ**: MQL5 (MetaTrader 5)
- **Trạng thái**: Phiên bản nâng cấp với tính năng Lot-based Reset và Panel hiển thị thông tin

## ✨ Tính năng chính

- **Hệ thống lưới tự động**: Tự động tạo và quản lý các lệnh tại các mức giá được tính toán sẵn
- **Cân bằng lưới**: Đảm bảo mỗi mức giá chỉ có tối đa 1 lệnh Buy và 1 lệnh Sell để tránh mất cân bằng
- **Cấu hình riêng biệt**: Bật/tắt và cấu hình độc lập cho từng loại lệnh (Buy Limit, Sell Limit, Buy Stop, Sell Stop)
- **Lot size và TP riêng**: Mỗi loại lệnh có lot size và Take Profit riêng
- **Gấp thếp (Martingale)**: Hỗ trợ gấp thếp riêng cho từng loại lệnh với hệ số tùy chỉnh
- **Ghi nhớ lot size**: Tự động ghi nhớ lot size theo mức lưới khi đạt TP và bổ sung lại với đúng lot size đó
- **TP tổng**: 3 loại TP tổng (lệnh mở, phiên, tích lũy) với tùy chọn Reset hoặc Dừng EA
- **Trading Stop, Step Tổng (Gồng lãi)**: Tính năng V3 - Tự động bảo vệ lãi khi đạt ngưỡng và gồng lãi theo giá
- **Lot-based Reset**: Tính năng mới V4 - Reset EA dựa trên điều kiện lot và tổng phiên
- **Panel hiển thị thông tin**: Tính năng mới V4 - Panel trực quan hiển thị thông tin EA trên chart với format số tiền K$/M$
- **Thông báo về điện thoại**: Tính năng mới V4 - Gửi thông báo push notification về điện thoại khi EA reset
- **Theo dõi lịch sử**: Một số thông số không reset khi EA reset (số tiền lỗ lớn nhất, số lot lớn nhất, tổng lot lớn nhất)
- **Tự động bổ sung lệnh**: Tùy chọn tự động tạo lại lệnh khi lệnh cũ bị đóng
- **Magic Number**: Quản lý lệnh riêng biệt với Magic Number

## 🛠️ Cài đặt

1. Sao chép file `GridBalancedTradingV4.mq5` vào thư mục `MQL5/Experts/` của MetaTrader 5
2. Khởi động lại MetaTrader 5 hoặc làm mới Navigator (F5)
3. Kéo và thả EA vào biểu đồ mong muốn
4. Cấu hình các tham số theo nhu cầu
5. Bật chế độ AutoTrading
6. Panel thông tin sẽ tự động hiển thị trên chart

## ⚙️ Tham số cấu hình

### Cài đặt lưới

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `GridDistancePips` | Khoảng cách giữa các mức giá trong lưới (pips) | 20.0 |
| `MaxGridLevels` | Số lượng mức lưới tối đa mỗi phía (trên và dưới giá cơ sở) | 10 |
| `AutoRefillOrders` | Tự động bổ sung lệnh khi lệnh cũ bị đóng | true |

### Cài đặt lệnh Buy Limit

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `EnableBuyLimit` | Cho phép lệnh Buy Limit | true |
| `LotSizeBuyLimit` | Khối lượng Buy Limit (mức 1) | 0.01 |
| `TakeProfitPipsBuyLimit` | Take Profit Buy Limit (pips, 0=off) | 30.0 |
| `EnableMartingaleBuyLimit` | Bật gấp thếp Buy Limit | false |
| `MartingaleMultiplierBuyLimit` | Hệ số gấp thếp Buy Limit (mức 2=x2, mức 3=x4...) | 2.0 |

### Cài đặt lệnh Sell Limit

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `EnableSellLimit` | Cho phép lệnh Sell Limit | true |
| `LotSizeSellLimit` | Khối lượng Sell Limit (mức 1) | 0.01 |
| `TakeProfitPipsSellLimit` | Take Profit Sell Limit (pips, 0=off) | 30.0 |
| `EnableMartingaleSellLimit` | Bật gấp thếp Sell Limit | false |
| `MartingaleMultiplierSellLimit` | Hệ số gấp thếp Sell Limit (mức 2=x2, mức 3=x4...) | 2.0 |

### Cài đặt lệnh Buy Stop

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `EnableBuyStop` | Cho phép lệnh Buy Stop | true |
| `LotSizeBuyStop` | Khối lượng Buy Stop (mức 1) | 0.01 |
| `TakeProfitPipsBuyStop` | Take Profit Buy Stop (pips, 0=off) | 30.0 |
| `EnableMartingaleBuyStop` | Bật gấp thếp Buy Stop | false |
| `MartingaleMultiplierBuyStop` | Hệ số gấp thếp Buy Stop (mức 2=x2, mức 3=x4...) | 2.0 |

### Cài đặt lệnh Sell Stop

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `EnableSellStop` | Cho phép lệnh Sell Stop | true |
| `LotSizeSellStop` | Khối lượng Sell Stop (mức 1) | 0.01 |
| `TakeProfitPipsSellStop` | Take Profit Sell Stop (pips, 0=off) | 30.0 |
| `EnableMartingaleSellStop` | Bật gấp thếp Sell Stop | false |
| `MartingaleMultiplierSellStop` | Hệ số gấp thếp Sell Stop (mức 2=x2, mức 3=x4...) | 2.0 |

### TP Tổng

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `TotalProfitTPOpen` | TP tổng lệnh đang mở (USD, 0=off) | 0.0 |
| `ActionOnTotalProfitOpen` | Hành động khi đạt TP tổng lệnh mở (0=Dừng EA, 1=Reset EA) | Reset EA |
| `TotalProfitTPSession` | TP tổng phiên (USD, 0=off) | 0.0 |
| `ActionOnTotalProfitSession` | Hành động khi đạt TP tổng phiên (0=Dừng EA, 1=Reset EA) | Reset EA |
| `TotalProfitTPAccumulated` | TP tổng tích lũy (USD, 0=off) | 0.0 |

### Trading Stop, Step Tổng (Gồng lãi)

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `EnableTradingStopStepTotal` | Bật Trading Stop, Step Tổng | false |
| `TradingStopStepMode` | Chế độ gồng lãi (0=Theo lệnh mở, 1=Theo phiên) | Theo lệnh mở |
| `TradingStopStepTotalProfit` | Lãi tổng lệnh đang mở để kích hoạt (USD, dùng khi chế độ = Theo lệnh mở, 0=off) | 50.0 |
| `TradingStopStepSessionProfit` | Lãi tổng phiên để kích hoạt (USD, dùng khi chế độ = Theo phiên, 0=off) | 50.0 |
| `TradingStopStepReturnProfit` | Lãi tổng khi quay lại để tiếp tục (USD, nếu < ngưỡng kích hoạt thì hủy) | 20.0 |
| `TradingStopStepPointA` | Điểm A cách lệnh dương thấp nhất/cao nhất (pips) | 10.0 |
| `TradingStopStepSize` | Step pips để di chuyển SL (pips) | 5.0 |
| `ActionOnTradingStopStepComplete` | Hành động khi giá chạm SL (0=Dừng EA, 1=Reset EA) | Dừng EA |

### Lot-based Reset - Tính năng mới V4

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `EnableLotBasedReset` | Bật reset dựa trên lot và tổng phiên | false |
| `MaxLotThreshold` | Lot lớn nhất của lệnh đang mở để kích hoạt (0=off) | 0.1 |
| `TotalLotThreshold` | Tổng lot của lệnh đang mở để kích hoạt (0=off) | 1.0 |
| `SessionProfitForLotReset` | Tổng phiên hiện tại (USD) để reset khi đạt điều kiện lot (0=off) | 50.0 |
| `ActionOnLotBasedReset` | Hành động khi đạt điều kiện lot (0=Dừng EA, 1=Reset EA) | Reset EA |

### Cài đặt chung

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `MagicNumber` | Magic Number để nhận diện lệnh của EA | 123456 |
| `CommentOrder` | Comment được gắn vào mỗi lệnh | "Grid Balanced V4" |
| `EnableResetNotification` | Bật thông báo về điện thoại khi EA reset | false |

## 📊 Cách hoạt động

### 1. Khởi tạo lưới
Khi EA được khởi động, nó sẽ:
- Lấy giá hiện tại (BID) làm giá cơ sở
- Tạo một mảng các mức giá cố định dựa trên `GridDistancePips` và `MaxGridLevels`
- Tổng số mức = `MaxGridLevels * 2 + 1` (bao gồm cả trên và dưới giá cơ sở)
- Mức 1 là gần giá cơ sở nhất, mức 2 xa hơn, v.v.

### 2. Quản lý lệnh
Trên mỗi tick:
- EA kiểm tra tất cả các mức giá trong lưới
- Đối với mỗi mức giá:
  - Nếu mức giá ở **phía trên** giá hiện tại:
    - Đặt lệnh **Buy Stop** (nếu `EnableBuyStop = true`)
    - Đặt lệnh **Sell Limit** (nếu `EnableSellLimit = true`)
  - Nếu mức giá ở **phía dưới** giá hiện tại:
    - Đặt lệnh **Buy Limit** (nếu `EnableBuyLimit = true`)
    - Đặt lệnh **Sell Stop** (nếu `EnableSellStop = true`)

### 3. Cân bằng lưới
- EA đảm bảo mỗi mức giá chỉ có tối đa 1 lệnh Buy và 1 lệnh Sell
- Tránh đặt lệnh trùng lặp tại cùng một mức giá
- Bỏ qua các mức giá quá gần giá hiện tại (nhỏ hơn 5 pips)

### 4. Gấp thếp (Martingale)
- Mức 1: Lot size cơ bản (không gấp)
- Mức 2: Lot size × Multiplier (ví dụ: x2)
- Mức 3: Lot size × Multiplier² (ví dụ: x4)
- Mức n: Lot size × Multiplier^(n-1)

**Ví dụ:** Lot = 0.01, Multiplier = 2.0
- Mức 1: 0.01 lot
- Mức 2: 0.02 lot (x2)
- Mức 3: 0.04 lot (x4)
- Mức 4: 0.08 lot (x8)

### 5. Ghi nhớ lot size theo mức lưới
- Khi một lệnh đạt TP, EA ghi nhớ lot size của lệnh đó tại mức lưới đó
- Khi bổ sung lệnh lại (nếu `AutoRefillOrders = true`), EA sử dụng đúng lot size đã lưu thay vì tính toán lại
- Đảm bảo tính nhất quán trong chiến lược gấp thếp

### 6. TP Tổng

#### TP Tổng Lệnh Đang Mở
- Tính tổng profit của tất cả lệnh đang mở (floating profit)
- Khi đạt mức USD đặt → Reset EA hoặc Dừng EA

#### TP Tổng Phiên
- Tính: **Vốn hiện tại - Vốn ban đầu** (lãi)
- Vốn hiện tại = Equity (Balance + Floating Profit/Loss)
- Vốn ban đầu = Equity khi EA khởi động hoặc reset
- Khi đạt mức USD đặt → Reset EA (reset phiên về 0) hoặc Dừng EA

#### TP Tổng Tích Lũy
- Tích lũy profit qua các lần reset
- Mỗi lần reset, profit phiên được cộng vào tích lũy
- Khi đạt mức USD đặt → Dừng EA vĩnh viễn

### 7. Trading Stop, Step Tổng (Gồng lãi) - Tính năng mới V3

Tính năng này tự động bảo vệ lãi khi đạt ngưỡng và "gồng lãi" (trailing stop) theo giá.

EA hỗ trợ **2 chế độ gồng lãi**:

#### Chế độ 1: Theo lệnh mở
- Kích hoạt khi: **Tổng lãi lệnh đang mở** >= `TradingStopStepTotalProfit` (ví dụ: 30 USD)
- Tính theo: Profit floating của tất cả lệnh đang mở

#### Chế độ 2: Theo phiên
- Kích hoạt khi: **Lãi phiên** >= `TradingStopStepSessionProfit` (ví dụ: 30 USD)
- Tính theo: **Vốn hiện tại - Vốn ban đầu** (khi EA khởi động hoặc reset)
- Mỗi lần Reset EA: Reset phiên về 0 và cập nhật vốn ban đầu mới

#### Quy trình hoạt động:

**Bước 1: Kích hoạt**
- **Chế độ lệnh mở**: Khi tổng lãi lệnh đang mở >= `TradingStopStepTotalProfit` (ví dụ: 30 USD)
- **Chế độ phiên**: Khi lãi phiên (Vốn hiện tại - Vốn ban đầu) >= `TradingStopStepSessionProfit` (ví dụ: 30 USD)
- EA tự động kích hoạt chế độ Trading Stop

**Bước 2: Thiết lập**
- Xóa tất cả lệnh chờ (pending orders)
- Ngừng đặt lệnh mới
- Xóa Take Profit của tất cả lệnh dương (đang lãi)
- Tính điểm A:
  - Với Sell: Điểm A = Giá lệnh dương thấp nhất - `TradingStopStepPointA` pips
  - Với Buy: Điểm A = Giá lệnh dương cao nhất + `TradingStopStepPointA` pips

**Bước 3a: Kiểm tra tổng lãi (nếu chưa đến step 1)**
- **Chế độ lệnh mở**: Kiểm tra tổng lãi lệnh đang mở
- **Chế độ phiên**: Kiểm tra lãi phiên (Vốn hiện tại - Vốn ban đầu)
- Nếu tổng lãi giảm nhưng >= `TradingStopStepReturnProfit` (ví dụ: 20 USD):
  - Vẫn ở chế độ Trading Stop (chờ giá di chuyển)
- Nếu tổng lãi giảm < `TradingStopStepReturnProfit` (ví dụ: < 20 USD):
  - Hủy Trading Stop
  - Khôi phục TP cho tất cả lệnh dương
  - Bổ sung lại lệnh chờ
  - EA trở về hoạt động bình thường như lúc chưa đạt ngưỡng

**Bước 3b: Step đầu tiên**
- Khi giá di chuyển 1 step (`TradingStopStepSize` pips):
  - **Với Sell**: Giá giảm 1 step → Set SL tại điểm A cho tất cả lệnh dương → Đóng tất cả lệnh âm
  - **Với Buy**: Giá tăng 1 step → Set SL tại điểm A cho tất cả lệnh dương → Đóng tất cả lệnh âm

**Bước 4: Gồng lãi (Trailing Stop)**
- Mỗi khi giá di chuyển thêm 1 step:
  - **Với Sell**: Giá giảm thêm 1 step → SL dịch xuống thêm 1 step (gồng lãi)
  - **Với Buy**: Giá tăng thêm 1 step → SL dịch lên thêm 1 step (gồng lãi)

**Bước 5: Kết thúc**
- Khi giá quay đầu chạm SL:
  - Theo `ActionOnTradingStopStepComplete`:
    - **Dừng EA** (0): Đóng tất cả lệnh và dừng hoàn toàn, EA không đặt lệnh nào nữa
    - **Reset EA** (1): Reset lại từ đầu tại giá mới, EA tiếp tục hoạt động với grid mới

#### Ví dụ cụ thể:

**Chế độ lệnh mở:**
```
Tổng lãi lệnh đang mở đạt 35 USD (ngưỡng 30 USD) → Kích hoạt Trading Stop
  ↓
Xóa lệnh chờ, xóa TP, tính điểm A (ví dụ: 840)
  ↓
Giá đi xuống 5 pips → Set SL = 840, đóng lệnh âm
  ↓
Giá tiếp tục xuống 5 pips → SL dịch xuống 835
  ↓
Giá tiếp tục xuống 5 pips → SL dịch xuống 830
  ↓
Giá quay đầu chạm SL → 
  - Dừng EA: Chốt lãi, dừng hoàn toàn
  - HOẶC Reset EA: Chốt lãi, reset và bắt đầu lại từ giá mới
```

**Chế độ phiên:**
```
Vốn ban đầu: 10,000 USD
Vốn hiện tại: 10,035 USD
Lãi phiên: 35 USD (ngưỡng 30 USD) → Kích hoạt Trading Stop
  ↓
Xóa lệnh chờ, xóa TP, tính điểm A (ví dụ: 840)
  ↓
Giá đi xuống 5 pips → Set SL = 840, đóng lệnh âm
  ↓
Giá tiếp tục xuống 5 pips → SL dịch xuống 835
  ↓
Giá tiếp tục xuống 5 pips → SL dịch xuống 830
  ↓
Giá quay đầu chạm SL → 
  - Dừng EA: Chốt lãi, dừng hoàn toàn
  - HOẶC Reset EA: Chốt lãi, reset và bắt đầu lại từ giá mới
  - Khi Reset EA: Vốn ban đầu mới = Vốn hiện tại, lãi phiên reset về 0
```

### 8. Lot-based Reset - Tính năng mới V4

Tính năng này cho phép EA tự động reset khi đạt đồng thời 3 điều kiện:
- **Lot lớn nhất** của lệnh đang mở >= `MaxLotThreshold`
- **Tổng lot** của lệnh đang mở >= `TotalLotThreshold`
- **Tổng phiên** (Vốn hiện tại - Vốn ban đầu) >= `SessionProfitForLotReset`

**Ví dụ:**
```
MaxLotThreshold = 0.1 lot
TotalLotThreshold = 1.0 lot
SessionProfitForLotReset = 50 USD

Khi:
- Có lệnh với lot lớn nhất = 0.12 lot (>= 0.1)
- Tổng lot = 1.2 lot (>= 1.0)
- Tổng phiên = 55 USD (>= 50)
→ EA sẽ reset hoặc dừng (tùy ActionOnLotBasedReset)
```

**Hành động:**
- **Reset EA** (1): Đóng tất cả lệnh, reset và khởi động lại từ giá mới
- **Dừng EA** (0): Đóng tất cả lệnh và dừng hoàn toàn

### 9. Panel hiển thị thông tin - Tính năng mới V4

EA tự động hiển thị panel thông tin trên chart với các thông tin:

**Thông tin hiển thị:**
- **Biểu đồ**: Tên symbol và giá hiện tại với indicator xu hướng (▲/▼)
- **Số lưới tối đa**: Số lượng lưới tối đa
- **Khoảng cách lưới**: Khoảng cách lưới (pips)
- **Số tiền lỗ lớn nhất / số dư**: Số âm lớn nhất của lệnh đang mở / số dư tại thời điểm đó (với progress bar)
- **Số lot lớn nhất**: Số lot lớn nhất từng có (không reset)
- **Tổng lot**: Tổng lot lớn nhất từng có (không reset)
- **Số tiền các lệnh đang mở**: Profit/loss của các lệnh đang mở (màu xanh nếu lãi, đỏ nếu lỗ)
- **Số tiền của phiên**: Profit/loss của phiên hiện tại với phần trăm (màu xanh nếu lãi, đỏ nếu lỗ)

**Đặc điểm:**
- Panel tự động cập nhật mỗi 10 tick
- Hiển thị ở góc trên bên trái của chart
- Màu sắc thay đổi theo trạng thái (xanh = lãi, đỏ = lỗ)
- **Format số tiền tự động**: Tất cả số tiền hiển thị với format K$ và M$ (ví dụ: 1.20K$, 1.00M$)
- Một số thông số không reset khi EA reset để theo dõi lịch sử

### 10. Thông báo về điện thoại - Tính năng mới V4

Khi `EnableResetNotification = true`, EA sẽ tự động gửi thông báo push notification về điện thoại qua MT5 Mobile App khi EA reset.

**Nội dung thông báo bao gồm:**
1. **Biểu đồ**: Tên symbol đang giao dịch (ví dụ: EURUSD)
2. **Chức năng**: Lý do reset (TP Tổng Lệnh Mở, TP Tổng Phiên, Trading Stop, Step Tổng, Lot-based Reset, hoặc Thủ công)
3. **Số dư**: Số dư hiện tại tại thời điểm reset (format K$/M$)
4. **Lỗ lớn nhất**: Số âm lớn nhất từng có / số dư tại thời điểm đó / phần trăm
5. **Lot**: Lot lớn nhất từng có / tổng lot lớn nhất từng có

**Ví dụ thông báo:**
```
EA RESET
Biểu đồ: EURUSD
Chức năng: TP Tổng Phiên
Số dư: 10.50K$
Lỗ lớn nhất: -1.20K$ / 10.00K$ (12.00%)
Lot: 0.50 / 5.00
```

**Lưu ý:**
- Cần kết nối tài khoản MT5 với MT5 Mobile App để nhận thông báo
- Thông báo chỉ được gửi khi EA reset, không gửi khi EA dừng
- Tất cả số tiền trong thông báo được format tự động với K$ và M$ (2 số thập phân)

### 11. Reset EA
Khi reset:
- Đóng tất cả pending orders
- Đóng tất cả positions đang mở
- Reset basePrice về giá hiện tại
- Reset grid levels
- Reset lot sizes đã lưu
- Reset phiên (tổng phiên về 0)
- Cập nhật vốn ban đầu mới
- **KHÔNG reset** (giữ lại để theo dõi lịch sử):
  - Số tiền lỗ lớn nhất (`maxNegativeProfit`) và số dư tại thời điểm đó (`balanceAtMaxLoss`)
  - Số lot lớn nhất từng có (`maxLotEver`)
  - Tổng lot lớn nhất từng có (`totalLotEver`)
- EA tiếp tục hoạt động với cấu hình mới

### 12. Dừng EA
Khi dừng:
- Đóng tất cả pending orders
- Đóng tất cả positions đang mở
- Set flag dừng EA
- EA không quản lý lệnh nữa
- EA không mở thêm lệnh nào

## ⚠️ Cảnh báo rủi ro

- **Giao dịch lưới có rủi ro cao**: Chiến lược này có thể tạo ra nhiều lệnh đồng thời, làm tăng yêu cầu ký quỹ
- **Gấp thếp tăng rủi ro**: Gấp thếp có thể làm tăng lot size nhanh chóng, cần quản lý ký quỹ cẩn thận
- **Trading Stop cần hiểu rõ**: Tính năng Trading Stop có thể thay đổi hành vi EA đáng kể, cần test kỹ trước khi sử dụng
- **Thị trường trending**: Lưới có thể hoạt động kém hiệu quả trong thị trường có xu hướng mạnh một chiều
- **Yêu cầu ký quỹ**: Đảm bảo tài khoản có đủ ký quỹ để chịu được nhiều lệnh cùng lúc, đặc biệt khi sử dụng gấp thếp
- **Kiểm thử kỹ**: Luôn test EA trên tài khoản demo trước khi sử dụng trên tài khoản thật
- **Không có đảm bảo lợi nhuận**: Trading luôn có rủi ro, không có chiến lược nào đảm bảo 100% lợi nhuận

## 📝 Lưu ý kỹ thuật

- **File EA**: `GridBalancedTradingV4.mq5`
- EA được viết cho **MetaTrader 5** (MQL5), không tương thích với MT4
- Sử dụng thư viện `Trade.mqh` để thực hiện giao dịch
- Tất cả giá được chuẩn hóa theo số chữ số thập phân của symbol
- EA tự động tính toán chuyển đổi pips sang giá dựa trên symbol
- Không sử dụng Stop Loss (đã được loại bỏ trong V2)
- Lot size được chuẩn hóa về 2 chữ số thập phân

## 🔍 Ví dụ cấu hình

### Cấu hình thận trọng (Conservative)
```
GridDistancePips = 30.0
MaxGridLevels = 5
LotSizeBuyLimit = 0.01
LotSizeSellLimit = 0.01
LotSizeBuyStop = 0.01
LotSizeSellStop = 0.01
TakeProfitPipsBuyLimit = 40.0
TakeProfitPipsSellLimit = 40.0
TakeProfitPipsBuyStop = 40.0
TakeProfitPipsSellStop = 40.0
EnableMartingaleBuyLimit = false
EnableMartingaleSellLimit = false
EnableMartingaleBuyStop = false
EnableMartingaleSellStop = false
TotalProfitTPSession = 50.0
ActionOnTotalProfitSession = Reset EA
EnableTradingStopStepTotal = false
```

### Cấu hình tích cực (Aggressive)
```
GridDistancePips = 15.0
MaxGridLevels = 15
LotSizeBuyLimit = 0.05
LotSizeSellLimit = 0.05
LotSizeBuyStop = 0.05
LotSizeSellStop = 0.05
TakeProfitPipsBuyLimit = 25.0
TakeProfitPipsSellLimit = 25.0
TakeProfitPipsBuyStop = 25.0
TakeProfitPipsSellStop = 25.0
EnableMartingaleBuyLimit = true
MartingaleMultiplierBuyLimit = 2.0
EnableMartingaleSellLimit = true
MartingaleMultiplierSellLimit = 2.0
TotalProfitTPSession = 100.0
ActionOnTotalProfitSession = Reset EA
EnableTradingStopStepTotal = true
TradingStopStepMode = Theo lệnh mở
TradingStopStepTotalProfit = 50.0
TradingStopStepReturnProfit = 20.0
TradingStopStepPointA = 10.0
TradingStopStepSize = 5.0
ActionOnTradingStopStepComplete = Dừng EA
```

### Cấu hình với Trading Stop (chế độ lệnh mở)
```
EnableTradingStopStepTotal = true
TradingStopStepMode = Theo lệnh mở
TradingStopStepTotalProfit = 30.0
TradingStopStepReturnProfit = 20.0
TradingStopStepPointA = 10.0
TradingStopStepSize = 5.0
ActionOnTradingStopStepComplete = Dừng EA
```

### Cấu hình với Trading Stop (chế độ phiên)
```
EnableTradingStopStepTotal = true
TradingStopStepMode = Theo phiên
TradingStopStepSessionProfit = 30.0
TradingStopStepReturnProfit = 20.0
TradingStopStepPointA = 10.0
TradingStopStepSize = 5.0
ActionOnTradingStopStepComplete = Reset EA
```

### Cấu hình với Lot-based Reset
```
EnableLotBasedReset = true
MaxLotThreshold = 0.1
TotalLotThreshold = 1.0
SessionProfitForLotReset = 50.0
ActionOnLotBasedReset = Reset EA
```

### Cấu hình với thông báo về điện thoại
```
EnableResetNotification = true
```

## 🔄 So sánh các phiên bản

### So sánh V2 và V3

| Tính năng | V2 | V3 |
|-----------|----|----|
| Bật/tắt loại lệnh | Riêng từng loại | Riêng từng loại |
| Lot size | Riêng cho từng loại lệnh | Riêng cho từng loại lệnh |
| Take Profit | Riêng cho từng loại lệnh | Riêng cho từng loại lệnh |
| Stop Loss | Không | Không |
| Gấp thếp | Có (riêng cho từng loại) | Có (riêng cho từng loại) |
| Ghi nhớ lot size | Có (theo mức lưới) | Có (theo mức lưới) |
| TP tổng | Có (3 loại) | Có (3 loại) |
| Reset EA | Có | Có |
| Dừng EA | Có | Có |
| Trading Stop, Step Tổng | Không | Có (Tính năng mới) |
| Khôi phục khi lãi giảm | Không | Có (Tự động hủy Trading Stop) |

### So sánh V3 và V4

| Tính năng | V3 | V4 |
|-----------|----|----|
| Trading Stop, Step Tổng | Có | Có |
| Lot-based Reset | Không | Có (Tính năng mới) |
| Panel hiển thị thông tin | Không | Có (Tính năng mới) |
| Format số tiền K$/M$ | Không | Có (trên panel và thông báo) |
| Thông báo về điện thoại | Không | Có (Tính năng mới) |
| Theo dõi lịch sử lỗ lớn nhất | Không | Có (không reset) |
| Theo dõi lịch sử lot lớn nhất | Không | Có (không reset) |
| Action cho Lot-based Reset | Không | Có (Dừng EA hoặc Reset EA) |

## 📞 Hỗ trợ

Nếu gặp vấn đề hoặc có câu hỏi về **Grid Balanced Trading V4**, vui lòng:
- Kiểm tra log trong tab "Experts" của MetaTrader 5
- Xác nhận file `GridBalancedTradingV4.mq5` đã được compile thành công (không có lỗi trong tab "Errors")
- Đảm bảo AutoTrading đã được bật
- Kiểm tra Magic Number để đảm bảo không trùng với EA khác
- Kiểm tra log debug để theo dõi profit và trạng thái EA
- Kiểm tra panel hiển thị trên chart để theo dõi thông tin EA
- Đọc kỹ phần Trading Stop, Step Tổng và Lot-based Reset để hiểu cách hoạt động
- Để nhận thông báo về điện thoại, cần kết nối tài khoản MT5 với MT5 Mobile App và bật `EnableResetNotification = true`

## 📜 Giấy phép

EA này được cung cấp "as-is" không có bất kỳ bảo đảm nào. Sử dụng trên trách nhiệm của bạn.

---

**Lưu ý**: Luôn test kỹ trên tài khoản demo trước khi sử dụng thực tế. Giao dịch có rủi ro, có thể dẫn đến mất vốn. Đặc biệt cẩn thận khi sử dụng tính năng gấp thếp, Trading Stop và Lot-based Reset vì có thể làm tăng rủi ro đáng kể. Panel hiển thị thông tin giúp theo dõi trạng thái EA, nhưng không thay thế việc quản lý rủi ro cẩn thận. Thông báo về điện thoại giúp theo dõi EA từ xa, nhưng cần đảm bảo kết nối ổn định với MT5 Mobile App.
