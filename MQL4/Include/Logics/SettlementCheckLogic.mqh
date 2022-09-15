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
