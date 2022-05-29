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
#include <Defines/Defines.mqh>

class TrendCheckLogic
{
    private:
    IndicatorLogic indicator;
    string _symbol;

    public:
        //------------------------------------------------------------------
        // コンストラクタ
        TrendCheckLogic();
        
        //------------------------------------------------------------------
        // デストラクタ
        ~TrendCheckLogic();

        int GetDayTrendStatus()

        int GetLongTrendStatus();

        int GetUpTrendEntryStatus();

        int GetDownTrendEntryStatus();

        int GetUpTrendPositionCut();

        int GetDownTrendPositionCut();
};

    //------------------------------------------------------------------
    // コンストラクタ
    TrendCheckLogic::TrendCheckLogic()
    {
        _symbol = Symbol();
        indicator = IndicatorLogic(_symbol);
    }

    //------------------------------------------------------------------
    // デストラクタ
    TrendCheckLogic::~TrendCheckLogic()
    {
    }

    /// <summary>
    /// 現在の日足レンドを取得
    /// <summary>
    /// <returns>上トレンド:1 下トレンド:-1 無トレンド:0</returns>
    int TrendCheckLogic::GetDayTrendStatus()
    {
        int result = DAY_TREND_NON;
        double nowPrice = iClose(_symbol, PERIOD_D1, 0);

        // GMMA Index
        double gmmaDayIndexShort = indicator.GetGmmaIndex(PERIOD_D1, 0, 0);
        double gmmaDayIndexLong = indicator.GetGmmaIndex(PERIOD_D1, 1, 0);
        double ema30 = indicator.GetMa(PERIOD_D1, 30, MODE_EMA, PRICE_CLOSE, 0)

        if(gmmaDayIndexLong == 5 && (gmmaDayIndexShort >= 0 || ema30 < nowPrice))
        {
            double tmeaUp = indicator.GetTemaIndex(PERIOD_D1, 0, 0);
            double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_D1, 0, 0);
            
            if(tmeaUp >= 0.1 && gmmaWidthUp > 0)
            {
                result = DAY_TREND_PLUS;
            }
        }
        else if(gmmaDayIndexLong == -5 && (gmmaDayIndexShort <= 0 || ema30 > nowPrice))
        {
            double tmeaDown = indicator.GetTemaIndex(PERIOD_D1, 1, 0);
            double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_D1, 1, 0);

            if(tmeaDown <= -0.1 && gmmaWidthDown < 0)
            {
                result = DAY_TREND_MINUS;
            }
        }

        return result;
    }

    /// <summary>
    /// 現在の4Hトレンドを取得
    /// <summary>
    /// <returns>上トレンド:1 下トレンド:-1 無トレンド:0 エラー:2147483647</returns>
    int TrendCheckLogic::GetLongTrendStatus()
    {
        int result = LONG_TREND_NON;

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_H4, 6 ,regressionTilt);

        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 0);
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 0);

        if(regressionTilt > 0)


        // エラー数値の場合
        if (gmmaWidthUp == EMPTY_VALUE || gmmaWidthDown == EMPTY_VALUE)
        {
            return result;
        }

        // GMMA Index Long
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_H4, 1, 0);

        // GMMA Index Short
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_H4, 0, 0);

        // TEMA
        double beforeTmmaUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 1);
        double beforeTmmaDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 1);
        double nowTmmaUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 0);
        double nowTmmaDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 0);

        if (gmmaIndexLong == 5 && gmmaIndexShort == 5 && gmmaWidthUp > 0 && beforeTmmaUp >= 0.1 && nowTmmaUp >= 0.1)
        {
            result = LONG_TREND_PLUS;
        }
        else if(gmmaIndexLong == -5 && gmmaIndexShort == -5 && gmmaWidthDown < 0 && beforeTmmaDown <= -0.1 && nowTmmaDown <= -0.1)
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

        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_M15, 0, 0);
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_M15, 1, 0);
        // そもその判定の価値なしトレンド
        if((gmmaWidthUp == 2147483647 && gmmaWidthDown == 2147483647) || (gmmaWidthUp == 0 && gmmaWidthDown == 0))
        {
            return result;
        }

        // GMMA Index Long
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 1);

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        // TEMA 傾き
        double beforeTemaUp = indicator.GetTemaIndex(PERIOD_M15, 0, 1);
        double beforeTemaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 1);

        // RSI3
        double rsiShort = indicator.GetThreeLineRci(PERIOD_M15, 0, 1);
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 1);
        double rsiLong = indicator.GetThreeLineRci(PERIOD_M15, 2, 1);

        bool rsiInterrelationShort = (rsiShort > 80 && rsiMiddle > 70);
        bool rsiInterrelationLong = (rsiShort > 70 && rsiMiddle > 60);

        if(gmmaIndexLong == 5 && 
           gmmaIndexShort == 5 && 
           regressionTilt > 0 && 
           (rsiInterrelationShort || rsiInterrelationLong) && 
           beforeTemaUp > 0 && 
           beforeTemaDown == 0)
        {
            double nowGmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);
            double nowGmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 0);
            // TEMA 傾き
            double temaUp = indicator.GetTemaIndex(PERIOD_M15, 0, 0);
            double temaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 0);

            // トリガー条件
            if(nowGmmaIndexShort == 5 && 
               nowGmmaIndexLong == 5 && 
               temaUp > 0 && 
               temaDown == 0)
            {
                Print ("-------------------GMMA Up Entry On-------------------");
                result = ENTRY_ON;
                return result;
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

        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_M15, 0, 0);
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_M15, 1, 0);
        // そもその判定の価値なしトレンド
        if((gmmaWidthUp == 2147483647 && gmmaWidthDown == 2147483647) || (gmmaWidthUp == 0 && gmmaWidthDown == 0))
        {
            return result;
        }

        // GMMA Index
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 1);
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        // TEMA 傾き
        double beforeTemaUp = indicator.GetTemaIndex(PERIOD_M15, 0, 1);
        double beforeTemaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 1);

        // RSI3
        double rsiShort = indicator.GetThreeLineRci(PERIOD_M15, 0, 1);
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 1);
        double rsiLong = indicator.GetThreeLineRci(PERIOD_M15, 2, 1);

        bool rsiInterrelationShort = (rsiShort <-80 && rsiMiddle < -70);
        bool rsiInterrelationLong = (rsiShort < -70 && rsiMiddle < -60);;

        if(gmmaIndexLong == -5 &&
           gmmaIndexShort == -5 && 
           regressionTilt < 0 && 
           (rsiInterrelationShort || rsiInterrelationLong) && 
           beforeTemaUp == 0 &&
           beforeTemaDown < 0)
        {
            double nowGmmaIndex = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);
            // TEMA 傾き
            double temaUp = indicator.GetTemaIndex(PERIOD_M15, 0, 0);
            double temaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 0);

            // トリガー条件
            if(nowGmmaIndex == -5 && temaUp == 0 && temaDown < 0)
            {
                Print ("-------------------GMMA Down Entry On-------------------");
                result = ENTRY_ON;
                return result;
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
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        // TEMA 傾き
        double beforeTemaUp = indicator.GetTemaIndex(PERIOD_M15, 0, 1);;
        double temaUp = indicator.GetTemaIndex(PERIOD_M15, 0, 0);
        double temaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 0);

        // RSI3
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 0);

        // 現在値
        double nowPrice = iClose(_symbol, PERIOD_M5 , 0);

        // iMA（1:string symbol,2:int timeframe,3:int period,4:int ma_shift,5:int ma_methid,6:int applied_price,7:int shift）。
        double ema4h = iMA(_symbol, PERIOD_H4, 15, 0, MODE_EMA, PRICE_CLOSE, 0);

        if(nowPrice < ema4h)
        {
            Print ("-------------------EMA Up Position Cut-------------------");
            result  = POSITION_CUT_ON;
        }
        else if(beforeTemaUp == 0 && temaUp == 0 && temaDown <= -0.05 && gmmaIndexShort <= 0 && rsiMiddle < 70)
        {
            Print ("-------------------TEMA GMMA INDEX Up Position Cut-------------------");
            result  = POSITION_CUT_ON;
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
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        // TEMA 傾き
        double beforeTemaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 1);
        double temaDown = indicator.GetTemaIndex(PERIOD_M15, 1, 0);

        // RSI3
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 0);

        // 現在値
        double nowPrice = iClose(_symbol,  PERIOD_M5 , 0);

        // iMA（1:string symbol,2:int timeframe,3:int period,4:int ma_shift,5:int ma_methid,6:int applied_price,7:int shift）。
        double ema4h = iMA(_symbol, PERIOD_H4, 15, 0, MODE_EMA, PRICE_CLOSE, 0);

        if(nowPrice > ema4h)
        {
            Print ("-------------------EMA Down Position Cut-------------------");
            result  = POSITION_CUT_ON;
        }
        else if(beforeTemaDown == 0 && temaDown == 0 && temaDown >= 0.05 &&  gmmaIndexShort >= 0 && rsiMiddle > -70)
        {
            Print ("-------------------TEMA GMMA INDEX Up Position Cut-------------------");
            result  = POSITION_CUT_ON;
        }

        return result;
    }

