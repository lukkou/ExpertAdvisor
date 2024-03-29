//------------------------------------------------------------------
// TEMA
// V1.1 色分け機能追加
#property copyright "Copyright 2015,  Daisuke"
#property link      "http://mt4program.blogspot.jp/"
#property version   "1.10"
#property strict
#property indicator_chart_window

//バッファーを指定する。
#property indicator_buffers 5

//プロット数を指定する。
#property indicator_plots   2

#property indicator_label1  "TEMAUP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "TEMADOWN"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrIndianRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_type3   DRAW_NONE
#property indicator_type4   DRAW_NONE
#property indicator_type5   DRAW_NONE

input double Alfa = 0.1;//指数係数
input ENUM_APPLIED_PRICE MaPrice = PRICE_CLOSE;//適用価格

// TEMA
double temaUp[];

// TEMA
double temaDown[];

// EMA
double ema1[];

// EMA EMA
double ema2[];

// EMA EMA EMA
double ema3[];

//------------------------------------------------------------------
//初期化
int OnInit()
{
   //インジケーターバッファを初期化する。
   int count = 0 ;
   SetIndexBuffer(count++,temaUp);
   SetIndexBuffer(count++,temaDown);
   SetIndexBuffer(count++,ema1);
   SetIndexBuffer(count++,ema2);
   SetIndexBuffer(count++,ema3);
   
   if( Alfa <= 0 || Alfa >= 1 ) return INIT_PARAMETERS_INCORRECT;
   
   string short_name = "TEMA(" + DoubleToStr(Alfa) + ")";
   IndicatorShortName(short_name);
   
   return INIT_SUCCEEDED;
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
   for( int i = (rates_total - prev_calculated - 1); i >= 0 && !IsStopped(); i-- )
   {
      double price = GetPrice(open[i], close[i], high[i], low[i], MaPrice);
      if( i >= (rates_total - 2) )
      {
         ema1[i] = price;
         ema2[i] = price;
         ema3[i] = price;
         continue;
      }
      ema1[i] = Alfa * price + ( 1 - Alfa ) * ema1[i + 1];
      ema2[i] = Alfa * ema1[i] + ( 1 - Alfa ) * ema2[i + 1];
      ema3[i] = Alfa * ema2[i] + ( 1 - Alfa ) * ema3[i + 1];
      double temaBefore = ema1[i + 1] * 3 - ema2[i + 1] * 3 + ema3[i + 1];
      double temaNow = ema1[i] * 3 - ema2[i] * 3 + ema3[i];
      
      if( temaBefore < temaNow )
      {
         temaUp[i + 1] = temaBefore;
         temaUp[i] = temaNow;
         temaDown[i] = EMPTY_VALUE;
      }
      else
      {
         temaDown[i + 1] = temaBefore;
         temaUp[i] = EMPTY_VALUE;
         temaDown[i] = temaNow;
      }
   }
   //元となる値を計算する。
   return(rates_total - 1);
}


//------------------------------------------------------------------
// 価格を計算する。
// return 対象価格
double GetPrice(
   double open,   // オープン値
   double close,  // クローズ値
   double high,   // 高値
   double low,    // 安値
   ENUM_APPLIED_PRICE maPrice    //取得価格
   )
{
   double price = 0;

   switch( maPrice )
   {
      case PRICE_CLOSE:
         price = close;
         break;
      case PRICE_OPEN:
         price = open;
         break;
      case PRICE_HIGH:
         price = high;
         break;
      case PRICE_LOW:
         price = low;
         break;
      case PRICE_MEDIAN:
         price = (high + low) / 2;
         break;
      case PRICE_TYPICAL:
         price = (high + low + close) / 3;
         break;
      case PRICE_WEIGHTED:
         price = (high + low + close + close) / 4;
         break;
   }
   return price;
}