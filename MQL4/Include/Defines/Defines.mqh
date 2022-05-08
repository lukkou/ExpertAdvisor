//+------------------------------------------------------------------+
//|                                     ExpertAdvisorTradeHelper.mq4 |
//| ExpertAdvisorHelper　v1.0.0     Copyright 2017, Lukkou_EA_Trader |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//シグナルなし
#define OP_NONE (0)

//シグナルなし
#define OP_UP (1)

//全決済
#define OP_CLOSEALL (-2)

// 指標発表無し
#define INDEX_RELEASE_NOTEXIST (0)

// 指標発表有り
#define INDEX_RELEASE_EXIST (1)

// 長期(4H)トレンド上 下 無
#define LONG_TREND_PLUS (1)
#define LONG_TREND_MINUS (-1)
#define LONG_TREND_NON (0)

// 短期(15m)エントリー判定
#define ENTRY_OFF (0)
#define ENTRY_ON (1)

// 決済判定
#define POSITION_CUT_OFF (0)
#define POSITION_CUT_ON (1)