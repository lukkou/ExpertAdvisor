//+------------------------------------------------------------------+
//|                                               IndicatorLogic.mqh |
//| TradeQuantityHelper v1.0.0                Copyright 2022, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

// 取引数調整クラス
#property copyright "Copyright 2022,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

class IndicatorLogic{
    public:
    //------------------------------------------------------------------
    // コンストラクタ
    IndicatorLogic();

    //------------------------------------------------------------------
    // デストラクタ
    ~IndicatorLogic();

    double GetTema(int timeSpan,int mode,int shift);

    double GetGmmaIndex(int timeSpan,int mode,int shift);

    double GetGmmaWidth(int timeSpan,int mode,int shift);

    double GetThreeLineRci(int timeSpan,int mode,int shift);

    datetime GetCileTime(int cileTime);

    double GetGmmaRegressionLine(double timeSpan,double term,double &regressionTilt);
};

    //------------------------------------------------------------------
    // コンストラクタ
    IndicatorLogic::IndicatorLogic()
    {
    }

    //------------------------------------------------------------------
    // デストラクタ
    IndicatorLogic::~IndicatorLogic()
    {
    }

    /// <summary>
    /// TEMAのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値
    /// 0:TemaUp 1:TemaDown
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値を取得</returns>
    double IndicatorLogic::GetTema(int timeSpan,int mode,int shift)
    {
        double result = iCustom(Symbol(),timeSpan,"TemaCumulative",mode,shift);
        return result;
    }

    /// <summary>
    /// GMMAIndexのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値
    /// 0:ShortIndex 1:LongIndex
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値を取得</returns>
    double IndicatorLogic::GetGmmaIndex(int timeSpan,int mode,int shift)
    {
        double result = iCustom(Symbol(),timeSpan,"GMMAIndex",mode,shift);
        return result;
    }

    /// <summary>
    /// GMMAWidthのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値</param>
    /// 0:Up 1:Down 2:ShortWidth 3:LongWidth
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値を取得</returns>
    double IndicatorLogic::GetGmmaWidth(int timeSpan,int mode,int shift)
    {
        double result = iCustom(Symbol(),timeSpan,"GMMAWidth",mode,shift);
        return result;
    }

    /// <summary>
    /// 3ラインRCIのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値</param>
    /// 0:RCI9 1:RCI26 2:RCI52
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値を取得</returns>
    double IndicatorLogic::GetThreeLineRci(int timeSpan,int mode,int shift)
    {
        double result = iCustom(Symbol(),timeSpan,"RCI_3Line_v130",mode,shift);
        return result;
    }

    /// <summary>
    /// 現在時刻からの計算時間を取得
    /// <summary>
    ///param name="cileTime":計算する時間(3600:1時間後,-1800:30分前,86400:1日後)
    /// <returns>最小のEMA</returns>
    datetime IndicatorLogic::GetCileTime(int cileTime)
    {
        datetime tm = TimeLocal();
        return tm + cileTime;
    }

    /// <summary>
    ///　GMMA Width 回帰直線を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="term">傾きにを計算する期間(ローソク足の本数)</param>
    /// <param name="regressionTilt">傾きを保持するout変数</param>
    /// <returns>切片</returns>
    double IndicatorLogic::GetGmmaRegressionLine(double timeSpan,double term,double &regressionTilt)
    {
        double result = 0;
    
        int timeList[]; 
        ArrayResize(timeList, term);
        double valueList[];
        ArrayResize(valueList, term);
    
        int timeTotal = 0;
        double valueTotal = 0;
    
        double timeAverage = 0;
        double valueAverage = 0;
    
        int mqlIndex = term;
    
        for(int i = 1; i <= term; i++)
        {
            timeList[i - 1] = i;
            //ここでインジケーターの値を取得
            double indicatorValue = GetGmmaWidth(timeSpan,2,mqlIndex);
            indicatorValue = indicatorValue * 10;
            valueList[i - 1] = indicatorValue;
    
            //ついで合計値を計算
            timeTotal += i;
            valueTotal += indicatorValue;
            mqlIndex--;
        }
        //平均を計算
        timeAverage = timeTotal / term;
        valueAverage = valueTotal / term;
    
        double alphaOne = 0;
        double alphaTwo = 0;
    
        //最小二乗法でロスを計算
        for(int i = 1; i <= term; i++)
        {
            //timeDiff = (Xn - Xave)
            double timeDiff = timeAverage - timeList[i - 1];
    
            //valueDiff = (Yn - Yave)
            double valueDiff = valueAverage - valueList[i - 1];
    
            //Σ(Xn - Xave)(Yn - Yave)
            alphaOne = alphaOne + (timeDiff * valueDiff);
    
            //Σ(Xn - Xave)(Xn - Xave)
            alphaTwo = alphaTwo + (timeDiff * timeDiff);
        }
    
        //傾き計算
        double alpha = alphaOne / alphaTwo;
        regressionTilt = alpha;
    
        //切片計算
        double regressionSection = valueAverage - alpha * timeAverage;
        result = regressionSection;
    
        return result;
    }