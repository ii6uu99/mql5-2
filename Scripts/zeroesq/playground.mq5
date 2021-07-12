//+------------------------------------------------------------------+
//|                                                   playground.mq5 |
//|                                           Gabriel Guedes de Sena |
//|                                       twitter.com/gabriel_guedes |
//+------------------------------------------------------------------+
#property copyright "Gabriel Guedes de Sena"
#property link      "twitter.com/gabriel_guedes"
#property version   "1.00"

#include <zeroesq\MyUtils.mqh>
#include <Strings\String.mqh>
//---

CMyUtils utils;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{

   string some_string = SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION);
   Print(_Symbol);
   Print(some_string);
   
   MqlDateTime some_datetime;
   
   TimeCurrent(some_datetime);
   
   Print(IntegerToString(some_datetime.year)+IntegerToString(some_datetime.mon,2,'0')+IntegerToString(some_datetime.day,2,'0'));
   string file_name = _Symbol+IntegerToString(some_datetime.year)+IntegerToString(some_datetime.mon,2,'0')+IntegerToString(some_datetime.day,2,'0')+".csv";
   Print(file_name);

}
//+------------------------------------------------------------------+
