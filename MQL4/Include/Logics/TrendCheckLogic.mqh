//+------------------------------------------------------------------+
//|                                              TrendCheckLogic.mqh |
//| IndicatorLogic v1.0.0                     Copyright 2022, Lukkou |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Logics/IndicatorLogic.mqh>

class TrendCheckLogic
{
    private:
    IndicatorLogic indicator;

    public:
        //------------------------------------------------------------------
        // コンストラクタ
        TrendCheckLogic();
        
        //------------------------------------------------------------------
        // デストラクタ
        ~TrendCheckLogic();

        int GetUpTrendEntryStatus();

        int GetDownTrendEntryStatus()
};

    //------------------------------------------------------------------
    // コンストラクタ
    TrendCheckLogic::TrendCheckLogic()
    {
        indicator = IndicatorLogic();
    }

    //------------------------------------------------------------------
    // デストラクタ
    TrendCheckLogic::~TrendCheckLogic()
    {
        indicator = NULL
    }

    /// <summary>
    /// 現在の4Hトレンドを取得
    /// <summary>
    /// <returns>上トレンド:1 下トレンド:-1 無トレンド:0 エラー:2147483647</returns>
    int TrendCheckLogic::GetLongTrendStatus()
    {
        int result = LONG_TREND_NON;

        // GMMA Index Long
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_H4, 1, 0);

        // GMMA Index Short
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_H4, 0, 0);

        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 1);
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 1);

        // TEMA
        double tmmaUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 1);
        double tmmaDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 1);

        // GMMA Width 傾き
        double regressionTilt = 0
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_H4, 6 ,regressionTilt);

        if(gmmaWidthUp == 2147483647 || gmmaWidthDown == 2147483647)
        {
            return 2147483647;
        }

        if (gmmaIndexLong == 5 && gmmaIndexShort == 5 && gmmaWidthUp > 0 && tmmaUp > 0 && gmmaRegressionLine > 0)
        {
            result = LONG_TREND_PLUS;
        }
        else if(gmmaIndexLong == -5 && gmmaIndexShort == -5 && gmmaWidthDown < 0 && tmmaDown < 0 && gmmaRegressionLine < 0)
        {
            result = LONG_TREND_MINUS;
        }

        return result;
    }

    /// <summary>
    /// 15m足のアップトレンドエントリ判定
    /// <summary>
    /// <returns>エントリ無:0 エントリー有:1</returns>
    int TrendCheckLogic::GetUpTrendEntryStatus()
    {
        int result = ENTRY_OFF;

        // GMMA Index Long
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 1);
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);

        // RSI3 26
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 1);

        // RSI3 52
        double rsiLong = indicator.GetThreeLineRci(PERIOD_M15, 2, 1);

        if(gmmaIndexLong == 5 && gmmaIndexShort > 0 && gmmaIndexShort < 5 && rsiMiddle >= 50 && rsiLong >= 50)
        {
            double nowGmmaIndex = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            // トリガー条件
            if(nowGmmaIndex == 5)
            {
                result = ENTRY_ON;
            }
        }

        return result;
    }

    /// <summary>
    /// 15m足のダウントレンドエントリ判定
    /// <summary>
    /// <returns>エントリ無:0 エントリー有:1</returns>
    int TrendCheckLogic::GetDownTrendEntryStatus()
    {
        int result = ENTRY_OFF;

        // GMMA Index
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 1);
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);

        // RSI3 26
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 1);

        // RSI3 52
        double rsiLong = indicator.GetThreeLineRci(PERIOD_M15, 2, 1);

        if(gmmaIndexLong == -5 && gmmaIndexShort < 0 && gmmaIndexShort > -5 && rsiMiddle <= -50 && rsiLong <= -50)
        {
            double nowGmmaIndex = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            // トリガー条件
            if(nowGmmaIndex == -5)
            {
                result = ENTRY_ON;
            }
        }

        return result;
    }

    /// <summary>
    /// アップトレンドの決済判定
    /// <summary>
    /// <returns>決済無:0 決済有:1</returns>
    int TrendCheckLogic::GetUpTrendPositionCut()
    {
        int result = POSITION_CUT_OFF;

        // GMMA Index
        double agoGmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);

        // GMMA Width 傾き
        double regressionTilt = 0
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        if(agoGmmaIndexShort < 5 || gmmaRegressionLine < 0)
        {
            // 現在値
            double nowPrice = iClose(NULL, PERIOD_M5 , 0);

            // iMA（1:string symbol,2:int timeframe,3:int period,4:int ma_shift,5:int ma_methid,6:int applied_price,7:int shift）。
            double ema30 = iMA(NULL,PERIOD_M15, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
            double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            if(nowPrice < ema30 || agoGmmaIndexShort > gmmaIndexShort)
            {
                result  = POSITION_CUT_ON;
            }
        }

        return result;
    }

    /// <summary>
    /// ダウントレンドの決済判定
    /// <summary>
    /// <returns>決済無:0 決済有:1</returns>
    int TrendCheckLogic::GetDownTrendPositionCut()
    {
        int result = POSITION_CUT_OFF;

        // GMMA Index
        double agoGmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);

        // GMMA Width 傾き
        double regressionTilt = 0
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        if(agoGmmaIndexShort > -5 || gmmaRegressionLine > 0)
        {
            // 現在値
            double nowPrice = iClose(NULL, PERIOD_M5 , 0);

            // iMA（1:string symbol,2:int timeframe,3:int period,4:int ma_shift,5:int ma_methid,6:int applied_price,7:int shift）。
            double ema30 = iMA(NULL,PERIOD_M15, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
            double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            if(nowPrice > ema30 || agoGmmaIndexShort < gmmaIndexShort)
            {
                result  = POSITION_CUT_ON;
            }
        }

        return result;
    }

