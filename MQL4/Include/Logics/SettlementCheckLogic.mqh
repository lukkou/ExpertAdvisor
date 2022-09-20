//+------------------------------------------------------------------+
//|                                         SettlementCheckLogic.mqh |
//| SettlementCheckLogic v0.0.1               Copyright 2022, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "0.01"
#property strict

#include <Defines/Defines.mqh>

class SettlementCheckLogic{
    public:
    string _symbol;
    double _nowPrice;

    //------------------------------------------------------------------
    // コンストラクタ
    SettlementCheckLogic();

    //------------------------------------------------------------------
    // デストラクタ
    ~SettlementCheckLogic();

    // 買いの場合の命名規則(ベース：BuySettlement)
    // 負け：Defeat
    int BuySettlementDefeat();

    // 守り：Protect
    int BuySettlementProtect();

    // 攻守：Offense
    int BuySettlementOffense();

    // 攻め：Attack
    int BuySettlementAttack();

    // 売りの場合の命名規則(ベース：SellSettlement)
    // 負け：Defeat
    int SellSettlementDefeat();

    // 守り：Protect
    int SellSettlementProtect();

    // 攻守：Offense
    int SellSettlementOffense();

    // 攻め：Attack
    int SellSettlementAttack();
};

    //------------------------------------------------------------------
    // コンストラクタ
    SettlementCheckLogic::SettlementCheckLogic()
    {
        _symbol = Symbol();
        _nowPrice = iClose(_symbol, PERIOD_D1, 0);
    }

    //------------------------------------------------------------------
    // デストラクタ
    SettlementCheckLogic::~SettlementCheckLogic()
    {
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

        if(_nowPrice < ema60 && (gmmaWidthDown == EMPTY_VALUE || gmmaWidthDown != 0))
        {
            result = POSITION_CUT_ON;
        }

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(守り)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementProtect()
    {
        int result = POSITION_CUT_OFF;

        // -1足の高値
        double onePreviousHighPrice = indicator.GetMa(PERIOD_M15, 1, MODE_EMA, PRICE_HIGH, 1);
        // -1足の中間値
        double onePreviousCenterPrice = indicator.GetMa(PERIOD_M15, 1, MODE_EMA, PRICE_MEDIAN, 1);
        // -1足のボリンジャーバンド3σの値
        double onePreviousBandsPrice = indicator.GetBands(PERIOD_M15, 20, 3, PRICE_CLOSE, MODE_UPPER, 1);

        if(onePreviousBandsPrice > onePreviousHighPrice && onePreviousCenterPrice > _nowPrice)
        {
            result = POSITION_CUT_ON;
        }

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(攻守)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementOffense()
    {
        int result = POSITION_CUT_OFF;

        // 
        double a = indicator.GetMa(PERIOD_M15, 1, MODE_EMA, PRICE_HIGH, 1);

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(攻め)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementAttack()
    {
        int result = POSITION_CUT_OFF;

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

        return result;
    }

    /// <summary>
    /// 売りポジションの売買判定(守り)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int SellSettlementProtect()
    {
        int result = POSITION_CUT_OFF;

        return result;
    }

    /// <summary>
    /// 売りポジションの売買判定(攻守)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int SellSettlementOffense()
    {
        int result = POSITION_CUT_OFF;

        return result;
    }

    /// <summary>
    /// 売りポジションの売買判定(攻め)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int SellSettlementAttack()
    {
        int result = POSITION_CUT_OFF;

        return result;
    }