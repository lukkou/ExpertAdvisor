//+------------------------------------------------------------------+
//|                                     ExpertAdvisorTradeHelper.mq4 |
//| ExpertAdvisorHelper　v1.0.0     Copyright 2017, Lukkou_EA_Trader |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#include 
//------------------------------------------------------------------
// 注文関係ラッパークラス
class ExpertAdvisorTradeHelper
{
private:
// マジックナンバー
int m_magicNumber;

// 最大ポジション数
int m_maxPosition;

// Pips倍率
int m_pipsRate;

// 対象通貨ペア
string m_CurrencyPair;

// 保有ポジション
CArrayInt m_positions ;
public:
//------------------------------------------------------------------
// コンストラクタ
ExpertAdvisorTradeHelper(
string currencyPair, //対象通貨ペア
int magicNumber, //マジックナンバー
int maxPosition //最大ポジション数
);

//------------------------------------------------------------------
// デストラクタ
~ExpertAdvisorTradeHelper();

//------------------------------------------------------------------
// 発注する
// Return 発注成功時インデックス それ以外-1
int SendOrder(
int cmd, //売買種別 
double volume, //売買ロット
double price, //価格
uint slippage, //許容スリッピング（Pips単位）
uint stoploss, //ストップロス（Pips単位）
uint takeprofit, //利確値（Pips単位）
string comment, //コメント
datetime expiration, //注文有効期限
color arrowColor //注文矢印の色
);

//------------------------------------------------------------------
// 成行き決済を行う。
// Return 発注成功時ture それ以外false
bool CloseOrder(
int index, // 決済するインデックス
uint slippage, // 許容スリッピング
color arrowColor = clrNONE //注文矢印の色
);

//------------------------------------------------------------------
// 全ポジションを成行き決済を行う。
// Return 発注成功時ture それ以外false
bool CloseOrderAll(
uint slippage, // 許容スリッピング
color arrowColor = clrNONE //注文矢印の色
);

//------------------------------------------------------------------
// 現在のポジション数を取得する。
// Return 現在のポジション数を取得する。
int GetPositionCount(){ return m_positions.Total(); };

//------------------------------------------------------------------
// 最大のポジション数を取得する。
// Return 最大のポジション数を取得する。
int GetMaxPosition() { return m_maxPosition; } ;

private:

//------------------------------------------------------------------
// 設定パラメータが安全かどうか
// Return 安全ture それ以外false
bool IsSafeParameter();

};

//------------------------------------------------------------------
// コンストラクタ
ExpertAdvisorTradeHelper::ExpertAdvisorTradeHelper(
string currencyPair, //対象通貨ペア
int magicNumber = 0, //マジックナンバー
int maxPosition = 0 //マジックナンバー
)
{
m_CurrencyPair = currencyPair;
m_magicNumber = magicNumber;
m_maxPosition = maxPosition;

m_positions.Resize(m_maxPosition);

//Pips計算 小数点桁数が3or5の場合、Point()*10=1pips
int dig = Digits();
m_pipsRate = dig == 3 || dig == 5 ? 10 : 1;
}

//------------------------------------------------------------------
// デストラクタ
ExpertAdvisorTradeHelper::~ExpertAdvisorTradeHelper()
{
}

//------------------------------------------------------------------
// 発注する
// Return 発注成功時インデックス それ以外-1
int ExpertAdvisorTradeHelper::SendOrder(
int cmd, //売買種別 
double volume, //売買ロット
double price, //価格
uint slippage, //許容スリッピング（Pips単位）
uint stoploss = 0, //ストップロス（Pips単位）
uint takeprofit = 0, //利確値（Pips単位）
string comment = NULL, //コメント
datetime expiration = 0, //注文有効期限
color arrowColor = clrNONE //注文矢印の色
)
{
if( !this.IsSafeParameter() ) return -1;
if( m_positions.Total() >= m_positions.Max() ) return -1 ;

//pips値からストップロス値、利益確定値を取得する。 
double stoplossValue = 0 ;
double takeprofitValue = 0;

int flag = cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP ? 1 : -1;
double bid = MarketInfo(m_CurrencyPair, MODE_BID);
if( stoploss != 0 )
{
stoplossValue = NormalizeDouble(bid - Point() * m_pipsRate * stoploss * flag, Digits() );
}
if( takeprofit != 0)
{
takeprofitValue = NormalizeDouble(bid + Point() * m_pipsRate * takeprofit * flag, Digits());
}

int tiket = ::OrderSend(m_CurrencyPair, cmd, volume, price,
slippage * m_pipsRate, stoplossValue, takeprofitValue, 
comment, m_magicNumber, expiration, arrowColor);

if( tiket < 0 ) return -1 ;

m_positions.Add(tiket);

return m_positions.Total() - 1;
}

//------------------------------------------------------------------
// 成行き決済を行う。
// Return 発注成功時ture それ以外false
bool ExpertAdvisorTradeHelper::CloseOrder(
int index, // 決済するインデックス
uint slippage, // 許容スリッピング
color arrowColor = clrNONE //注文矢印の色
)
{
int targetTicket = m_positions.At(index);
if( !OrderSelect(targetTicket, SELECT_BY_TICKET) ) return false;

if( !OrderClose(OrderTicket(),OrderLots(), OrderClosePrice(), slippage * m_pipsRate, arrowColor) )
return false;

m_positions.Delete(index);

return true;
}

//------------------------------------------------------------------
// 全ポジションを成行き決済を行う。
// Return 発注成功時ture それ以外false
bool ExpertAdvisorTradeHelper::CloseOrderAll(
uint slippage, // 許容スリッピング
color arrowColor = clrNONE //注文矢印の色
)
{
bool result = true;
for( int i = m_positions.Total() - 1; i >= 0; i--)
{
result &= this.CloseOrder(i, slippage, arrowColor);
}

return true;
}

//------------------------------------------------------------------
// 設定パラメータが安全かどうか
// Return 安全ture それ以外false
bool ExpertAdvisorTradeHelper::IsSafeParameter()
{
if( m_CurrencyPair == NULL ) return false;
if( m_maxPosition == 0 ) return false; 
return true;
}

//使い方はこんな感じになります。
//ExpertAdvisorTradeHelper *myObj;

//------------------------------------------------------------------
//初期化
int OnInit()
{
myObj = new ExpertAdvisorTradeHelper(Symbol(), MagicNumber, 3);
return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//終了処理
void OnDeinit(const int reason) //終了理由
{
delete myObj;
}

//------------------------------------------------------------------
// 気配値表示処理 
void OnTick()
{
myObj.SendOrder(OP_BUY, 0.1, MarketInfo(Symbol(), MODE_ASK), 2); 
}