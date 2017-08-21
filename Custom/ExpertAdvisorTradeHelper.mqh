//+------------------------------------------------------------------+
//|                                     ExpertAdvisorTradeHelper.mq4 |
//| ExpertAdvisorHelper　v1.0.0     Copyright 2017, Lukkou_EA_Trader |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

// 注文関係ラッパークラス
#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Arrays/ArrayInt.mqh>
#include <Custom/TradingDefines.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>

//------------------------------------------------------------------
// 注文関係ラッパークラス
class ExpertAdvisorTradeHelper
{
private:
   // マジックナンバー
   int m_magicNumber;
   
   // 最大ポジション数
   int m_maxPosition;
   
   // 最大スプレット
   double m_spreadFilter;
   
   // Pips倍率
   int m_pipsRate;
   
   // 対象通貨ペア
   string m_symbol;
   
   // 保有ポジション
   CArrayInt m_positions ;
   
   // タイムアウト値
   uint m_timeout;
   
   // 少数桁数
   int m_digit;
   
   // 取扱い最小値
   double m_point ;
   
   // デフォルトのコメント
   string m_defualtComment;
   
   // カウントダウン方式の場合true
   bool m_isCountdown;
public:
   //------------------------------------------------------------------
   // コンストラクタ
   ExpertAdvisorTradeHelper(
      string symbol,       //対象通貨ペア
      int magicNumber,     //マジックナンバー
      int maxPosition,     //最大ポジション数
      double spreadFilter, //最大スプレット
      uint timeout,        //タイムアウト
      bool isCountdown,    // カウントダウン方式
      string defualtComment //デフォルトコメント
      );

   //------------------------------------------------------------------
   // デストラクタ
   ~ExpertAdvisorTradeHelper();
   
   //------------------------------------------------------------------
   // 発注する
   // Return   発注成功時インデックス それ以外-1
   int SendOrder(
      int cmd,                //売買種別  
      double volume,          //売買ロット
      double price,           //価格
      uint slippage,          //許容スリッピング（Pips単位）
      uint stoploss,          //ストップロス（Pips単位）
      uint takeprofit,        //利確値（Pips単位）
      string comment,         //コメント
      datetime expiration,    //注文有効期限
      color arrowColor        //注文矢印の色
   );
   
   //------------------------------------------------------------------
   // 発注する
   // Return   発注成功時インデックス それ以外-1
   int SendOrderPrice(
      int cmd,                      //売買種別  
      double volume,                //売買ロット
      double price,                 //価格(成行き時は現在値を自動設定)
      uint slippage,                //許容スリッピング（Pips単位）
      double stoploss = 0,          //ストップロス（価格）
      double takeprofit = 0,        //利確値（価格）
      string comment = NULL,        //コメント
      datetime expiration = 0,      //注文有効期限
      color arrowColor = clrNONE    //注文矢印の色
   );
   
   //------------------------------------------------------------------
   // 成行き決済を行う。
   // Return   発注成功時ture それ以外false
   bool CloseOrder(
      int index,                    //決済するインデックス
      uint slippage,                //許容スリッピング
      color arrowColor = clrNONE    //注文矢印の色
   );
   
   //------------------------------------------------------------------
   // 全ポジションを成行き決済を行う。
   // Return   発注成功時ture それ以外false
   bool CloseOrderAll(
      uint slippage,                //許容スリッピング
      color arrowColor = clrNONE    //注文矢印の色
   );

   //------------------------------------------------------------------
   // 注文を変更する。
   // Return   発注成功時ture それ以外false
   bool ModifyOrder(
      int index,              //決済するインデックス
      uint stoploss,          //ストップロス（Pips単位）
      uint takeprofit,        //利確値（Pips単位）
      color arrowColor        //注文矢印の色
   );
   
   //------------------------------------------------------------------
   // 注文を変更する。
   // Return   発注成功時ture それ以外false
   bool ExpertAdvisorTradeHelper::ModifyOrderPrice(
      int index,                 //決済するインデックス
      double stoploss,           //ストップロス（Pips単位）
      double takeprofit = 0,     //利確値（Pips単位）0は変更なし
      color arrowColor = clrNONE //注文矢印の色
   );

   //------------------------------------------------------------------
   // すべての注文を変更する。
   bool ModifyOrderAll(
      uint stoploss,          //ストップロス（Pips単位）
      uint takeprofit,        //利確値（Pips単位）
      color arrowColor        //注文矢印の色
   );
   
   //------------------------------------------------------------------
   // マジックナンバーを取得する。
   // Return   マジックナンバー
   int GetMagicNumber() { return m_magicNumber; };
   
   //------------------------------------------------------------------
   // 現在のポジション数を取得する。
   // Return   現在のポジション数を取得する。
   int GetPositionCount(){ return m_positions.Total(); };
   
   //------------------------------------------------------------------
   // 最大ポジション数を取得する。
   // Return   最大ポジション数を取得する。
   int GetMaxPosition(){ return m_maxPosition; };
   
   //------------------------------------------------------------------
   // 通貨ペアを取得する。
   // Return   最大ポジション数を取得する。
   string GetSymbol(){ return m_symbol; };
   
   //------------------------------------------------------------------
   // 指定番号のチケットを取得する。
   // Return   チケット番号 取得失敗時-1
   int GetTicket(
      int index         //インデックス
   );
   
   //------------------------------------------------------------------
   // 指定番号の売買種別 を取得する。
   // Return   売買種別 
   int GetOrderType(
      int index         //インデックス
   );
   
   //------------------------------------------------------------------
   // 指定番号の現在利益を取得する。
   // Return   現在利益(Pips)
   double GetOrderProfit(
      int index         //インデックス
   );
   
   //------------------------------------------------------------------
   // 指定番号の現在リミット値を取得する。
   // Return   リミット値
   double GetOrderLimit(
      int index         //インデックス
   );
   
   //------------------------------------------------------------------
   // 指定番号の現在リミット値を取得する。
   // Return   リミット値(Pips)
   double GetOrderLimitPips(
      int index         //インデックス
   );

   //------------------------------------------------------------------
   // 指定番号のオープン価格を取得する。。
   // Return   オープン値
   double GetOrderOpen(
      int index         //インデックス
   );
   
   
   //------------------------------------------------------------------
   // 指定番号の現在値を取得する。
   // Return   現在価格
   double GetOrderClose(
      int index         //インデックス
   );
   
   //------------------------------------------------------------------
   // 指定番号の取引開始時間 を取得する。
   // Return   取引開始時間 
   datetime GetOrderOpenTime(
      int index         //インデックス
   );

   //------------------------------------------------------------------
   // 1pipsあたりの値を取得する。
   // Return   1pipあたりの値
   double GetPipsValue() { return m_point * m_pipsRate; } ;

   //------------------------------------------------------------------
   // 指定pipsあたりの値を取得する。
   // Return   指定pipあたりの値
   double GetPipsValue(
      double pips    // 指定Pips
   ){ return pips * m_point * m_pipsRate; } ;
   
   //------------------------------------------------------------------
   // ポジションリストを更新する。
   void RefreshPositions();
   
private:

   //------------------------------------------------------------------
   // 設定パラメータが安全かどうか
   // Return 安全ture それ以外false
   bool IsSafeParameter();

};

//------------------------------------------------------------------
// コンストラクタ
ExpertAdvisorTradeHelper::ExpertAdvisorTradeHelper(
      string symbol,             //対象通貨ペア
      int magicNumber = 0,       //マジックナンバー
      int maxPosition = 3,       //最大ポジション数
      double spreadFilter = 5,   //最大スプレット
      uint timeout = 1000,       //タイムアウト(ms)
      bool isCountdown = false,  // カウントダウン方式
      string defualtComment=NULL //デフォルトコメント 
)
{
   m_symbol = symbol;
   m_magicNumber = magicNumber;
   m_maxPosition = maxPosition;
   m_timeout = timeout;
   m_positions.Resize(m_maxPosition);
   m_defualtComment = defualtComment;
   m_isCountdown = isCountdown;
   
   //Pips計算 小数点桁数が3or5の場合、Point()*10=1pips
   m_digit = (int)MarketInfo(m_symbol, MODE_DIGITS);
   m_point = (double)MarketInfo(m_symbol, MODE_POINT);

   m_pipsRate = m_digit == 3 || m_digit == 5 ? 10 : 1;
   
   for( int i = 0 ; i < OrdersTotal(); i++)
   {
      if( OrderSelect(i, SELECT_BY_POS) )
      {
         if( OrderMagicNumber() == m_magicNumber && OrderSymbol() == m_symbol)
         {
            m_positions.Add(OrderTicket());
         }
      }
   }
   m_spreadFilter = GetPipsValue(spreadFilter);
}

//------------------------------------------------------------------
// デストラクタ
ExpertAdvisorTradeHelper::~ExpertAdvisorTradeHelper()
{
}

//------------------------------------------------------------------
// 発注する
// Return   発注成功時インデックス それ以外-1
int ExpertAdvisorTradeHelper::SendOrder(
      int cmd,                      //売買種別  
      double volume,                //売買ロット
      double price,                 //価格(成行き時は現在値を自動設定)
      uint slippage,                //許容スリッピング（Pips単位）
      uint stoploss = 0,            //ストップロス（Pips単位）
      uint takeprofit = 0,          //利確値（Pips単位）
      string comment = NULL,        //コメント
      datetime expiration = 0,      //注文有効期限
      color arrowColor = clrNONE    //注文矢印の色
)
{
   if( !this.IsSafeParameter() ) return -1;
   if( m_positions.Total() >= m_maxPosition ) return -1 ;

   if( comment == NULL ) comment = m_defualtComment;

   // 計算用 負数フラグ
   int flag = cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP ? 1 : -1;
   
   uint start = GetTickCount();
   while(!IsStopped())
   {
      if( (GetTickCount() - start ) > m_timeout ) return -1;

      double bid = MarketInfo(m_symbol, MODE_BID);
      double ask = MarketInfo(m_symbol, MODE_ASK);
      
      // スプレットが大きすぎる場合は取引しない。
      if( NormalizeDouble(MathAbs(ask - bid), m_digit) > m_spreadFilter )
      {
         Print("Order failed. spread over.");
         return -1;
      }

      if( cmd == OP_SELL ) price = bid;
      if( cmd == OP_BUY ) price = ask;

      double closeTarget = cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP ? ask : bid; 

      //pips値からストップロス値、利益確定値を取得する。   
      double stoplossValue = 0 ;
      double takeprofitValue = 0;
      if( stoploss != 0 )
      {
         stoplossValue = NormalizeDouble(closeTarget - this.GetPipsValue(stoploss) * flag, m_digit );
      }
      if( takeprofit != 0)
      {
         takeprofitValue = NormalizeDouble(closeTarget + this.GetPipsValue(takeprofit) * flag, m_digit );
      }

      if( IsTradeAllowed() )
      {
         if( AccountFreeMarginCheck(m_symbol, cmd, volume) < 0 )
         {
            int errorCode = GetLastError();
            Print("AccountFreeMarginCheck Error[",errorCode ,"]");
            return -1;
         }
         
         int tiket = -1;
         if( m_isCountdown )
         {
            tiket = ::OrderSend(m_symbol, cmd, volume, price,
               slippage * m_pipsRate, 0, 0, 
               comment, m_magicNumber, expiration, arrowColor);
         }
         else
         {
            tiket = ::OrderSend(m_symbol, cmd, volume, price,
               slippage * m_pipsRate, stoplossValue, takeprofitValue, 
               comment, m_magicNumber, expiration, arrowColor);
         }
            
         if( tiket >= 0 )
         {
            m_positions.Add(tiket);
            
            if( m_isCountdown )
            {
               ModifyOrder(m_positions.Total() - 1, stoploss, takeprofit);
            }
            
            return m_positions.Total() - 1;
         }
         else
         {
            int errorCode = GetLastError();
            
            // リトライしても仕方がないエラーの時は終了してしまう。
            if( errorCode == ERR_INVALID_PRICE ||
               errorCode == ERR_INVALID_STOPS ||
               errorCode == ERR_INVALID_TRADE_VOLUME ||
               errorCode == ERR_NOT_ENOUGH_MONEY )
            {
               return -1;
            }
         }
      }
      Sleep(100);
   }
   Print("SendOrder Timeout");
   return -1;
}

//------------------------------------------------------------------
// 発注する
// Return   発注成功時インデックス それ以外-1
int ExpertAdvisorTradeHelper::SendOrderPrice(
      int cmd,                      //売買種別  
      double volume,                //売買ロット
      double price,                 //価格(成行き時は現在値を自動設定)
      uint slippage,                //許容スリッピング（Pips単位）
      double stoploss = 0,          //ストップロス（価格）
      double takeprofit = 0,        //利確値（価格）
      string comment = NULL,        //コメント
      datetime expiration = 0,      //注文有効期限
      color arrowColor = clrNONE    //注文矢印の色
)
{
   if( !this.IsSafeParameter() ) return -1;
   if( m_positions.Total() >= m_maxPosition ) return -1 ;

   if( comment == NULL ) comment = m_defualtComment;

   // 計算用 負数フラグ
   int flag = cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP ? 1 : -1;
   
   uint start = GetTickCount();
   while(!IsStopped())
   {
      if( (GetTickCount() - start ) > m_timeout ) return -1;

      double bid = MarketInfo(m_symbol, MODE_BID);
      double ask = MarketInfo(m_symbol, MODE_ASK);
      
      // スプレットが大きすぎる場合は取引しない。
      if( NormalizeDouble(MathAbs(ask - bid), m_digit) > m_spreadFilter ) return -1;

      //pips値からストップロス値、利益確定値を取得する。   
      double stoplossValue = NormalizeDouble(stoploss, m_digit) ;
      double takeprofitValue = NormalizeDouble(takeprofit, m_digit) ;

      if( cmd == OP_SELL )
      {
         price = bid;
         if( stoplossValue > 0 && price > stoplossValue) return -1;
         if( takeprofitValue > 0 && price < takeprofitValue) return -1;
      }
      if( cmd == OP_BUY )
      {
         price = ask;
         if( stoplossValue > 0 && price < stoplossValue) return -1;
         if( takeprofitValue > 0 && price > takeprofitValue) return -1;
      }

      double closeTarget = cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP ? ask : bid; 


      if( IsTradeAllowed() )
      {
         if( AccountFreeMarginCheck(m_symbol, cmd, volume) < 0 )
         {
            int errorCode = GetLastError();
            Print("AccountFreeMarginCheck Error[",errorCode ,"]");
            return -1;
         }
         
         int tiket = -1;
         if( m_isCountdown )
         {
            tiket = ::OrderSend(m_symbol, cmd, volume, price,
               slippage * m_pipsRate, 0, 0, 
               comment, m_magicNumber, expiration, arrowColor);
         }
         else
         {
            tiket = ::OrderSend(m_symbol, cmd, volume, price,
               slippage * m_pipsRate, stoplossValue, takeprofitValue, 
               comment, m_magicNumber, expiration, arrowColor);
         }
            
         if( tiket >= 0 )
         {
            m_positions.Add(tiket);
            
            if( m_isCountdown )
            {
               ModifyOrderPrice(m_positions.Total() - 1, stoploss, takeprofit);
            }
            
            return m_positions.Total() - 1;
         }
         else
         {
            int errorCode = GetLastError();
            
            // リトライしても仕方がないエラーの時は終了してしまう。
            if( errorCode == ERR_INVALID_PRICE ||
               errorCode == ERR_INVALID_STOPS ||
               errorCode == ERR_INVALID_TRADE_VOLUME ||
               errorCode == ERR_NOT_ENOUGH_MONEY )
            {
               return -1;
            }
         }
      }
      Sleep(100);
   }
   Print("SendOrder Timeout");
   return -1;
}

//------------------------------------------------------------------
// 成行き決済を行う。
// Return   発注成功時ture それ以外false
bool ExpertAdvisorTradeHelper::CloseOrder(
   int index,                    //決済するインデックス
   uint slippage,                //許容スリッピング
   color arrowColor = clrNONE    //注文矢印の色
)
{
   uint start = GetTickCount();
   while(!IsStopped())
   {
      if( (GetTickCount() - start ) > m_timeout ) return false;

      if( IsTradeAllowed() )
      {
         // オーダーが選択できない状態（すでに存在しない）場合は、リストから削除して終了する。
         int targetTicket = m_positions.At(index);
         if( !OrderSelect(targetTicket, SELECT_BY_TICKET) ) 
         {
            m_positions.Delete(index);
            return false;
         }
      
         if( OrderClose(OrderTicket(),OrderLots(), OrderClosePrice(), slippage * m_pipsRate, arrowColor) )
         {
            m_positions.Delete(index);
            return true;
         }
         else
         {
            int errorCode = GetLastError();

            // リトライしても仕方がないエラーの時は終了してしまう。
            if( errorCode == ERR_INVALID_TICKET)
            {
               m_positions.Delete(index);
               return false;
            }
         }
      }
      Sleep(100);
   }
   
   Print("CloseOrder Timeout");

   return false;
}

//------------------------------------------------------------------
// 全ポジションを成行き決済を行う。
// Return   発注成功時ture それ以外false
bool ExpertAdvisorTradeHelper::CloseOrderAll(
   uint slippage,                // 許容スリッピング
   color arrowColor = clrNONE    // 注文矢印の色
)
{
   RefreshPositions();
   bool result = true;
   for( int i = m_positions.Total() - 1; i >= 0; i--)
   {
      result &= this.CloseOrder(i, slippage, arrowColor);
   }

   return result;
}

//------------------------------------------------------------------
// 注文を変更する。
// Return   発注成功時ture それ以外false
bool ExpertAdvisorTradeHelper::ModifyOrder(
   int index,                 //決済するインデックス
   uint stoploss,             //ストップロス（Pips単位）
   uint takeprofit = 0,       //利確値（Pips単位）0は変更なし
   color arrowColor = clrNONE //注文矢印の色
)
{
   uint start = GetTickCount();
   while(!IsStopped())
   {
      if( (GetTickCount() - start ) > m_timeout ) return false;

      if( IsTradeAllowed() )
      {
         // オーダーが選択できない状態（すでに存在しない）場合は、リストから削除して終了する。
         int targetTicket = m_positions.At(index);
         if( !OrderSelect(targetTicket, SELECT_BY_TICKET) ) 
         {
            m_positions.Delete(index);
            return false;
         }
         
         // 実際のポジション以外は無視
         int cmd = OrderType();
         if( cmd != OP_BUY && cmd != OP_SELL )
         {
            return false;
         }
   
         double bid = MarketInfo(m_symbol, MODE_BID);
         double ask = MarketInfo(m_symbol, MODE_ASK);

         // 計算用 負数フラグ
         int flag = cmd == OP_BUY  ? 1 : -1;

         double closeTarget = cmd == OP_BUY ? ask : bid; 
         //pips値からストップロス値、利益確定値を取得する。   
         double stoplossValue = 0 ;
         double takeprofitValue = 0;
         double nowStop = OrderStopLoss();

         if( stoploss != 0 )
         {
            stoplossValue = NormalizeDouble(closeTarget - this.GetPipsValue(stoploss) * flag, m_digit );
         }
         else
         {
            // ０の場合変更しない。
            if( nowStop > 0 ) stoplossValue = nowStop;
         }
         
         if( nowStop > 0 ) 
         {
            // 注文ストップ値は下方方向への変更は許可しない。
            if((cmd == OP_BUY && stoplossValue <= OrderStopLoss() ) ||
               (cmd == OP_SELL && stoplossValue >= OrderStopLoss() ) ) stoplossValue = nowStop ;
         }
            
         if( takeprofit != 0)
         {
            closeTarget = OrderOpenPrice();
            takeprofitValue = NormalizeDouble(closeTarget + this.GetPipsValue(takeprofit) * flag, m_digit );
         }
         else
         {
            // ０の場合変更しない。
            double profit = OrderTakeProfit();
            if( stoplossValue > 0 && profit > 0 ) takeprofitValue = profit;
         }
         
         // 変更がない場合はコマンドを実行しない。
         if( stoplossValue == 0 && takeprofitValue == 0 ) return true;

         if( OrderModify(targetTicket, OrderOpenPrice(), stoplossValue, takeprofitValue, 0, arrowColor ))
         {
            return true;
         }
         else
         {
            int errorCode = GetLastError();
            
            // 変更なしだった
            if( errorCode == ERR_NO_RESULT ) return true;
            
            // リトライしても仕方がないエラーの時は終了してしまう。
            if( errorCode == ERR_INVALID_PRICE ||
               errorCode == ERR_INVALID_STOPS ||
               errorCode == ERR_INVALID_TRADE_VOLUME ||
               errorCode == ERR_NOT_ENOUGH_MONEY)
            {
               return false;
            }
         }
      }
   }
   Print("ModifyOrder Timeout");
   return false;
}

//------------------------------------------------------------------
// 注文を変更する。
// Return   発注成功時ture それ以外false
bool ExpertAdvisorTradeHelper::ModifyOrderPrice(
   int index,                 //決済するインデックス
   double stoploss,           //ストップロス
   double takeprofit = 0,     //利確値（Pips単位）0は変更なし
   color arrowColor = clrNONE //注文矢印の色
)
{
   uint start = GetTickCount();
   while(!IsStopped())
   {
      if( (GetTickCount() - start ) > m_timeout ) return false;

      if( IsTradeAllowed() )
      {
         // オーダーが選択できない状態（すでに存在しない）場合は、リストから削除して終了する。
         int targetTicket = m_positions.At(index);
         if( !OrderSelect(targetTicket, SELECT_BY_TICKET) ) 
         {
            m_positions.Delete(index);
            return false;
         }
         
         // 実際のポジション以外は無視
         int cmd = OrderType();
         if( cmd != OP_BUY && cmd != OP_SELL )
         {
            return false;
         }
   
         double bid = MarketInfo(m_symbol, MODE_BID);
         double ask = MarketInfo(m_symbol, MODE_ASK);

         // 計算用 負数フラグ
         int flag = cmd == OP_BUY  ? 1 : -1;

         double closeTarget = cmd == OP_BUY ? ask : bid; 
         //pips値からストップロス値、利益確定値を取得する。   
         double stoplossValue = NormalizeDouble(stoploss, m_digit );
         double takeprofitValue = NormalizeDouble(takeprofit, m_digit) ;
         double nowStop = OrderStopLoss();

         if( stoploss == 0 && nowStop > 0) stoplossValue = nowStop;
         if( nowStop > 0 ) 
         {
            // 注文ストップ値は下方方向への変更は許可しない。
            if((cmd == OP_BUY && stoplossValue <= nowStop ) ||
               (cmd == OP_SELL && stoplossValue >= nowStop ) ) stoplossValue = nowStop ;
         }
         double nowTakeProfit = OrderTakeProfit();
         if( takeprofit == 0 && nowTakeProfit > 0 ) takeprofitValue = nowTakeProfit; 
         
         if( cmd == OP_SELL )
         {
            if( stoplossValue > 0 && closeTarget > stoplossValue) return false;
            if( takeprofitValue > 0 && closeTarget < takeprofitValue) return false;
         }
         if( cmd == OP_BUY )
         {
            if( stoplossValue > 0 && closeTarget < stoplossValue) return false;
            if( takeprofitValue > 0 && closeTarget > takeprofitValue) return false;
         }
         
         // 変更がない場合はコマンドを実行しない。
         if( stoplossValue == nowStop && takeprofitValue == nowTakeProfit ) return true;

         if( OrderModify(targetTicket, OrderOpenPrice(), stoplossValue, takeprofitValue, 0, arrowColor ))
         {
            return true;
         }
         else
         {
            int errorCode = GetLastError();
           
            // 変更なしだった
            if( errorCode == ERR_NO_RESULT ) return true;
            
            // リトライしても仕方がないエラーの時は終了してしまう。
            if( errorCode == ERR_INVALID_PRICE ||
               errorCode == ERR_INVALID_STOPS ||
               errorCode == ERR_INVALID_TRADE_VOLUME ||
               errorCode == ERR_NOT_ENOUGH_MONEY)
            {
               return false;
            }
         }
      }
   }
   Print("ModifyOrder Timeout");
   return false;
}

//------------------------------------------------------------------
// すべての注文を変更する。
bool ExpertAdvisorTradeHelper::ModifyOrderAll(
   uint stoploss,             //ストップロス（Pips単位）
   uint takeprofit = 0,       //利確値（Pips単位）
   color arrowColor = clrNONE //注文矢印の色
)
{
   RefreshPositions();
   bool result = true;
   for( int i = m_positions.Total() - 1; i >= 0; i--)
   {
      result &= this.ModifyOrder(i, stoploss, takeprofit, arrowColor);
   }

   return result;
}

//------------------------------------------------------------------
// 設定パラメータが安全かどうか
// Return 安全ture それ以外false
bool ExpertAdvisorTradeHelper::IsSafeParameter()
{
   if( m_symbol == NULL ) return false;
   if( m_maxPosition == 0 ) return false; 
   return true;
}

//------------------------------------------------------------------
// ポジションリストを更新する。
void ExpertAdvisorTradeHelper::RefreshPositions()
{
   m_positions.Clear();
   for( int i = 0 ; i < OrdersTotal(); i++)
   {
      if( OrderSelect(i, SELECT_BY_POS) )
      {
         if( OrderMagicNumber() == m_magicNumber && OrderSymbol() == m_symbol)
         {
            m_positions.Add(OrderTicket());
         }
      }
   }
}

//------------------------------------------------------------------
// 指定番号のチケットを取得する。
// Return   チケット番号 取得失敗時-1
int ExpertAdvisorTradeHelper::GetTicket(
      int index         //インデックス
   )
{
   if(index < 0 || index >= m_positions.Total() ) return -1;
   return m_positions.At(index);
}

//------------------------------------------------------------------
// 指定番号の売買種別 を取得する。
// Return   売買種別 
int ExpertAdvisorTradeHelper::GetOrderType(
      int index         //インデックス
   )
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return OP_NONE;
   if( OrderSelect(ticket, SELECT_BY_TICKET) ) return OrderType();
   
   return OP_NONE;
}

//------------------------------------------------------------------
// 指定番号の現在利益を取得する。
// Return   現在利益(Pips)
double ExpertAdvisorTradeHelper::GetOrderProfit(
      int index         //インデックス
   )
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return 0;
   if( OrderSelect(ticket, SELECT_BY_TICKET) )
   {
      if( OrderType() == OP_BUY )
      {
         return (OrderClosePrice() - OrderOpenPrice()) / GetPipsValue();
      }
      else      
      {
         return (OrderOpenPrice() - OrderClosePrice()) / GetPipsValue();
      }
   }
   
   return 0;
}

//------------------------------------------------------------------
// 指定番号の現在リミット値を取得する。
// Return   リミット値
double ExpertAdvisorTradeHelper::GetOrderLimit(
   int index         //インデックス
)
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return 0;
   if( OrderSelect(ticket, SELECT_BY_TICKET) )
   {
      return OrderStopLoss();
   }
   
   return 0;

}

//------------------------------------------------------------------
// 指定番号の現在リミット値を取得する。
// Return   リミット値
double ExpertAdvisorTradeHelper::GetOrderLimitPips(
   int index         //インデックス
)
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return 0;
   if( OrderSelect(ticket, SELECT_BY_TICKET) )
   {
      if( OrderType() == OP_BUY )
      {
         return (OrderClosePrice() - OrderStopLoss()) / GetPipsValue();
      }
      else      
      {
         return (OrderStopLoss() - OrderClosePrice()) / GetPipsValue();
      }
   }
   
   return 0;
}


//------------------------------------------------------------------
// 指定番号の現在値を取得する。
// Return   現在価格
double ExpertAdvisorTradeHelper::GetOrderClose(
   int index         //インデックス
)
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return 0;
   if( OrderSelect(ticket, SELECT_BY_TICKET) )
   {
      return OrderClosePrice();
   }
  
   return 0;
}

//------------------------------------------------------------------
// 指定番号のオープン価格を取得する。。
// Return   オープン値
double ExpertAdvisorTradeHelper::GetOrderOpen(
   int index         //インデックス
)
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return 0;
   if( OrderSelect(ticket, SELECT_BY_TICKET) )
   {
      return OrderOpenPrice();
   }
   
   return 0;
}



//------------------------------------------------------------------
// 指定番号の取引開始時間 を取得する。
// Return   取引開始時間 
datetime ExpertAdvisorTradeHelper::GetOrderOpenTime(
   int index         //インデックス
)
{
   int ticket = GetTicket(index);
   if( ticket < 0 ) return 0;
   if( OrderSelect(ticket, SELECT_BY_TICKET) )
   {
      return OrderOpenTime();
   }
   return 0;
}