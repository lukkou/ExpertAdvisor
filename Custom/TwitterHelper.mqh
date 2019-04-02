//+------------------------------------------------------------------+
//|                                                  TweetHelper.mqh |
//| TweetHelper v1.0.0                        Copyright 2017, Lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict
#import "shell32.dll"
    int ShellExecuteA(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
    int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

class TwitterHelper{
    private:
    string _path;

    public:
    //------------------------------------------------------------------
    // コンストラクタ
    ///param name="APIのフォルダパス"
    TwitterHelper(string path);

    //------------------------------------------------------------------
    // デストラクタ
    ~TwitterHelper();

    //------------------------------------------------------------------
    // 新規ポジションの情報を書き込み
    void NewOrderTweet(int orderNo,string symbol, string orderType, double price, string type);
    
    //------------------------------------------------------------------
    // ポジション解消の情報を書き込み
    void SettementOrderTweet(int orderNo, string symbol, string orderType, double price, double profits, string type);
    
    //------------------------------------------------------------------
    // トレード結果をTwitterへ書き込み
    void ExecTradeTweet(string tweetStr);

    //------------------------------------------------------------------
    // 指標発表の時間をTwitterへ書き込み
    void ExecTweet(string tweetStr);
};

    //------------------------------------------------------------------
    // コンストラクタ
    ///param path="APIのフォルダパス(空の場合はデフォルトパスを使用)"
    TwitterHelper::TwitterHelper(string path){
        if (path != ""){
            _path = path;
        }else{
            //空白はコマンドラインでエラーとなるためMSDOS時代のフォルダ名を使用する
            //Program Files (x86)→PROGRA~2
            //Program Files      →PROGRA~1
            _path = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";
        }
    }
    
    //------------------------------------------------------------------
    // デストラクタ
    TwitterHelper::~TwitterHelper(){
    }

    //------------------------------------------------------------------
    // 新規ポジションの場合のツイート文を作成
    TwitterHelper::NewOrderTweet(int orderNo,string symbol, string orderType, double price, string type)
    {
        string tweetStr = "";

        tweetStr = tweetStr + "\n";
        tweetStr = tweetStr + "OrderNo:" + IntegerToString(orderNo) + "\n";
        tweetStr = tweetStr + "Symbol:" + symbol + "\n";
        tweetStr = tweetStr + "OrderType :" + orderType + "\n";
        tweetStr = tweetStr + "Price :" + DoubleToStr(price) + "\n";
        tweetStr = tweetStr + "Type :" + type;

        this.ExecTradeTweet(tweetStr);
    }

    //------------------------------------------------------------------
    // ポジション解消の場合のツイート分を作成
    TwitterHelper::SettementOrderTweet(int orderNo,string symbol, string orderType, double price, double profits, string type)
    {
        string tweetStr = "";

        tweetStr = tweetStr + "\n";
        tweetStr = tweetStr + "OrderNo:" + IntegerToString(orderNo) + "\n";
        tweetStr = tweetStr + "Symbol:" + symbol + "\n";
        tweetStr = tweetStr + "OrderType :" + orderType + "\n";
        tweetStr = tweetStr + "Price :" + DoubleToStr(price) + "\n";
        tweetStr = tweetStr + "Profits :" + DoubleToStr(profits) + "\n";
        tweetStr = tweetStr + "Type :" + type;

        this.ExecTradeTweet(tweetStr);
    }

    //------------------------------------------------------------------
    // Twitterへの書き込み(取引結果専用)
    TwitterHelper::ExecTradeTweet(string tweetStr){
        if (IsDllsAllowed()) {
            string cmd = StringConcatenate("TWEET /I",tweetStr);

            //Tweetする!!
            ShellExecuteW(NULL,"open",_path,cmd,NULL,5);
        }else{
            PrintFormat(StringConcatenate(TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES),":Tweet fail."));
        }
    }

    //------------------------------------------------------------------
    // Twitterへの書き込み(なんでも)
    TwitterHelper::ExecTweet(string tweetStr){
        if (IsDllsAllowed()) {
            string cmd = StringConcatenate("TWEET",tweetStr);

            //Tweetする!!
            ShellExecuteW(NULL,"open",_path,cmd,NULL,5);
        }else{
            PrintFormat(StringConcatenate(TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES),":Tweet fail."));
        }
    }