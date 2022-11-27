//------------------------------------------------------------------
// TEMA GMMA Index
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
#property indicator_type1   DRAW_NONE
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

double shortIndex[];
double longIndex[];

double ema1[];
double ema2[];
double ema3[];
double ema4[];
double ema5[];
double ema6[];
double ema7[];
double ema8[];
double ema9[];
double ema10[];
double ema11[];
double ema12[];

double ema1_1[];
double ema2_1[];
double ema3_1[];
double ema4_1[];
double ema5_1[];
double ema6_1[];
double ema7_1[];
double ema8_1[];
double ema9_1[];
double ema10_1[];
double ema11_1[];
double ema12_1[];

double ema1_2[];
double ema2_2[];
double ema3_2[];
double ema4_2[];
double ema5_2[];
double ema6_2[];
double ema7_2[];
double ema8_2[];
double ema9_2[];
double ema10_2[];
double ema11_2[];
double ema12_2[];

double ema1_3[];
double ema2_3[];
double ema3_3[];
double ema4_3[];
double ema5_3[];
double ema6_3[];
double ema7_3[];
double ema8_3[];
double ema9_3[];
double ema10_3[];
double ema11_3[];
double ema12_3[];

double alfa1 = 2 / (Period1 * 2 + 1.0);   // EMA1期間
double alfa2 = 2 / (Period2 * 2 + 1.0);   // EMA2期間
double alfa3 = 2 / (Period3 * 2 + 1.0);   // EMA3期間
double alfa4 = 2 / (Period4 * 2 + 1.0);   // EMA4期間
double alfa5 = 2 / (Period5 * 2 + 1.0);   // EMA5期間
double alfa6 = 2 / (Period6 * 2 + 1.0);   // EMA6期間
double alfa7 = 2 / (Period7 * 2 + 1.0);   // EMA7期間
double alfa8 = 2 / (Period8 * 2 + 1.0);   // EMA8期間
double alfa9 = 2 / (Period9 * 2 + 1.0);   // EMA9期間
double alfa10 = 2 / (Period10 * 2 + 1.0); // EMA10期間
double alfa11 = 2 / (Period11 * 2 + 1.0); // EMA11期間
double alfa12 = 2 / (Period12 * 2 + 1.0); // EMA12期間


//------------------------------------------------------------------
//初期化
int OnInit()
{
   //インジケーターバッファを初期化する。
   IndicatorBuffers(12 * 4 + 2);

   int count = 0 ;
   SetIndexBuffer(count++, shortIndex);
   SetIndexBuffer(count++, longIndex);

   SetIndexBuffer(count++, ema1);
   SetIndexBuffer(count++, ema2);
   SetIndexBuffer(count++, ema3);
   SetIndexBuffer(count++, ema4);
   SetIndexBuffer(count++, ema5);
   SetIndexBuffer(count++, ema6);
   SetIndexBuffer(count++, ema7);
   SetIndexBuffer(count++, ema8);
   SetIndexBuffer(count++, ema9);
   SetIndexBuffer(count++, ema10);
   SetIndexBuffer(count++, ema11);
   SetIndexBuffer(count++, ema12);

   SetIndexBuffer(count++, ema1_1);
   SetIndexBuffer(count++, ema2_1);
   SetIndexBuffer(count++, ema3_1);
   SetIndexBuffer(count++, ema4_1);
   SetIndexBuffer(count++, ema5_1);
   SetIndexBuffer(count++, ema6_1);
   SetIndexBuffer(count++, ema7_1);
   SetIndexBuffer(count++, ema8_1);
   SetIndexBuffer(count++, ema9_1);
   SetIndexBuffer(count++, ema10_1);
   SetIndexBuffer(count++, ema11_1);
   SetIndexBuffer(count++, ema12_1);
   
   SetIndexBuffer(count++, ema1_2);
   SetIndexBuffer(count++, ema2_2);
   SetIndexBuffer(count++, ema3_2);
   SetIndexBuffer(count++, ema4_2);
   SetIndexBuffer(count++, ema5_2);
   SetIndexBuffer(count++, ema6_2);
   SetIndexBuffer(count++, ema7_2);
   SetIndexBuffer(count++, ema8_2);
   SetIndexBuffer(count++, ema9_2);
   SetIndexBuffer(count++, ema10_2);
   SetIndexBuffer(count++, ema11_2);
   SetIndexBuffer(count++, ema12_2);
   
   SetIndexBuffer(count++, ema1_3);
   SetIndexBuffer(count++, ema2_3);
   SetIndexBuffer(count++, ema3_3);
   SetIndexBuffer(count++, ema4_3);
   SetIndexBuffer(count++, ema5_3);
   SetIndexBuffer(count++, ema6_3);
   SetIndexBuffer(count++, ema7_3);
   SetIndexBuffer(count++, ema8_3);
   SetIndexBuffer(count++, ema9_3);
   SetIndexBuffer(count++, ema10_3);
   SetIndexBuffer(count++, ema11_3);
   SetIndexBuffer(count++, ema12_3);
   
   for(int i = 2; i < count; i++ )
   {
      SetIndexStyle(i, DRAW_NONE);
   }

   string short_name = "TGMMA Index";
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
   if( prev_calculated == 0 )
   {
      ResetBuffer();
   }
   
   for( int i = rates_total - prev_calculated - 1 ; i >= 0; i-- )
   {
      if( i >= rates_total - 1 ) continue;
   
      double price = GetPrice(open[i], close[i], high[i], low[i], MaPrice);
      ema1_1[i] = alfa1 * price + ( 1 - alfa1 ) * ema1_1[i + 1];
      ema1_2[i] = alfa1 * ema1_1[i] + ( 1 - alfa1 ) * ema1_2[i + 1];
      ema1_3[i] = alfa1 * ema1_2[i] + ( 1 - alfa1 ) * ema1_3[i + 1];
      ema1[i] = ema1_1[i] * 3 - ema1_2[i] * 3 + ema1_3[i];

      ema2_1[i] = alfa2 * price + ( 1 - alfa2 ) * ema2_1[i + 1];
      ema2_2[i] = alfa2 * ema2_1[i] + ( 1 - alfa2 ) * ema2_2[i + 1];
      ema2_3[i] = alfa2 * ema2_2[i] + ( 1 - alfa2 ) * ema2_3[i + 1];
      ema2[i] = ema2_1[i] * 3 - ema2_2[i] * 3 + ema2_3[i];

      ema3_1[i] = alfa3 * price + ( 1 - alfa3 ) * ema3_1[i + 1];
      ema3_2[i] = alfa3 * ema3_1[i] + ( 1 - alfa3 ) * ema3_2[i + 1];
      ema3_3[i] = alfa3 * ema3_2[i] + ( 1 - alfa3 ) * ema3_3[i + 1];
      ema3[i] = ema3_1[i] * 3 - ema3_2[i] * 3 + ema3_3[i];
      
      ema4_1[i] = alfa4 * price + ( 1 - alfa4 ) * ema4_1[i + 1];
      ema4_2[i] = alfa4 * ema4_1[i] + ( 1 - alfa4 ) * ema4_2[i + 1];
      ema4_3[i] = alfa4 * ema4_2[i] + ( 1 - alfa4 ) * ema4_3[i + 1];
      ema4[i] = ema4_1[i] * 3 - ema4_2[i] * 3 + ema4_3[i];
      
      ema5_1[i] = alfa5 * price + ( 1 - alfa5 ) * ema5_1[i + 1];
      ema5_2[i] = alfa5 * ema5_1[i] + ( 1 - alfa5 ) * ema5_2[i + 1];
      ema5_3[i] = alfa5 * ema5_2[i] + ( 1 - alfa5 ) * ema5_3[i + 1];
      ema5[i] = ema5_1[i] * 3 - ema5_2[i] * 3 + ema5_3[i];

      ema6_1[i] = alfa6 * price + ( 1 - alfa6 ) * ema6_1[i + 1];
      ema6_2[i] = alfa6 * ema6_1[i] + ( 1 - alfa6 ) * ema6_2[i + 1];
      ema6_3[i] = alfa6 * ema6_2[i] + ( 1 - alfa6 ) * ema6_3[i + 1];
      ema6[i] = ema6_1[i] * 3 - ema6_2[i] * 3 + ema6_3[i];

      ema7_1[i] = alfa7 * price + ( 1 - alfa7 ) * ema7_1[i + 1];
      ema7_2[i] = alfa7 * ema7_1[i] + ( 1 - alfa7 ) * ema7_2[i + 1];
      ema7_3[i] = alfa7 * ema7_2[i] + ( 1 - alfa7 ) * ema7_3[i + 1];
      ema7[i] = ema7_1[i] * 3 - ema7_2[i] * 3 + ema7_3[i];

      ema8_1[i] = alfa8 * price + ( 1 - alfa8 ) * ema8_1[i + 1];
      ema8_2[i] = alfa8 * ema8_1[i] + ( 1 - alfa8 ) * ema8_2[i + 1];
      ema8_3[i] = alfa8 * ema8_2[i] + ( 1 - alfa8 ) * ema8_3[i + 1];
      ema8[i] = ema8_1[i] * 3 - ema8_2[i] * 3 + ema8_3[i];

      ema9_1[i] = alfa9 * price + ( 1 - alfa9 ) * ema9_1[i + 1];
      ema9_2[i] = alfa9 * ema9_1[i] + ( 1 - alfa9 ) * ema9_2[i + 1];
      ema9_3[i] = alfa9 * ema9_2[i] + ( 1 - alfa9 ) * ema9_3[i + 1];
      ema9[i] = ema9_1[i] * 3 - ema9_2[i] * 3 + ema9_3[i];

      ema10_1[i] = alfa10 * price + ( 1 - alfa10 ) * ema10_1[i + 1];
      ema10_2[i] = alfa10 * ema10_1[i] + ( 1 - alfa10 ) * ema10_2[i + 1];
      ema10_3[i] = alfa10 * ema10_2[i] + ( 1 - alfa10 ) * ema10_3[i + 1];
      ema10[i] = ema10_1[i] * 3 - ema10_2[i] * 3 + ema10_3[i];

      ema11_1[i] = alfa11 * price + ( 1 - alfa11 ) * ema11_1[i + 1];
      ema11_2[i] = alfa11 * ema11_1[i] + ( 1 - alfa11 ) * ema11_2[i + 1];
      ema11_3[i] = alfa11 * ema11_2[i] + ( 1 - alfa11 ) * ema11_3[i + 1];
      ema11[i] = ema11_1[i] * 3 - ema11_2[i] * 3 + ema11_3[i];

      ema12_1[i] = alfa12 * price + ( 1 - alfa12 ) * ema12_1[i + 1];
      ema12_2[i] = alfa12 * ema12_1[i] + ( 1 - alfa12 ) * ema12_2[i + 1];
      ema12_3[i] = alfa12 * ema12_2[i] + ( 1 - alfa12 ) * ema12_3[i + 1];
      ema12[i] = ema12_1[i] * 3 - ema12_2[i] * 3 + ema12_3[i];
      
      shortIndex[i] = 
          (ema1[i] > ema2[i] ? 1 : -1)
        + (ema2[i] > ema3[i] ? 1 : -1)
        + (ema3[i] > ema4[i] ? 1 : -1)
        + (ema4[i] > ema5[i] ? 1 : -1)
        + (ema5[i] > ema6[i] ? 1 : -1);
      
      longIndex[i] = 
          (ema7[i] > ema8[i] ? 1 : -1)
        + (ema8[i] > ema9[i] ? 1 : -1)
        + (ema9[i] > ema10[i] ? 1 : -1)
        + (ema10[i] > ema11[i] ? 1 : -1)
        + (ema11[i] > ema12[i] ? 1 : -1);

      if( i >= rates_total - 2 ) continue;
   }
   
   //元となる値を計算する。unFix期間は計算し続ける。
   return(rates_total - 1);
}

//------------------------------------------------------------------
//バッファをリセットする。
void ResetBuffer()
{
   ArrayInitialize(ema1, 0);
   ArrayInitialize(ema2, 0);
   ArrayInitialize(ema3, 0);
   ArrayInitialize(ema4, 0);
   ArrayInitialize(ema5, 0);
   ArrayInitialize(ema6, 0);
   ArrayInitialize(ema7, 0);
   ArrayInitialize(ema8, 0);
   ArrayInitialize(ema9, 0);
   ArrayInitialize(ema10, 0);
   ArrayInitialize(ema11, 0);
   ArrayInitialize(ema12, 0);

   ArrayInitialize(ema1_1, 0);
   ArrayInitialize(ema2_1, 0);
   ArrayInitialize(ema3_1, 0);
   ArrayInitialize(ema4_1, 0);
   ArrayInitialize(ema5_1, 0);
   ArrayInitialize(ema6_1, 0);
   ArrayInitialize(ema7_1, 0);
   ArrayInitialize(ema8_1, 0);
   ArrayInitialize(ema9_1, 0);
   ArrayInitialize(ema10_1, 0);
   ArrayInitialize(ema11_1, 0);
   ArrayInitialize(ema12_1, 0);

   ArrayInitialize(ema1_2, 0);
   ArrayInitialize(ema2_2, 0);
   ArrayInitialize(ema3_2, 0);
   ArrayInitialize(ema4_2, 0);
   ArrayInitialize(ema5_2, 0);
   ArrayInitialize(ema6_2, 0);
   ArrayInitialize(ema7_2, 0);
   ArrayInitialize(ema8_2, 0);
   ArrayInitialize(ema9_2, 0);
   ArrayInitialize(ema10_2, 0);
   ArrayInitialize(ema11_2, 0);
   ArrayInitialize(ema12_2, 0);

   ArrayInitialize(ema1_3, 0);
   ArrayInitialize(ema2_3, 0);
   ArrayInitialize(ema3_3, 0);
   ArrayInitialize(ema4_3, 0);
   ArrayInitialize(ema5_3, 0);
   ArrayInitialize(ema6_3, 0);
   ArrayInitialize(ema7_3, 0);
   ArrayInitialize(ema8_3, 0);
   ArrayInitialize(ema9_3, 0);
   ArrayInitialize(ema10_3, 0);
   ArrayInitialize(ema11_3, 0);
   ArrayInitialize(ema12_3, 0);
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