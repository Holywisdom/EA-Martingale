//+------------------------------------------------------------------+
//|                                                  TwinWarrior.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Holywisdom , Facebook : Thanongkiat Tamtai , Thailand "
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern string ______ = "Buy Order Setting" ; 
extern bool Buy_Open = true ; 
extern double Buy_Lot = 0.01 ;
extern int Buy_StepLot = 80 ;
extern int Buy_TakeProfit = 20 ;
extern int Buy_StopLoss = 0 ;
extern double Buy_LotPlus = 0.01 ;
extern int Buy_MaxOrder = 5 ;
extern int Buy_StepHedge = 20 ;
extern int Buy_Slippage = 10 ; 
extern int Buy_MagicNumber = 11111111 ;

extern string _______ = "Sell Order Setting" ;
extern bool Sell_Open = true ; 
extern double Sell_Lot = 0.01 ;
extern int Sell_StepLot = 80 ;
extern int Sell_TakeProfit = 20 ;
extern int Sell_StopLoss = 0 ;
extern double Sell_LotPlus = 0.01 ;
extern int Sell_MaxOrder = 5 ;
extern int Sell_StepHedge = 20 ;
extern int Sell_Slippage = 10 ; 
extern int Sell_MagicNumber = 22222222 ;

extern string ________ = "RSI Indicator Setting" ;
extern int RSI_Period = 14 ;
extern ENUM_APPLIED_PRICE RSI_ApplyTo = PRICE_CLOSE ;
extern int RSI_BuyLevel = 70 ; 
extern int RSI_SellLevel = 30 ;

int Digit = 0 ; 

double LastBuyOrderPrice ; 
double LastSellOrderPrice ;

double NextBuyOrderPrice ;
double NextSellOrderPrice ;

int OnInit()
  {
      
   Digit = MarketInfo(Symbol(),MODE_DIGITS);
   
   if (Digit == 3 || Digit == 5) 
   
   {
      Buy_TakeProfit = Buy_TakeProfit*10 ;
      Buy_StopLoss = Buy_StopLoss*10 ;
      Buy_StepLot = Buy_StepLot*10 ;
      Buy_StepHedge = Buy_StepHedge*10;
      
      Sell_TakeProfit = Sell_TakeProfit*10 ;
      Sell_StopLoss = Sell_StopLoss*10 ;
      Sell_StepLot = Sell_StepLot*10 ;
      Buy_StepHedge = Buy_StepHedge*10 ;
      
      LastBuyOrderPrice = Ask ; 
      LastSellOrderPrice = Bid ;
   }
     
   return(INIT_SUCCEEDED);
  }

void OpenBuy(int BuyOrderCount) 

{
   string TextComment = "BuyOrder " + BuyOrderCount ; 
   if (Buy_StopLoss == 0 ) 
   {
      OrderSend(Symbol(),OP_BUY,NormalizeDouble(Buy_Lot+(Buy_LotPlus*BuyOrderCount),2),Ask,Buy_Slippage,0,Ask+Point*Buy_TakeProfit,TextComment,Buy_MagicNumber,0,Green);
   }
   else 
   {
      OrderSend(Symbol(),OP_BUY,NormalizeDouble(Buy_Lot+(Buy_LotPlus*BuyOrderCount),2),Ask,Buy_Slippage,Ask-Point*Buy_StopLoss,Ask+Point*Buy_TakeProfit,TextComment,Buy_MagicNumber,0,Green);
   }
            
}

void OpenSell(int SellOrderCount) 

{
   string TextComment = "SellOrder " + SellOrderCount ; 
   if (Sell_StopLoss == 0 )
   {
   
      OrderSend(Symbol(),OP_SELL,NormalizeDouble(Sell_Lot+(Sell_LotPlus*SellOrderCount),2),Bid,Sell_Slippage,0,Bid-Point*Sell_TakeProfit,TextComment,Sell_MagicNumber,0,Red);
   }   
   else
   {
      OrderSend(Symbol(),OP_SELL,NormalizeDouble(Sell_Lot+(Sell_LotPlus*SellOrderCount),2),Bid,Sell_Slippage,Bid+Point*Sell_StopLoss,Bid-Point*Sell_TakeProfit,TextComment,Sell_MagicNumber,0,Red);
   }

}

void CheckBuy() 
{
      int BuyOrderCount = 0 ;
    
      if (Buy_Open == true) 
   
      {     
        for(int i=0 ;i<OrdersTotal();i++)
           { 
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Buy_MagicNumber )
                  {
                     if(OrderType()==OP_BUY)
                        {
                         BuyOrderCount++;
                         LastBuyOrderPrice = OrderOpenPrice() ;
                        }
                  }
           }

         if (BuyOrderCount == 0 && RSIIndicatorCondition(RSI_BuyLevel,"Buy") && isZeroOrder())
        {   
            OpenBuy(BuyOrderCount) ;
            ModifyBuy() ;
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Buy_MagicNumber  )
                  {
                     if(OrderType()==OP_BUY)
                        {
                            LastBuyOrderPrice = OrderOpenPrice() ;
                        }  
                  }
        } 

         if (BuyOrderCount > 0 && BuyOrderCount < Buy_MaxOrder )
        {   
            NextBuyOrderPrice = LastBuyOrderPrice-Point*Buy_StepLot ; 
            
            if (Ask < NextBuyOrderPrice ) 
               { 
                   OpenBuy(BuyOrderCount);
                   ModifyBuy();
               }
        }
            
      }
}

void CheckSell() 
{  
   int SellOrderCount = 0 ;
       
      if (Sell_Open == true ) 
         
      {     
        for(int i=0 ;i<OrdersTotal();i++)
           { 
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Sell_MagicNumber )
                  {
                     if(OrderType()==OP_SELL)
                     {
                         SellOrderCount++;
                         LastSellOrderPrice = OrderOpenPrice() ;
                     }
                  }
           }
              
        if (SellOrderCount == 0 && RSIIndicatorCondition(RSI_SellLevel,"Sell") && isZeroOrder() )
        {
            OpenSell(SellOrderCount) ;
            ModifySell() ;
            OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Sell_MagicNumber )
                  {
                     if(OrderType()==OP_SELL)
                        {
                            LastSellOrderPrice = OrderOpenPrice() ;
                        }
                  }  
        }   
         
        if (SellOrderCount > 0 && SellOrderCount < Sell_MaxOrder )
        {
            NextSellOrderPrice = LastSellOrderPrice+Point*Sell_StepLot ; 
            
            if (Bid > NextSellOrderPrice ) 
            { 
                OpenSell(SellOrderCount);
                ModifySell() ; 
            }
        }
      }
}

void ModifyBuy() 
{  
   double BuySumPriceLot = 0 ;
   double BuySumLot = 0 ; 
   double BuyModifyPrice = 0 ;
   double BuyTpPrice = 0 ;  
    
      if (Buy_Open == true && OrdersTotal() > 1 ) 
   
      {     
        for(int i=0 ;i<OrdersTotal();i++)
           { 
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Buy_MagicNumber )
                  {
                     if(OrderType()==OP_BUY)
                        {
                         BuySumPriceLot += OrderOpenPrice() * OrderLots();
                         BuySumLot += OrderLots() ; 
                        }
                  }
                       
           }
           
           BuyModifyPrice = NormalizeDouble(BuySumPriceLot/BuySumLot , Digit)  ; 
           BuyTpPrice = BuyModifyPrice + Buy_TakeProfit * Point ;    
         
        
        //Print( "Modify TP Price : " , (LastSellOrderPrice+(SellLastPrice2-SellLastPrice1)/2)+Point*Sell_TakeProfit ) ; 
           
        for(int i=0 ;i<OrdersTotal();i++)
           { 
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Buy_MagicNumber )
                  {
                     if(OrderType()==OP_BUY)
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),BuyTpPrice,0,Green);
                  }
           }
            
      }
  }


void ModifySell() 
{  
   double SellSumPriceLot = 0 ;
   double SellSumLot = 0 ; 
   double SellModifyPrice = 0 ;
   double SellTpPrice = 0 ;   
    
      if (Sell_Open == true && OrdersTotal() > 1 ) 
   
      {     
        for(int i=0 ;i<OrdersTotal();i++)
           { 
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Sell_MagicNumber )
                  {
                     if(OrderType()==OP_SELL)
                        {
                         SellSumPriceLot += OrderOpenPrice() * OrderLots();
                         SellSumLot += OrderLots() ;
                        }
                  }   
           }
           
           SellModifyPrice = NormalizeDouble(SellSumPriceLot/SellSumLot , Digit)  ; 
           SellTpPrice = SellModifyPrice - Sell_TakeProfit * Point ;

        
        //Print( "Modify TP Price : " , (LastSellOrderPrice+(SellLastPrice2-SellLastPrice1)/2)+Point*Sell_TakeProfit ) ; 
           
        for(int i=0 ;i<OrdersTotal();i++)
           { 
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Sell_MagicNumber )
                  {
                     if(OrderType()==OP_SELL)
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),SellTpPrice,0,Red);
                  }
           }
            
      }
  }

bool RSIIndicatorCondition(int RSILevel,string TypeOrder)
{  
   if ( TypeOrder == "Buy" ) {
      if(iRSI(NULL,0,RSI_Period,RSI_ApplyTo,0) > RSILevel) {
         return true ; 
      }
      else {
         return false ;  
      }
   }
   
   else if ( TypeOrder == "Sell" ) {
      if(iRSI(NULL,0,RSI_Period,RSI_ApplyTo,0) < RSILevel) {
         return true ; 
      }
      else {
         return false ;  
      }
   }
   return false ;
}

bool isZeroOrder()
{
  int OrderCount = 0 ;
   
  for(int i=0 ;i<OrdersTotal();i++)
     { 
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if ( OrderSymbol() == Symbol() && (OrderMagicNumber() == Sell_MagicNumber || OrderMagicNumber() == Buy_MagicNumber ))
            {
                OrderCount++;
                Print( "Modify TP Price : " , OrderTicket() ) ; 
            }
     }
     
   if (OrderCount == 0 ) {
      return true ; 
   }
   else {
      return false ; 
   }
}

  
int start() 
{  
  // Print("LastBuyOrderPrice : ",LastBuyOrderPrice) ; 
  // Print("LastSellOrderPrice : ",LastSellOrderPrice) ; 
   CheckBuy();
   CheckSell();

   return(0);
}