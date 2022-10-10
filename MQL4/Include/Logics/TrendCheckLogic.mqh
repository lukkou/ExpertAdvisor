//+------------------------------------------------------------------+
//|                                              TrendCheckLogic.mqh |
//| TrendCheckLogic v0.0.1                    Copyright 2022, Lukkou |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "0.01"
#property strict

#include <Logics/IndicatorLogic.mqh>
#include <Custom/CandleStickHelper.mqh>
#include <Defines/Defines.mqh>

class TrendCheckLogic
{
    private:
    IndicatorLogic indicator;
    CandleStickHelper candleStick;
    string _symbol;

    public:
        //------------------------------------------------------------------
        // コンストラクタ
        TrendCheckLogic();
        
        //------------------------------------------------------------------
        // デストラクタ
        ~TrendCheckLogic();

        int GetDayTrendStatus();

        int GetLongTrendStatus(int dayTrend);

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
        indicator = IndicatorLogic();
        candleStick = CandleStickHelper();
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
        double ema30 = indicator.GetMa(PERIOD_D1, 30, MODE_EMA, PRICE_CLOSE, 0);

        if(gmmaDayIndexLong == 5 && (gmmaDayIndexShort > 0 || ema30 < nowPrice))
        {
            double tmeaUp = indicator.GetTemaIndex(PERIOD_D1, 0, 0);
            double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_D1, 0, 0);
            
            if(tmeaUp >= 0.1 && gmmaWidthUp > 0)
            {
                result = DAY_TREND_PLUS;
            }
        }
        else if(gmmaDayIndexLong == -5 && (gmmaDayIndexShort < 0 || ema30 > nowPrice))
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
    /// <param name="dayTrend">日足トレンド</param>
    /// <returns>上トレンド:1 下トレンド:-1 無トレンド:0 エラー:2147483647</returns>
    int TrendCheckLogic::GetLongTrendStatus(int dayTrend)
    {
        int result = LONG_TREND_NON;
        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_H4, 0, 0);
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_H4, 1, 0);
        double gmmaWidthLong = indicator.GetGmmaWidth(PERIOD_H4, 3, 0);

        // そもその判定の価値なしトレンド
        if(gmmaWidthUp == EMPTY_VALUE || gmmaWidthDown == EMPTY_VALUE || (gmmaWidthUp == 0 && gmmaWidthDown == 0))
        {
             Print ("-------------------Not 4h Trend-------------------");
            return result;
        }

        // エラー数値の場合
        if (gmmaWidthLong == EMPTY_VALUE)
        {
            return result;
        }

        // Print("GMMA UP  ：" + DoubleToString(gmmaWidthUp));
        // Print("GMMA LONG：" + DoubleToString(gmmaWidthLong));

        // BB Squeezeのトレンド判定(BB Squeezeのトレンドがある場合にのみ上下判定を実施)
        double bbSqueezeTrend = indicator.GetBbSqueeze(PERIOD_H4, 3, 0);
        double onePreviousBbSqueezeTrend = indicator.GetBbSqueeze(PERIOD_H4, 3, 1);
        if(bbSqueezeTrend == 0 && onePreviousBbSqueezeTrend == 0)
        {
            // GMMA Width 傾き
            double regressionTiltLogn = 0;
            double gmmaRegressionLineLogn = indicator.GetGmmaRegressionLine(PERIOD_H4, 6, 3, regressionTiltLogn);
            // Print("傾き     ：" + DoubleToString(regressionTiltLogn));
            // Print("切片     ：" + DoubleToString(gmmaRegressionLineLogn));

            if(dayTrend == DAY_TREND_PLUS && gmmaWidthUp > 0 && (regressionTiltLogn > 0 || gmmaWidthLong > 0))
            {
                double roc = indicator.GetROC3(PERIOD_H4, 0, 0);
                double rocSignal = indicator.GetROC3(PERIOD_H4, 1, 0);
                double bbSqueezeUp = indicator.GetBbSqueeze(PERIOD_H4, 0, 0);
                // Print("ROC     ：" + DoubleToString(roc));
                // Print("BBS     ：" + DoubleToString(bbSqueezeUp));
                // Print("BBS Line：" + DoubleToString(bbSqueezeTrend));

                if(roc > 0.5 && roc > rocSignal && bbSqueezeUp > 0)
                {
                    Print ("-------------------4h Up Trend On-------------------");
                    result = LONG_TREND_PLUS;
                }
            }
            else if(dayTrend == DAY_TREND_MINUS && gmmaWidthDown < 0 && (regressionTiltLogn < 0 || gmmaWidthLong < 0))
            {
                double roc = indicator.GetROC3(PERIOD_H4, 0, 0);
                double rocSignal = indicator.GetROC3(PERIOD_H4, 1, 0);
                double bbSqueezeDown = indicator.GetBbSqueeze(PERIOD_H4, 1, 0);

                if(roc < -0.5 && roc < rocSignal && bbSqueezeDown < 0)
                {
                    Print ("-------------------4h Down Trend On-------------------");
                    result = LONG_TREND_MINUS;
                }
            }
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

        // そもその判定の価値なしトレンド
        if(gmmaWidthUp == EMPTY_VALUE || gmmaWidthUp == 0)
        {
             Print ("-------------------Not UP 15m Trend-------------------");
            return result;
        }

        // 高値切り下げならエントリ無し
        bool lowRoundingDown = candleStick.IsLowRoundingDown(PERIOD_M15);
        if(lowRoundingDown)
        {
            return result;
        }

        // Now Price
        double nowPrice = iClose(_symbol, PERIOD_M15, 0);

        // EMA 20
        double ema20 = indicator.GetMa(PERIOD_M15, 20, MODE_EMA, PRICE_CLOSE, 0);

        // GMMA Index Long
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 0);

        if(nowPrice > ema20 && gmmaIndexLong == 5)
        {
            // GMMA Width Long
            double gmmaWidthLong = indicator.GetGmmaWidth(PERIOD_M15, 3, 0);

            if(gmmaWidthLong > 0 && gmmaWidthUp > 0)
            {
                Print ("-------------------Bands Check-------------------");
                // 現在の2σボリンジャーバンド
                double now2Bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_UPPER, 0);
                // -1足の2σボリンジャーバンド
                double onePrevious2Bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_UPPER, 1);
                // -2足の2σボリンジャーバンド
                double towPrevious2Bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_UPPER, 2);
                // -1足の高値
                double onePreviousHighPrice = iHigh(_symbol, PERIOD_M15, 1);
                // -2足の高値
                double towPreviousHighPrice = iHigh(_symbol, PERIOD_M15, 2);

                if(now2Bands > nowPrice && onePrevious2Bands > onePreviousHighPrice && towPrevious2Bands > towPreviousHighPrice)
                {
                    Print ("-------------------BB Squeeze Check-------------------");
                    // BBスクイーズのUP・トレンド
                    double nowSqueezeUp = indicator.GetBbSqueeze(PERIOD_M15, 0, 0);
                    double nowPreviousSqueezeTrend = indicator.GetBbSqueeze(PERIOD_M15, 3, 0);
                    double onePreviousSqueezeTrend = indicator.GetBbSqueeze(PERIOD_M15, 3, 1);

                    if(nowSqueezeUp > 0 && nowPreviousSqueezeTrend == 0 && onePreviousSqueezeTrend == 0)
                    {
                        Print ("-------------------Up Entry On-------------------");
                        result = ENTRY_ON;
                    }
                }
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
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_M15, 1, 0);

        // そもその判定の価値なしトレンド
        if(gmmaWidthDown == EMPTY_VALUE || gmmaWidthDown == 0)
        {
            Print ("-------------------Not Down 15m Trend-------------------");
            return result;
        }

        // 安値切り上げならエントリ無し
        bool highRoundingUp = candleStick.IsHighRoundingUp(PERIOD_M15);
        if(highRoundingUp)
        {
            return result;
        }

        // Now Price
        double nowPrice = iClose(_symbol, PERIOD_M15, 0);

        // EMA 20
        double ema20 = indicator.GetMa(PERIOD_M15, 20, MODE_EMA, PRICE_CLOSE, 0);

        // GMMA Index Long
        double gmmaIndexLong = indicator.GetGmmaIndex(PERIOD_M15, 1, 0);

        if(nowPrice < ema20 && gmmaIndexLong == -5)
        {
            // GMMA Width Long
            double gmmaWidthLong = indicator.GetGmmaWidth(PERIOD_M15, 3, 0);
            if(gmmaWidthLong < 0 && gmmaWidthDown < 0)
            {
                Print ("-------------------Bands Check-------------------");
                // 現在の2σボリンジャーバンド
                double now2Bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_LOWER, 0);
                // -1足の2σボリンジャーバンド
                double onePrevious2Bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_LOWER, 1);
                // -2足の2σボリンジャーバンド
                double towPrevious2Bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_LOWER, 2);
                // -1足の安値
                double onePreviousLowPrice = iLow(_symbol, PERIOD_M15, 1);
                // -2足の安値
                double towPreviousLowPrice = iLow(_symbol, PERIOD_M15, 2);

                if(now2Bands < nowPrice && onePrevious2Bands < onePreviousLowPrice && towPrevious2Bands < towPreviousLowPrice)
                {
                    Print ("-------------------BB Squeeze Check-------------------");
                    // BBスクイーズのUP・トレンド
                    double nowSqueezeDown = indicator.GetBbSqueeze(PERIOD_M15, 1, 0);
                    double nowPreviousSqueezeTrend = indicator.GetBbSqueeze(PERIOD_M15, 3, 0);
                    double onePreviousSqueezeTrend = indicator.GetBbSqueeze(PERIOD_M15, 3, 1);

                    if(nowSqueezeDown < 0 && nowPreviousSqueezeTrend == 0 && onePreviousSqueezeTrend == 0)
                    {
                        Print ("-------------------Down Entry On-------------------");
                        result = ENTRY_ON;
                    }
                }
            }
        }

        return result;
    }