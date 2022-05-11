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
    private:
    string _symbol;

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

    double GetGmmaRegressionLine(double timeSpan,double term,double &regressionTilt);

    bool ThreeRedArmies(int timeSpan,int shift);

    bool ThreeBlackArmies(int timeSpan,int shift);
};

    //------------------------------------------------------------------
    // コンストラクタ
    IndicatorLogic::IndicatorLogic()
    {
        _symbol = Symbol()
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
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetTema(int timeSpan,int mode,int shift)
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
    double IndicatorLogic::GetGmmaIndex(int timeSpan,int mode,int shift)
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
    double IndicatorLogic::GetGmmaWidth(int timeSpan,int mode,int shift)
    {
        double result = iCustom(_symbol,timeSpan,"GMMAWidth",mode,shift);
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
    /// <returns>TEMAのインジケーター値</returns>
    double IndicatorLogic::GetThreeLineRci(int timeSpan,int mode,int shift)
    {
        double result = iCustom(_symbol,timeSpan,"RCI_3Line_v130",mode,shift);
        return result;
    }

    /// <summary>
    /// 現在の足が赤三兵になってるかを取得
    /// <summary>
    /// <param name="shift">判定対象のTickTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>赤三兵判定結果</returns>
    bool IndicatorLogic::ThreeRedArmies(int timeSpan,int shift)
    {
        bool result = false;

        double nowOpenPrice = iOpen(_symbol, timeSpan , 0 + shift);
        double before1OpenPrice = iOpen(_symbol, timeSpan , 1 + shift);
        double before2OpenPrice = iOpen(_symbol, timeSpan , 2 + shift);

        double nowClosePrice = iClose(_symbol, timeSpan , 0 + shift);
        double before1ClosePrice = iClose(_symbol, timeSpan , 1 + shift);
        double before2ClosePrice = iClose(_symbol, timeSpan , 2 + shift);

        double nowEma = iMA(_symbol, timeSpan, 3, 0, MODE_EMA, PRICE_CLOSE, 0 + shift);
        double before1Ema = iMA(_symbol,timeSpan,3, 0, MODE_EMA, PRICE_CLOSE, 1 + shift);
        double before2Ema = iMA(_symbol,timeSpan,3, 0, MODE_EMA, PRICE_CLOSE, 2 + shift);

        // それぞれの足が陽線かのチェック
        bool nowRed = nowClosePrice > nowOpenPrice;
        bool before1Red = before1ClosePrice > before1OpenPrice;
        bool before2Red = before2ClosePrice > before2OpenPrice;

        // それぞれの終値がEMAより高値かのチェック
        bool nowUp = nowClosePrice > nowEma;
        bool before1Up = before1ClosePrice > before1Ema;
        bool before2Up = before2ClosePrice > before2Ema;

        // それぞれの足の終わり値が高値を更新しているかのチェック
        bool updateNow = nowClosePrice > before1ClosePrice;
        bool updateBefore = before1ClosePrice > before2ClosePrice;


        if(nowRed && before1Red && before2Red && updateNow && updateBefore && nowUp && before1Up && before2Up)
        {
            result = true;
        }

        return result;
    }

    /// <summary>
    /// 現在の足が黒三兵になってるかを取得
    /// <summary>
    /// <param name="shift">判定対象のTickTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
    /// <returns>黒三兵判定結果</returns>
    bool IndicatorLogic::ThreeBlackArmies(int timeSpan,int shift)
    {
        bool result = false;

        double nowOpenPrice = iOpen(_symbol, timeSpan , 0 + shift);
        double before1OpenPrice = iOpen(_symbol, timeSpan , 1 + shift);
        double before2OpenPrice = iOpen(_symbol, timeSpan , 2 + shift);

        double nowClosePrice = iClose(_symbol, timeSpan , 0 + shift);
        double before1ClosePrice = iClose(_symbol, timeSpan , 1 + shift);
        double before2ClosePrice = iClose(_symbol, timeSpan , 2 + shift);

        double nowEma = iMA(_symbol, timeSpan, 3, 0, MODE_EMA, PRICE_CLOSE, 0 + shift);
        double before1Ema = iMA(_symbol,timeSpan,3, 0, MODE_EMA, PRICE_CLOSE, 1 + shift);
        double before2Ema = iMA(_symbol,timeSpan,3, 0, MODE_EMA, PRICE_CLOSE, 2 + shift);

        // それぞれの足が陰線かのチェック
        bool nowBlack = nowClosePrice < nowOpenPrice;
        bool before1Black = before1ClosePrice < before1OpenPrice;
        bool before2Black = before2ClosePrice < before2OpenPrice;

        // それぞれの終値がEMAより安値かのチェック
        bool nowUp = nowClosePrice < nowEma;
        bool before1Up = before1ClosePrice < before1Ema;
        bool before2Up = before2ClosePrice < before2Ema;

        // それぞれの足の終わり値が安値を更新しているかのチェック
        bool updateNow = nowClosePrice < before1ClosePrice;
        bool updateBefore = before1ClosePrice < before2ClosePrice;


        if(nowBlack && before1Black && before2Black && updateNow && updateBefore && nowUp && before1Up && before2Up)
        {
            result = true;
        }

        return result;
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