//+------------------------------------------------------------------+
//|                                                    OrderTest.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "0.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/TwitterHelper.mqh>

input int MagicNumber = 11180002; //マジックナンバー 他のEAと当らない値を使用する。
input double SpreadFilter = 2;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern int SdSigma = 3;
extern double RiskPercent = 2.0;

input double Slippage = 10;      //許容スリッピング（Pips単位）
input uint TakeProfit = 200;      //利益確定

// トレード補助クラス
ExpertAdvisorTradeHelper OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);
// 取引数調整クラスSide BarVSide Bar
TradeQuantityHelper LotHelper(Symbol(), PERIOD_M15, 15, 0, MODE_EMA, PRICE_CLOSE, 2, SdSigma, RiskPercent);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
    double lossRenge = LotHelper.GetSdLossRenge();
    double lotSize = LotHelper.GetSdLotSize(lossRenge);
    double pLotSize = LotHelper.GetLotSize(lossRenge);

    PrintFormat("ポジション時間：" + TimeCurrent());
    PrintFormat("ロスカット値段：" + lossRenge);
    PrintFormat("ロットサイズ：" + lotSize);
    PrintFormat("%ロットサイズ：" + pLotSize);

    int orderCmd = OP_BUY;
    OrderHelper.SendOrder(orderCmd, lotSize, 0, Slippage, lossRenge, TakeProfit );
    double orderPrice = OrderHelper.GetOrderClose(0);
    //PrintFormat("通貨ペア：" + Symbol() + "オーダー：OP_BUY 約定価格：" + DoubleToStr(orderPrice,2));

    int positionCount = OrderHelper.GetPositionCount();
    double orderProfit = OrderHelper.GetOrderProfit(0);
    double orderLimit = OrderHelper.GetOrderLimit(0);

    PrintFormat("決済時間：" + TimeCurrent());
    PrintFormat("ポジション数：" + positionCount);
    PrintFormat("利益：" + orderProfit);
   
    //ポジションを保持していれば決済する
    //OrderHelper.CloseOrder(0, Slippage);

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    double temaUp = GetTema(PERIOD_M15,0,0);
    double temaDown = GetTema(PERIOD_M15,1,0);
    
    double gmmaIndexLong = GetGmmaIndex(PERIOD_M15,0,0);
    double gmmaIndexShort = GetGmmaIndex(PERIOD_M15,1,0);

    double gmmaUp = GetGmmaWidth(PERIOD_H4,0,0);
    double gmmaDown = GetGmmaWidth(PERIOD_H4,1,0);
    double gmmaWidthLong = GetGmmaWidth(PERIOD_H4,2,0);
    double gmmaWidthShort = GetGmmaWidth(PERIOD_H4,3,0);
    
    double rciShort = GetThreeLineRci(PERIOD_H4,0,0);
    double rciMedium = GetThreeLineRci(PERIOD_H4,1,0);
    double rciLong = GetThreeLineRci(PERIOD_H4,2,0);
    
    double closePrice = iClose(Symbol(),PERIOD_M15,0);

    PrintFormat("▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲");
    PrintFormat("Close Price" + DoubleToString(closePrice));
    
    PrintFormat("TEMA Up:" + DoubleToString(temaUp));
    PrintFormat("TEMA Down:" + DoubleToString(temaDown));
    
    PrintFormat("GMMA Index Long:" + DoubleToString(gmmaIndexLong));
    PrintFormat("GMMA Index: Short" + DoubleToString(gmmaIndexShort));
    
    PrintFormat("GMMA UP:" + DoubleToString(gmmaUp));
    PrintFormat("GMMA Down:" + DoubleToString(gmmaDown));
    PrintFormat("GMMA Width Long:" + DoubleToString(gmmaWidthLong));
    PrintFormat("GMMA Width Short:" + DoubleToString(gmmaWidthShort));
    
    PrintFormat("RCI S:" + DoubleToString(rciShort));
    PrintFormat("RCI M:" + DoubleToString(rciMedium));
    PrintFormat("RCI L:" + DoubleToString(rciLong));
    PrintFormat("▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽");

}
//+------------------------------------------------------------------+

/// <summary>
/// TEMAのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetTema(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"TemaCumulative",mode,shift);
    return result;
}

/// <summary>
/// GMMAIndexのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetGmmaIndex(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"GMMAIndex",mode,shift);
    return result;
}

/// <summary>
/// GMMAWidthのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetGmmaWidth(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"GMMAWidth",mode,shift);
    return result;
}

/// <summary>
/// 3ラインRCIのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetThreeLineRci(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"RCI_3Line_v130",mode,shift);
    return result;
}