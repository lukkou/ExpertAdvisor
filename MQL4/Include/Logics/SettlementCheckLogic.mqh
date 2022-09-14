//+------------------------------------------------------------------+
//|                                         SettlementCheckLogic.mqh |
//| SettlementCheckLogic v1.0.0               Copyright 2022, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

class SettlementCheckLogic{
    public:
    string _symbol;

    //------------------------------------------------------------------
    // コンストラクタ
    SettlementCheckLogic();

    //------------------------------------------------------------------
    // デストラクタ
    ~SettlementCheckLogic();
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
    // 買いの場合の命名規則(ベース：BuySettlement)
    // BuySettlement
    // 負け：Defeat
    // 守り：Protect
    // 攻守：Offense 
    // 攻め：Attack

    // 売りの場合の命名規則(ベース：SellSettlement)
    // 負け：Defeat
    // 守り：Protect
    // 攻守：Offense 
    // 攻め：Attack