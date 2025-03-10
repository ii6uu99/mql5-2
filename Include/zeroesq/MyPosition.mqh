//+------------------------------------------------------------------+
//|                                                   MyPosition.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#define EXPERT_MAGIC 123456

#include <zeroesq\MyTrade.mqh>

struct tyPosition
{
   ulong       magic;
   long        type;
   ulong       ticket;
   double      volume;
   long        time;
   double      entry_price;
   double      sl;
   double      tp;
   datetime    last_bar_time;
   ulong       bars_duration;
   double      open_profit;
   double      max_profit;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyPosition
{
private:
   tyPosition        mInfo;
   CMyTrade          trade;
   void              UpdateBarsDuration(datetime pTime);
   void              ResetBarsDuration();
   void              ResetInfo();
   void              SetSLTP(double pSL, double pTP);
public:
   CMyPosition(void);
   void              SetMagic(ulong pMagic);
   bool              Update(datetime pCurrentBarTime);
   bool              IsOpen();
   bool              IsLong();
   bool              IsShort();
   bool              IsFlat();
   long              GetType();
   ulong             GetTicket();
   double            GetSL();
   double            GetTP();
   double            GetVolume();
   ulong             GetMagic();
   double            GetProfit();
   double            GetDrawdown();
   double            GetMaxProfit();
   ulong             GetTicketByMagic(ulong pMagic);
   bool              ModifySLTP(double pSL, double pTP);
   bool              SetBreakevenSLTP();
   ulong             GetBarsDuration();
   bool              IsValidSLTP(ulong pPositionType, double pSL, double pTP);
   bool              CloseIfSLTP(double pPrice);
   bool              Close();
   bool              Reverse();
   bool              BuyMarket(double pVolume, double pSL, double pTP, string pComment = NULL);
   bool              SellMarket(double pVolume, double pSL, double pTP, string pComment = NULL);
   bool              BuyStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL);
   bool              SellStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::CMyPosition(void)
{
   ResetInfo();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::SetMagic(ulong pMagic)
{
   mInfo.magic = pMagic;
}
//+------------------------------------------------------------------+
//| Update Position Info                               |
//+------------------------------------------------------------------+
bool CMyPosition::Update(datetime pCurrentBarTime)
{
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string positionSymbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      long typeLastChecked = PositionGetInteger(POSITION_TYPE);
      if(magic == mInfo.magic && positionSymbol == _Symbol) {
         mInfo.ticket = PositionGetTicket(i);
         mInfo.volume = PositionGetDouble(POSITION_VOLUME);
         mInfo.time = PositionGetInteger(POSITION_TIME);
         mInfo.entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
         mInfo.open_profit = PositionGetDouble(POSITION_PROFIT);
         if(mInfo.open_profit > mInfo.max_profit) {
            mInfo.max_profit = mInfo.open_profit;
         }

         if(mInfo.type != typeLastChecked) { //---position reversal
            ResetBarsDuration();
            mInfo.type = typeLastChecked;
            mInfo.max_profit = 0.00;
         }      

         if(pCurrentBarTime > mInfo.last_bar_time && pCurrentBarTime > mInfo.time) {
            UpdateBarsDuration(pCurrentBarTime);
         }

         return(true);
      }
   }

   ResetInfo();
   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::ResetInfo(void)
{
   mInfo.ticket = NULL;
   mInfo.type = -1;
   mInfo.volume = 0.00;
   mInfo.time = 0;
   mInfo.entry_price = 0.00;
   mInfo.sl = 0.00;
   mInfo.tp = 0.00;
   mInfo.bars_duration = 0;
   mInfo.last_bar_time = 0;
   mInfo.open_profit = 0.00;
   mInfo.max_profit = 0.00;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::ResetBarsDuration(void)
{
   mInfo.bars_duration = 0;
   mInfo.last_bar_time = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::UpdateBarsDuration(datetime pTime)
{
   mInfo.bars_duration++;
   mInfo.last_bar_time = pTime;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyPosition::SetSLTP(double pSL, double pTP)
{
   mInfo.sl = pSL;
   mInfo.tp = pTP;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool CMyPosition::OpenAtMarket(ulong pType,double pVolume,double pSL,double pTP,string pComment=NULL)
//{
//   bool success = false;
//
//   if(pType == POSITION_TYPE_BUY) {
//      success = trade.BuyMarket(mInfo.magic, pVolume, 0, 0, pComment);
//      if(success) SetSLTP(pSL, pTP);
//   }
//
//   else if(pType == POSITION_TYPE_SELL) {
//      success = trade.SellMarket(mInfo.magic, pVolume, 0, 0, pComment);
//      if(success) SetSLTP(pSL, pTP);
//   }
//
//   else {
//      Print("WARN - Invalid Position TYPE");
//      success = false;
//   }
//
//   return(success);
//}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::BuyMarket(double pVolume, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;
   success = trade.BuyMarket(mInfo.magic, pVolume, pSL, pTP, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SellMarket(double pVolume, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;
   success = trade.SellMarket(mInfo.magic, pVolume, pSL, pTP, pComment);
   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::BuyStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;

   success = trade.BuyStopLimit(mInfo.magic, pVolume, pPrice, pSL, pTP);

   return(success);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SellStop(double pVolume, double pPrice, double pSL, double pTP, string pComment = NULL)
{
   bool success = false;

   success = trade.SellStopLimit(mInfo.magic, pVolume, pPrice, pSL, pTP);

   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::CloseIfSLTP(double pPrice)
{
   long   positionType = GetType();
   ulong   magic = GetMagic();
   double sl = GetSL();
   double tp = GetTP();

   if(StopLossHit(positionType, sl, pPrice)) {
      return(trade.Close(magic, 0, "SL zeroesq"));
   }

   if(TakeProfitHit(positionType, tp, pPrice)) {
      return(trade.Close(magic, 0, "TP zeroesq"));
   }

   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::Close(void)
{
   ulong magic = GetMagic();
   return(trade.Close(magic));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::Reverse(void)
{
   bool success = trade.Reverse(GetType(), GetMagic(), GetVolume());

   return(success);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsOpen(void)
{
   if(mInfo.type == POSITION_TYPE_BUY || mInfo.type == POSITION_TYPE_SELL)
      return(true);
   else
      return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsLong(void)
{
   return(mInfo.type == POSITION_TYPE_BUY);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsShort(void)
{
   return(mInfo.type == POSITION_TYPE_SELL);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsFlat(void)
{
   return(mInfo.type == -1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CMyPosition::GetType(void)
{
   return(mInfo.type);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetTicket(void)
{
   return(mInfo.ticket);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetVolume(void)
{
   return(mInfo.volume);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetSL(void)
{
   return(mInfo.sl);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetTP(void)
{
   return(mInfo.tp);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetMagic(void)
{
   return(mInfo.magic);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetProfit(void)
{
   return(mInfo.open_profit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetDrawdown(void)
{
   if(mInfo.max_profit > 0.00) {
   }
   return(mInfo.open_profit - mInfo.max_profit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMyPosition::GetMaxProfit(void)
{
   return(mInfo.max_profit);
}
//+------------------------------------------------------------------+
//| Get First Position by magic number                               |
//+------------------------------------------------------------------+
ulong CMyPosition::GetTicketByMagic(ulong pMagic)
{
   uint total = PositionsTotal();

   for(uint i = 0; i < total; i++) {
      string positionSymbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(magic == pMagic && positionSymbol == _Symbol) {
         return(PositionGetTicket(i));
      }
   }
   return(NULL);
}
//+------------------------------------------------------------------+
//| Change Position Take Profit                                      |
//+------------------------------------------------------------------+
bool CMyPosition::ModifySLTP(double pSL, double pTP)
{

   if(!IsOpen()) {
      Print("WARN - Invalid SLTP. No open position");
      return(false);
   }

   if(!IsValidSLTP(mInfo.type, pSL, pTP)) {
      return(false);
   }

   mInfo.sl = pSL;
   mInfo.tp = pTP;

   //PrintFormat("INFO - SLTP Levels Modified - SL(%.2f) and/or TP(%.2f).", pSL, pTP);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::IsValidSLTP(ulong pType, double pSL, double pTP)
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_LAST);


   if(pType == POSITION_TYPE_BUY) {
      if((pSL >= currentPrice && pSL != 0.0) || (pTP <= currentPrice && pTP != 0.0)) {
         PrintFormat("WARN - SL(%.2f) or TP(%.2f) out of bounds", pSL, pTP);
         return(false);
      }
   }

   if(pType == POSITION_TYPE_SELL) {
      if((pSL <= currentPrice && pSL != 0.0) || (pTP >= currentPrice && pTP != 0)) {
         PrintFormat("WARN - SL(%.2f) or TP(%.2f) out of bounds", pSL, pTP);
         return(false);
      }
   }

   PrintFormat("INFO - OK validity check - SL(%.2f) and/or TP(%.2f).", pSL, pTP);
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyPosition::SetBreakevenSLTP(void)
{
   double lastTick = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   double sl = mInfo.sl, tp = mInfo.tp;

   if(mInfo.type == POSITION_TYPE_BUY && lastTick > mInfo.entry_price && mInfo.sl != mInfo.entry_price)
      sl = mInfo.entry_price;
   else if(mInfo.type == POSITION_TYPE_BUY && lastTick <= mInfo.entry_price && mInfo.tp != mInfo.entry_price)
      tp = mInfo.entry_price;
   else if(mInfo.type == POSITION_TYPE_SELL && lastTick < mInfo.entry_price && mInfo.sl != mInfo.entry_price)
      sl = mInfo.entry_price;
   else if(mInfo.type == POSITION_TYPE_SELL && lastTick >= mInfo.entry_price && mInfo.tp != mInfo.entry_price)
      tp = mInfo.entry_price;
   else {
      return(false);
   }

   return(ModifySLTP(sl, tp));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CMyPosition::GetBarsDuration(void)
{
   return(mInfo.bars_duration);
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Misc Functions                                                                 |
//+------------------------------------------------------------------+
bool StopLossHit(long pType, double pStopLoss, double pLastDeal)
{
   if(pStopLoss == 0.0) {
      return(false);
   }

   if(pType == POSITION_TYPE_BUY && pLastDeal <= pStopLoss) {
      return(true);
   }

   if(pType == POSITION_TYPE_SELL && pLastDeal >= pStopLoss) {
      return(true);
   }

   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TakeProfitHit(long pType, double pTakeProfit, double pLastDeal)
{
   if(pTakeProfit == 0.0) {
      return(false);
   }

   if(pType == POSITION_TYPE_BUY && pLastDeal >= pTakeProfit) {
      return(true);
   }

   if(pType == POSITION_TYPE_SELL && pLastDeal <= pTakeProfit) {
      return(true);
   }

   return(false);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
