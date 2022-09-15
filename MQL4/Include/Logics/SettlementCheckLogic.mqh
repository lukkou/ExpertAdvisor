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

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(守り)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementProtect()
    {
        int result = POSITION_CUT_OFF;

        return result;
    }

    /// <summary>
    /// 買いポジションの売買判定(攻守)
    /// <summary>
    /// <returns>決済しない:0 決済する:1</returns>
    int BuySettlementOffense()
    {
        int result = POSITION_CUT_OFF;

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