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

class CandleStickHelper{
    public:
    //------------------------------------------------------------------
    // コンストラクタ
    CandleStickHelper();

    //------------------------------------------------------------------
    // デストラクタ
    ~CandleStickHelper();

    //------------------------------------------------------------------
    // ローソク足が陽線か陰線かチェックする
    bool IsCandleBodyStyle(int time,int shift);

    //------------------------------------------------------------------
    // ローソク足が星かチェックする
    bool IsCandleStickStar(int time,int shift);
};

    //------------------------------------------------------------------
    // コンストラクタ
    CandleStickHelper::CandleStickHelper(){
    }

    //------------------------------------------------------------------
    // デストラクタ
    CandleStickHelper::~CandleStickHelper(){
    }

    //------------------------------------------------------------------
    // ローソク足が陽線か陰線かチェックする
    ///param name="time":取得時間
    ///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
    /// Return   0 = 星 1 = 陽線 2 = 陰線
    int CandleStickHelper::IsCandleBodyStyle(int time,int shift){
        int result = 0;

        double open = iOpen(NULL,time,shift);
        double close = iClose(NULL,time,shift);

        if(open > close){
            result = 1
        }else if(open < close){
            result = 2
        }

        return result;
    }

    //------------------------------------------------------------------
    // ローソク足が星かチェックする
    ///param name="time":取得時間
    ///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
    /// Return   結果
    bool CandleStickHelper::IsCandleStickStar(int time,int shift){
        bool result = false;

        double open = iOpen(NULL,time,shift);
        double high = iHigh(NULL,time,shift);
        double low = iLow(NULL,time,shift);
        double close = iClose(NULL,time,shift);

        if(open > close){
            //陽線の場合
            double body = open - close;
            double upBeard = high - open;
            double downBeard = close - low;

            if(body <= upBeard){
                result = true;
            }else if(body <= downBeard){
                result = true;
            }

        }else if(open < close){
            //陰線の場合
            double body = close - open;
            double upBeard = high - close;
            double downBeard = open - low;

            if(body <= upBeard){
                result = true;
            }else if(body <= downBeard){
                result = true;
            }
        }
        else{
            result = true;
        }

        return result;
    }


