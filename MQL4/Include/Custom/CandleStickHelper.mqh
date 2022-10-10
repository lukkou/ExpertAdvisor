//+------------------------------------------------------------------+
//|                                                 CoutomCommon.mq4 |
//| CandleStickHelper v1.0.0                  Copyright 2017, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

// ローソク足確認補助クラス
#property copyright "Copyright 2017,  lukkou"
#property link    "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Defines/Defines.mqh>

class CandleStickHelper{
    private:
    string _symbol;

    public:
    //------------------------------------------------------------------
    // コンストラクタ
    CandleStickHelper();

    //------------------------------------------------------------------
    // デストラクタ
    ~CandleStickHelper();

    //------------------------------------------------------------------
    // 現在の足の陽線陰線を取得
    int GetBodyPriceType(int timeSpan);

    //------------------------------------------------------------------
    // 指定時間のローソク足本体の幅を取得
    double GetBodyPrice(int timeSpan, int shift);

    //------------------------------------------------------------------
    // ローソク足が陽線か陰線かチェックする
    int CandleBodyStyle(int time,int shift);

    //------------------------------------------------------------------
    // ローソク足の上ひげの長さを取得
    double GetUpBeardPrice(int time,int shift);

    //------------------------------------------------------------------
    // ローソク足の下ひげの長さを取得
    double GetDownBeardPrice(int time,int shift);

    //------------------------------------------------------------------
    // ローソク足の中間値を取得
    double GetBodyMiddlePrice(int time,int shift);

    // 今足から見て -3 -2 -1足の高値が切り上げているかの判定
    bool IsHighRoundingUp(int time);

    // 今足から見て -3 -2 -1足の安値が切り下げているかの判定
    bool IsLowRoundingDown(int time);
};


    //------------------------------------------------------------------
    // コンストラクタ
    CandleStickHelper::CandleStickHelper()
    {
        _symbol = Symbol();
    }

    //------------------------------------------------------------------
    // デストラクタ
    CandleStickHelper::~CandleStickHelper()
    {
    }

//+------------------------------------------------------------------+
//| Public function　area                                            |
//+------------------------------------------------------------------+

    /// <summary>
    /// 現在の足の陽線陰線を取得
    /// <summary>
    /// <param name="timeSpan">取得する時間軸</param>
    /// <returns>現在の日足の陽線陰線タイプ</returns>
    int CandleStickHelper::GetBodyPriceType(int timeSpan)
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
    double CandleStickHelper::GetBodyPrice(int timeSpan, int shift)
    {
        double result = 0;

        double open = iOpen(_symbol, timeSpan, shift);
        double close = iClose(_symbol, timeSpan, shift);

        result = MathAbs(open - close);
        return result;
    }

    //------------------------------------------------------------------
    // ローソク足が陽線か陰線かチェックする
    ///param name="time":取得時間
    ///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
    /// Return   0 = 星 1 = 陽線 -1 = 陰線
    int CandleStickHelper::CandleBodyStyle(int time,int shift){
        int result = STAR_CANDLE_STICK;

        double open = iOpen(_symbol, time, shift);
        double close = iClose(_symbol, time, shift);

        if(open < close)
        {
            result = WHITE_CANDLE_STICK;
        }
        else if(open > close)
        {
            result = BLACK_CANDLE_STICK;
        }

        return result;
    }

    //------------------------------------------------------------------
    // ローソク足の上ひげの長さを取得
    ///param name="time":取得時間
    ///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
    /// Return   結果
    double CandleStickHelper::GetUpBeardPrice(int time,int shift)
    {
        double result = 0;

        double upPrice = 0;
        double open = iOpen(NULL,time,shift);
        double high = iHigh(NULL,time,shift);
        double close = iClose(NULL,time,shift);

        if(open < close)
        {
            upPrice = close;
        }
        else
        {
            upPrice = open;
        }

        result = high - upPrice;
        return result;
    }

    //------------------------------------------------------------------
    // ローソク足の下ひげの長さを取得
    ///param name="time":取得時間
    ///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
    /// Return   結果
    double CandleStickHelper::GetDownBeardPrice(int time,int shift)
    {
        double result = 0;

        double downPrice = 0;
        double open = iOpen(NULL,time,shift);
        double low = iLow(NULL,time,shift);
        double close = iClose(NULL,time,shift);

        if(open > close)
        {
            downPrice = close;
        }
        else
        {
            downPrice = open;
        }

        result = downPrice - low;
        return result;
    }

    //------------------------------------------------------------------
    // ローソク足の中間値を取得
    ///param name="time":取得時間
    ///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
    /// Return   結果
    double CandleStickHelper::GetBodyMiddlePrice(int time,int shift)
    {
        double open = iOpen(NULL,time,shift);
        double close = iClose(NULL,time,shift);

        double result = (open + close) / 2;
        return result;
    }

    //------------------------------------------------------------------
    // -3 -2 -1足の高値が切り上げているか
    ///param name="time":取得時間
    /// Return 結果
    bool CandleStickHelper::IsHighRoundingUp(int time)
    {
        bool result = false;

        double oneHigh = iHigh(_symbol, time, 1);
        double towHigh = iHigh(_symbol, time, 2);
        double threeHigh = iHigh(_symbol, time, 3);

        if(threeHigh < towHigh && towHigh < oneHigh)
        {
            result = true;
        }

        // 終値切り上げかつ各足の陽線(-3・-2・-1足陰線かつ-3 End > -2 End >-1 End)
        double oneClose = iClose(_symbol, time, 1);
        double towClose = iClose(_symbol, time, 2);
        double threeClose = iClose(_symbol, time, 3);

        int oneCandleStick = CandleBodyStyle(time, 1);
        int twoCandleStick = CandleBodyStyle(time, 2);
        int threeCandleStick = CandleBodyStyle(time, 3);

        if(threeClose < towClose && towClose < oneClose && threeCandleStick == WHITE_CANDLE_STICK && twoCandleStick == WHITE_CANDLE_STICK && oneCandleStick == WHITE_CANDLE_STICK)
        {
            // このreturnが糞かどうかを問うななの・。・
            result = true;
            return result;
        }

        return result;
    }

    //------------------------------------------------------------------
    // -3 -2 -1足の安値が切り下げているか
    ///param name="time":取得時間
    /// Return 結果
    bool CandleStickHelper::IsLowRoundingDown(int time)
    {
        bool result = false;

        // 安値の取得(-3 High > -2 High > -1 High)
        double oneLow = iLow(_symbol, time, 1);
        double towLow = iLow(_symbol, time, 2);
        double threeLow = iLow(_symbol, time, 3);

        if((threeLow > towLow && towLow > oneLow) || )
        {
            // このreturnが糞かどうかを問うななの・。・
            result = true;
            return result;
        }

        // 終値切り下げかつ各足の陰線(-3・-2・-1足陰線かつ-3 End > -2 End >-1 End)
        double oneClose = iClose(_symbol, time, 1);
        double towClose = iClose(_symbol, time, 2);
        double threeClose = iClose(_symbol, time, 3);

        int oneCandleStick = CandleBodyStyle(time, 1);
        int twoCandleStick = CandleBodyStyle(time, 2);
        int threeCandleStick = CandleBodyStyle(time, 3);

        if(threeClose > towClose && towClose > oneClose && threeCandleStick == BLACK_CANDLE_STICK && twoCandleStick == BLACK_CANDLE_STICK && oneCandleStick == BLACK_CANDLE_STICK)
        {
            // このreturnが糞かどうかを問うななの・。・
            result = true;
            return result;
        }

        return result;
    }