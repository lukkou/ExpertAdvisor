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