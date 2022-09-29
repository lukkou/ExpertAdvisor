//+------------------------------------------------------------------+
//|                                         SettlementCheckLogic.mqh |
//| SettlementCheckLogic v0.0.1               Copyright 2022, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "0.01"
#property strict

#include <Logics/IndicatorLogic.mqh>
#include <Defines/Defines.mqh>
#include <Custom/CandleStickHelper.mqh>

class SettlementCheckLogic{
    private:
    IndicatorLogic indicator;
    string _symbol;
    double _nowPrice;

    // 買いの場合の命名規則(ベース：BuySettlement)
    // 負け：Defeat
    int BuySettlementDefeat();

    // 守り・攻守：Protect
    int BuySettlementProtect();

    // 攻め：Attack
    int BuySettlementAttack();

    // 売りの場合の命名規則(ベース：SellSettlement)
    // 負け：Defeat
    int SellSettlementDefeat();

    // 守り・攻守：Protect
    int SellSettlementProtect();

    // 攻め：Attack
    int SellSettlementAttack();

    public:
    //------------------------------------------------------------------
    // コンストラクタ
    SettlementCheckLogic();

    //------------------------------------------------------------------
    // デストラクタ
    ~SettlementCheckLogic();

    // 買いの場合の決済判断実施
    int IsBuySettlement();

    // 売りの場合の決済判断実施
    int IsSellSettlement();
};

    //------------------------------------------------------------------
    // コンストラクタ
    SettlementCheckLogic::SettlementCheckLogic()
    {
        _symbol = Symbol();
        _nowPrice = iClose(_symbol, PERIOD_D1, 0);
        indicator = IndicatorLogic();
    }

    //------------------------------------------------------------------
    // デストラクタ
    SettlementCheckLogic::~SettlementCheckLogic()
    {
    }

    /// <summary>
    /// 買いポジションの決済判定
    /// <summary>
    /// <returns>決済しない:false 決済する:true</returns>
    int IsBuySettlement()
    {
        int result = POSITION_CUT_OFF;

        // 負け → 攻め → 守り・攻守の順で判定
        result = BuySettlementDefeat();
        if(result == POSITION_CUT_ON)
        {
            return result;
        }

        result = BuySettlementAttack();
        if(result == POSITION_CUT_ON)
        {
            return result;
        }

        return = BuySettlementProtect();
        if(result == POSITION_CUT_ON)
        {
            return result;
        }

        return result;
    }

    /// <summary>
    /// 売りポジションの決済判定
    /// <summary>
    /// <returns>決済しない:false 決済する:true</returns>
    int IsSellSettlement()
    {
        int result = POSITION_CUT_OFF;

        // 負け → 攻め → 守り・攻守の順で判定
        result = SellSettlementDefeat();
        if(result == POSITION_CUT_ON)
        {
            return result;
        }

        result = SellSettlementAttack();
        if(result == POSITION_CUT_ON)
        {
            return result;
        }

        result = SellSettlementProtect();
        if(result == POSITION_CUT_ON)
        {
            return result;
        }

        return result;
    }

    /// ▽▽▽▽▽▽ 買い決済の判定 ▽▽▽▽▽▽
    /// <summary>
    /// 買いポジションの売買判定(負け)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementDefeat()
    {
        int result = POSITION_CUT_OFF;

        // EMA 60
        double ema60 = indicator.GetMa(PERIOD_M15, 60, MODE_EMA, PRICE_CLOSE, 0);

        // GMMA Width
        double gmmaWidthDown = indicator.GetGmmaWidth(PERIOD_M15, 1, 0);

        // ボリンジャーバンドバンド-2σ
        double bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_LOWER, 0);

        if(_nowPrice < ema60 || _nowPrice < bands || (gmmaWidthDown == EMPTY_VALUE || gmmaWidthDown != 0))
        {
            result = POSITION_CUT_ON;
        }

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(守り・攻守)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementProtect()
    {
        int result = POSITION_CUT_OFF;

        // -1足の高値
        double onePreviousHighPrice = iHigh(_symbol, PERIOD_M15, 1);
        // -1足のボリンジャーバンド3σの値
        double onePreviousBandsPrice = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_UPPER, 1);

        if(onePreviousBandsPrice > onePreviousHighPrice)
        {
            // -1足の中間値
            double onePreviousCenterPrice = indicator.GetMa(PERIOD_M15, 1, MODE_EMA, PRICE_MEDIAN, 1);
            if(onePreviousCenterPrice > _nowPrice)
            {
                result = POSITION_CUT_ON;
            }
        }
        // ここまで守りの判断

        
        // -2足の高値
        double twoPreviousHighPrice = iHigh(_symbol, PERIOD_M15, 2);
        // -2足のボリンジャーバンド3σの値
        double twoPreviousBandsPrice = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_UPPER, 2);

        bool lowRoundingDown = IsLowRoundingDown();
        if(lowRoundingDown)
        {
            result = POSITION_CUT_ON;
        }
        // ここまで攻守の判断

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(攻め)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementAttack()
    {
        int result = POSITION_CUT_OFF;

        // -2足の判断
        double towPreviousHigh = iHigh(_symbol, PERIOD_M15, 2);
        double towPreviousBands = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_UPPER, 2);

        if(towPreviousHigh > towPreviousBands)
        {
            // -1足の判断
            double onePreviousHigh = iHigh(_symbol, PERIOD_M15, 1);
            double towPreviousBands = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_UPPER, 1);

            if(onePreviousHigh > towPreviousBands)
            {
                // 今足の判断
                double nowBands = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_UPPER, 0);
                if(_nowPrice > nowBands)
                {
                    result = POSITION_CUT_ON;
                }
            }
        }

        return result;
    }

    /// ▽▽▽▽▽▽ 売り決済の判定 ▽▽▽▽▽▽
    /// <summary>
    /// 売りポジションの売買判定(負け)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int SellSettlementDefeat()
    {
        int result = POSITION_CUT_OFF;

        // EMA 60
        double ema60 = indicator.GetMa(PERIOD_M15, 60, MODE_EMA, PRICE_CLOSE, 0);

        // GMMA Width
        double gmmaWidthUp = indicator.GetGmmaWidth(PERIOD_M15, 0, 0);

        // ボリンジャーバンドバンド-2σ
        double bands = indicator.GetBands(PERIOD_M15, 20, 2, PRICE_CLOSE, MODE_UPPER, 0);

        if(_nowPrice > ema60 || _nowPrice > bands || (gmmaWidthDown == EMPTY_VALUE || gmmaWidthUp != 0))
        {
            result = POSITION_CUT_ON;
        }

        return result;
    }

    /// <summary>
    /// 売りポジションの売買判定(守り 攻守)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int SellSettlementProtect()
    {
        int result = POSITION_CUT_OFF;

        // -1足の安値
        double onePreviousHighPrice = iLow(_symbol, PERIOD_M15, 1);
        // -1足のボリンジャーバンド3σの値
        double onePreviousBandsPrice = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_LOWER, 1);

        if(onePreviousBandsPrice < onePreviousHighPrice)
        {
            // -1足の中間値
            double onePreviousCenterPrice = indicator.GetMa(PERIOD_M15, 1, MODE_EMA, PRICE_MEDIAN, 1);
            if(onePreviousCenterPrice < _nowPrice)
            {
                result = POSITION_CUT_ON;
            }
        }

        return result;
    }

    /// <summary>
    /// 売りポジションの売買判定(攻め)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int SellSettlementAttack()
    {
        int result = POSITION_CUT_OFF;

        // -2足の判断
        double towPreviousLow = iLow(_symbol, PERIOD_M15, 2);
        double towPreviousBands = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_LOWER, 2);

        if(towPreviousLow < towPreviousBands)
        {
            // -1足の判断
            double onePreviousLow = iLow(_symbol, PERIOD_M15, 1);
            double towPreviousBands = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_LOWER, 1);
        
            if(onePreviousLow < towPreviousBands)
            {
                // 今足の判断
                double nowBands = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_LOWER, 0);
                if(_nowPrice < nowBands)
                {
                    result = POSITION_CUT_ON;
                }
            }
        }

        return result;
    }