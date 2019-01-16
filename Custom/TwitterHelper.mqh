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
    // トレード結果をTwitterへ書き込み
    void ExecTradeTweet(string symbol,string order,string price,string time);

    //------------------------------------------------------------------
    // 指標発表の時間をTwitterへ書き込み
    void ExecIndexTweet(string indexName,string time);
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
    // Twitterへの書き込み
    TwitterHelper::ExecTradeTweet(string symbol,string order,string price,string time){
    PrintFormat("S");
        if (IsDllsAllowed()) {
            string cmd = StringConcatenate("TWEET /I /D /T ",symbol," ",order," ",price);

            //Tweetする!!
            ShellExecuteW(NULL,"open",_path,cmd,NULL,5);
        }else{
            PrintFormat(StringConcatenate(time,":Tweet fail."));
        }
        PrintFormat("E");
    }