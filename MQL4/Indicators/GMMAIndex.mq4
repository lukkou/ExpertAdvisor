//------------------------------------------------------------------
// GMMA Index
#property copyright "Copyright 2016,  Daisuke"
#property link      "http://mt4program.blogspot.jp/"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_level1 0
#property indicator_maximum 6
#property indicator_minimum -6

//バッファーを指定する。
#property indicator_buffers 2

//プロット数を指定する。
#property indicator_plots   2

#property indicator_label1  "SHORT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "LONG"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input ENUM_APPLIED_PRICE MaPrice = PRICE_CLOSE; // 対象価格

//iCustomで期間パラメータの指定面倒なので省略できるようにしておく
//#define _FOR_EA_
#ifdef _FOR_EA_
#define __INPUT__
#else
#define __INPUT__ input
#endif

__INPUT__ int Period1 = 3;  // EMA1期間
__INPUT__ int Period2 = 5;  // EMA2期間
__INPUT__ int Period3 = 8;  // EMA3期間
__INPUT__ int Period4 = 10;  // EMA4期間
__INPUT__ int Period5 = 12;  // EMA5期間
__INPUT__ int Period6 = 15;  // EMA6期間
__INPUT__ int Period7 = 30;  // EMA7期間
__INPUT__ int Period8 = 35;  // EMA8期間
__INPUT__ int Period9 = 40;  // EMA9期間
__INPUT__ int Period10 = 45;  // EMA10期間
__INPUT__ int Period11 = 50;  // EMA11期間
__INPUT__ int Period12 = 60;  // EMA12期間

__INPUT__ bool ShowOverThreshold = false; //長期Indexが長期閾値で、短期Indexが短期閾値を超えた場合、矢印を出す
__INPUT__ bool ShowUnderThreshold = false; //長期Indexが長期閾値で、短期Indexが短期閾値再びを超えた場合、矢印を出す

__INPUT__ double ShortThreshold = -5;  // 短期閾値
__INPUT__ double LongThreshold = 5;    // 長期閾値
__INPUT__ ENUM_OBJECT BuyObjectType = OBJ_ARROW_BUY;   //買い時オブジェクトタイプ
__INPUT__ ENUM_OBJECT SellObjectType = OBJ_ARROW_SELL; //売り時オブジェクトタイプ

__INPUT__ int BuyArrowCode = 233; //買い時矢印形状 233上矢印、161丸、
__INPUT__ int SellArrowCode = 234; //売り時矢印形状 234下矢印、161丸
__INPUT__ color BuyColor = C'128,128,255';
__INPUT__ color SellColor = C'255,128,128';

__INPUT__ bool IsClosePosition = true;  // オブジェクトの位置を終値基準にする場合True、高値安値基準にする場合false

double shortIndex[];
double longIndex[];

#define OBJECT_NAME "GMMA_I_OBJ"

//------------------------------------------------------------------
//初期化
int OnInit()
{
   //インジケーターバッファを初期化する。
   int count = 0 ;
   SetIndexBuffer(count++, shortIndex);
   SetIndexBuffer(count++, longIndex);

   string short_name = "GMMA Index";
   IndicatorShortName(short_name);

   return INIT_SUCCEEDED;
}

//------------------------------------------------------------------
//終了処理
void OnDeinit(const int reason)
{
   long chartId = ChartID();

   int total = ObjectsTotal(chartId);
   //生成したオブジェクトを削除する。
   //０から削除するとインデックス位置がずれて
   //正しく削除できないため、後ろから削除するようにする。
   for( int i = total - 1; i >= 0 ; i--)
   {
      string name = ObjectName(chartId, i);
      
      // 先頭文字列がOBJECT_NAMEと一致する場合、削除する。
      if( StringFind(name, OBJECT_NAME) == 0 )
      {
         ObjectDelete(chartId, name);
      }
   }
}


//------------------------------------------------------------------
//計算イベント
int OnCalculate(const int rates_total,          //各レート要素数
                const int prev_calculated,      //計算済み要素数
                const datetime &time[],         //要素ごとの時間配列
                const double &open[],           //オープン価格配列
                const double &high[],           //高値配列
                const double &low[],            //安値配列
                const double &close[],          //クローズ価格配列
                const long &tick_volume[],      //ティック数（要素の更新回数）
                const long &volume[],           //実ボリューム（？）
                const int &spread[])            //スプレット
{
   for( int i = rates_total - prev_calculated - 1 ; i >= 0; i-- )
   {
      double ema1 = iMA(Symbol(), PERIOD_CURRENT, Period1, 0, MODE_EMA, MaPrice, i);
      double ema2 = iMA(Symbol(), PERIOD_CURRENT, Period2, 0, MODE_EMA, MaPrice, i);
      double ema3 = iMA(Symbol(), PERIOD_CURRENT, Period3, 0, MODE_EMA, MaPrice, i);
      double ema4 = iMA(Symbol(), PERIOD_CURRENT, Period4, 0, MODE_EMA, MaPrice, i);
      double ema5 = iMA(Symbol(), PERIOD_CURRENT, Period5, 0, MODE_EMA, MaPrice, i);
      double ema6 = iMA(Symbol(), PERIOD_CURRENT, Period6, 0, MODE_EMA, MaPrice, i);

      shortIndex[i] = 
          (ema1 > ema2 ? 1 : -1)
        + (ema2 > ema3 ? 1 : -1)
        + (ema3 > ema4 ? 1 : -1)
        + (ema4 > ema5 ? 1 : -1)
        + (ema5 > ema6 ? 1 : -1);
      
      double ema7 = iMA(Symbol(), PERIOD_CURRENT, Period7, 0, MODE_EMA, MaPrice, i);
      double ema8 = iMA(Symbol(), PERIOD_CURRENT, Period8, 0, MODE_EMA, MaPrice, i);
      double ema9 = iMA(Symbol(), PERIOD_CURRENT, Period9, 0, MODE_EMA, MaPrice, i);
      double ema10 = iMA(Symbol(), PERIOD_CURRENT, Period10, 0, MODE_EMA, MaPrice, i);
      double ema11 = iMA(Symbol(), PERIOD_CURRENT, Period11, 0, MODE_EMA, MaPrice, i);
      double ema12 = iMA(Symbol(), PERIOD_CURRENT, Period12, 0, MODE_EMA, MaPrice, i);

      longIndex[i] = 
          (ema7 > ema8 ? 1 : -1)
        + (ema8 > ema9 ? 1 : -1)
        + (ema9 > ema10 ? 1 : -1)
        + (ema10 > ema11 ? 1 : -1)
        + (ema11 > ema12 ? 1 : -1);

      if( i >= rates_total - 2 ) continue;

      DeleteArrawObject(time[i]);

      if( ShowOverThreshold )
      {
         if( longIndex[i] >= LongThreshold && shortIndex[i + 1] > ShortThreshold && shortIndex[i] <= ShortThreshold )
         {
            CreateArrawObject(BuyObjectType, time[i], open[i], close[i], high[i], low[i]);
         }
         if( longIndex[i] <= -LongThreshold && shortIndex[i + 1] < -ShortThreshold && shortIndex[i] >= -ShortThreshold )
         {
            CreateArrawObject(SellObjectType, time[i], open[i], close[i], high[i], low[i]);
         }
      }
      if( ShowUnderThreshold )
      {
         if( longIndex[i] >= LongThreshold && shortIndex[i + 1] <= ShortThreshold && shortIndex[i] > ShortThreshold )
         {
            CreateArrawObject(BuyObjectType, time[i], open[i], close[i], high[i], low[i]);
         }
         if( longIndex[i] <= -LongThreshold && shortIndex[i + 1] >= -ShortThreshold && shortIndex[i] < -ShortThreshold )
         {
            CreateArrawObject(SellObjectType, time[i], open[i], close[i], high[i], low[i]);
         }
      }
   }
   
   //元となる値を計算する。unFix期間は計算し続ける。
   return(rates_total - 1);
}

//------------------------------------------------------------------
//売買矢印オブジェクトを生成する。
bool CreateArrawObject(
   ENUM_OBJECT objectType,  //オブジェクトの種類
   datetime time,           //表示時間（横軸）
   double open,            //始値
   double close,           //終値
   double high,            //高値
   double low              //安値
   )
{
   //オブジェクトを作成する。
   long chartId = ChartID();
   
   double price = IsClosePosition ? close : (objectType == BuyObjectType ? high : low);
    
   string name = OBJECT_NAME + TimeToStr(time);
   if( !ObjectCreate(chartId, name, objectType, 0, time, price) )
   {
      return false;
   }
   ObjectSetInteger(chartId, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(chartId, name, OBJPROP_COLOR, objectType == BuyObjectType ? BuyColor : SellColor);
   ObjectSetInteger(chartId, name, OBJPROP_ARROWCODE, objectType == BuyObjectType ? BuyArrowCode : SellArrowCode);
   
   int anchor;
   
   if( IsClosePosition )
   {
      anchor = open < close ? ANCHOR_BOTTOM : ANCHOR_TOP ;
   }
   else
   {
      anchor = objectType == BuyObjectType ? ANCHOR_BOTTOM : ANCHOR_TOP;
   }
   
   ObjectSetInteger(chartId, name, OBJPROP_ANCHOR, anchor);
   return true;
}

//------------------------------------------------------------------
//売買矢印オブジェクトを削除する。
bool DeleteArrawObject(
   datetime time           //表示時間（横軸）
)
{
   //オブジェクトを作成する。
   long chartId = ChartID();
   string name = OBJECT_NAME + TimeToStr(time);
   return ObjectDelete(chartId, name);
}
