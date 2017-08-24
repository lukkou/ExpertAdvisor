//+------------------------------------------------------------------+
//|                                            TradeQuantityCalc.mqh |
//| TradeQuantityCalc v1.0.0                  Copyright 2017, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

//------------------------------------------------------------------
// トレード時のロット数、標準偏差を基準にした損切り幅を計算
class TradeQuantityCalc{
private:
    //計算通貨ペア
    string _symbol;

    // マジックナンバー
    int _magicNumber;

    //確認時間(5分足、1時間足など…)
    int _timeFrame;

    //採用移動平均線の期間
    int _maPeriod;

    //移動平均線の標準偏差の表示をずらすバーの個数
    int _maShift;

    //移動平均線のタイプ
    int _maType;

    //価格データの種類(高値、終値など)
    int _appliedPrice

    //移動平均線の標準偏差の値を取得したいバーの位置
    int _shift;

    //シグマ値
    int _sigma;

    //資金
    double _funds;

    //リスク率(%)
    double _riskPercent;

public:
    //------------------------------------------------------------------
    // コンストラクタ
    ///param name="symbol":対象通貨ペア
    ///param name="magicNumber":マジックナンバー
    ///param name="timeFrame":確認時間
    ///param name="maPeriod":採用移動平均線の期間
    ///param name="maShift":移動平均線の標準偏差の表示をずらすバーの個数
    ///param name="maType":移動平均線のタイプ
    ///param name="appliedPrice":価格データの種類
    ///param name="shift":移動平均線の標準偏差の値を取得したいバーの位置
    ///param name="funds":資金
    ///param name="riskPercent":リスク率(%)
    TradeQuantityCalc(
        string symbol,
        int magicNumber,
        int timeFrame,
        int maPeriod,
        int maShift,
        int maType,
        int appliedPrice,
        int shift,
        int sigma,
        double funds,
        double riskPercent,
    );

    //------------------------------------------------------------------
    // デストラクタ
    ~TradeQuantityCalc();

    //------------------------------------------------------------------
    // 1pips当たりの価格単位を取得
    // Return   1pips当たりの価格単位
    double GetUnitPerPips()
    {
        return CalculatUnitPerPips();
    };

    //------------------------------------------------------------------
    // 標準偏差に基づく変動損切り幅を取得
    // Return   変動損切り幅値
    double GetLossRenge()
    {
        return CalculatLossRenge();
    };

    //------------------------------------------------------------------
    // 資産のＮ％のリスクのロット数を取得
    // Return   ロット数  
    double GetLotSize(double pips)
    {
        return CalculatLotSizeRiskPercent(pips);
    };

private:
    //------------------------------------------------------------------
    // 1pips当たりの価格単位を計算
    double CalculatUnitPerPips();

    //------------------------------------------------------------------
    // 損切り幅を計算
    double CalculatLossRenge();

    //------------------------------------------------------------------
    // ロット数を計算
    double CalculatLotSizeRiskPercent(double pips);
};

//------------------------------------------------------------------
// コンストラクタ
///param name="symbol":対象通貨ペア
///param name="magicNumber":マジックナンバー
///param name="timeFrame":確認時間
///param name="maPeriod":採用移動平均線の期間
///param name="maShift":移動平均線の標準偏差の表示をずらすバーの個数
///param name="maType":移動平均線のタイプ
///param name="appliedPrice":価格データの種類
///param name="shift":移動平均線の標準偏差の値を取得したいバーの位置
///param name="funds":資金
///param name="riskPercent":リスク率(%)
TradeQuantityCalc::TradeQuantityCalc(
        string symbol,
        int magicNumber,
        int timeFrame,
        int maPeriod,
        int maShift,
        int maType,
        int appliedPrice,
        int shift,
        int sigma,
        double funds,
        double riskPercent,
    )
{
    _symbol = symbol;
    _magicNumber = magicNumber;
    _timeFrame = timeFrame;
    _maPeriod = maPeriod;
    _maShift = maShift;
    _maType = maType;
    _appliedPrice = appliedPrice;
    _shift = shift;
    _sigma = sigma;
    _funds = funds;
    _riskPercent = riskPercent;
}

//------------------------------------------------------------------
// デストラクタ
StandardDeviationLossCalc::~StandardDeviationLossCalc()
{
}

//------------------------------------------------------------------
// 1pips当たりの価格単位を計算
double CalculatUnitPerPips()
{
    //通貨ペアに対する小数点数を取得
    double digits = MarketInfo(aSymbol, MODE_DIGITS);

    // 通貨ペアに対応するポイント（最小価格単位）を取得
    // 3桁/5桁のFX業者の場合、0.001/0.00001
    // 2桁/4桁のFX業者の場合、0.01/0.0001
    double point = MarketInfo(aSymbol, MODE_POINT);
 
    // 価格単位の初期化
    double currencyUnit = 0.0;
 

    if(digits == 3.0 || digits == 5.0)
    {
        // 3桁/5桁のFX業者の場合
        currencyUnit = point * 10.0;    
    }
    else
    {   
        // 2桁/4桁のFX業者の場合
        currencyUnit = point;
    }
    
    return currencyUnit;
}

//------------------------------------------------------------------
// 損切り幅を計算
///return 標準偏差に基づく変動損切り幅
double CalculatLossRenge()
{
    // 標準偏差
    double sd = iStdDiv(_symbol,_timeFrame,_maPeriod,_maShift,_maType,_appliedPrice,1);
    //標準返済に基づく変動損切り幅
    double sdRange = NormalizeDouble(_sigma * sd,MarketInfo(_symbol,MODE_DIGITS));

    double lotSize = CalculatLotSizeRiskPercent(sdRange / CalculatUnitPerPips());

    return lotSize;
}

//------------------------------------------------------------------
// Lotサイズを計算
///param name="pips":損切り値（pips）
///return ロット数(ポジれない場合は-1)
double CalculatLotSizeRiskPercent(double pips)
{
    //取引対象の通貨を１ロット売買した場合の１ポイント当たりの変動額
    double tickValue = MarketInfo(_symbol,MODE_TICKVALUE);

    // tickValueは最小価格単位で計算されるため、3/5桁業者の場合、10倍しないと1pipsにならない
    if(MarketInfo(aSymbol, MODE_DIGITS) == 3 || MarketInfo(aSymbol, MODE_DIGITS) == 5)
    {
        tickValue *= 10.0;
    }

    //資金からのリスク量を計算
    double riskAmount = _funds * (_riskPercent / 100);
    double lotSize = riskAmount / (pips * tickValue)
    double lotStep = MarketInfo(aSymbol, MODE_LOTSTEP);

    // ロットステップ単位未満は切り捨て
    // 0.123⇒0.12（lotStep=0.01の場合）
    // 0.123⇒0.1 （lotStep=0.1の場合）
    lotSize = MathFloor(lotSize / lotStep) * lotStep;

    // 証拠金ベースの制限
    double margin = MarketInfo(aSymbol, MODE_MARGINREQUIRED);

    if (margin > 0.0)
    {
        double accountMax = _funds / margin;
        accountMax = MathFloor(accountMax / lotStep) * lotStep;

        if (lotSize > accountMax)
        {
            lotSize = accountMax;
        }
    }

    //最大ロット数、最小ロット数対応
    double minLots = MarketInfo(aSymbol, MODE_MINLOT);
    double maxLots = MarketInfo(aSymbol, MODE_MAXLOT);

    if(lotSize < minLots)
    {
        // 仕掛けようとするロット数が最小単位に満たない場合、
        // そのまま仕掛けると過剰リスクになるため、エラーに
        lotSize = -1.0;
    }
    else if(lotSize > maxLots)
    {
        lotSize = maxLots;
    }

    return lotSize;
}