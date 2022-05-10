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

    public:
        //------------------------------------------------------------------
        // コンストラクタ
        TrendCheckLogic();
        
        //------------------------------------------------------------------
        // デストラクタ
        ~TrendCheckLogic();

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
        indicator = IndicatorLogic();
    }

    //------------------------------------------------------------------
    // デストラクタ
    TrendCheckLogic::~TrendCheckLogic()
    {
    }

    /// <summary>
    /// 現在の4Hトレンドを取得
    /// <summary>
    /// <returns>上トレンド:1 下トレンド:-1 無トレンド:0 エラー:2147483647</returns>
    int TrendCheckLogic::GetLongTrendStatus()
    {
        int result = LONG_TREND_NON;

        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 1);
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 1);

        // エラー数値の場合
        if(gmmaWidthUp == 2147483647 || gmmaWidthDown == 2147483647)
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

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_H4, 6 ,regressionTilt);

        if (gmmaIndexLong == 5 && gmmaIndexShort == 5 && gmmaWidthUp > 0 && beforeTmmaUp > 0 && nowTmmaUp > 0)
        {
            result = LONG_TREND_PLUS;
        }
        else if(gmmaIndexLong == -5 && gmmaIndexShort == -5 && gmmaWidthDown < 0 && beforeTmmaDown < 0 && nowTmmaDown < 0)
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
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 1);
        double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 1);

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        // TEMA 傾き
        double temaUp = indicator.GetTema(PERIOD_M15, 0, 1);
        double temaDown = indicator.GetTema(PERIOD_M15, 1, 1);

        // RSI3 26
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 1);

        // RSI3 52
        double rsiLong = indicator.GetThreeLineRci(PERIOD_M15, 2, 1);

        if(gmmaIndexLong == 5 && gmmaIndexShort == 5 && regressionTilt > 0 && rsiMiddle >= 70 && rsiLong >= 50)
        {
            double nowGmmaIndex = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            // トリガー条件
            if(nowGmmaIndex == 5)
            {
                result = ENTRY_ON;
                return result;
            }
        }

        // 赤三兵フラグ
        bool redFlg = indicator.ThreeRedArmies(PERIOD_M15, 1);
        if(redFlg)
        {
            // 現在値
            double nowPrice = iClose(Symbol(), PERIOD_M5 , 0);
            // ボリンジャーバンド
            double nowBb = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
            if(nowPrice > nowBb)
            {
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

        // RSI3 26
        double rsiMiddle = indicator.GetThreeLineRci(PERIOD_M15, 1, 1);

        // RSI3 52
        double rsiLong = indicator.GetThreeLineRci(PERIOD_M15, 2, 1);

        if(gmmaIndexLong == -5 && gmmaIndexShort == -5 && regressionTilt < 0 && rsiMiddle <= -70 && rsiLong <= -50)
        {
            double nowGmmaIndex = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            // トリガー条件
            if(nowGmmaIndex == -5)
            {
                result = ENTRY_ON;
                return result;
            }
        }

        // 黒三兵フラグ
        bool blackFlg = indicator.ThreeRedArmies(PERIOD_M15, 1);
        if(redFlg)
        {
            // 現在値
            double nowPrice = iClose(Symbol(), PERIOD_M5 , 0);
            // ボリンジャーバンド
            double nowBb = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
            if(nowPrice > nowBb)
            {
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

        // 現在値
        double nowPrice = iClose(Symbol(), PERIOD_M5 , 0);

        // iMA（1:string symbol,2:int timeframe,3:int period,4:int ma_shift,5:int ma_methid,6:int applied_price,7:int shift）。
        double ema30 = iMA(Symbol(), PERIOD_M15, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
        
        // RSI 9
        double rsiShort = indicator.GetThreeLineRci(PERIOD_M15, 0, 0);

        if(nowPrice < ema30)
        {
            Print ("-------------------EMA Position Cut-------------------");
            result  = POSITION_CUT_ON;
        }
        else if(agoGmmaIndexShort > gmmaIndexShort - 1)
        {
            Print ("-------------------GMMA INDEX Position Cut-------------------");
            result  = POSITION_CUT_ON;
        }
        else if(rsiShort <= 0)
        {
            Print ("-------------------RSI Position Cut-------------------");
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

        // GMMA Width 傾き
        double regressionTilt = 0;
        double gmmaRegressionLine = indicator.GetGmmaRegressionLine(PERIOD_M15, 16 ,regressionTilt);

        if(regressionTilt > 0)
        {
            // 現在値
            double nowPrice = iClose(Symbol(),  PERIOD_M5 , 0);

            // iMA（1:string symbol,2:int timeframe,3:int period,4:int ma_shift,5:int ma_methid,6:int applied_price,7:int shift）。
            double ema30 = iMA(Symbol(), PERIOD_M15, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
            double gmmaIndexShort = indicator.GetGmmaIndex(PERIOD_M15, 0, 0);

            // RSI 9
            double rsiShort = indicator.GetThreeLineRci(PERIOD_M15, 0, 0);

            if(nowPrice > ema30)
            {
                Print ("-------------------EMA Position Cut-------------------");
                result  = POSITION_CUT_ON;
            }
            else if(agoGmmaIndexShort < gmmaIndexShort + 1)
            {
                Print ("-------------------GMMA INDEX Position Cut-------------------");
                result  = POSITION_CUT_ON;
            }
            else if(rsiShort >= 0)
            {
                Print ("-------------------RSI Position Cut-------------------");
                result  = POSITION_CUT_ON;
            }
        }

        return result;
    }

