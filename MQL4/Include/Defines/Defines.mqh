//+------------------------------------------------------------------+
//|                                     ExpertAdvisorTradeHelper.mq4 |
//| ExpertAdvisorHelper　v0.0.1     Copyright 2017, Lukkou_EA_Trader |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "0.01"
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

// 日足の陽線陰線
#define PLUS_STICK (1)
#define MINUS_STICK (-1)
#define NON_STICK (0)

// 日付レンド上 下 無
#define DAY_TREND_PLUS (1)
#define DAY_TREND_MINUS (-1)
#define DAY_TREND_NON (0)

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