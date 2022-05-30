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
        double ema30 = indicator.GetMa(PERIOD_D1, 30, MODE_EMA, PRICE_CLOSE, 0);

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
    /// <param name="dayTrend">日足トレンド</param>
    /// <returns>上トレンド:1 下トレンド:-1 無トレンド:0 エラー:2147483647</returns>
    int TrendCheckLogic::GetLongTrendStatus(int dayTrend)
    {
        int result = LONG_TREND_NON;
        // GMMA Width
        double gmmaWidthLong = indicator.GetGmmaWidth(PERIOD_H4, 0, 3);
        // エラー数値の場合
        if (gmmaWidthLong == EMPTY_VALUE)
        {
            return result;
        }

        // GMMA Width 傾き
        double regressionTiltShort = 0;
        double gmmaRegressionLineShort = indicator.GetGmmaRegressionLine(PERIOD_H4, 6, 2, regressionTilt);
        double regressionTiltLogn = 0;
        double gmmaRegressionLineLogn = indicator.GetGmmaRegressionLine(PERIOD_H4, 6, 3, regressionTilt);

        if(dayTrend == DAY_TREND_PLUS && regressionTiltShort > 0 && (regressionTiltLogn > 0 || gmmaWidthLong > 0))
        {
            double roc = indicator.GetROC3(PERIOD_H4, 0, 0);
            double bbSqueezeUp = indicator.GetBbSqueeze(PERIOD_H4, 0, 0);
            double bbSqueezeTrend = indicator.GetBbSqueeze(PERIOD_H4, 0, 3);

            if(roc > 0.5 && bbSqueezeUp > 0 && bbSqueezeTrend == 0)
            {
                result = LONG_TREND_PLUS;
            }
        }
        else if(dayTrend == DAY_TREND_MINUS && regressionTiltShort < 0 && (regressionTiltLogn < 0 || gmmaWidthLong < 0))
        {
            double roc = indicator.GetROC3(PERIOD_H4, 0, 0);
            double bbSqueezeDown = indicator.GetBbSqueeze(PERIOD_H4, 0, 0);
            double bbSqueezeTrend = indicator.GetBbSqueeze(PERIOD_H4, 0, 3);

            if(roc < 0.5 && bbSqueezeDown < 0 && bbSqueezeTrend == 0)
            {
                result = LONG_TREND_MINUS;
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
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_M15, 1, 0);
        // そもその判定の価値なしトレンド
        if((gmmaWidthUp == EMPTY_VALUE || gmmaWidthDown == EMPTY_VALUE) || (gmmaWidthUp == 0 && gmmaWidthDown == 0))
        {
            return result;
        }

        double rciAve = indicator.GetThreeLineRci(PERIOD_M15, 3, 0);
        double gmmaWidthLong = indicator.GetGmmaWidth(PERIOD_M15, 3, 0);

        if(rciAve > 55 && gmmaWidthUp > 0 && gmmaWidthLong > 0)
        {
            Print ("-------------------Up Entry On-------------------");
            result = ENTRY_ON;
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
        if((gmmaWidthUp == EMPTY_VALUE || gmmaWidthDown == EMPTY_VALUE) || (gmmaWidthUp == 0 && gmmaWidthDown == 0))
        {
            return result;
        }

        double rciAve = indicator.GetThreeLineRci(PERIOD_M15, 3, 0);
        double gmmaWidthLong = indicator.GetGmmaWidth(PERIOD_M15, 3, 0);

        if(rciAve < -55 && gmmaWidthDown < 0 && gmmaWidthLong < 0)
        {
            Print ("-------------------Down Entry On-------------------");
            result = ENTRY_ON;
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
        
        int bodyPriceType = indicator.GetBodyPriceType(PERIOD_M15);
        if(bodyPriceType == MINUS_STICK)
        {
            double bodyPrice = indicator.GetBodyPrice(PERIOD_M15, 0);
            double emaWidth = indicator.GetEmaWidth(PERIOD_M15, 0, 30, 60);

            if(bodyPrice > emaWidth)
            {
                Print ("-------------------BodyPrice Position Cut-------------------");
                result  = POSITION_CUT_ON;
            }
        }

        double rci3Ave = indicator.GetThreeLineRci(PERIOD_M15, 3, 0);
        if(rci3Ave < 45)
        {
            Print ("-------------------RCI3Ave Position Cut-------------------");
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

        int bodyPriceType = indicator.GetBodyPriceType(PERIOD_M15);
        if(bodyPriceType == PLUS_STICK)
        {
            double bodyPrice = indicator.GetBodyPrice(PERIOD_M15, 0);
            double emaWidth = indicator.GetEmaWidth(PERIOD_M15, 0, 30, 60);

            if(bodyPrice > emaWidth)
            {
                Print ("-------------------BodyPrice Position Cut-------------------");
                result  = POSITION_CUT_ON;
            }
        }

        double rci3Ave = indicator.GetThreeLineRci(PERIOD_M15, 3, 0);
        if(rci3Ave > -45)
        {
            Print ("-------------------RCI3Ave Position Cut-------------------");
            result  = POSITION_CUT_ON;
        }

        return result;
    }

