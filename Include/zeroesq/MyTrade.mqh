//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"

#include <zeroesq\errordescription.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyTrade
  {
private:
   ENUM_ORDER_TYPE_FILLING mFillType;
   ulong    mDeviation;
   ulong    mMagic;
   bool     OpenPosition(string pSymbol, ENUM_ORDER_TYPE pType, double pVolume, double pStop=0, double pProfit=0, string pComment=NULL);
   bool     OpenPending(string pSymbol,ENUM_ORDER_TYPE pType,double pVolume,double pPrice,double pStop=0,double pProfit=0,double pStoplimit=0,datetime pExpiration=0,string pComment=NULL);
   bool     SendAndCheckOrder(MqlTradeRequest &pRequest);
   bool     SelectPositionByMagic(string pSymbol, ulong pMagic);
   string   GetOrderTypeDescription(ENUM_ORDER_TYPE pType);
   string   GetActionTypeDescription(ENUM_TRADE_REQUEST_ACTIONS pAction);
   int      CheckRetcode(uint pRetcode);

public:
   void  Init(ulong pMagic, ulong pDeviation, ENUM_ORDER_TYPE_FILLING pFilltype);   
   bool  BuyMarket(string pSymbol,double pVolume,double pStop=0,double pProfit=0,string pComment=NULL);
   bool  SellMarket(string pSymbol,double pVolume,double pStop=0,double pProfit=0,string pComment=NULL);
   bool  BuyStop(string pSymbol,double pVolume,double pPrice,double pStop=0,double pProfit=0,datetime pExpiration=0,string pComment=NULL);
   bool  SellStop(string pSymbol, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool  BuyLimit(string pSymbol, double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool  SellLimit(string pSymbol,double pVolume, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, string pComment = NULL);
   bool  BuyStopLimit(string pSymbol,double pVolume,double pPrice,double pStop= 0,double pProfit = 0,datetime pExpiration = 0,string pComment = NULL);
   bool  SellStopLimit(string pSymbol,double pVolume,double pPrice,double pStop=0,double pProfit=0,datetime pExpiration=0,string pComment=NULL);
   //bool  ModifyPosition(string pSymbol,double pStop,double pProfit=0);
   bool  Close(string pSymbol,double pVolume=0,string pComment=NULL);
   bool  RemoveOrder(ulong pTicket);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMyTrade::Init(ulong pMagic,ulong pDeviation,ENUM_ORDER_TYPE_FILLING pFilltype)
{
   mMagic=pMagic;
   mDeviation=pDeviation;
   mFillType=pFilltype;
}
//+------------------------------------------------------------------+
//| Open Position                                                    |
//+------------------------------------------------------------------+
bool CMyTrade::OpenPosition(string pSymbol, ENUM_ORDER_TYPE pType, double pVolume, double pStop=0.000000, double pProfit=0.000000, string pComment=NULL)
{
   MqlTradeRequest request={};

   request.action=TRADE_ACTION_DEAL;
   request.symbol=pSymbol;
   request.type=pType;
   request.volume=pVolume;
   request.sl=NormalizeDouble(pStop, _Digits);
   request.tp=NormalizeDouble(pProfit, _Digits);
   request.deviation=mDeviation;
   request.type_filling=mFillType;
   request.comment=pComment;
   request.magic=mMagic;
   
   if(pType==ORDER_TYPE_BUY)
      request.price=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
   else if(pType==ORDER_TYPE_SELL)
      request.price=SymbolInfoDouble(pSymbol,SYMBOL_BID);
   
   bool sendResult=SendAndCheckOrder(request);
   
   return(sendResult);
}
//+------------------------------------------------------------------+
//| Open Pending                                                     |
//+------------------------------------------------------------------+
bool CMyTrade::OpenPending(string pSymbol,ENUM_ORDER_TYPE pType,double pVolume,double pPrice,double pStop=0,double pProfit=0,
                         double pStoplimit=0,datetime pExpiration=0,string pComment=NULL)
{
   MqlTradeRequest request={};
   
   request.action = TRADE_ACTION_PENDING;
   request.symbol = pSymbol;
   request.type=pType;
   request.sl = NormalizeDouble(pStop,_Digits);
   request.tp = NormalizeDouble(pProfit,_Digits);
   request.comment= pComment;
   request.volume = pVolume;
   request.price=pPrice;
   request.stoplimit=pStoplimit;
   request.magic=mMagic;

   if(pExpiration>0)
   {
      request.expiration= pExpiration;
      request.type_time = ORDER_TIME_SPECIFIED;
   }
   else request.type_time=ORDER_TIME_DAY;
   
   bool sendResult=SendAndCheckOrder(request);
   
   return(sendResult);
  }
//+------------------------------------------------------------------+
//| Send and Check Order                                             |
//+------------------------------------------------------------------+
bool CMyTrade::SendAndCheckOrder(MqlTradeRequest &pRequest)
{
   MqlTradeResult result={};

   bool sendReturn=OrderSend(pRequest,result);

   int checkCode=CheckRetcode(result.retcode);
   string retCodeDescr=TradeServerReturnCodeDescription(result.retcode);
   string orderTypeDescr=GetOrderTypeDescription(pRequest.type);
   string tradeActionDescr=GetActionTypeDescription(pRequest.action);
      

   if(checkCode==CHECK_RETCODE_OK) 
      {
       Print(tradeActionDescr, " " ,orderTypeDescr," order #",result.deal,": ",result.retcode," - ",retCodeDescr,", Volume: ",result.volume,", Price: ",result.price,", Bid: ",result.bid,", Ask: ",result.ask);         
       return(true);      
      }

   else if(checkCode==CHECK_RETCODE_ERROR)
      {
       Alert(tradeActionDescr, " ", orderTypeDescr, ": Error ",result.retcode," - ",retCodeDescr);
      }
   
   else
      {
       Print("Server error detected, maybe you should retry...");
      }

   return(false);
}
//+------------------------------------------------------------------+
//| Buy Market                                                       |
//+------------------------------------------------------------------+
bool CMyTrade::BuyMarket(string pSymbol,double pVolume,double pStop=0.000000,double pProfit=0.000000,string pComment=NULL)
{
   bool success=OpenPosition(pSymbol,ORDER_TYPE_BUY,pVolume,pStop,pProfit,pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Sell Market                                                      |
//+------------------------------------------------------------------+
bool CMyTrade::SellMarket(string pSymbol,double pVolume,double pStop=0.000000,double pProfit=0.000000,string pComment=NULL)
{
   bool success=OpenPosition(pSymbol,ORDER_TYPE_SELL,pVolume,pStop,pProfit,pComment);
   return(success);
}
//+------------------------------------------------------------------+
//| Buy Stop                                                         |
//+------------------------------------------------------------------+
bool CMyTrade::BuyStop(string pSymbol,double pVolume,double pPrice,double pStop=0.000000,double pProfit=0.000000,datetime pExpiration=0,string pComment=NULL)
  {
   bool success=OpenPending(pSymbol,ORDER_TYPE_BUY_STOP,pVolume,pPrice,pStop,pProfit,0.00,pExpiration,pComment);
   return(success);
  }
//+------------------------------------------------------------------+
//| Sell Stop                                                        |
//+------------------------------------------------------------------+
bool CMyTrade::SellStop(string pSymbol,double pVolume,double pPrice,double pStop=0.000000,double pProfit=0.000000,datetime pExpiration=0,string pComment=NULL)
  {
   bool success=OpenPending(pSymbol,ORDER_TYPE_SELL_STOP,pVolume,pPrice,pStop,pProfit,0.00,pExpiration,pComment);
   return(success);
  }
//+------------------------------------------------------------------+
//| Buy Limit                                                        |
//+------------------------------------------------------------------+
bool CMyTrade::BuyLimit(string pSymbol,double pVolume,double pPrice,double pStop=0.000000,double pProfit=0.000000,datetime pExpiration=0,string pComment=NULL)
  {
   bool success=OpenPending(pSymbol,ORDER_TYPE_BUY_LIMIT,pVolume,pPrice,pStop,pProfit,0.00,pExpiration,pComment);
   return(success);
  }
//+------------------------------------------------------------------+
//| Sell Limit                                                       |
//+------------------------------------------------------------------+
bool CMyTrade::SellLimit(string pSymbol,double pVolume,double pPrice,double pStop=0.000000,double pProfit=0.000000,datetime pExpiration=0,string pComment=NULL)
  {
   bool success=OpenPending(pSymbol,ORDER_TYPE_SELL_LIMIT,pVolume,pPrice,pStop,pProfit,0.00,pExpiration,pComment);
   return(success);
  }
//+------------------------------------------------------------------+
//| Buy Stop Limit                                                   |
//+------------------------------------------------------------------+
bool CMyTrade::BuyStopLimit(string pSymbol,double pVolume,double pPrice,double pStop=0.000000,double pProfit=0.000000,datetime pExpiration=0,string pComment=NULL)
  {
   bool success=OpenPending(pSymbol,ORDER_TYPE_BUY_STOP_LIMIT,pVolume,pPrice,pStop,pProfit,pPrice,pExpiration,pComment);
   return(success);
  }
//+------------------------------------------------------------------+
//| Sell Stop Limit                                                  |
//+------------------------------------------------------------------+
bool CMyTrade::SellStopLimit(string pSymbol,double pVolume,double pPrice,double pStop=0.000000,double pProfit=0.000000,datetime pExpiration=0,string pComment=NULL)
  {
   bool success=OpenPending(pSymbol,ORDER_TYPE_SELL_STOP_LIMIT,pVolume,pPrice,pStop,pProfit,pPrice,pExpiration,pComment);
   return(success);
  }
////+------------------------------------------------------------------+
////| Modify Position                                                  |
////+------------------------------------------------------------------+
//bool CMyTrade::ModifyPosition(string pSymbol,double pStop,double pProfit=0)
//  {
//   MqlTradeRequest request={0};
//   
//   request.action = TRADE_ACTION_SLTP;
//   request.symbol = pSymbol;
//   request.sl = pStop;
//   request.tp = pProfit;
//   request.magic=mMagic;
//   
//   bool sendResult=SendAndCheckOrder(request);
//   
//   return(sendResult);
//
//}
//+------------------------------------------------------------------+
//| Close Position                                                   |
//+------------------------------------------------------------------+
bool CMyTrade::Close(string pSymbol,double pVolume=0.000000,string pComment=NULL)
{
   MqlTradeRequest request={};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = pSymbol;
   request.comment = pComment;
   request.magic = mMagic;
   
   if(!SelectPositionByMagic(pSymbol,mMagic)) return(false);
   
   request.position=PositionGetInteger(POSITION_TICKET);
   
   double openLots = PositionGetDouble(POSITION_VOLUME);
   if(pVolume>openLots || pVolume<=0) request.volume=openLots;
   else request.volume=pVolume;
   
   long openType = PositionGetInteger(POSITION_TYPE);
   if(openType==POSITION_TYPE_BUY)
      {
       request.type=ORDER_TYPE_SELL;
       request.price=SymbolInfoDouble(pSymbol,SYMBOL_BID);
      }

   if(openType==POSITION_TYPE_SELL) 
      {
       request.type=ORDER_TYPE_BUY;
       request.price=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
      }
   
   
   bool sendResult=SendAndCheckOrder(request);
   
   return(sendResult);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyTrade::SelectPositionByMagic(string pSymbol,ulong pMagic)
{
   bool res=false;
   uint total=PositionsTotal();
   
   for(uint i=0; i<total; i++)
      {
       string positionSymbol=PositionGetSymbol(i);
       ulong magic=PositionGetInteger(POSITION_MAGIC);
       if(magic==pMagic&&positionSymbol==pSymbol)
         {
          res=true;
          break;
         }
   }
   return(res);
}
//+------------------------------------------------------------------+
//| Delete One pending order                                         |
//+------------------------------------------------------------------+
bool CMyTrade::RemoveOrder(ulong pTicket)
  {
   MqlTradeRequest request={};
   
   request.action= TRADE_ACTION_REMOVE;
   request.order = pTicket;
   
   bool sendResult=SendAndCheckOrder(request);
   
   return(sendResult);


  }
////+------------------------------------------------------------------+
////| Delete Multiple pending orders                                   |
////+------------------------------------------------------------------+
//bool CMyTrade::DeleteMany(ulong &pTicket[])
//{
//   for(int i =0;i<ArraySize(pTicket);i++)
//   {
//      if(!DeleteOne(pTicket[i])) return(false);
//   }
//   return(true);
//}
////+------------------------------------------------------------------+
////| Linear Grid Sell Limit                                           |
////+------------------------------------------------------------------+
//bool CMyTrade::LinearGridSell(double pPrice, double pVolume, int pLevels, double pPoints, string pComment)
//{
//   double priceLevel = pPrice;
//
//   for(int i=1; i<=pLevels; i++)
//   {
//      priceLevel = priceLevel + pPoints;
//      if(!SellLimit(_Symbol,pVolume,priceLevel,0,0,0,pComment)) return(false);
//   }
//
//   return(true);
//}
////+------------------------------------------------------------------+
////| Linear Grid Buy Limit                                            |
////+------------------------------------------------------------------+
//bool CMyTrade::LinearGridBuy(double pPrice, double pVolume, int pLevels, double pPoints, string pComment)
//{
//   double priceLevel = pPrice;
//
//   for(int i=1; i<=pLevels; i++)
//   {
//      priceLevel = priceLevel - pPoints;
//      if(!BuyLimit(_Symbol,pVolume,priceLevel,0,0,0,pComment)) return(false);
//   }
//
//   return(true);
//}
////+------------------------------------------------------------------+
////| Opposite Orders                                                   |
////+------------------------------------------------------------------+
//bool CMyTrade::OppositeOrder(string pSymbol,ENUM_ORDER_TYPE pType,double pVolume,double pPrice,string pComment)
//{
//   if(pType==ORDER_TYPE_BUY||pType==ORDER_TYPE_BUY_LIMIT||pType==ORDER_TYPE_BUY_STOP||pType==ORDER_TYPE_BUY_STOP_LIMIT)
//   {
//      return SellLimit(pSymbol,pVolume,pPrice,0,0,0,pComment);
//   }
//
//   if(pType==ORDER_TYPE_SELL||pType==ORDER_TYPE_SELL_LIMIT||pType==ORDER_TYPE_SELL_STOP||pType==ORDER_TYPE_SELL_STOP_LIMIT)
//   {
//      return BuyLimit(pSymbol,pVolume,pPrice,0,0,0,pComment);
//   }
//
//   return(false);
//}
//+------------------------------------------------------------------+
//| Get order type description                                       |
//+------------------------------------------------------------------+
string CMyTrade::GetOrderTypeDescription(ENUM_ORDER_TYPE pType)
{
   string orderType;
   if(pType==ORDER_TYPE_BUY) orderType="buy market";
   else if(pType == ORDER_TYPE_SELL) orderType = "sell market";
   else if(pType == ORDER_TYPE_BUY_STOP) orderType = "buy stop";
   else if(pType == ORDER_TYPE_BUY_LIMIT) orderType = "buy limit";
   else if(pType == ORDER_TYPE_SELL_STOP) orderType = "sell stop";
   else if(pType == ORDER_TYPE_SELL_LIMIT) orderType = "sell limit";
   else if(pType == ORDER_TYPE_BUY_STOP_LIMIT) orderType = "buy stop limit";
   else if(pType == ORDER_TYPE_SELL_STOP_LIMIT) orderType = "sell stop limit";
   else orderType= "invalid order type";
   return(orderType);
}
//+------------------------------------------------------------------+
//| Check action type                                                |
//+------------------------------------------------------------------+
string CMyTrade::GetActionTypeDescription(ENUM_TRADE_REQUEST_ACTIONS pAction)
{
   string tradeAction;
   if(pAction==TRADE_ACTION_DEAL) tradeAction="Open";
   else if(pAction==TRADE_ACTION_PENDING) tradeAction="Place";
   else if(pAction==TRADE_ACTION_SLTP) tradeAction="SL/TP Modify";
   else if(pAction==TRADE_ACTION_SLTP) tradeAction="Modify";
   else if(pAction==TRADE_ACTION_REMOVE) tradeAction="Remove";
   else if(pAction==TRADE_ACTION_CLOSE_BY) tradeAction="Close By";
   else tradeAction= "invalid action type";
   return(tradeAction);
}
//+------------------------------------------------------------------+
//| CheckRetcode                                                     |
//+------------------------------------------------------------------+
int CMyTrade::CheckRetcode(uint pRetcode)
{
   int status;

   switch(pRetcode)
   {
      case TRADE_RETCODE_REQUOTE:
      case TRADE_RETCODE_CONNECTION:
      case TRADE_RETCODE_PRICE_CHANGED:
      case TRADE_RETCODE_TIMEOUT:
      case TRADE_RETCODE_PRICE_OFF:
      case TRADE_RETCODE_REJECT:
      case TRADE_RETCODE_ERROR:
         status=CHECK_RETCODE_RETRY;
         break;
      case TRADE_RETCODE_DONE:
      case TRADE_RETCODE_DONE_PARTIAL:
      case TRADE_RETCODE_PLACED:
      case TRADE_RETCODE_NO_CHANGES:
         status=CHECK_RETCODE_OK;
         break;
      default: status=CHECK_RETCODE_ERROR;
    }

   return(status);
}
////+------------------------------------------------------------------+
////| Miscellaneous Functions & Enumerations                           |
////+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ENUM_CHECK_RETCODE                                               |
//+------------------------------------------------------------------+
enum ENUM_CHECK_RETCODE
{
 CHECK_RETCODE_OK,
 CHECK_RETCODE_ERROR,
 CHECK_RETCODE_RETRY,
};