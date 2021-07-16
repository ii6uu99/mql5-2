//+------------------------------------------------------------------+
//|                                                   noname.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\MyTrade.mqh>
#include <zeroesq\MyPosition.mqh>
#include <zeroesq\MyPriceBars.mqh>
#include <zeroesq\MyPending.mqh>
#include <zeroesq\MyUtils.mqh>
#include <zeroesq\MyReport.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string   inpExpertName = "no name";  //Expert Name
input uint     inpLongWindow = 10;
input uint     inpShortWindow = 5;


//+------------------------------------------------------------------+
//| My Basic Objects                                                 |
//+------------------------------------------------------------------+
CMyPosition position;
CMyTrade    trade;
CMyBars     bars;
CMyPending  pending;
CMyUtils    utils;
CMyReport   report;
//+------------------------------------------------------------------+
//| Indicator handles and buffers                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double volume = 0.00;
double expectedRange = 0.00;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   int atrHandle = INVALID_HANDLE;
   atrHandle = iATR(_Symbol, PERIOD_D1, 20);

   double atr[];
   ArraySetAsSeries(atr, true);
   CopyBuffer(atrHandle, 0, 1, 1, atr);
   expectedRange = atr[0];

   report.SetStartTime();

   if(!utils.IsValidExpertName(inpExpertName)) {
      return(INIT_FAILED);
   }

   ulong magic_number = utils.StringToMagic(inpExpertName);
   if (!trade.SetMagicNumber(magic_number))
      return(INIT_FAILED);

   volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   return(INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
   EventKillTimer();

   trade.ReleaseMagicNumber();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bars.SetInfo(10);
   position.UpdateInfo(trade.GetMagic(), bars.GetOne(0).time);

   if(bars.IsNewBar())
      Print(position.GetBarsDuration());

   bool goLong = false, goShort = false;
   double lastClose = bars.GetOne(1).close;
   double lowestClose = bars.GetLowest(PRICE_CLOSE, 1, 10);
   double highestClose = bars.GetHighest(PRICE_CLOSE, 1, 10);

   if(lowestClose != highestClose) { //---skip dojis (they trigger consecutive reversals)
      if(lastClose == lowestClose)
         goShort = true;

      if(lastClose == highestClose)
         goLong = true;
   }


   if(position.IsOpen()) {          //---positioned
      if((position.GetType() == POSITION_TYPE_BUY && goShort) || ( position.GetType() == POSITION_TYPE_SELL && goLong))
         trade.Reverse(position.GetType(), position.GetVolume());

   } else {                         //---flat
      if(goLong)
         trade.BuyMarket(volume);
      if(goShort)
         trade.SellMarket(volume);

   }

}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{

}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
//---

}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{

}

//+------------------------------------------------------------------+
//| OnTester Function                                                |
//+------------------------------------------------------------------+
double OnTester()
{
   double ret = 0.0;
   report.SetEndTime();
   report.SetDeals(trade.GetMagic(), 0, TimeCurrent());
   //report.SaveDealsToCSV();

   return(ret);
}
//+------------------------------------------------------------------+
