//+------------------------------------------------------------------+
//|                                            ImportCandlestick.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/TwitterHelper.mqh>
#include <MQLMySQL.mqh>

//マジックナンバー 他のEAと当らない値を使用する。
input int MagicNumber = 11180000; 

string _host;
string _user;
string _password;
int _port;
string _database;
int _socket;
int _clientFlag;

/// <summary>
/// Expert initialization function(ロード時)
/// </summary>
int OnInit()
{
    string iniInfo = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Experts\\MyConnection.ini";
    Print ("パス: ",iniInfo);

    _host = ReadIni(iniInfo, "MYSQL", "Host");
    _user = ReadIni(iniInfo, "MYSQL", "User");
    _password = ReadIni(iniInfo, "MYSQL", "Password");
    _port = StrToInteger(ReadIni(iniInfo, "MYSQL", "Port"));
    _database = ReadIni(iniInfo, "MYSQL", "Database");
    _socket =  ReadIni(iniInfo, "MYSQL", "Socket");
    _clientFlag = StrToInteger(ReadIni(iniInfo, "MYSQL", "ClientFlag"));  

    Print ("Host: ",_host, ", User: ", _user, ", Database: ",_database);
    return(INIT_SUCCEEDED);
}

/// <summary>
/// Expert deinitialization function(ロード解除時)
/// </summary>
void OnDeinit(const int reason)
{

}

/// <summary>
/// Expert tick function(ローソク足ごとの実行)
/// </summary>
void OnTick()
{
    //USDJPYを更新
    MergeCandlestick("USDJPY");

    //USDEURを更新
    MergeCandlestick("USDEUR");

    //USDGBPを更新
    MergeCandlestick("USDGBP");

    //USDCADを更新
    MergeCandlestick("USDCAD");

    //USDAUDを更新
    MergeCandlestick("USDAUD");

    //USDCHFを更新
    MergeCandlestick("USDCHF");


    //EURJPYを更新
    MergeCandlestick("EURJPY");

    //GBPJPYを更新
    MergeCandlestick("GBPJPY");

    //CADJPYを更新
    MergeCandlestick("CADJPY");

    //AUDJPYを更新
    MergeCandlestick("AUDJPY");

    //CHFJPYを更新
    MergeCandlestick("CHFJPY");


    //EURGBPを更新
    MergeCandlestick("EURGBP");

    //EURCADを更新
    MergeCandlestick("EURCAD");

    //EURAUDを更新
    MergeCandlestick("EURAUD");

    //EURCHFを更新
    MergeCandlestick("EURCHF");


    //GBPCADを更新
    MergeCandlestick("GBPCAD");

    //GBPAUDを更新
    MergeCandlestick("GBPAUD");

    //GBPCHFを更新
    MergeCandlestick("GBPCHF");


    //CADAUDを更新
    MergeCandlestick("CADAUD");

    //CADCHFを更新
    MergeCandlestick("CADCHF");


    //AUDCHFを更新
    MergeCandlestick("AUDCHF");
}

/// <summary>
/// Expert tick function(ローソク足ごとの実行)
/// </summary>
void MergeCandlestick(string symbol)
{
    double open = iOpen(symbol,PERIOD_M1,0);
    double high = iHigh(symbol,PERIOD_M1,0);
    double low = iLow(symbol,PERIOD_M1,0);
    double close = iClose(symbol,PERIOD_M1,0);

    string localTime = TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES);
    string globalTime = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);

    StringReplace(localTime,".","/");
    StringReplace(globalTime,".","/");

    int db = MySqlConnect(_host, _user, _password, _database, _port, _socket, _clientFlag);

    string query = "";
    query = query + "insert ";
    query = query + "into ExchangeTimeLine(";
    query = query + "   symbol";
    query = query + "    , globaltime";
    query = query + "    , span";
    query = query + "    , localtime";
    query = query + "    , open";
    query = query + "    , high";
    query = query + "    , low";
    query = query + "    , close";
    query = query + ") ";
    query = query + "values ( ";
    query = query + "  '" + symbol + "'";
    query = query + "  , str_to_date('" + globalTime + ":00" + "','%Y-%m-%d %H:%i:%s')";
    query = query + "  , 1";
    query = query + "  , str_to_date('" + localTime + ":00" + "','%Y-%m-%d %H:%i:%s')";
    query = query + "  , " + DoubleToString(open);
    query = query + "  , " + DoubleToString(high);
    query = query + "  , " + DoubleToString(low);
    query = query + "  , " + DoubleToString(close);
    query = query + ") ";
    query = query + "  on duplicate key update ";
    query = query + "  open = " + DoubleToString(open);
    query = query + "  , high = " + DoubleToString(high);
    query = query + "  , low = " + DoubleToString(low);
    query = query + "  , close = " + DoubleToString(close);

    MySqlExecute(db, query);
    MySqlDisconnect(db);
}

