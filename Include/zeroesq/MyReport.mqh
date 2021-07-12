//+------------------------------------------------------------------+
//|                                                     MyReport.mqh |
//|                                                   Gabriel Guedes |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes"
#property link      "twitter.com/gabriel_guedes"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct MyDeal
{
   datetime          time;
   string            symbol;
   ulong             type;
   ulong             direction;
   double            volume;
   double            price;
   ulong             order;
   double            comission;
   double            profit;
};
//+------------------------------------------------------------------+
//| Class CMyReport definition                                       |
//+------------------------------------------------------------------+
class CMyReport
{
private:
   MyDeal            mDeals[];
   void              InsertDeal(MyDeal &pDeal);

public:
                     CMyReport(void);
   void              SetDeals(ulong pMagic, datetime pFromDate, datetime pToDate);
   void              SaveFile(string pDirectory = "myreports");
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMyReport::CMyReport(void)
{

}
//+------------------------------------------------------------------+
//| Set Deals                                                        |
//+------------------------------------------------------------------+
void CMyReport::SetDeals(ulong pMagic, datetime pFromDate, datetime pToDate)
{
   HistorySelect(pFromDate, pToDate);

   uint total = HistoryDealsTotal();
   ulong ticket = 0;
   ulong magic = 0;

   for(uint i = 0; i < total; i++) {
      if(!(ticket = HistoryDealGetTicket(i)) > 0)
         continue;
      if((magic = HistoryDealGetInteger(ticket, DEAL_MAGIC)) != pMagic)
         continue;

      MyDeal deal = {};
      deal.time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      deal.symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      deal.type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      deal.direction = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      deal.volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      deal.price = HistoryDealGetDouble(ticket, DEAL_PRICE);
      deal.order = HistoryDealGetInteger(ticket, DEAL_ORDER);
      deal.comission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      deal.profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

      InsertDeal(deal);

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyReport::InsertDeal(MyDeal &pDeal)
{
   int total = ArraySize(mDeals);

   ArrayResize(mDeals, total + 1);

   mDeals[total].time = pDeal.time;
   mDeals[total].symbol = pDeal.symbol;
   mDeals[total].type = pDeal.type;
   mDeals[total].direction = pDeal.direction;
   mDeals[total].volume = pDeal.volume;
   mDeals[total].price = pDeal.price;
   mDeals[total].order = pDeal.order;
   mDeals[total].profit = pDeal.profit;
}
//+------------------------------------------------------------------+
//| Save File                                                        |
//+------------------------------------------------------------------+
void CMyReport::SaveFile(string pDirectory = "myreports")
{
   if(ArraySize(mDeals) <= 0) {
      Print("INFO - No deals found. Nothing to be saved to report file.");
      return;
   }
   
   string fileName = "sample.csv";
   short delimiter = ',';
   int fileHandle = FileOpen(pDirectory + "//" + fileName, FILE_READ | FILE_WRITE | FILE_ANSI, delimiter);

   if(fileHandle != INVALID_HANDLE) {
      PrintFormat("INFO - %s file available for writing", fileName);
      PrintFormat("INFO - File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));

      for(int i = 0; i < ArraySize(mDeals); i++)
         FileWrite(fileHandle, mDeals[i].time, mDeals[i].symbol, mDeals[i].type, mDeals[i].direction, mDeals[i].volume, mDeals[i].price, mDeals[i].order, mDeals[i].profit);

      FileClose(fileHandle);
      PrintFormat("INFO - Data written, %s file closed.", fileName);
   } else
      PrintFormat("INFO - Failed to open %s file, Error code = %d", fileName, GetLastError());
}
//+------------------------------------------------------------------+
