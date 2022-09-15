//+------------------------------------------------------------------+
//|                                               IndicatorLogic.mqh |
//| IndicatorLogic v0.0.1                     Copyright 2022, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

// 取引数調整クラス
#property copyright "Copyright 2022,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "0.01"
#property strict

#include <Defines/Defines.mqh>

class IndicatorLogic{
    private:
    string _symbol;

    public:
    //------------------------------------------------------------------
    // コンストラクタ
    IndicatorLogic();

    //------------------------------------------------------------------
    // デストラクタ
    ~IndicatorLogic();

    int GetBodyPriceType(int timeSpan);

    double GetBodyPrice(int timeSpan, int shift);

    double GetMa(int timeSpan, int maSpan, int mode, int priceType, int shift);

    double GetEmaWidth(int timeSpan, int shift, int emaUnder, int emaUpper);

    double GetTema(int timeSpan, int mode, int shift);

    double GetTemaIndex(int timeSpan, int mode, int shift);

    double GetGmmaIndex(int timeSpan, int mode, int shift);

    double GetGmmaWidth(int timeSpan, int mode, int shift);

    double GetThreeLineRci(int timeSpan, int mode, int shift);

    double GetROC3(int timeSpan, int mode, int shift);

    double GetBbSqueeze(int timeSpan, int mode, int shift);

    double GetGmmaRegressionLine(int timeSpan, int term, int mode, double &regressionTilt);
};

    //------------------------------------------------------------------
    // コンストラクタ
    IndicatorLogic::IndicatorLogic()
    {
        _symbol = Symbol();
    }

    //------------------------------------------------------------------
    // デストラクタ
    IndicatorLogic::~IndicatorLogic()
    {
    }

    /// <summary>
    /// 現在の足の陽線陰線を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <returns>現在の日足の陽線陰線タイプ</returns>
    int IndicatorLogic::GetBodyPriceType(int timeSpan)
    {
        int result = NON_STICK;

        double open = iOpen(_symbol, timeSpan, 0);
        double close = iClose(_symbol, timeSpan, 0);

        if(open > close)
        {
            result = MINUS_STICK;
        }
        else if(open < close)
        {
            result = PLUS_STICK;
        }

        return result;
    }

    /// <summary>
    /// 指定時間のローソク足本体の幅を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>ローソク足本体の幅</returns>
    double IndicatorLogic::GetBodyPrice(int timeSpan, int shift)
    {
        double result = 0;

        double open = iOpen(_symbol, timeSpan, shift);
        double close = iClose(_symbol, timeSpan, shift);

        result = MathAbs(open - close);
        return result;
    }

    /// <summary>
    /// MA値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="maSpan">MAの期間</param>
    /// <param name="mode">使用する移動平均モード
    /// MODE_SMA MODE_EMA MODE_SMMA MODE_LWMA
    /// https://yukifx.web.fc2.com/sub/reference/02_stdconstans/indicator/indicator_smoothing.html
    /// </param>
    ///<param name="priceType">使用する価格定数
    /// PRICE_CLOSE PRICE_OPEN PRICE_HIGH PRICE_LOW PRICE_MEDIAN PRICE_TYPICAL PRICE_WEIGHTED
    /// https://yukifx.web.fc2.com/sub/reference/02_stdconstans/indicator/indicator_price.html
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>MA値</returns>
    double IndicatorLogic::GetMa(int timeSpan, int maSpan, int mode, int priceType, int shift)
    {
        double result = iMA(_symbol, timeSpan , maSpan, 0, mode, priceType, shift);
        return result;
    }

    /// <summary>
    /// ボリンジャーバンド値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="bandSpan">ボリンジャーバンドの期間</param>
    /// <param name="deviation">取得するシグマ値</param>
    /// <param name="mode">使用する価格定数
    /// PRICE_CLOSE PRICE_OPEN PRICE_HIGH PRICE_LOW PRICE_MEDIAN PRICE_TYPICAL PRICE_WEIGHTED
    /// https://yukifx.web.fc2.com/sub/reference/02_stdconstans/indicator/indicator_price.html
    /// </param>
    /// <param name="lineIndex">取得する
    /// MODE_MAIN(ベースライン) MODE_UPPER(上のライン) MODE_LOWER(下のライン)
    /// https://yukifx.web.fc2.com/sub/reference/02_stdconstans/indicator/indicator_indicatorline.html#anchor_band
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>ボリンジャーバンド値</returns>
    double IndicatorLogic::GetBands(int timeSpan, int bandSpan, int deviation, int mode, int lineIndex, int shift)
    {
        double result = iBands(_symbol, timeSpan , bandSpan, deviation, 0, mode, lineIndex, shift);
        return result;
    }
    

    /// <summary>
    /// EMA値の幅を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <param name="emaUnder">幅の下時間軸</param>
    /// <param name="emaUpper">幅の上時間軸</param>
    /// <returns>EMA値の幅</returns>
    double IndicatorLogic::GetEmaWidth(int timeSpan, int shift, int emaUnder, int emaUpper)
    {
        double result = 0;

        double underEma = GetMa(timeSpan, emaUnder, MODE_EMA, PRICE_CLOSE, shift);
        double upperEma = GetMa(timeSpan, emaUpper, MODE_EMA, PRICE_CLOSE, shift);

        result = MathAbs(underEma - upperEma);
        return result;
    }

    /// <summary>
    /// TEMAのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値
    /// 0:TemaUp 1:TemaDown
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetTema(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"TEMA",mode,shift);
        return result;
    }

    /// <summary>
    /// TEMA GMMA Indexのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値
    /// 0:TemaIndexUp 1:TemaIndexDown
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetTemaIndex(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"TemaCumulative",mode,shift);
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
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetGmmaIndex(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"GMMAIndex",mode,shift);
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
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetGmmaWidth(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"GMMAWidth",mode,shift);
        return result;
    }

    /// <summary>
    /// 3ラインRCIのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値</param>
    /// 0:RCI9 1:RCI26 2:RCI52　3:RCI Ave
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetThreeLineRci(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"RCI_3Line_v130",mode,shift);
        return result;
    }

    /// <summary>
    /// KeysROC3のインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値</param>
    /// 0:ROC 1:シグナル
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetROC3(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"keys_ROC3",mode,shift);
        return result;
    }

    /// <summary>
    /// BbSqueezeWAlertNmcのインジケーター値を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="mode">取得するインジケーター値</param>
    /// 0:BbSqueeze Up 1:BbSqueeze Down 2:BbSqueeze NonTrend 3:BbSqueeze Trend
    /// </param>
    /// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetBbSqueeze(int timeSpan, int mode, int shift)
    {
        double result = iCustom(_symbol,timeSpan,"bbsqueeze w Alert nmc",mode,shift);
        return result;
    }

    /// <summary>
    ///　GMMA Width 回帰直線を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <param name="term">傾きにを計算する期間(ローソク足の本数)</param>
    /// <param name="term">傾きにを計算するGMMA Widthの値(GMMA Widthのパラメーター)</param>
    /// <param name="regressionTilt">傾きを保持するout変数</param>
    /// <returns>切片</returns>
    double IndicatorLogic::GetGmmaRegressionLine(int timeSpan, int term, int mode, double &regressionTilt)
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
            double indicatorValue = GetGmmaWidth(timeSpan, mode, mqlIndex);
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

