//------------------------------------------------------------------
// GMMA
#property copyright "Copyright 2016,  Daisuke"
#property link      "http://mt4program.blogspot.jp/"
#property version   "1.00"
#property strict
#property indicator_chart_window

//バッファーを指定する。
#property indicator_buffers 12

//プロット数を指定する。
#property indicator_plots   12

input color ShortLineColor = clrIndianRed;// 短期色
input color LongLineColor = clrAqua;// 長期色
input ENUM_APPLIED_PRICE MaPrice = PRICE_CLOSE; // 対象価格

input int Period1 = 3;  // EMA1期間
input int Period2 = 5;  // EMA2期間
input int Period3 = 8;  // EMA3期間
input int Period4 = 10;  // EMA4期間
input int Period5 = 12;  // EMA5期間
input int Period6 = 15;  // EMA6期間
input int Period7 = 30;  // EMA7期間
input int Period8 = 35;  // EMA8期間
input int Period9 = 40;  // EMA9期間
input int Period10 = 45;  // EMA10期間
input int Period11 = 50;  // EMA11期間
input int Period12 = 60;  // EMA12期間

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

//------------------------------------------------------------------
//初期化
int OnInit()
{
   //インジケーターバッファを初期化する。
   int count = 0 ;
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

   for(int i = 0; i < 6; i++ )
   {
      SetIndexStyle(i, DRAW_LINE, STYLE_SOLID, 1, ShortLineColor);
      SetIndexStyle(i + 6, DRAW_LINE, STYLE_SOLID, 1, LongLineColor);
   }

   string short_name = "GMMA";
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
   for( int i = 0; i < rates_total - prev_calculated && !IsStopped(); i++ )
   {
      ema1[i] = iMA(Symbol(), PERIOD_CURRENT, Period1, 0, MODE_EMA, MaPrice, i);
      ema2[i] = iMA(Symbol(), PERIOD_CURRENT, Period2, 0, MODE_EMA, MaPrice, i);
      ema3[i] = iMA(Symbol(), PERIOD_CURRENT, Period3, 0, MODE_EMA, MaPrice, i);
      ema4[i] = iMA(Symbol(), PERIOD_CURRENT, Period4, 0, MODE_EMA, MaPrice, i);
      ema5[i] = iMA(Symbol(), PERIOD_CURRENT, Period5, 0, MODE_EMA, MaPrice, i);
      ema6[i] = iMA(Symbol(), PERIOD_CURRENT, Period6, 0, MODE_EMA, MaPrice, i);
      ema7[i] = iMA(Symbol(), PERIOD_CURRENT, Period7, 0, MODE_EMA, MaPrice, i);
      ema8[i] = iMA(Symbol(), PERIOD_CURRENT, Period8, 0, MODE_EMA, MaPrice, i);
      ema9[i] = iMA(Symbol(), PERIOD_CURRENT, Period9, 0, MODE_EMA, MaPrice, i);
      ema10[i] = iMA(Symbol(), PERIOD_CURRENT, Period10, 0, MODE_EMA, MaPrice, i);
      ema11[i] = iMA(Symbol(), PERIOD_CURRENT, Period11, 0, MODE_EMA, MaPrice, i);
      ema12[i] = iMA(Symbol(), PERIOD_CURRENT, Period12, 0, MODE_EMA, MaPrice, i);
   }
   
   //元となる値を計算する。unFix期間は計算し続ける。
   return(rates_total - 1);
}
