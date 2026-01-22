//+------------------------------------------------------------------+
//|                              GridBalancedTradingV4.mq5           |
//|                       EA Grid Trading với cân bằng lưới tự động  |
//+------------------------------------------------------------------+
#property copyright "Grid Balanced Trading"
#property version   "4.00"
#property description "Grid Trading EA với hệ thống cân bằng lưới tự động - V4"

#include <Trade\Trade.mqh>

//--- Enum cho hành động khi đạt TP tổng
enum ENUM_TP_ACTION
{
   TP_ACTION_STOP_EA = 0,    // Dừng EA
   TP_ACTION_RESET_EA = 1    // Reset EA
};

//--- Enum cho chế độ Trading Stop
enum ENUM_TRADING_STOP_MODE
{
   TRADING_STOP_MODE_OPEN = 0,    // Theo ngưỡng các lệnh mở
   TRADING_STOP_MODE_SESSION = 1  // Theo ngưỡng phiên
};

//--- Input parameters - Cài đặt lưới
input group "=== CÀI ĐẶT LƯỚI ==="
input double GridDistancePips = 20.0;           // Khoảng cách lưới (pips)
input int MaxGridLevels = 10;                   // Số lượng lưới tối đa
input bool AutoRefillOrders = true;             // Tự động bổ sung lệnh khi đóng

//--- Input parameters - Cài đặt lệnh Buy Limit
input group "=== CÀI ĐẶT LỆNH BUY LIMIT ==="
input bool EnableBuyLimit = true;               // Cho phép lệnh Buy Limit
input double LotSizeBuyLimit = 0.01;            // Khối lượng Buy Limit (mức 1)
input double TakeProfitPipsBuyLimit = 30.0;     // Take Profit Buy Limit (pips, 0=off)
input bool EnableMartingaleBuyLimit = false;    // Bật gấp thếp Buy Limit
input double MartingaleMultiplierBuyLimit = 2.0; // Hệ số gấp thếp Buy Limit (mức 2=x2, mức 3=x4...)

//--- Input parameters - Cài đặt lệnh Sell Limit
input group "=== CÀI ĐẶT LỆNH SELL LIMIT ==="
input bool EnableSellLimit = true;              // Cho phép lệnh Sell Limit
input double LotSizeSellLimit = 0.01;           // Khối lượng Sell Limit (mức 1)
input double TakeProfitPipsSellLimit = 30.0;    // Take Profit Sell Limit (pips, 0=off)
input bool EnableMartingaleSellLimit = false;   // Bật gấp thếp Sell Limit
input double MartingaleMultiplierSellLimit = 2.0; // Hệ số gấp thếp Sell Limit (mức 2=x2, mức 3=x4...)

//--- Input parameters - Cài đặt lệnh Buy Stop
input group "=== CÀI ĐẶT LỆNH BUY STOP ==="
input bool EnableBuyStop = true;                // Cho phép lệnh Buy Stop
input double LotSizeBuyStop = 0.01;             // Khối lượng Buy Stop (mức 1)
input double TakeProfitPipsBuyStop = 30.0;      // Take Profit Buy Stop (pips, 0=off)
input bool EnableMartingaleBuyStop = false;     // Bật gấp thếp Buy Stop
input double MartingaleMultiplierBuyStop = 2.0; // Hệ số gấp thếp Buy Stop (mức 2=x2, mức 3=x4...)

//--- Input parameters - Cài đặt lệnh Sell Stop
input group "=== CÀI ĐẶT LỆNH SELL STOP ==="
input bool EnableSellStop = true;               // Cho phép lệnh Sell Stop
input double LotSizeSellStop = 0.01;            // Khối lượng Sell Stop (mức 1)
input double TakeProfitPipsSellStop = 30.0;     // Take Profit Sell Stop (pips, 0=off)
input bool EnableMartingaleSellStop = false;    // Bật gấp thếp Sell Stop
input double MartingaleMultiplierSellStop = 2.0; // Hệ số gấp thếp Sell Stop (mức 2=x2, mức 3=x4...)

//--- Input parameters - TP tổng
input group "=== TP TỔNG ==="
input double TotalProfitTPOpen = 0.0;                          // TP tổng lệnh đang mở (USD, 0=off)
input ENUM_TP_ACTION ActionOnTotalProfitOpen = TP_ACTION_RESET_EA; // Hành động khi đạt TP tổng lệnh mở
input double TotalProfitTPSession = 0.0;                       // TP tổng phiên (USD, 0=off)
input ENUM_TP_ACTION ActionOnTotalProfitSession = TP_ACTION_RESET_EA; // Hành động khi đạt TP tổng phiên
input double TotalProfitTPAccumulated = 0.0;                   // TP tổng tích lũy (USD, 0=off)

//--- Input parameters - Trading Stop, Step Tổng
input group "=== TRADING STOP, STEP TỔNG (GỒNG LÃI) ==="
input bool EnableTradingStopStepTotal = false;                 // Bật Trading Stop, Step Tổng
input ENUM_TRADING_STOP_MODE TradingStopStepMode = TRADING_STOP_MODE_OPEN; // Chế độ gồng lãi (0=Theo lệnh mở, 1=Theo phiên)
input double TradingStopStepTotalProfit = 50.0;                // Lãi tổng lệnh đang mở để kích hoạt (USD, 0=off)
input double TradingStopStepSessionProfit = 50.0;              // Lãi tổng phiên để kích hoạt (USD, dùng khi chế độ = Theo phiên, 0=off)
input double TradingStopStepReturnProfit = 20.0;               // Lãi tổng khi quay lại để tiếp tục (USD, nếu < ngưỡng kích hoạt thì hủy)
input double TradingStopStepPointA = 10.0;                     // Điểm A cách lệnh dương thấp nhất (pips)
input double TradingStopStepSize = 5.0;                        // Step pips để di chuyển SL (pips)
input ENUM_TP_ACTION ActionOnTradingStopStepComplete = TP_ACTION_STOP_EA; // Hành động khi giá chạm SL (0=Dừng EA, 1=Reset EA)
input bool EnableLotBasedReset = false;                        // Bật reset dựa trên lot và tổng phiên
input double MaxLotThreshold = 0.1;                            // Lot lớn nhất của lệnh đang mở để kích hoạt (0=off)
input double TotalLotThreshold = 1.0;                          // Tổng lot của lệnh đang mở để kích hoạt (0=off)
input double SessionProfitForLotReset = 50.0;                  // Tổng phiên hiện tại (USD) để reset khi đạt điều kiện lot (0=off)

//--- Input parameters - Cài đặt chung
input group "=== CÀI ĐẶT CHUNG ==="
input int MagicNumber = 123456;                 // Magic Number
input string CommentOrder = "Grid Balanced V4"; // Comment cho lệnh
input bool EnableResetNotification = false;     // Bật thông báo về điện thoại khi EA reset

//--- Global variables
CTrade trade;
double pnt;
int dgt;
double basePrice;                               // Giá cơ sở để tính các level
double gridLevels[];                            // Mảng chứa các level giá cố định
int gridLevelIndex[];                           // Mảng lưu chỉ số mức lưới (1, 2, 3...)

// Cấu trúc lưu lot size cho mỗi mức lưới và loại lệnh
struct GridLotSize
{
   double lotSizeBuyLimit[50];                  // Lot size cho Buy Limit theo mức (max 50 mức)
   double lotSizeSellLimit[50];                 // Lot size cho Sell Limit theo mức
   double lotSizeBuyStop[50];                   // Lot size cho Buy Stop theo mức
   double lotSizeSellStop[50];                  // Lot size cho Sell Stop theo mức
};

GridLotSize gridLotSizes;                       // Lưu trữ lot size cho mỗi mức lưới

// Biến theo dõi profit
double sessionProfit = 0.0;                     // Profit của phiên hiện tại (không dùng nữa, tính từ vốn)
double accumulatedProfit = 0.0;                 // Profit tích lũy qua các lần reset
datetime sessionStartTime = 0;                  // Thời gian bắt đầu phiên
double initialEquity = 0.0;                     // Vốn ban đầu (Equity) khi bắt đầu phiên
double minEquity = 0.0;                        // Vốn thấp nhất (khi lỗ lớn nhất) trong phiên
double maxNegativeProfit = 0.0;                 // Số âm lớn nhất của lệnh đang mở (không reset khi EA reset)
double balanceAtMaxLoss = 0.0;                  // Số dư tại thời điểm có số âm lớn nhất (không reset khi EA reset)
double maxLotEver = 0.0;                         // Số lot lớn nhất từng có (không reset khi EA reset)
double totalLotEver = 0.0;                      // Tổng lot lớn nhất từng có (không reset khi EA reset)
bool eaStopped = false;                         // Flag dừng EA
bool isResetting = false;                       // Flag đang trong quá trình reset

// Biến theo dõi Trading Stop, Step Tổng
bool isTradingStopActive = false;               // Flag đang ở chế độ Trading Stop
double pointA = 0.0;                            // Điểm A (SL) cho các lệnh dương
double lastPriceForStep = 0.0;                  // Giá cuối để theo dõi step
double initialPriceForStop = 0.0;               // Giá ban đầu khi kích hoạt stop
bool firstStepDone = false;                     // Flag đã thực hiện step đầu tiên (đóng lệnh âm, set SL)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   dgt = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   pnt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // Khởi tạo giá cơ sở
   basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Tạo mảng các level giá cố định
   InitializeGridLevels();
   
   Print("========================================");
   Print("Grid Balanced Trading EA V4 đã khởi động");
   Print("Symbol: ", _Symbol);
   Print("Base Price: ", basePrice);
   Print("Grid Distance: ", GridDistancePips, " pips");
   Print("Max Levels: ", MaxGridLevels);
   Print("Auto Refill: ", AutoRefillOrders ? "ON" : "OFF");
   Print("--- Loại lệnh được bật ---");
   Print("Buy Limit: ", EnableBuyLimit ? "ON" : "OFF", " | Sell Limit: ", EnableSellLimit ? "ON" : "OFF");
   Print("Buy Stop: ", EnableBuyStop ? "ON" : "OFF", " | Sell Stop: ", EnableSellStop ? "ON" : "OFF");
   Print("--- Cài đặt lệnh ---");
   if(EnableBuyLimit)
   {
      Print("  Buy Limit - Lot: ", LotSizeBuyLimit, " | TP: ", TakeProfitPipsBuyLimit, " pips");
      if(EnableMartingaleBuyLimit)
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierBuyLimit, "x (mức 2=", LotSizeBuyLimit * MartingaleMultiplierBuyLimit, ", mức 3=", LotSizeBuyLimit * MathPow(MartingaleMultiplierBuyLimit, 2), "...)");
   }
   if(EnableSellLimit)
   {
      Print("  Sell Limit - Lot: ", LotSizeSellLimit, " | TP: ", TakeProfitPipsSellLimit, " pips");
      if(EnableMartingaleSellLimit)
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierSellLimit, "x (mức 2=", LotSizeSellLimit * MartingaleMultiplierSellLimit, ", mức 3=", LotSizeSellLimit * MathPow(MartingaleMultiplierSellLimit, 2), "...)");
   }
   if(EnableBuyStop)
   {
      Print("  Buy Stop - Lot: ", LotSizeBuyStop, " | TP: ", TakeProfitPipsBuyStop, " pips");
      if(EnableMartingaleBuyStop)
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierBuyStop, "x (mức 2=", LotSizeBuyStop * MartingaleMultiplierBuyStop, ", mức 3=", LotSizeBuyStop * MathPow(MartingaleMultiplierBuyStop, 2), "...)");
   }
   if(EnableSellStop)
   {
      Print("  Sell Stop - Lot: ", LotSizeSellStop, " | TP: ", TakeProfitPipsSellStop, " pips");
      if(EnableMartingaleSellStop)
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierSellStop, "x (mức 2=", LotSizeSellStop * MartingaleMultiplierSellStop, ", mức 3=", LotSizeSellStop * MathPow(MartingaleMultiplierSellStop, 2), "...)");
   }
   Print("Tổng số levels: ", ArraySize(gridLevels));
   Print("--- TP Tổng ---");
   if(TotalProfitTPOpen > 0)
      Print("TP Tổng lệnh mở: ", TotalProfitTPOpen, " USD | Hành động: ", ActionOnTotalProfitOpen == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
   if(TotalProfitTPSession > 0)
      Print("TP Tổng phiên: ", TotalProfitTPSession, " USD | Hành động: ", ActionOnTotalProfitSession == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
   if(TotalProfitTPAccumulated > 0)
      Print("TP Tổng tích lũy: ", TotalProfitTPAccumulated, " USD | Hành động: Dừng EA");
   Print("--- Trading Stop, Step Tổng ---");
   bool tradingStopEnabled = false;
   if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
   {
      tradingStopEnabled = (EnableTradingStopStepTotal && TradingStopStepTotalProfit > 0);
   }
   else
   {
      tradingStopEnabled = (EnableTradingStopStepTotal && TradingStopStepSessionProfit > 0);
   }
   
   if(tradingStopEnabled)
   {
      Print("Trading Stop, Step Tổng: ON");
      Print("  - Chế độ: ", TradingStopStepMode == TRADING_STOP_MODE_OPEN ? "Theo lệnh mở" : "Theo phiên");
      if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
      {
         Print("  - Lãi kích hoạt (lệnh mở): ", TradingStopStepTotalProfit, " USD");
      }
      else
      {
         Print("  - Lãi kích hoạt (phiên): ", TradingStopStepSessionProfit, " USD");
      }
      Print("  - Lãi quay lại: ", TradingStopStepReturnProfit, " USD");
      Print("  - Điểm A cách lệnh dương: ", TradingStopStepPointA, " pips");
      Print("  - Step di chuyển SL: ", TradingStopStepSize, " pips");
      Print("  - Hành động khi chạm SL: ", ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
   }
   else
   {
      Print("Trading Stop, Step Tổng: OFF");
   }
   Print("========================================");
   
   // Khởi tạo phiên
   sessionStartTime = TimeCurrent();
   sessionProfit = 0.0;
   accumulatedProfit = 0.0;
   initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // Lưu vốn ban đầu (Balance + Floating)
   minEquity = initialEquity;  // Khởi tạo vốn thấp nhất bằng vốn ban đầu
   maxNegativeProfit = 0.0;  // Khởi tạo số âm lớn nhất
   balanceAtMaxLoss = AccountInfoDouble(ACCOUNT_BALANCE);  // Khởi tạo số dư tại thời điểm lỗ lớn nhất
   maxLotEver = 0.0;  // Khởi tạo số lot lớn nhất từng có
   totalLotEver = 0.0;  // Khởi tạo tổng lot lớn nhất từng có
   
   Print("Vốn ban đầu phiên: ", initialEquity, " USD");
   
   // Tạo panel hiển thị thông tin
   CreatePanel();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Xóa panel
   DeletePanel();
   
   Print("Grid Balanced Trading EA V4 đã dừng. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Nếu EA đã dừng thì không làm gì
   if(eaStopped)
   {
      // Log mỗi 1000 tick để xác nhận EA đã dừng
      static int stoppedTickCount = 0;
      stoppedTickCount++;
      if(stoppedTickCount % 1000 == 0)
      {
         Print("EA đã DỪNG - Không thực hiện bất kỳ hoạt động nào");
      }
      return;
   }
   
   // Kiểm tra TP tổng
   CheckTotalProfit();
   
   // Nếu EA bị dừng sau khi kiểm tra TP tổng thì không quản lý lệnh
   if(eaStopped)
   {
      static int firstStopLog = 0;
      if(firstStopLog == 0)
      {
         Print("========================================");
         Print("EA đã được DỪNG sau khi kiểm tra TP tổng");
         Print("EA sẽ KHÔNG quản lý lệnh nữa");
         Print("========================================");
         firstStopLog = 1;
      }
      return;
   }
   
   // Kiểm tra Trading Stop, Step Tổng
   if(EnableTradingStopStepTotal)
   {
      if(!isTradingStopActive)
      {
         CheckTradingStopStepTotal();
      }
      else
      {
         ManageTradingStop();
      }
   }
   
   // Kiểm tra reset dựa trên lot và tổng phiên
   if(EnableLotBasedReset)
   {
      CheckLotBasedReset();
   }
   
   // Chỉ quản lý lệnh khi không ở chế độ Trading Stop
   if(!isTradingStopActive)
   {
      ManageGridOrders();
   }
   
   // Cập nhật panel (mỗi 10 tick để giảm tải)
   static int tickCount = 0;
   tickCount++;
   if(tickCount % 10 == 0)
   {
      UpdatePanel();
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra và xử lý TP tổng                                       |
//+------------------------------------------------------------------+
void CheckTotalProfit()
{
   // 1. Kiểm tra TP tổng lệnh đang mở
   if(TotalProfitTPOpen > 0)
   {
      double openProfit = GetTotalOpenProfit();
      // Debug: In thông tin mỗi 100 tick để kiểm tra
      static int tickCount = 0;
      tickCount++;
      if(tickCount % 100 == 0)
      {
         Print("Debug - TP Tổng lệnh mở: ", openProfit, " / ", TotalProfitTPOpen, " USD");
      }
      
      if(openProfit >= TotalProfitTPOpen)
      {
         Print("========================================");
         Print("=== ĐẠT TP TỔNG LỆNH MỞ: ", openProfit, " USD ===");
         Print("========================================");
         if(ActionOnTotalProfitOpen == TP_ACTION_RESET_EA)
         {
            ResetEA("TP Tổng Lệnh Mở");
         }
         else
         {
            Print("EA sẽ DỪNG HOẠT ĐỘNG (không reset)");
            StopEA();
         }
         return; // Dừng kiểm tra các TP khác
      }
   }
   
   // 2. Kiểm tra TP tổng phiên
   // TP tổng phiên = Vốn hiện tại - Vốn ban đầu (tính lãi)
   // Vốn hiện tại = Equity (Balance + Floating Profit/Loss)
   if(TotalProfitTPSession > 0)
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // Vốn hiện tại (Balance + Floating)
      double totalSessionProfit = currentEquity - initialEquity;  // Profit phiên = Vốn hiện tại - Vốn ban đầu (lãi)
      
      // Debug: In thông tin mỗi 100 tick để kiểm tra
      static int tickCountSession = 0;
      tickCountSession++;
      if(tickCountSession % 100 == 0)
      {
         Print("Debug - TP Tổng phiên: ", totalSessionProfit, " USD (Vốn hiện tại: ", currentEquity, " - Vốn ban đầu: ", initialEquity, ") / ", TotalProfitTPSession, " USD");
         Print("  - So sánh: ", totalSessionProfit, " >= ", TotalProfitTPSession, " ? ", (totalSessionProfit >= TotalProfitTPSession ? "TRUE" : "FALSE"));
         Print("  - ActionOnTotalProfitSession = ", ActionOnTotalProfitSession, " (0=Dừng EA, 1=Reset EA)");
      }
      
      // Kiểm tra điều kiện - In log khi gần đạt TP (trong vòng 5 USD)
      if(totalSessionProfit >= (TotalProfitTPSession - 5.0) && totalSessionProfit < TotalProfitTPSession)
      {
         Print("⚠ GẦN ĐẠT TP TỔNG PHIÊN: ", totalSessionProfit, " / ", TotalProfitTPSession, " USD");
      }
      
      // Kiểm tra điều kiện
      if(totalSessionProfit >= TotalProfitTPSession)
      {
         Print("========================================");
         Print("=== ĐẠT TP TỔNG PHIÊN: ", totalSessionProfit, " USD ===");
         Print("  - Vốn ban đầu: ", initialEquity, " USD");
         Print("  - Vốn hiện tại: ", currentEquity, " USD");
         Print("  - Tổng phiên (Hiện tại - Ban đầu): ", totalSessionProfit, " USD");
         Print("  - Mục tiêu: ", TotalProfitTPSession, " USD");
         Print("  - ActionOnTotalProfitSession = ", ActionOnTotalProfitSession);
         Print("========================================");
         
         if(ActionOnTotalProfitSession == TP_ACTION_RESET_EA)
         {
            Print("Hành động: RESET EA");
            ResetEA("TP Tổng Phiên");
         }
         else if(ActionOnTotalProfitSession == TP_ACTION_STOP_EA)
         {
            Print("Hành động: DỪNG EA");
            StopEA();
         }
         else
         {
            Print("⚠ LỖI: ActionOnTotalProfitSession không hợp lệ: ", ActionOnTotalProfitSession);
         }
         return; // Dừng kiểm tra các TP khác
      }
   }
   
   // 3. Kiểm tra TP tổng tích lũy
   // Tổng tích lũy = Profit tích lũy + Profit phiên hiện tại
   // Profit phiên hiện tại = Vốn hiện tại - Vốn ban đầu
   if(TotalProfitTPAccumulated > 0)
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      double sessionProfitCurrent = currentEquity - initialEquity;  // Profit phiên hiện tại
      double totalAccumulated = accumulatedProfit + sessionProfitCurrent;
      if(totalAccumulated >= TotalProfitTPAccumulated)
      {
         Print("========================================");
         Print("=== ĐẠT TP TỔNG TÍCH LŨY: ", totalAccumulated, " USD ===");
         Print("EA sẽ DỪNG HOẠT ĐỘNG VĨNH VIỄN");
         Print("========================================");
         StopEA();
      }
   }
}

//+------------------------------------------------------------------+
//| Tính tổng profit của các lệnh đang mở (floating profit/loss)    |
//+------------------------------------------------------------------+
double GetTotalOpenProfit()
{
   double totalProfit = 0.0;
   
   // Duyệt qua tất cả positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            // Cộng profit và swap của mỗi position (có thể dương hoặc âm)
            totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         }
      }
   }
   
   return totalProfit;
}

//+------------------------------------------------------------------+
//| Reset EA - Khởi động lại tại giá mới                             |
//+------------------------------------------------------------------+
void ResetEA(string resetReason = "Thủ công")
{
   Print("=== RESET EA ===");
   Print("Lý do reset: ", resetReason);
   
   // Đánh dấu đang trong quá trình reset
   isResetting = true;
   
   // Cộng profit của phiên hiện tại vào tích lũy trước khi reset
   // Profit phiên = Vốn hiện tại - Vốn ban đầu (lãi)
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double totalSessionProfit = currentEquity - initialEquity;
   accumulatedProfit += totalSessionProfit;
   
   Print("Profit phiên trước reset: ", totalSessionProfit, " USD");
   Print("  - Vốn ban đầu: ", initialEquity, " USD");
   Print("  - Vốn hiện tại: ", currentEquity, " USD");
   Print("Tổng tích lũy trước reset: ", accumulatedProfit, " USD");
   
   // Đóng tất cả pending orders
   CloseAllPendingOrders();
   
   // Đóng tất cả positions đang mở
   CloseAllOpenPositions();
   
   // Đợi một chút để các lệnh đóng hoàn tất
   Sleep(500);
   
   // Tắt flag reset
   isResetting = false;
   
   // Reset basePrice tại giá mới
   basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Reset grid levels
   InitializeGridLevels();
   
   // Reset lot sizes đã lưu
   ZeroMemory(gridLotSizes);
   
   // Reset phiên về 0 và cập nhật vốn ban đầu mới
   sessionProfit = 0.0;  // Reset tổng phiên về 0
   sessionStartTime = TimeCurrent();
   
   // Cập nhật vốn ban đầu mới (sau khi đóng tất cả lệnh)
   double oldInitialEquity = initialEquity;
   initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // Vốn mới khi EA khởi động lại
   minEquity = initialEquity;  // Reset vốn thấp nhất về vốn ban đầu mới
   // KHÔNG reset maxNegativeProfit và balanceAtMaxLoss - giữ lại để theo dõi lịch sử
   // KHÔNG reset maxLotEver và totalLotEver - giữ lại để theo dõi lịch sử
   
   // Đảm bảo EA tiếp tục hoạt động sau khi reset
   eaStopped = false;
   
   // Reset biến Trading Stop
   isTradingStopActive = false;
   pointA = 0.0;
   lastPriceForStep = 0.0;
   initialPriceForStop = 0.0;
   firstStepDone = false;
   
   Print("EA đã reset tại giá mới: ", basePrice);
   Print("Tổng tích lũy sau reset: ", accumulatedProfit, " USD");
   Print("--- Reset phiên ---");
   Print("  - Vốn ban đầu cũ: ", oldInitialEquity, " USD");
   Print("  - Vốn ban đầu mới: ", initialEquity, " USD");
   Print("  - Tổng phiên đã reset về: 0 USD");
   Print("Phiên mới đã bắt đầu - Tổng phiên sẽ tính lại từ vốn ban đầu mới");
   
   // Gửi thông báo về điện thoại nếu được bật
   if(EnableResetNotification)
   {
      SendResetNotification(resetReason);
   }
}

//+------------------------------------------------------------------+
//| Dừng EA - Đóng tất cả lệnh và xóa pending orders                |
//+------------------------------------------------------------------+
void StopEA()
{
   Print("========================================");
   Print("=== DỪNG EA ===");
   Print("Đang đóng tất cả lệnh...");
   
   // Đóng tất cả pending orders
   int pendingCount = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            if(trade.OrderDelete(ticket))
               pendingCount++;
         }
      }
   }
   Print("Đã xóa ", pendingCount, " pending orders");
   
   // Đóng tất cả positions đang mở
   int positionCount = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            if(trade.PositionClose(ticket))
               positionCount++;
         }
      }
   }
   Print("Đã đóng ", positionCount, " positions");
   
   // Set flag dừng EA
   eaStopped = true;
   
   Print("EA đã DỪNG - Không quản lý lệnh nữa");
   Print("========================================");
}

//+------------------------------------------------------------------+
//| Đóng tất cả positions đang mở                                    |
//+------------------------------------------------------------------+
void CloseAllOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            trade.PositionClose(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Tính profit/loss của position đã đóng (realized profit/loss)     |
//+------------------------------------------------------------------+
double CalculateClosedPositionProfit(ulong positionId)
{
   double totalProfit = 0.0;
   
   if(HistorySelectByPosition(positionId))
   {
      int totalDeals = HistoryDealsTotal();
      
      for(int i = 0; i < totalDeals; i++)
      {
         ulong dealTicket = HistoryDealGetTicket(i);
         if(dealTicket > 0)
         {
            long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            
            if(dealMagic == MagicNumber && dealSymbol == _Symbol)
            {
               totalProfit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
               totalProfit += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
               totalProfit += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
            }
         }
      }
   }
   
   return totalProfit;
}

//+------------------------------------------------------------------+
//| Đóng tất cả pending orders                                       |
//+------------------------------------------------------------------+
void CloseAllPendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            trade.OrderDelete(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Trade transaction handler                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                       const MqlTradeRequest& request,
                       const MqlTradeResult& result)
{
   // Chỉ xử lý khi position đóng
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      // Kiểm tra xem có phải position đóng do TP không
      if(HistoryDealSelect(trans.deal))
      {
         long reason = HistoryDealGetInteger(trans.deal, DEAL_REASON);
         
         // Xử lý khi position đóng do TP hoặc SL
         if(reason == DEAL_REASON_TP || reason == DEAL_REASON_SL || reason == DEAL_REASON_SO)
         {
            // Lấy thông tin position đã đóng
            long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
            
            if(magic == MagicNumber && symbol == _Symbol)
            {
               // Lấy Position ID từ deal
               ulong positionId = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
               
               // Tính profit của position đã đóng (có thể lãi hoặc lỗ)
               double positionProfit = CalculateClosedPositionProfit(positionId);
               
               // Nếu đang trong quá trình reset, không cộng vào sessionProfit
               // (profit đã được tính vào tích lũy khi reset)
               if(!isResetting)
               {
                  // Cộng profit/loss của lệnh đã đóng vào tổng phiên
                  sessionProfit += positionProfit;
               }
               
               Print("Position đóng - Lý do: ", reason == DEAL_REASON_TP ? "TP" : (reason == DEAL_REASON_SL ? "SL" : "SO"), 
                     " | Profit: ", positionProfit, " USD | Tổng phiên: ", sessionProfit, " USD");
            }
         }
         
         // Chỉ xử lý logic bổ sung lệnh khi đạt TP
         if(reason == DEAL_REASON_TP)
         {
            // Lấy thông tin position đã đóng
            long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
            
            if(magic == MagicNumber && symbol == _Symbol)
            {
               // Lấy Position ID từ deal
               ulong positionId = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
               
               // Lấy thông tin position từ History
               if(HistorySelectByPosition(positionId))
               {
                  int totalDeals = HistoryDealsTotal();
                  double lotSize = 0;
                  double priceOpen = 0;
                  ENUM_ORDER_TYPE orderType = WRONG_VALUE;
                  
                  // Tìm deal mở position (deal đầu tiên)
                  for(int i = 0; i < totalDeals; i++)
                  {
                     ulong dealTicket = HistoryDealGetTicket(i);
                     if(dealTicket > 0)
                     {
                        long dealType = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
                        if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
                        {
                           lotSize = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
                           priceOpen = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
                           
                           // Xác định loại lệnh dựa trên giá mở và giá hiện tại
                           double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                           
                           if(dealType == DEAL_TYPE_BUY)
                           {
                              // Buy Limit: giá mở < giá hiện tại, Buy Stop: giá mở > giá hiện tại
                              if(priceOpen < currentPrice)
                                 orderType = ORDER_TYPE_BUY_LIMIT;
                              else
                                 orderType = ORDER_TYPE_BUY_STOP;
                           }
                           else // DEAL_TYPE_SELL
                           {
                              // Sell Limit: giá mở > giá hiện tại, Sell Stop: giá mở < giá hiện tại
                              if(priceOpen > currentPrice)
                                 orderType = ORDER_TYPE_SELL_LIMIT;
                              else
                                 orderType = ORDER_TYPE_SELL_STOP;
                           }
                           break;
                        }
                     }
                  }
                  
                  // Tìm mức lưới tương ứng
                  if(orderType != WRONG_VALUE && priceOpen > 0 && lotSize > 0)
                  {
                     int levelNumber = GetGridLevelNumber(priceOpen);
                     if(levelNumber > 0)
                     {
                        // Lưu lot size cho mức lưới này
                        SaveLotSizeForLevel(orderType, levelNumber, lotSize);
                        
                        Print("✓ Position đạt TP - Mức ", levelNumber, " | ", EnumToString(orderType), " | Lot: ", lotSize, " | Giá mở: ", priceOpen);
                        
                        // Nếu AutoRefillOrders được bật, bổ sung lệnh lại
                        if(AutoRefillOrders)
                        {
                           // Đợi một chút để đảm bảo position đã đóng hoàn toàn
                           Sleep(100);
                           double levelPrice = GetLevelPrice(levelNumber, orderType);
                           if(levelPrice > 0)
                           {
                              EnsureOrderAtLevel(orderType, levelPrice, levelNumber);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Khởi tạo các level giá cố định cho lưới                        |
//+------------------------------------------------------------------+
void InitializeGridLevels()
{
   double gridDistance = GridDistancePips * pnt * 10.0;
   int totalLevels = MaxGridLevels * 2 + 1; // Cả 2 phía + giá cơ sở
   
   ArrayResize(gridLevels, totalLevels);
   ArrayResize(gridLevelIndex, totalLevels);
   
   int index = 0;
   
   // Level phía trên giá cơ sở (mức 1 là gần nhất, MaxGridLevels là xa nhất)
   for(int i = 1; i <= MaxGridLevels; i++)
   {
      gridLevels[index] = NormalizeDouble(basePrice + (i * gridDistance), dgt);
      gridLevelIndex[index] = i; // Mức lưới: 1, 2, 3... MaxGridLevels
      index++;
   }
   
   // Level giá cơ sở (không dùng, nhưng giữ để tương thích)
   gridLevels[index] = NormalizeDouble(basePrice, dgt);
   gridLevelIndex[index] = 0;
   index++;
   
   // Level phía dưới giá cơ sở (mức 1 là gần nhất, MaxGridLevels là xa nhất)
   for(int i = 1; i <= MaxGridLevels; i++)
   {
      gridLevels[index] = NormalizeDouble(basePrice - (i * gridDistance), dgt);
      gridLevelIndex[index] = i; // Mức lưới: 1, 2, 3... MaxGridLevels
      index++;
   }
   
   Print("Đã khởi tạo ", totalLevels, " grid levels");
}

//+------------------------------------------------------------------+
//| Quản lý hệ thống lưới                                           |
//+------------------------------------------------------------------+
void ManageGridOrders()
{
   // Nếu EA đã dừng thì không quản lý lệnh
   if(eaStopped)
      return;
   
   // Nếu đang ở chế độ Trading Stop thì không đặt lệnh mới
   if(isTradingStopActive)
      return;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Duyệt qua tất cả các level và đảm bảo có lệnh
   for(int i = 0; i < ArraySize(gridLevels); i++)
   {
      double level = gridLevels[i];
      
      // Bỏ qua level quá gần giá hiện tại
      double minDistance = GridDistancePips * pnt * 5.0;
      if(MathAbs(level - currentPrice) < minDistance)
         continue;
      
      // Quyết định loại lệnh dựa trên vị trí level so với giá hiện tại
      // Chỉ đặt lệnh nếu loại lệnh đó được bật trong input
      int levelNumber = gridLevelIndex[i]; // Mức lưới: 1, 2, 3...
      
      if(level > currentPrice)
      {
         // Level phía trên giá hiện tại - chỉ đặt Buy Stop và/hoặc Sell Limit nếu được bật
         if(EnableBuyStop)
            EnsureOrderAtLevel(ORDER_TYPE_BUY_STOP, level, levelNumber);
         if(EnableSellLimit)
            EnsureOrderAtLevel(ORDER_TYPE_SELL_LIMIT, level, levelNumber);
      }
      else if(level < currentPrice)
      {
         // Level phía dưới giá hiện tại - chỉ đặt Buy Limit và/hoặc Sell Stop nếu được bật
         if(EnableBuyLimit)
            EnsureOrderAtLevel(ORDER_TYPE_BUY_LIMIT, level, levelNumber);
         if(EnableSellStop)
            EnsureOrderAtLevel(ORDER_TYPE_SELL_STOP, level, levelNumber);
      }
   }
}

//+------------------------------------------------------------------+
//| Đảm bảo có lệnh tại level - tạo nếu chưa có                    |
//+------------------------------------------------------------------+
void EnsureOrderAtLevel(ENUM_ORDER_TYPE orderType, double priceLevel, int levelNumber)
{
   // Nếu EA đã dừng thì không đặt lệnh
   if(eaStopped)
      return;
   
   // Nếu đang ở chế độ Trading Stop thì không đặt lệnh mới
   if(isTradingStopActive)
      return;
   
   // Kiểm tra xem đã có lệnh hoặc position tại level này chưa
   if(OrderOrPositionExistsAtLevel(orderType, priceLevel))
      return;
   
   // Kiểm tra cân bằng lưới
   if(!CanPlaceOrderAtLevel(orderType, priceLevel))
      return;
   
   // Đặt lệnh mới với mức lưới
   PlacePendingOrder(orderType, priceLevel, levelNumber);
}

//+------------------------------------------------------------------+
//| Kiểm tra có lệnh hoặc position tại level không                 |
//+------------------------------------------------------------------+
bool OrderOrPositionExistsAtLevel(ENUM_ORDER_TYPE orderType, double priceLevel)
{
   double tolerance = GridDistancePips * pnt * 5.0;
   bool isBuyOrder = (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP);
   
   // Kiểm tra pending orders
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
            if(MathAbs(orderPrice - priceLevel) < tolerance)
            {
               ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
               bool isOrderBuy = (ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP);
               
               if(isBuyOrder == isOrderBuy)
                  return true;
            }
         }
      }
   }
   
   // Kiểm tra positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            if(MathAbs(posPrice - priceLevel) < tolerance)
            {
               ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               bool isPosBuy = (pt == POSITION_TYPE_BUY);
               
               if(isBuyOrder == isPosBuy)
                  return true;
            }
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra có thể đặt lệnh tại level không (cân bằng lưới)       |
//+------------------------------------------------------------------+
bool CanPlaceOrderAtLevel(ENUM_ORDER_TYPE orderType, double priceLevel)
{
   double tolerance = GridDistancePips * pnt * 5.0;
   bool isBuyOrder = (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP);
   
   int buyCount = 0;
   int sellCount = 0;
   
   // Đếm pending orders tại level này
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber && 
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
            if(MathAbs(orderPrice - priceLevel) < tolerance)
            {
               ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
               if(ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP)
                  buyCount++;
               else if(ot == ORDER_TYPE_SELL_LIMIT || ot == ORDER_TYPE_SELL_STOP)
                  sellCount++;
            }
         }
      }
   }
   
   // Đếm positions tại level này
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && 
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            if(MathAbs(posPrice - priceLevel) < tolerance)
            {
               ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(pt == POSITION_TYPE_BUY)
                  buyCount++;
               else if(pt == POSITION_TYPE_SELL)
                  sellCount++;
            }
         }
      }
   }
   
   // Kiểm tra cân bằng: mỗi level tối đa 1 Buy và 1 Sell
   if(isBuyOrder && buyCount >= 1)
      return false;
   if(!isBuyOrder && sellCount >= 1)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Đặt lệnh chờ với TP                                            |
//+------------------------------------------------------------------+
void PlacePendingOrder(ENUM_ORDER_TYPE orderType, double priceLevel, int levelNumber)
{
   double price = NormalizeDouble(priceLevel, dgt);
   double lotSize = 0;
   double tp = 0;
   bool enableMartingale = false;
   double martingaleMultiplier = 1.0;
   
   // Xác định Lot Size và Take Profit dựa trên loại lệnh
   if(orderType == ORDER_TYPE_BUY_LIMIT)
   {
      lotSize = LotSizeBuyLimit;
      enableMartingale = EnableMartingaleBuyLimit;
      martingaleMultiplier = MartingaleMultiplierBuyLimit;
      if(TakeProfitPipsBuyLimit > 0)
         tp = NormalizeDouble(price + TakeProfitPipsBuyLimit * pnt * 10.0, dgt);
   }
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
   {
      lotSize = LotSizeSellLimit;
      enableMartingale = EnableMartingaleSellLimit;
      martingaleMultiplier = MartingaleMultiplierSellLimit;
      if(TakeProfitPipsSellLimit > 0)
         tp = NormalizeDouble(price - TakeProfitPipsSellLimit * pnt * 10.0, dgt);
   }
   else if(orderType == ORDER_TYPE_BUY_STOP)
   {
      lotSize = LotSizeBuyStop;
      enableMartingale = EnableMartingaleBuyStop;
      martingaleMultiplier = MartingaleMultiplierBuyStop;
      if(TakeProfitPipsBuyStop > 0)
         tp = NormalizeDouble(price + TakeProfitPipsBuyStop * pnt * 10.0, dgt);
   }
   else if(orderType == ORDER_TYPE_SELL_STOP)
   {
      lotSize = LotSizeSellStop;
      enableMartingale = EnableMartingaleSellStop;
      martingaleMultiplier = MartingaleMultiplierSellStop;
      if(TakeProfitPipsSellStop > 0)
         tp = NormalizeDouble(price - TakeProfitPipsSellStop * pnt * 10.0, dgt);
   }
   
   // Kiểm tra xem có lot size đã lưu cho mức lưới này không (từ lệnh TP trước đó)
   double savedLotSize = GetSavedLotSize(orderType, levelNumber);
   if(savedLotSize > 0)
   {
      // Sử dụng lot size đã lưu (từ lệnh đạt TP trước đó)
      lotSize = savedLotSize;
      Print("  → Sử dụng lot size đã lưu: ", lotSize, " cho mức ", levelNumber);
   }
   else
   {
      // Tính toán lot size với gấp thếp mới
      // Mức 1: lotSize (không gấp)
      // Mức 2: lotSize * multiplier
      // Mức 3: lotSize * multiplier^2
      // Mức n: lotSize * multiplier^(n-1)
      if(enableMartingale && levelNumber > 1 && martingaleMultiplier > 0)
      {
         double multiplier = MathPow(martingaleMultiplier, levelNumber - 1);
         lotSize = NormalizeDouble(lotSize * multiplier, 2);
      }
   }
   
   // Đặt lệnh (không có Stop Loss)
   bool result = false;
   if(orderType == ORDER_TYPE_BUY_LIMIT)
      result = trade.BuyLimit(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
      result = trade.SellLimit(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   else if(orderType == ORDER_TYPE_BUY_STOP)
      result = trade.BuyStop(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   else if(orderType == ORDER_TYPE_SELL_STOP)
      result = trade.SellStop(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   
   if(result)
   {
      string martingaleInfo = "";
      if(enableMartingale && levelNumber > 1)
         martingaleInfo = " | Mức " + IntegerToString(levelNumber) + " (x" + DoubleToString(MathPow(martingaleMultiplier, levelNumber - 1), 2) + ")";
      Print("✓ Đã đặt lệnh: ", EnumToString(orderType), " tại ", price, " | Lot: ", lotSize, " | TP: ", tp, martingaleInfo);
   }
   else
   {
      Print("✗ Lỗi đặt lệnh: ", EnumToString(orderType), " | Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Lưu lot size cho mức lưới khi đạt TP                            |
//+------------------------------------------------------------------+
void SaveLotSizeForLevel(ENUM_ORDER_TYPE orderType, int levelNumber, double lotSize)
{
   if(levelNumber < 1 || levelNumber >= 50)
      return;
   
   int index = levelNumber - 1; // Mảng bắt đầu từ 0
   
   if(orderType == ORDER_TYPE_BUY_LIMIT)
      gridLotSizes.lotSizeBuyLimit[index] = lotSize;
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
      gridLotSizes.lotSizeSellLimit[index] = lotSize;
   else if(orderType == ORDER_TYPE_BUY_STOP)
      gridLotSizes.lotSizeBuyStop[index] = lotSize;
   else if(orderType == ORDER_TYPE_SELL_STOP)
      gridLotSizes.lotSizeSellStop[index] = lotSize;
}

//+------------------------------------------------------------------+
//| Lấy lot size đã lưu cho mức lưới                                |
//+------------------------------------------------------------------+
double GetSavedLotSize(ENUM_ORDER_TYPE orderType, int levelNumber)
{
   if(levelNumber < 1 || levelNumber >= 50)
      return 0;
   
   int index = levelNumber - 1;
   
   if(orderType == ORDER_TYPE_BUY_LIMIT)
      return gridLotSizes.lotSizeBuyLimit[index];
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
      return gridLotSizes.lotSizeSellLimit[index];
   else if(orderType == ORDER_TYPE_BUY_STOP)
      return gridLotSizes.lotSizeBuyStop[index];
   else if(orderType == ORDER_TYPE_SELL_STOP)
      return gridLotSizes.lotSizeSellStop[index];
   
   return 0;
}

//+------------------------------------------------------------------+
//| Lấy số mức lưới từ giá                                          |
//+------------------------------------------------------------------+
int GetGridLevelNumber(double price)
{
   double tolerance = GridDistancePips * pnt * 5.0;
   
   for(int i = 0; i < ArraySize(gridLevels); i++)
   {
      if(MathAbs(gridLevels[i] - price) < tolerance)
      {
         return gridLevelIndex[i];
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Lấy giá của mức lưới theo số mức và loại lệnh                  |
//+------------------------------------------------------------------+
double GetLevelPrice(int levelNumber, ENUM_ORDER_TYPE orderType)
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < ArraySize(gridLevels); i++)
   {
      if(gridLevelIndex[i] == levelNumber)
      {
         double level = gridLevels[i];
         
         // Kiểm tra xem level có phù hợp với loại lệnh không
         if(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_SELL_STOP)
         {
            if(level < currentPrice)
               return level;
         }
         else if(orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_SELL_LIMIT)
         {
            if(level > currentPrice)
               return level;
         }
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Kiểm tra điều kiện kích hoạt Trading Stop, Step Tổng           |
//+------------------------------------------------------------------+
void CheckTradingStopStepTotal()
{
   double currentProfit = 0.0;
   double threshold = 0.0;
   string profitType = "";
   
   // Kiểm tra theo chế độ đã chọn
   if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
   {
      // Chế độ: Theo lệnh mở
      if(TradingStopStepTotalProfit <= 0)
         return;
      
      currentProfit = GetTotalOpenProfit();
      threshold = TradingStopStepTotalProfit;
      profitType = "lệnh đang mở";
   }
   else // TRADING_STOP_MODE_SESSION
   {
      // Chế độ: Theo phiên
      if(TradingStopStepSessionProfit <= 0)
         return;
      
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      currentProfit = currentEquity - initialEquity;  // Lãi phiên = Vốn hiện tại - Vốn ban đầu
      threshold = TradingStopStepSessionProfit;
      profitType = "phiên";
   }
   
   // Kiểm tra xem có đạt mức kích hoạt không
   if(currentProfit >= threshold)
   {
      Print("========================================");
      Print("=== KÍCH HOẠT TRADING STOP, STEP TỔNG ===");
      Print("Chế độ: ", TradingStopStepMode == TRADING_STOP_MODE_OPEN ? "Theo lệnh mở" : "Theo phiên");
      Print("Tổng lãi ", profitType, ": ", currentProfit, " USD");
      Print("Mức kích hoạt: ", threshold, " USD");
      Print("========================================");
      
      ActivateTradingStop();
   }
}

//+------------------------------------------------------------------+
//| Kích hoạt Trading Stop - Xóa lệnh chờ, xóa TP, tính điểm A    |
//+------------------------------------------------------------------+
void ActivateTradingStop()
{
   isTradingStopActive = true;
   firstStepDone = false;
   initialPriceForStop = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   lastPriceForStep = initialPriceForStop;
   
   // 1. Xóa tất cả lệnh chờ
   CloseAllPendingOrders();
   Print("✓ Đã xóa tất cả lệnh chờ");
   
   // 2. Tìm lệnh dương (đang lãi) và xóa TP của chúng, tính điểm A
   double lowestProfitPrice = 0.0; // Giá thấp nhất của lệnh dương
   bool foundProfitPosition = false;
   
   // Duyệt qua tất cả positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ xử lý lệnh dương (đang lãi)
            if(positionProfit > 0)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               
               // Xóa TP của lệnh này
               if(!trade.PositionModify(ticket, 0, 0))
               {
                  Print("⚠ Lỗi xóa TP cho position ", ticket, ": ", GetLastError());
               }
               
               // Tìm giá thấp nhất (cho Sell) hoặc cao nhất (cho Buy)
               ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               
               if(!foundProfitPosition)
               {
                  lowestProfitPrice = openPrice;
                  foundProfitPosition = true;
               }
               else
               {
                  // Với Sell: tìm giá thấp nhất
                  // Với Buy: tìm giá cao nhất
                  if(posType == POSITION_TYPE_SELL)
                  {
                     if(openPrice < lowestProfitPrice)
                        lowestProfitPrice = openPrice;
                  }
                  else // POSITION_TYPE_BUY
                  {
                     if(openPrice > lowestProfitPrice)
                        lowestProfitPrice = openPrice;
                  }
               }
            }
         }
      }
   }
   
   if(!foundProfitPosition)
   {
      Print("⚠ Không tìm thấy lệnh dương nào để gồng lãi");
      isTradingStopActive = false;
      return;
   }
   
   // 3. Tính điểm A
   // Với Sell: điểm A = giá thấp nhất - X pips (phía dưới)
   // Với Buy: điểm A = giá cao nhất + X pips (phía trên)
   // Tuy nhiên, cần kiểm tra loại lệnh dương
   double pointADistance = TradingStopStepPointA * pnt * 10.0;
   
   // Kiểm tra xem lệnh dương là Buy hay Sell
   bool isProfitSell = false;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            if(positionProfit > 0)
            {
               ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(posType == POSITION_TYPE_SELL)
               {
                  isProfitSell = true;
                  break;
               }
            }
         }
      }
   }
   
   if(isProfitSell)
   {
      // Sell: điểm A = giá thấp nhất - X pips
      pointA = NormalizeDouble(lowestProfitPrice - pointADistance, dgt);
   }
   else
   {
      // Buy: điểm A = giá cao nhất + X pips
      pointA = NormalizeDouble(lowestProfitPrice + pointADistance, dgt);
   }
   
   Print("✓ Đã tính điểm A: ", pointA);
   Print("  - Giá lệnh dương thấp nhất (Sell)/cao nhất (Buy): ", lowestProfitPrice);
   Print("  - Khoảng cách: ", TradingStopStepPointA, " pips");
   Print("  - Điểm A sẽ được set làm SL khi giá đi xuống/đi lên ", TradingStopStepSize, " pips");
}

//+------------------------------------------------------------------+
//| Quản lý Trading Stop - Đóng lệnh âm, di chuyển SL theo step    |
//+------------------------------------------------------------------+
void ManageTradingStop()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double stepDistance = TradingStopStepSize * pnt * 10.0;
   
   // Kiểm tra nếu chưa hoàn thành step đầu tiên và tổng lãi giảm xuống
   if(!firstStepDone)
   {
      double currentProfit = 0.0;
      double threshold = 0.0;
      string profitType = "";
      
      // Tính tổng lãi theo chế độ đã chọn
      if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
      {
         // Chế độ: Theo lệnh mở
         currentProfit = GetTotalOpenProfit();
         threshold = TradingStopStepTotalProfit;
         profitType = "lệnh đang mở";
      }
      else // TRADING_STOP_MODE_SESSION
      {
         // Chế độ: Theo phiên
         double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
         currentProfit = currentEquity - initialEquity;  // Lãi phiên = Vốn hiện tại - Vốn ban đầu
         threshold = TradingStopStepSessionProfit;
         profitType = "phiên";
      }
      
      // Nếu tổng lãi giảm xuống dưới ngưỡng kích hoạt
      if(currentProfit < threshold)
      {
         // Nếu >= ngưỡng quay lại, tiếp tục chế độ Trading Stop
         if(currentProfit >= TradingStopStepReturnProfit)
         {
            // Vẫn ở chế độ Trading Stop, chỉ log
            static int logCount = 0;
            logCount++;
            if(logCount % 100 == 0)
            {
               Print("Trading Stop đang chờ - Tổng lãi ", profitType, ": ", currentProfit, " USD (ngưỡng: ", threshold, " USD)");
            }
         }
         else
         {
            // Tổng lãi < ngưỡng quay lại → Hủy Trading Stop, khôi phục bình thường
            Print("========================================");
            Print("=== HỦY TRADING STOP - TỔNG LÃI GIẢM ===");
            Print("Chế độ: ", TradingStopStepMode == TRADING_STOP_MODE_OPEN ? "Theo lệnh mở" : "Theo phiên");
            Print("Tổng lãi ", profitType, " hiện tại: ", currentProfit, " USD");
            Print("Ngưỡng quay lại: ", TradingStopStepReturnProfit, " USD");
            Print("EA sẽ khôi phục lại bình thường");
            Print("========================================");
            
            // Khôi phục TP cho các lệnh dương
            RestoreTPForProfitPositions();
            
            // Hủy chế độ Trading Stop
            isTradingStopActive = false;
            pointA = 0.0;
            lastPriceForStep = 0.0;
            initialPriceForStop = 0.0;
            firstStepDone = false;
            
            // EA sẽ tự động bổ sung lại lệnh chờ khi ManageGridOrders() chạy
            return;
         }
      }
   }
   
   // Kiểm tra xem lệnh dương là Buy hay Sell
   bool isProfitSell = false;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            if(positionProfit > 0)
            {
               ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(posType == POSITION_TYPE_SELL)
               {
                  isProfitSell = true;
                  break;
               }
            }
         }
      }
   }
   
   // 1. Step đầu tiên: Khi giá đi xuống (Sell) hoặc đi lên (Buy) 1 step pips
   //    → Đặt SL tại điểm A, sau đó đóng tất cả lệnh âm
   if(!firstStepDone)
   {
      double priceChange = 0.0;
      if(isProfitSell)
      {
         // Với Sell: giá đi xuống (giảm)
         priceChange = lastPriceForStep - currentPrice;
         if(priceChange >= stepDistance)
         {
            Print("=== STEP 1: Giá đi xuống ", TradingStopStepSize, " pips ===");
            
            // Đặt SL tại điểm A cho tất cả lệnh dương TRƯỚC
            SetSLToPointAForProfitPositions();
            
            // Sau đó đóng tất cả lệnh âm
            CloseNegativePositions();
            
            firstStepDone = true;
            lastPriceForStep = currentPrice;
         }
      }
      else
      {
         // Với Buy: giá đi lên (tăng)
         priceChange = currentPrice - lastPriceForStep;
         if(priceChange >= stepDistance)
         {
            Print("=== STEP 1: Giá đi lên ", TradingStopStepSize, " pips ===");
            
            // Đặt SL tại điểm A cho tất cả lệnh dương TRƯỚC
            SetSLToPointAForProfitPositions();
            
            // Sau đó đóng tất cả lệnh âm
            CloseNegativePositions();
            
            firstStepDone = true;
            lastPriceForStep = currentPrice;
         }
      }
   }
   else
   {
      // 2. Các step tiếp theo: Dịch SL theo giá
      double priceChange = 0.0;
      double newPointA = pointA;
      
      if(isProfitSell)
      {
         // Với Sell: giá đi xuống thêm 1 step → dịch SL xuống theo
         priceChange = lastPriceForStep - currentPrice;
         if(priceChange >= stepDistance)
         {
            // Dịch điểm A xuống 1 step
            newPointA = NormalizeDouble(pointA - stepDistance, dgt);
            
            Print("=== STEP TIẾP: Giá đi xuống thêm ", TradingStopStepSize, " pips ===");
            Print("  - Điểm A cũ: ", pointA);
            Print("  - Điểm A mới: ", newPointA);
            
            // Cập nhật SL cho tất cả lệnh dương
            pointA = newPointA;
            UpdateSLForProfitPositions(newPointA);
            
            lastPriceForStep = currentPrice;
         }
         
         // Kiểm tra xem giá có quay đầu chạm SL không (giá tăng lên >= điểm A)
         if(currentPrice >= pointA)
         {
            Print("========================================");
            Print("=== GIÁ QUAY ĐẦU CHẠM SL ===");
            Print("Giá hiện tại: ", currentPrice);
            Print("Điểm A (SL): ", pointA);
            
            string actionText = "";
            if(ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA)
               actionText = "Reset EA";
            else if(ActionOnTradingStopStepComplete == TP_ACTION_STOP_EA)
               actionText = "Dừng EA";
            else
               actionText = "Khôi phục bình thường";
            
            Print("Hành động: ", actionText);
            Print("========================================");
            
            // Reset biến Trading Stop
            isTradingStopActive = false;
            pointA = 0.0;
            lastPriceForStep = 0.0;
            initialPriceForStop = 0.0;
            firstStepDone = false;
            
            // Thực hiện hành động theo cài đặt
            if(ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA)
            {
               // Reset EA - Mở lại từ đầu tại giá mới
               ResetEA("Trading Stop, Step Tổng");
            }
            else
            {
               // Dừng EA - Dừng hoàn toàn, không đặt lệnh nữa
               StopEA();
            }
         }
      }
      else
      {
         // Với Buy: giá đi lên thêm 1 step → dịch SL lên theo
         priceChange = currentPrice - lastPriceForStep;
         if(priceChange >= stepDistance)
         {
            // Dịch điểm A lên 1 step
            newPointA = NormalizeDouble(pointA + stepDistance, dgt);
            
            Print("=== STEP TIẾP: Giá đi lên thêm ", TradingStopStepSize, " pips ===");
            Print("  - Điểm A cũ: ", pointA);
            Print("  - Điểm A mới: ", newPointA);
            
            // Cập nhật SL cho tất cả lệnh dương
            pointA = newPointA;
            UpdateSLForProfitPositions(newPointA);
            
            lastPriceForStep = currentPrice;
         }
         
         // Kiểm tra xem giá có quay đầu chạm SL không (giá giảm xuống <= điểm A)
         if(currentPrice <= pointA)
         {
            Print("========================================");
            Print("=== GIÁ QUAY ĐẦU CHẠM SL ===");
            Print("Giá hiện tại: ", currentPrice);
            Print("Điểm A (SL): ", pointA);
            Print("Hành động: ", ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
            Print("========================================");
            
            // Reset biến Trading Stop
            isTradingStopActive = false;
            pointA = 0.0;
            lastPriceForStep = 0.0;
            initialPriceForStop = 0.0;
            firstStepDone = false;
            
            // Thực hiện hành động theo cài đặt
            if(ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA)
            {
               // Reset EA - Mở lại từ đầu tại giá mới
               ResetEA("Trading Stop, Step Tổng");
            }
            else
            {
               // Dừng EA - Dừng hoàn toàn, không đặt lệnh nữa
               StopEA();
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Đóng tất cả lệnh âm (đang lỗ)                                   |
//+------------------------------------------------------------------+
void CloseNegativePositions()
{
   int closedCount = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ đóng lệnh âm (đang lỗ)
            if(positionProfit < 0)
            {
               if(trade.PositionClose(ticket))
               {
                  closedCount++;
                  Print("✓ Đã đóng lệnh âm: Ticket ", ticket, " | Profit: ", positionProfit, " USD");
               }
            }
         }
      }
   }
   
   Print("Đã đóng ", closedCount, " lệnh âm");
}

//+------------------------------------------------------------------+
//| Đặt SL tại điểm A cho tất cả lệnh dương                         |
//+------------------------------------------------------------------+
void SetSLToPointAForProfitPositions()
{
   int modifiedCount = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ set SL cho lệnh dương
            if(positionProfit > 0)
            {
               if(trade.PositionModify(ticket, pointA, 0))
               {
                  modifiedCount++;
                  Print("✓ Đã set SL tại điểm A (", pointA, ") cho position ", ticket);
               }
               else
               {
                  Print("⚠ Lỗi set SL cho position ", ticket, ": ", GetLastError());
               }
            }
         }
      }
   }
   
   Print("Đã set SL tại điểm A cho ", modifiedCount, " lệnh dương");
}

//+------------------------------------------------------------------+
//| Cập nhật SL cho tất cả lệnh dương theo điểm A mới               |
//+------------------------------------------------------------------+
void UpdateSLForProfitPositions(double newSL)
{
   int modifiedCount = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ update SL cho lệnh dương
            if(positionProfit > 0)
            {
               if(trade.PositionModify(ticket, newSL, 0))
               {
                  modifiedCount++;
               }
            }
         }
      }
   }
   
   if(modifiedCount > 0)
   {
      Print("✓ Đã cập nhật SL cho ", modifiedCount, " lệnh dương tại ", newSL);
   }
}

//+------------------------------------------------------------------+
//| Khôi phục TP cho tất cả lệnh dương (khi hủy Trading Stop)       |
//+------------------------------------------------------------------+
void RestoreTPForProfitPositions()
{
   int restoredCount = 0;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ khôi phục TP cho lệnh dương
            if(positionProfit > 0)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               double tp = 0;
               
               // Xác định loại lệnh và tính TP tương ứng
               if(posType == POSITION_TYPE_BUY)
               {
                  // Buy Limit: giá mở < giá hiện tại
                  // Buy Stop: giá mở > giá hiện tại
                  if(openPrice < currentPrice)
                  {
                     // Buy Limit
                     if(TakeProfitPipsBuyLimit > 0)
                     {
                        tp = NormalizeDouble(openPrice + TakeProfitPipsBuyLimit * pnt * 10.0, dgt);
                     }
                  }
                  else
                  {
                     // Buy Stop
                     if(TakeProfitPipsBuyStop > 0)
                     {
                        tp = NormalizeDouble(openPrice + TakeProfitPipsBuyStop * pnt * 10.0, dgt);
                     }
                  }
               }
               else // POSITION_TYPE_SELL
               {
                  // Sell Limit: giá mở > giá hiện tại
                  // Sell Stop: giá mở < giá hiện tại
                  if(openPrice > currentPrice)
                  {
                     // Sell Limit
                     if(TakeProfitPipsSellLimit > 0)
                     {
                        tp = NormalizeDouble(openPrice - TakeProfitPipsSellLimit * pnt * 10.0, dgt);
                     }
                  }
                  else
                  {
                     // Sell Stop
                     if(TakeProfitPipsSellStop > 0)
                     {
                        tp = NormalizeDouble(openPrice - TakeProfitPipsSellStop * pnt * 10.0, dgt);
                     }
                  }
               }
               
               // Khôi phục TP (giữ nguyên SL hiện tại nếu có)
               double currentSL = PositionGetDouble(POSITION_SL);
               if(tp > 0)
               {
                  if(trade.PositionModify(ticket, currentSL, tp))
                  {
                     restoredCount++;
                     Print("✓ Đã khôi phục TP (", tp, ") cho position ", ticket);
                  }
                  else
                  {
                     Print("⚠ Lỗi khôi phục TP cho position ", ticket, ": ", GetLastError());
                  }
               }
            }
         }
      }
   }
   
   if(restoredCount > 0)
   {
      Print("Đã khôi phục TP cho ", restoredCount, " lệnh dương");
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra reset dựa trên lot và tổng phiên                       |
//+------------------------------------------------------------------+
void CheckLotBasedReset()
{
   // Kiểm tra các ngưỡng có được bật không
   if(MaxLotThreshold <= 0 || TotalLotThreshold <= 0 || SessionProfitForLotReset <= 0)
      return;
   
   // Tính lot lớn nhất và tổng lot của lệnh đang mở
   double maxLot = GetMaxLot();
   double totalLot = GetTotalLot();
   
   // Tính tổng phiên hiện tại
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double sessionProfit = currentEquity - initialEquity;
   
   // Kiểm tra điều kiện reset
   if(maxLot >= MaxLotThreshold && totalLot >= TotalLotThreshold && sessionProfit >= SessionProfitForLotReset)
   {
      Print("========================================");
      Print("=== RESET DỰA TRÊN LOT VÀ TỔNG PHIÊN ===");
      Print("Lot lớn nhất: ", maxLot, " (ngưỡng: ", MaxLotThreshold, ")");
      Print("Tổng lot: ", totalLot, " (ngưỡng: ", TotalLotThreshold, ")");
      Print("Tổng phiên: ", sessionProfit, " USD (ngưỡng: ", SessionProfitForLotReset, " USD)");
      Print("EA sẽ RESET và khởi động lại từ đầu tại giá mới");
      Print("========================================");
      
      ResetEA("Lot-based Reset");
   }
}

//+------------------------------------------------------------------+//+------------------------------------------------------------------+
//| Lấy lot lớn nhất của lệnh đang mở                                |
//+------------------------------------------------------------------+
double GetMaxLot()
{
   double maxLot = 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double lotSize = PositionGetDouble(POSITION_VOLUME);
            if(lotSize > maxLot)
               maxLot = lotSize;
         }
      }
   }
   
   return maxLot;
}

//+------------------------------------------------------------------+
//| Lấy tổng lot của lệnh đang mở                                     |
//+------------------------------------------------------------------+
double GetTotalLot()
{
   double totalLot = 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            totalLot += PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   
   return totalLot;
}

//+------------------------------------------------------------------+
//| Tạo panel hiển thị thông tin EA                                   |
//+------------------------------------------------------------------+
void CreatePanel()
{
   // Xóa các object cũ nếu có
   DeletePanel();
   
   int x = 20;  // Vị trí X
   int y = 30;  // Vị trí Y
   int width = 360;  // Chiều rộng panel (giảm từ 450)
   int currentY = y + 5;
   
   // Background panel chính (tăng chiều cao để bao phủ phần tài chính)
   CreateRectangle("EA_Panel_BG", x, y, width, 370, clrDarkSlateGray);
   
   // Header
   CreatePanelLabel("EA_Panel_Title", x + 10, currentY, "THÔNG TIN EA MT5", clrWhite, 10, true);
   CreatePanelLabel("EA_Panel_Status", x + width - 85, currentY, "ĐANG CHẠY", clrLime, 9, true);
   currentY += 25;
   
   // Section: TÊN BIỂU ĐỒ & GIÁ HIỆN TẠI
   CreatePanelLabel("EA_Panel_SymbolTitle", x + 10, currentY, "TÊN BIỂU ĐỒ & GIÁ HIỆN TẠI", clrWhite, 8, true);
   currentY += 20;
   CreatePanelLabel("EA_Panel_SymbolName", x + 10, currentY, "", clrWhite, 12, true);
   CreatePanelLabel("EA_Panel_Price", x + 180, currentY, "", clrLime, 12, true);
   CreatePanelLabel("EA_Panel_Trend", x + 320, currentY, "", clrLime, 10, false);
   currentY += 30;
   
   // Section: THÔNG SỐ LƯỚI
   CreatePanelLabel("EA_Panel_GridTitle", x + 10, currentY, "THÔNG SỐ LƯỚI", clrWhite, 8, true);
   currentY += 20;
   
   // Card: SỐ LƯỚI TỐI ĐA
   CreateCard("EA_Panel_Card_MaxLevels", x + 10, currentY, 165, 50);
   CreatePanelLabel("EA_Panel_MaxLevels_Label", x + 20, currentY + 3, "SỐ LƯỚI TỐI ĐA", clrLightGray, 7, false);
   CreatePanelLabel("EA_Panel_MaxLevels_Value", x + 20, currentY + 18, "", clrWhite, 14, true);
   CreatePanelLabel("EA_Panel_MaxLevels_Unit", x + 20, currentY + 35, "LỚP", clrLightGray, 8, false);
   
   // Card: KHOẢNG CÁCH LƯỚI
   CreateCard("EA_Panel_Card_GridDist", x + 185, currentY, 165, 50);
   CreatePanelLabel("EA_Panel_GridDist_Label", x + 195, currentY + 3, "KHOẢNG CÁCH LƯỚI", clrLightGray, 7, false);
   CreatePanelLabel("EA_Panel_GridDist_Value", x + 195, currentY + 18, "", clrWhite, 14, true);
   CreatePanelLabel("EA_Panel_GridDist_Unit", x + 195, currentY + 35, "PIPS", clrLightGray, 8, false);
   currentY += 65;
   
   // Section: QUẢN LÝ RỦI RO
   CreatePanelLabel("EA_Panel_RiskTitle", x + 10, currentY, "QUẢN LÝ RỦI RO", clrWhite, 8, true);
   currentY += 20;
   
   // Progress bar: SỐ TIỀN LỖ LỚN NHẤT / VỐN
   CreatePanelLabel("EA_Panel_MaxLoss_Label", x + 10, currentY, "SỐ TIỀN LỖ LỚN NHẤT / VỐN", clrLightGray, 7, false);
   currentY += 16;
   CreatePanelLabel("EA_Panel_MaxLoss_Value", x + 10, currentY, "", clrRed, 9, true);
   CreatePanelLabel("EA_Panel_MaxLoss_Capital", x + 120, currentY, "", clrWhite, 8, false);
   CreatePanelLabel("EA_Panel_MaxLoss_Percent", x + width - 50, currentY, "", clrWhite, 8, false);
   currentY += 16;
   CreateProgressBar("EA_Panel_ProgressBar", x + 10, currentY, width - 20, 6);
   currentY += 20;
   
   // Card: SỐ LOT LỚN NHẤT
   CreateCard("EA_Panel_Card_MaxLot", x + 10, currentY, 165, 50);
   CreatePanelLabel("EA_Panel_MaxLot_Label", x + 20, currentY + 3, "SỐ LOT LỚN NHẤT", clrLightGray, 7, false);
   CreatePanelLabel("EA_Panel_MaxLot_Value", x + 20, currentY + 18, "", clrWhite, 14, true);
   
   // Card: TỔNG LOT
   CreateCard("EA_Panel_Card_TotalLot", x + 185, currentY, 165, 50);
   CreatePanelLabel("EA_Panel_TotalLot_Label", x + 195, currentY + 3, "TỔNG LOT", clrLightGray, 7, false);
   CreatePanelLabel("EA_Panel_TotalLot_Value", x + 195, currentY + 18, "", clrLime, 14, true);
   currentY += 65;
   
   // Section: Tài chính
   CreatePanelLabel("EA_Panel_OpenProfit_Label", x + 10, currentY, "SỐ TIỀN CÁC LỆNH ĐANG MỞ", clrLightGray, 7, false);
   CreatePanelLabel("EA_Panel_OpenProfit_Value", x + 10, currentY + 16, "", clrLime, 12, true);
   
   CreatePanelLabel("EA_Panel_SessionProfit_Label", x + 185, currentY, "SỐ TIỀN CỦA PHIÊN", clrLightGray, 7, false);
   CreatePanelLabel("EA_Panel_SessionProfit_Value", x + 185, currentY + 16, "", clrLime, 12, true);
   CreatePanelLabel("EA_Panel_SessionProfit_Percent", x + 185, currentY + 32, "", clrLime, 9, false);
   
   // Cập nhật lần đầu
   UpdatePanel();
}

//+------------------------------------------------------------------+
//| Tạo card (hình chữ nhật)                                          |
//+------------------------------------------------------------------+
void CreateCard(string name, int x, int y, int width, int height)
{
   CreateRectangle(name, x, y, width, height, clrDimGray);
}

//+------------------------------------------------------------------+
//| Tạo hình chữ nhật                                                 |
//+------------------------------------------------------------------+
void CreateRectangle(string name, int x, int y, int width, int height, color bgColor)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Tạo progress bar                                                  |
//+------------------------------------------------------------------+
void CreateProgressBar(string name, int x, int y, int width, int height)
{
   // Background bar
   CreateRectangle(name + "_BG", x, y, width, height, clrDarkGray);
   // Progress bar (sẽ được cập nhật trong UpdatePanel)
   CreateRectangle(name + "_Fill", x, y, 0, height, clrRed);
}

//+------------------------------------------------------------------+
//| Tạo label cho panel                                               |
//+------------------------------------------------------------------+
void CreatePanelLabel(string name, int x, int y, string text, color clr, int fontSize, bool bold)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
}

//+------------------------------------------------------------------+
//| Cập nhật panel                                                    |
//+------------------------------------------------------------------+
void UpdatePanel()
{
   // Theo dõi vốn thấp nhất (khi lỗ lớn nhất)
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(minEquity == 0.0 || currentEquity < minEquity)
   {
      minEquity = currentEquity;
   }
   
   // Tính số âm lớn nhất của lệnh đang mở
   double currentOpenProfit = GetTotalOpenProfit();
   if(currentOpenProfit < maxNegativeProfit)
   {
      maxNegativeProfit = currentOpenProfit;
      balanceAtMaxLoss = AccountInfoDouble(ACCOUNT_BALANCE);  // Lưu số dư tại thời điểm có số âm lớn nhất
   }
   
   // Trạng thái EA
   string statusText = eaStopped ? "ĐÃ DỪNG" : "ĐANG CHẠY";
   color statusColor = eaStopped ? clrRed : clrLime;
   ObjectSetString(0, "EA_Panel_Status", OBJPROP_TEXT, statusText);
   ObjectSetInteger(0, "EA_Panel_Status", OBJPROP_COLOR, statusColor);
   
   // Tên biểu đồ và giá
   string symbolName = _Symbol;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string priceText = DoubleToString(currentPrice, dgt);
   
   // Xác định xu hướng
   static double lastPrice = 0;
   string trendIcon = "";
   if(lastPrice > 0)
   {
      if(currentPrice > lastPrice)
         trendIcon = "▲";
      else if(currentPrice < lastPrice)
         trendIcon = "▼";
      else
         trendIcon = "—";
   }
   lastPrice = currentPrice;
   
   ObjectSetString(0, "EA_Panel_SymbolName", OBJPROP_TEXT, symbolName);
   ObjectSetString(0, "EA_Panel_Price", OBJPROP_TEXT, priceText);
   ObjectSetString(0, "EA_Panel_Trend", OBJPROP_TEXT, trendIcon);
   
   // Số lưới tối đa
   ObjectSetString(0, "EA_Panel_MaxLevels_Value", OBJPROP_TEXT, IntegerToString(MaxGridLevels));
   
   // Khoảng cách lưới
   ObjectSetString(0, "EA_Panel_GridDist_Value", OBJPROP_TEXT, DoubleToString(GridDistancePips, 1));
   
   // Số tiền lỗ lớn nhất: số âm lớn nhất của lệnh đang mở / số dư lúc đó
   double maxLoss = maxNegativeProfit;  // Số âm lớn nhất của lệnh đang mở
   double maxLossPercent = (balanceAtMaxLoss > 0) ? (MathAbs(maxLoss) / balanceAtMaxLoss * 100.0) : 0.0;
   
   string maxLossValue = FormatMoney(maxLoss);
   string maxLossCapital = "/ " + FormatMoney(balanceAtMaxLoss);
   string maxLossPercentText = DoubleToString(maxLossPercent, 1) + "%";
   
   ObjectSetString(0, "EA_Panel_MaxLoss_Value", OBJPROP_TEXT, maxLossValue);
   ObjectSetString(0, "EA_Panel_MaxLoss_Capital", OBJPROP_TEXT, maxLossCapital);
   ObjectSetString(0, "EA_Panel_MaxLoss_Percent", OBJPROP_TEXT, maxLossPercentText);
   
   // Cập nhật progress bar
   int progressBarWidth = 340;  // width - 20 (360 - 20)
   int progressFillWidth = (int)(progressBarWidth * MathAbs(maxLossPercent) / 100.0);
   if(progressFillWidth > progressBarWidth) progressFillWidth = progressBarWidth;
   
   ObjectSetInteger(0, "EA_Panel_ProgressBar_Fill", OBJPROP_XSIZE, progressFillWidth);
   color progressColor = (maxLoss > 0) ? clrRed : clrLime;
   ObjectSetInteger(0, "EA_Panel_ProgressBar_Fill", OBJPROP_BGCOLOR, progressColor);
   
   // Số lot lớn nhất (cập nhật giá trị lớn nhất từng có, không reset khi EA reset)
   double maxLot = GetMaxLot();
   if(maxLot > maxLotEver)
      maxLotEver = maxLot;
   ObjectSetString(0, "EA_Panel_MaxLot_Value", OBJPROP_TEXT, DoubleToString(maxLotEver, 2));
   
   // Tổng lot lớn nhất (cập nhật giá trị lớn nhất từng có, không reset khi EA reset)
   double totalLot = GetTotalLot();
   if(totalLot > totalLotEver)
      totalLotEver = totalLot;
   ObjectSetString(0, "EA_Panel_TotalLot_Value", OBJPROP_TEXT, DoubleToString(totalLotEver, 2));
   
   // Số tiền của các lệnh đang mở
   double openProfit = GetTotalOpenProfit();
   string openProfitValue = FormatMoney(openProfit);
   color openProfitColor = (openProfit >= 0) ? clrLime : clrRed;
   ObjectSetString(0, "EA_Panel_OpenProfit_Value", OBJPROP_TEXT, openProfitValue);
   ObjectSetInteger(0, "EA_Panel_OpenProfit_Value", OBJPROP_COLOR, openProfitColor);
   
   // Số tiền của phiên
   double sessionProfitValue = currentEquity - initialEquity;
   double sessionPercent = (initialEquity > 0) ? (sessionProfitValue / initialEquity * 100.0) : 0.0;
   string sessionValue = FormatMoney(sessionProfitValue);
   string sessionPercentText = (sessionProfitValue >= 0 ? "+" : "") + DoubleToString(sessionPercent, 2) + "%";
   color sessionColor = (sessionProfitValue >= 0) ? clrLime : clrRed;
   ObjectSetString(0, "EA_Panel_SessionProfit_Value", OBJPROP_TEXT, sessionValue);
   ObjectSetInteger(0, "EA_Panel_SessionProfit_Value", OBJPROP_COLOR, sessionColor);
   ObjectSetString(0, "EA_Panel_SessionProfit_Percent", OBJPROP_TEXT, sessionPercentText);
   ObjectSetInteger(0, "EA_Panel_SessionProfit_Percent", OBJPROP_COLOR, sessionColor);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Xóa panel                                                         |
//+------------------------------------------------------------------+
void DeletePanel()
{
   string objects[] = {
      "EA_Panel_BG", "EA_Panel_Title", "EA_Panel_Status",
      "EA_Panel_SymbolTitle", "EA_Panel_SymbolName", "EA_Panel_Price", "EA_Panel_Trend",
      "EA_Panel_GridTitle", "EA_Panel_Card_MaxLevels", "EA_Panel_MaxLevels_Label", "EA_Panel_MaxLevels_Value", "EA_Panel_MaxLevels_Unit",
      "EA_Panel_Card_GridDist", "EA_Panel_GridDist_Label", "EA_Panel_GridDist_Value", "EA_Panel_GridDist_Unit",
      "EA_Panel_RiskTitle", "EA_Panel_MaxLoss_Label", "EA_Panel_MaxLoss_Value", "EA_Panel_MaxLoss_Capital", "EA_Panel_MaxLoss_Percent",
      "EA_Panel_ProgressBar_BG", "EA_Panel_ProgressBar_Fill",
      "EA_Panel_Card_MaxLot", "EA_Panel_MaxLot_Label", "EA_Panel_MaxLot_Value",
      "EA_Panel_Card_TotalLot", "EA_Panel_TotalLot_Label", "EA_Panel_TotalLot_Value",
      "EA_Panel_OpenProfit_Label", "EA_Panel_OpenProfit_Value",
      "EA_Panel_SessionProfit_Label", "EA_Panel_SessionProfit_Value", "EA_Panel_SessionProfit_Percent"
   };
   
   for(int i = 0; i < ArraySize(objects); i++)
   {
      ObjectDelete(0, objects[i]);
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Format số tiền với K và M                                          |
//+------------------------------------------------------------------+
string FormatMoney(double amount)
{
   string result = "";
   double absAmount = MathAbs(amount);
   
   if(absAmount >= 1000000.0)
   {
      // Triệu (M)
      double mValue = absAmount / 1000000.0;
      result = DoubleToString(mValue, 2) + "M";
   }
   else if(absAmount >= 1000.0)
   {
      // Nghìn (K)
      double kValue = absAmount / 1000.0;
      result = DoubleToString(kValue, 2) + "K";
   }
   else
   {
      // Dưới 1000
      result = DoubleToString(absAmount, 2);
   }
   
   // Thêm dấu âm nếu cần
   if(amount < 0)
      result = "-" + result;
   
   return result + "$";
}

//+------------------------------------------------------------------+
//| Gửi thông báo về điện thoại khi EA reset                          |
//+------------------------------------------------------------------+
void SendResetNotification(string resetReason)
{
   // 1. Biểu đồ
   string symbolName = _Symbol;
   
   // 2. EA Reset về chức năng gì
   string functionName = resetReason;
   
   // 3. Số dư hiện tại
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   string balanceText = FormatMoney(currentBalance);
   
   // 4. Số tiền lỗ lớn nhất / vốn (%)
   double maxLoss = maxNegativeProfit;
   double maxLossPercent = (balanceAtMaxLoss > 0) ? (MathAbs(maxLoss) / balanceAtMaxLoss * 100.0) : 0.0;
   string maxLossText = FormatMoney(maxLoss) + " / " + FormatMoney(balanceAtMaxLoss) + " (" + DoubleToString(maxLossPercent, 2) + "%)";
   
   // 5. Số lot lớn nhất / tổng lot lớn nhất
   string lotText = DoubleToString(maxLotEver, 2) + " / " + DoubleToString(totalLotEver, 2);
   
   // Tạo nội dung thông báo
   string message = "EA RESET\n";
   message += "Biểu đồ: " + symbolName + "\n";
   message += "Chức năng: " + functionName + "\n";
   message += "Số dư: " + balanceText + "\n";
   message += "Lỗ lớn nhất: " + maxLossText + "\n";
   message += "Lot: " + lotText;
   
   // Gửi thông báo
   SendNotification(message);
   
   Print("========================================");
   Print("Đã gửi thông báo về điện thoại:");
   Print(message);
   Print("========================================");
}
