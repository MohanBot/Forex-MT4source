/*  
XLogRegAdaptiveRSI_ZLBuySellStrat_v1 03/22/26 03:38pm
CUSTOMIZE THE FOLLOWING TO GET YOUR OWN EXPERT ADVISOR UP AND RUNNING

EvaluateEntry : To insert your custom entry signal
 
EvaluateExit : To insert your custom exit signal

ExecuteTrailingStop : To insert your trailing stop rules

StopLossPriceCalculate : To set your custom Stop Loss value

TakeProfitPriceCalculate : To set your custom Take Profit value



*/

/* Recommended settings tested on 03/22/26 03:38pm
Timeframe=5m
RSI Length 14
ZL Length=15

*/

//-PROPERTIES-//
//Properties help the software look better when you load it in MT4
//Provide more information and details
//This is what you see in the About tab when you load an Indicator or an Expert Advisor
#property link          "manmohan.pardesi@gmail.com"
#property version       "1.00"
#property strict true
#property copyright     "manmohan.pardesi@gmail.com 2026"
#property description   "EA" 
#property description   " "
#property description   "WARNING!!: You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for any damage or loss."
#property description   " "
//You can add an icon for when the EA loads on chart but it's not necessary
//The commented line below is an example of icon, icon must be in the MQL4/Files folder and have a ico extension
#property icon          ".\\..\\..\\Files\\squirrel-logo-vector.ico"

//-INCLUDES-//
//Include allows to import code from another file
//In the following instance the file has to be placed in the MQL4/Include Folder
//#include ".\\..\\..\\Include\\XEAUtilsAndErrorHandling.mqh"
#include <XEAUtilsAndErrorHandling.mqh>
//-COMMENTS-//
//This is a single line comment and I do it placing // at the start of the comment, this text is ignored when compiling

/*
This is a multi line comment
it starts with /* and it finishes with the * and / like below
*/


//-ENUMERATIVE VARIABLES-//
//Enumerative variables are useful to associate numerical values to easy to remember strings
//It is similar to constants but also helps if the variable is set from the input page of the EA
//The text after the // is what you see in the input paramenters when the EA loads
//It is good practice to place all the enumberative at the start

//Enumerative for the hour of the day
enum ENUM_HOUR{
   h00=00,     //00:00
   h01=01,     //01:00
   h02=02,     //02:00
   h03=03,     //03:00
   h04=04,     //04:00
   h05=05,     //05:00
   h06=06,     //06:00
   h07=07,     //07:00
   h08=08,     //08:00
   h09=09,     //09:00
   h10=10,     //10:00
   h11=11,     //11:00
   h12=12,     //12:00
   h13=13,     //13:00
   h14=14,     //14:00
   h15=15,     //15:00
   h16=16,     //16:00
   h17=17,     //17:00
   h18=18,     //18:00
   h19=19,     //19:00
   h20=20,     //20:00
   h21=21,     //21:00
   h22=22,     //22:00
   h23=23,     //23:00
};

//Enumerative for the entry signal value
enum ENUM_SIGNAL_ENTRY{
   SIGNAL_ENTRY_NEUTRAL=0,    //SIGNAL ENTRY NEUTRAL
   SIGNAL_ENTRY_BUY=1,        //SIGNAL ENTRY BUY
   SIGNAL_ENTRY_SELL=-1,      //SIGNAL ENTRY SELL
};

//Enumerative for the exit signal value
enum ENUM_SIGNAL_EXIT{
   SIGNAL_EXIT_NEUTRAL=0,     //SIGNAL EXIT NEUTRAL
   SIGNAL_EXIT_BUY=1,         //SIGNAL EXIT BUY
   SIGNAL_EXIT_SELL=-1,       //SIGNAL EXIT SELL
   SIGNAL_EXIT_ALL=2,         //SIGNAL EXIT ALL
};

//Enumerative for the allowed trading direction
enum ENUM_TRADING_ALLOW_DIRECTION{
   TRADING_ALLOW_BOTH=0,      //ALLOW BOTH BUY AND SELL
   TRADING_ALLOW_BUY=1,       //ALLOW BUY ONLY
   TRADING_ALLOW_SELL=-1,     //ALLOW SELL ONLY
};

//Enumerative for the base used for risk calculation
enum ENUM_RISK_BASE{
   RISK_BASE_EQUITY=1,        //EQUITY
   RISK_BASE_BALANCE=2,       //BALANCE
   RISK_BASE_FREEMARGIN=3,    //FREE MARGIN
};

//Enumerative for the default risk size
enum ENUM_RISK_DEFAULT_SIZE{
   RISK_DEFAULT_FIXED=1,      //FIXED SIZE
   RISK_DEFAULT_AUTO=2,       //AUTOMATIC SIZE BASED ON RISK
};

//Enumerative for the Stop Loss mode
enum ENUM_MODE_SL{
   SL_FIXED=0,                //FIXED STOP LOSS
   SL_AUTO=1,                 //AUTOMATIC STOP LOSS
   SL_EA_DETERMINES=2,                 //EA DETERMINES, NO STOP LOSS MP04
};

//Enumerative for the Take Profit Mode
enum ENUM_MODE_TP{
   TP_FIXED=0,                //FIXED TAKE PROFIT
   TP_AUTO=1,                 //AUTOMATIC TAKE PROFIT
    TP_EA_DETERMINES=2,                 //EA DETERMINES TAKE PROFIT MP04
};

//Enumerative for the stop loss calculation
enum ENUM_MODE_SL_BY{
   SL_BY_POINTS=0,            //STOP LOSS PASSED IN POINTS
   SL_BY_PRICE=1,             //STOP LOSS PASSED BY PRICE
};

//MP03
//Enumerative for the OrderType
enum ENUM_CUSTOM_ORDER_TYPE{
   ORDER_BUY_ORDER=0,     
   ORDER_SELL_ORDER=1, 
   ORDER_NA_ORDER=99       
};

enum ENUM_SHAPE
{
    ARROW = 226,           // Arrow
   // DN_ARROW = 233,      // MP Down Arrow
    BOLD_ARROW = 234,      // Bold Arrow
    HALLOW_ARROW = 242,    // Hallow Arrow
    WING = 218,            // Wing
    CIRCLE = 159,          // Circle
    SQUARE = 167,          // Square
    RHOMBUS = 119,         // Rhombus
    STAR = 172             // Star
};

enum ENUM_YESNO
{
   NO,     // No
   YES       // Yes
};

#define XZL_TOS_IND ".\\X\\XZeroLagMA_tos_v2"  // Indicator name of the Zero Lag MA
#define XADAP_RSI_IND ".\\X\\XAdaptive_RSI_RescRSI_NoVolume_v1"     // Indicator name of the Adaptive RSI
//#define XLINLOG_TOS_IND ".\\X\\XLinLogIndicator_wSlope_v4" // Indicator name of the Linear Log regression
#define XHAHIST_TOS_IND ".\\X\\XHAHistogram_tos_v1" // Indicator name of the Heiken Aishi histogram
//-INPUT PARAMETERS-//
//The input parameters are the ones that can be set by the user when launching the EA
//If you place a comment following the input variable this will be shown as description of the field

//This is where you should include the input parameters for your entry and exit signals
input string Comment_strategy="==========";                          //Entry And Exit Settings

input ENUM_YESNO EA_debug = NO; // debug?  
input int EA_MinBarsRequired = 0; // MP EA_MinBarsRequired set this to 0 in live trading and suitable value during strategy testing
input int EA_CandlesBack = 5; // EA_CandlesBack was 13 07/21/22
input ENUM_YESNO EA_showOrderArrows= YES; // Show buy sell order arrows?  
//MP082822 input int EA_RWD_bars_ago = 5;

input ENUM_YESNO EA_isVolume = NO; // Consider volume?

input double EA_LossLevelAlert = 150; // Close buy/sell trade when loss level reached
input double EA_LossMode = 0; // Is loss alert requested for 0 - Amount in $, 1 -in points
input ENUM_YESNO EA_isAlertAndNotify = YES; // Alert of EA on?  
input int EA_DelayFactor = 5; // how many bars to wait before next order?

//Add in this section the parameters for the indicators used in your entry and exit
/*input string Comment_x0="=========="; //params for TSV
input int      EA_tsv_length=26;  
input int      EA_tsv_ma_period=13;  

input string Comment_x2="=========="; //params for HH LH HL LL Indicator
input int  EA_HHLHHLLL_inputLookback        = 5;  
input int   EA_HHLHHLLL_inputLookahead        = 5;  
input ENUM_SHAPE EA_HHLHHLLL_inputShape = ARROW;    // Arrow Shape

input string Comment_x3="=========="; //params for XHighLowBandInd
input int EA_MA1_Period = 55;
input int EA_MA1_Shift  = 8;
input int EA_MA1_PriceTypeH = PRICE_HIGH;  // 0: Close, 1: Open, 2:High, 3:Low, 4: Median (high+low)/2
input int EA_MA1_AvgTypeH = MODE_EMA;  // Average type
input int EA_MA1_PriceTypeL = PRICE_LOW;  // 0: Close, 1: Open, 2:High, 3:Low, 4: Median (high+low)/2
input int EA_MA1_AvgTypeL = MODE_EMA;  // Average type
input int EA_MaxBarsToCalc3 = 2500; // limit calculations to max bars
*/
input string Comment_x4="=========="; //params for XAdaptive_RSI_RescRSI_NoVolume_v1

input int EA_ADAP_RSI_Length = 14;
input int EA_ADAP_RSI_MALength = 21;
input int EA_ADAP_RSI_Length_in = 70;
input int EA_ADAP_RSI_Length_out = 14;
enum EA_ADAP_RSI_ENUM_ANCHOR { ANCHOR_FOUR_HOURS, ANCHOR_DAY, ANCHOR_WEEK, ANCHOR_MONTH };
input EA_ADAP_RSI_ENUM_ANCHOR EA_ADAP_RSI_anchorPeriod = ANCHOR_DAY;
input string EA_ADAP_RSI_BeginTime = "08:00";
input int EA_ADAP_RSI_MAFast_length = 3;
input int EA_ADAP_RSI_MASlow_length = 5;
input int EA_ADAP_RSI_MaxBarsToCalc = 2500;

input string Comment_x5="==========";  // params for XZeroLagMA_tos_v2

//---- Inputs
input int    EA_ZL_InpLength     = 15;
input int    EA_ZL_MaxBarsToCalc = 2500;


input string Comment_x6="=========="; //params for XHAHistogram_tos_v1
input int             EA_HA_HIST_InpPeriod        = 6;
input int             EA_HA_HIST_InpSignalLength  = 5;
input ENUM_MA_METHOD  EA_HA_HIST_InpMAMethod      = MODE_EMA;
input double          EA_HA_HIST_InpWickThreshold = 0.05; // Sensitivity for Cyan/Magenta
input int             EA_HA_HIST_MaxBars          = 2500;

  
// MP added default expiration datetime
//datetime orderexpiry=StrToTime("2022.12.31 00:00")
  
//General input parameters
input string Comment_0="==========";                                 //Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE RiskDefaultSize=RISK_DEFAULT_FIXED;      //Position Size Mode
input double DefaultLotSize=0.5;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE RiskBase=RISK_BASE_BALANCE;                     //Risk Base
input int MaxRiskPerTrade=2;                                         //Percentage To Risk Each Trade
input double MinLotSize=0.05;                                        //Minimum Position Size Allowed
input double MaxLotSize=100;                                         //Maximum Position Size Allowed

input string Comment_1="==========";                                 //Trading Hours Settings
input bool UseTradingHours=true;                                 //Limit Trading Hours
input ENUM_HOUR TradingHourStart=h14;                                //Trading Start Hour (Broker Server Hour)
input ENUM_HOUR TradingHourEnd=h23;                                  //Trading End Hour (Broker Server Hour)

input string Comment_2="==========";                                 //Stop Loss And Take Profit Settings
input ENUM_MODE_SL StopLossMode=SL_EA_DETERMINES;                            //Stop Loss Mode
input int DefaultStopLoss=0;                                         //Default Stop Loss In Points (0=No Stop Loss)
input int MinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int MaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input ENUM_MODE_TP TakeProfitMode=TP_EA_DETERMINES;                          //Take Profit Mode
input int DefaultTakeProfit=0;                                       //Default Take Profit In Points (0=No Take Profit)
input int MinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int MaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points
input string Comment_x9="=========="; //params for trade management
input double MaxDrawdownAmtOnEachEARun =           500;                       // Max drawdown Amt beyond which EA will not generate orders, In dollars
//MP123121 commented out input ENUM_MA_METHOD MAMethod=MODE_EMA;                           //MA Method
//MP123121 commented out input ENUM_APPLIED_PRICE MAAppliedPrice=PRICE_CLOSE;              //MA Applied Price
//MP003
//Note Exness charges $3.5 commissions (or 35 points) per lot 
//and 12 points (or $12) to modify order
//For 1/2 lot the fees are the same
// For 10 lot the commissions are $70 and 2.5 pips $25 to modify order

extern string Reward_Size = "Reward ratio - decimals ok e.g. 2.5 = reward would be is risk x 2.5 in pips";
extern double Reward_Ratio = 20 ;
int BasePadAmount = 10; //in Points
double pips;
double FloatingPnL = 0;
double BeginningBalance =  AccountEquity();
double LastOrderPnL = 0;
double CurrOrderPnL = 0.0;
double LastFPL=0.0;
ENUM_CUSTOM_ORDER_TYPE CurrOrdType = ORDER_NA_ORDER;
int CurrOrdNum = 0;
int LastOrdNum = 0;
int LastBN = 0;
input string Comment_3="==========";                                 //Trailing Stop Settings
input bool UseTrailingStop=false;                                    //Use Trailing Stop
//MP03 added
input int WhenToTrail = 60; // In points, when to TrailStop so that profits can be locked
input int TrailStopLossAdjustBy = 25; // In points, New stop loss
 
input string Comment_4="==========";                                 //Additional Settings
input int MagicNumber=336677880;   //Magic Number For The Orders Opened By This EA
input string OrderNote="Please remember Manmohan.Pardesi@gmail if you profitted :)";                                           //Comment For The Orders Opened By This EA
input int Slippage=10;                                                //Slippage in points
input int MaxSpread=30;                                    //Maximum Allowed Spread To Trade In Points
 

//-GLOBAL VARIABLES-//
//The variables included in this section are global, hence they can be used in any part of the code
//It is useful to add a comment to remember what is the variable for

bool IsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool IsNewCandle=false;                   //Indicates if this is a new candle formed
bool IsSpreadOK=false;                    //Indicates if the spread is low enough to trade
bool IsOperatingHours=false;              //Indicates if it is possible to trade at the current time (server time)
bool IsTradedThisBar=false;               //Indicates if an order was already executed in the current candle

double TickValue=0;                       //Value of a tick in account currency at 1 lot
double LotSize=0;                         //Lot size for the position

//MP083022 int OrderOpRetry=10;                      //Number of attempts to retry the order submission
int OrderOpRetry=10;                      //Number of attempts to retry the order submission
int TotalOpenOrders=0;                    //Number of total open orders
int TotalOpenBuy=0;                       //Number of total open buy orders
int TotalOpenSell=0;                      //Number of total open sell orders
int StopLossBy=SL_BY_POINTS;              //How the stop loss is passed for the lot size calculation

ENUM_SIGNAL_ENTRY SignalEntry=SIGNAL_ENTRY_NEUTRAL;      //Entry signal variable
ENUM_SIGNAL_EXIT SignalExit=SIGNAL_EXIT_NEUTRAL;         //Exit signal variable
 
const int EA_ENTRY_CURRPER = 1;  
const int EA_ENTRY_PREVPER =2;  
const int EA_EXIT_CURRPER = 1;  
const int EA_EXIT_PREVPER = 2; 
    
//Indicator buffers

//XZeroLagMA_tos_v2
double EA_ZL_ZLHist=0;
double EA_ZL_EMAHist=1;
double EA_ZL_ZLMABuffer=2;
double EA_ZL_EMABuffer=3;

//XAdaptive_RSI_RescRSI_NoVolume_v1
double EA_ADAP_RSI_RSIBuf=0; // gray line RSI
double EA_ADAP_RSI_RSNeut=1;
double EA_ADAP_RSI_RSBull=2;
double EA_ADAP_RSI_RSBear=3;
double EA_ADAP_RSI_SMOOTH=4; // smooth MA yellow line

// XHAHistogram_tos_v1.mq4
double EA_HA_HIST_BufG=0; //  Bullish
double EA_HA_HIST_BufR=1; //  Bearish
double EA_HA_HIST_BufC=2; //  Strong Bull
double EA_HA_HIST_BufM=3; //  Strong Bear
double EA_HA_HIST_BufS=4; //  Signal Line

 
//MP const datetime DefaultOrderExpiry  = CurTime()+PERIOD_M1*60;
const datetime DefaultOrderExpiry  = CurTime()+(PERIOD_M5*60)*2;
int PipAdjust=1;  
//MP added
string messagetextPrefix;
string messagetext;
datetime NextTradeTime = 0;
int tfDelayMinutes=0;
datetime LastTradeTime = 0;

           
//MP 01/03/2022
// CREATE ARROW CODE refer https://docs.mql4.com/constants/objectconstants/enum_object/obj_arrow
//--- input parameters of the script
input string Comment_5="=========="; // parameters for Order buy/sell arrows
input string            InpName="Arrow";        // Arrow name
input int               InpDate=50;             // Anchor point date in %
input int               InpPrice=50;            // Anchor point price in %
input ENUM_ARROW_ANCHOR InpAnchor=ANCHOR_TOP;   // Anchor type
input color             InpColor=clrDodgerBlue; // Arrow color
input ENUM_LINE_STYLE   InpStyle=STYLE_SOLID;   // Border line style
input int               InpWidth=10;            // Arrow size
input bool              InpBack=false;          // Background arrow
input bool              InpSelection=false;     // Highlight to move
input bool              InpHidden=true;         // Hidden in the object list
input long              InpZOrder=0;            // Priority for mouse click
//+------------------------------------------------------------------+
//| Create the arrow                                                 |
//+------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID=0,           // chart's ID
                 const string            name="Arrow",         // arrow name
                 const int               sub_window=0,         // subwindow index
                 datetime                time=0,               // anchor point time
                 double                  price=0,              // anchor point price
                 const uchar             arrow_code=252,       // arrow code
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position
                 const color             clr=clrRed,           // arrow color
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                 const int               width=3,              // arrow size
                 const bool              back=false,           // in the background
                 const bool              selection=true,       // highlight to move
                 const bool              hidden=true,          // hidden in the object list
                 const long              z_order=0)            // priority for mouse click
 {
   //--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
   //--- reset the error value
   ResetLastError();
   //--- create an arrow
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price)) {
      if (EA_debug) Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return(false);
   }
   //--- set the arrow code
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
   //--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   //--- set the arrow color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   //--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   //--- set the arrow's size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   //--- enable (true) or disable (false) the mode of moving the arrow by mouse
   //--- when creating a graphical object using ObjectCreate function, the object cannot be
   //--- highlighted and moved by default. Inside this method, selection parameter
   //--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   //--- successful execution
   return(true);
 }
  
//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
{
   //--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
   //--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
}
                       

//-NATIVE MT4 EXPERT ADVISOR RUNNING FUNCTIONS-//

//OnInit is executed once, when the EA is loaded
//OnInit is also executed if the time frame or symbol for the chart is changed
int OnInit(){
      Print("   BeginningBalance  " ,  BeginningBalance ); 
      
     //MP added
     string tfName=GetCurrentTFName();
     switch(_Period)
        {
            case PERIOD_M1: tfDelayMinutes = EA_DelayFactor * 1; 
            case PERIOD_M5: tfDelayMinutes = EA_DelayFactor * 5; 
            case PERIOD_M15: tfDelayMinutes = EA_DelayFactor* 15; 
            case PERIOD_M30: tfDelayMinutes =  EA_DelayFactor * 30; 
            case PERIOD_H1: tfDelayMinutes = EA_DelayFactor* 60; 
            case PERIOD_H4: tfDelayMinutes = EA_DelayFactor * 240; 
            case PERIOD_D1: tfDelayMinutes = EA_DelayFactor * 1440; 
            case PERIOD_W1: tfDelayMinutes = EA_DelayFactor * 10080; 
            case PERIOD_MN1: tfDelayMinutes = EA_DelayFactor * 43200; 
            default: tfDelayMinutes = 15;
            
         }
     //string strTime=(string)TimeHour(CurTime())+":"+(string)TimeMinute(CurTime());
     messagetextPrefix= _Symbol + ", " + tfName + ": ";

    int NrOfDigits = (int)MarketInfo(Symbol(),MODE_DIGITS);     
    if(NrOfDigits == 5 || NrOfDigits == 3)            
         PipAdjust = 10;                                
    else if(NrOfDigits == 4 || NrOfDigits == 2)           
         PipAdjust = 1;   
   //It is useful to set a function to check the integrity of the initial parameters and call it as first thing
   CheckPreChecks();
   //If the initial pre checks have something wrong, stop the program
   if(!IsPreChecksOk){
      OnDeinit(INIT_FAILED);
      return(INIT_FAILED);
   }   
   //Function to initialize the values of the global variables
   InitializeVariables();
   
   //If everything is ok the function returns successfully and the control is passed to a timer or the OnTike function
   return(INIT_SUCCEEDED);
}


//The OnDeinit function is called just before terminating the program
void OnDeinit(const int reason){
   //You can include in this function something you want done when the EA closes
   //For example clean the chart form graphical objects, write a report to a file or some kind of alert
      if (EA_debug) Print("in deinit "); 
      
       //--- Force chart redraw in Strategy Tester
   /*if(IsVisualMode())
   {
      ChartRedraw();
      // Debug: Log redraw attempt
      Print("ChartRedraw called in Visual Mode");
   }*/
}


//The OnTick function is triggered every time MT4 receives a price change for the symbol in the chart
void OnTick(){
    //MP03 added 
    if (Bars < EA_MinBarsRequired)
    {
       if (EA_debug) Print("Need minimum bars before generating buy sell signals "  );  
       return;
    }
    //else if (EA_debug) Print ("Bars : ", Bars);
    
   //Re-initialize the values of the global variables at every run
   InitializeVariables();
   //ScanOrders scans all the open orders and collect statistics, if an error occurs it skips to the next price change
   if(!ScanOrders()) return;
   //CheckNewBar checks if the price change happened at the start of a new bar
   CheckNewBar();
   //CheckOperationHours checks if the current time is in the operating hours
   CheckOperationHours();
   //CheckSpread checks if the spread is above the maximum spread allowed
   CheckSpread();
   //CheckTradedThisBar checks if there was already a trade executed in the current candle
   CheckTradedThisBar();
   //EvaluateExit contains the code to decide if there is an exit signal
   EvaluateExit();
   //ExecuteExit executes the exit in case there is an exit signal
   ExecuteExit();
   //Scan orders again in case some where closed, if an error occurs it skips to the next price change
   if(!ScanOrders()) return;
   //Execute Trailing Stop
     ExecuteTrailingStop();
   //EvaluateEntry contains the code to decide if there is an entry signal
   EvaluateEntry();
   //ExecuteEntry executes the entry in case there is an entry signal
   ExecuteEntry();
}


//-CUSTOM EA FUNCTIONS-//

//Perform integrity checks when the EA is loaded
void CheckPreChecks(){
   if (EA_debug) Print ("In Checkprechecks");
   IsPreChecksOk=true;
   //Check if Live Trading is enabled in MT4
   if(!IsTradeAllowed()){
      IsPreChecksOk=false;
      Print("Live Trading is not enabled, please enable it in MT4 and chart settings");
      return;
   }
   //Check if the default stop loss you are setting in above the minimum and below the maximum
   if(DefaultStopLoss<MinStopLoss || DefaultStopLoss>MaxStopLoss){
      IsPreChecksOk=false;
      Print("Default Stop Loss must be between Minimum and Maximum Stop Loss Allowed");
      return;
   }
   //Check if the default take profit you are setting in above the minimum and below the maximum
   if(DefaultTakeProfit<MinTakeProfit || DefaultTakeProfit>MaxTakeProfit){
      IsPreChecksOk=false;
      Print("Default Take Profit must be between Minimum and Maximum Take Profit Allowed");
      return;
   }
   //Check if the Lot Size is between the minimum and maximum
   if(DefaultLotSize<MinLotSize || DefaultLotSize>MaxLotSize){
      IsPreChecksOk=false;
      Print("Default Lot Size must be between Minimum and Maximum Lot Size Allowed");
      return;
   }
   //Slippage must be >= 0
   if(Slippage<0){
      IsPreChecksOk=false;
      Print("Slippage must be a positive value");
      return;
   }
   //MaxSpread must be >= 0
   if(MaxSpread<0){
      IsPreChecksOk=false;
      Print("Maximum Spread must be a positive value");
      return;
   }
   //MaxRiskPerTrade is a % between 0 and 100
   if(MaxRiskPerTrade<0 || MaxRiskPerTrade>100){
      IsPreChecksOk=false;
      Print("Maximum Risk Per Trade must be a percentage between 0 and 100");
      return;
   }
   //MP03
   //if (GlobalVariableCheck("CurrOrderNumber")== false) {
   //    GlobalVariableSet("CurrOrderNumber", 0);
   //}
   //if (GlobalVariableCheck("CurrOrderType")== false) {
   //      GlobalVariableSet("CurrOrderType",ORDER_NA_ORDER);
   //}  
}


//Initialize variables
void InitializeVariables(){
if (EA_debug) Print ("InitializeVariables");
   IsNewCandle=false;
   IsTradedThisBar=false;
   IsOperatingHours=false;
   IsSpreadOK=false;
   
   LotSize=DefaultLotSize;
   TickValue=0;
   
   TotalOpenBuy=0;
   TotalOpenSell=0;
   TotalOpenOrders=0;
   //MP03   
   //CurrOrderPnL=0; 
   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   SignalExit=SIGNAL_EXIT_NEUTRAL;
}


//Evaluate if there is an entry signal
void EvaluateEntry(){
   if (EA_debug) Print ("EvaluateEntry");
   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   //if(!IsSpreadOK) return;    //If the spread is too high don't give an entry signal
   if(UseTradingHours && !IsOperatingHours) return;   //If you are using trading hours and it's not a trading hour don't give an entry signal
   //MP uncommented below because we want to create orders on a new bar only
   if(!IsNewCandle) return;      //If you want to provide a signal only if it's a new candle opening
   //if(IsTradedThisBar) return;   //If you don't want to execute multiple trades in the same bar
   //MP03uncommented
    if(TotalOpenOrders>0) return; //If there are already open orders , you don't want to open more
   //MP 3/6/22 applied again 
   if (OrdersTotal() > 0 ) return;
   FloatingPnL=AccountEquity();
   if((FloatingPnL<BeginningBalance ) && (BeginningBalance - FloatingPnL) >= MaxDrawdownAmtOnEachEARun) 
   { 
     Print ("EA MAX DRAWDOWN LIMIT REACHED. NO MORE ORDERS WILL BE CREATED!!!!!!!!!!!!!!!");
     return;
   }  
    

   double ZLMACurr= iCustom(Symbol(),PERIOD_CURRENT,XZL_TOS_IND,EA_ZL_InpLength ,EA_ZL_MaxBarsToCalc,EA_ZL_ZLMABuffer,EA_ENTRY_CURRPER);
   double EMACurr= iCustom(Symbol(),PERIOD_CURRENT,XZL_TOS_IND,EA_ZL_InpLength ,EA_ZL_MaxBarsToCalc,EA_ZL_EMABuffer,EA_ENTRY_CURRPER);
  
   double ZLMAPrev= iCustom(Symbol(),PERIOD_CURRENT,XZL_TOS_IND,EA_ZL_InpLength ,EA_ZL_MaxBarsToCalc,EA_ZL_ZLMABuffer,EA_ENTRY_PREVPER);
   double EMAPrev= iCustom(Symbol(),PERIOD_CURRENT,XZL_TOS_IND,EA_ZL_InpLength ,EA_ZL_MaxBarsToCalc,EA_ZL_EMABuffer,EA_ENTRY_PREVPER);

   double RSICurr= iCustom(Symbol(),PERIOD_CURRENT,XADAP_RSI_IND,EA_ADAP_RSI_Length,
    EA_ADAP_RSI_Length,
    EA_ADAP_RSI_MALength,
    EA_ADAP_RSI_Length_in,
    EA_ADAP_RSI_Length_out,
    EA_ADAP_RSI_anchorPeriod,
    EA_ADAP_RSI_BeginTime,
    EA_ADAP_RSI_MAFast_length,
    EA_ADAP_RSI_MASlow_length,
    EA_ADAP_RSI_MaxBarsToCalc,
    EA_ADAP_RSI_RSIBuf,EA_ENTRY_CURRPER);
    
    double SmoothRSICurr= iCustom(Symbol(),PERIOD_CURRENT,XADAP_RSI_IND,EA_ADAP_RSI_Length,
    EA_ADAP_RSI_Length,
    EA_ADAP_RSI_MALength,
    EA_ADAP_RSI_Length_in,
    EA_ADAP_RSI_Length_out,
    EA_ADAP_RSI_anchorPeriod,
    EA_ADAP_RSI_BeginTime,
    EA_ADAP_RSI_MAFast_length,
    EA_ADAP_RSI_MASlow_length,
    EA_ADAP_RSI_MaxBarsToCalc,
    EA_ADAP_RSI_SMOOTH,EA_ENTRY_CURRPER);
    
    //double closePrice = Close[EA_ENTRY_CURRPER];
  
      if (EA_debug) Print ("ZLMACurr ",ZLMACurr);
    if (EA_debug) Print ("ZLMAPrev ",ZLMAPrev);
    if (EA_debug) Print ("EMACurr ",EMACurr);
    if (EA_debug) Print ("EMAPrev ",EMAPrev);
    if (EA_debug) Print ("RSICurr ",RSICurr);
    if (EA_debug) Print ("SmoothRSICurr ",SmoothRSICurr);
  
   
   bool buyCond1= 
         ((ZLMACurr >=EMACurr && ZLMAPrev<EMACurr) )
         && RSICurr > SmoothRSICurr  
         // && closePrice >= openPrice
         ? true:false;
          
   //This is where you should insert your Entry Signal for SELL orders
   //Include a condition to open a sell order, the condition will have to set SignalEntry=SIGNAL_ENTRY_SELL      
   
    bool sellCond1 =
        ((ZLMACurr <EMACurr && ZLMAPrev>EMACurr) )
         && RSICurr < SmoothRSICurr  
         //        closePrice <= openPrice
           
            ? true:false;
    
   if (buyCond1) // Long
   {
       SignalEntry=SIGNAL_ENTRY_BUY;
       if (EA_debug) Print ("Enter Long order 123X"); 
         
   }
   
   if (sellCond1) // Short
   {
       SignalEntry=SIGNAL_ENTRY_SELL;
       if (EA_debug) Print ("Enter short order 123X");
       

   }
}

//Execute entry if there is an entry signal
void ExecuteEntry(){
   if (EA_debug) Print("In ExecuteEntry "); 
    //MP041722 added 
    if(TotalOpenOrders>0) return; //If there are already open orders and you don't want to open more
    //MP08/09/20
    // if (TimeCurrent() < NextTradeTime) return;
   //If there is no entry signal no point to continue, exit the function
   if(SignalEntry==SIGNAL_ENTRY_NEUTRAL) return;
   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;
   
   //If there is a Buy entry signal
   if(SignalEntry==SIGNAL_ENTRY_BUY){    
      RefreshRates();   //Get latest rates
      Operation=OP_BUY; //Set the operation to BUY
      //MP03 use real open price instead of OpenPrice=Ask;    //Set the open price to Ask price
      // OpenPrice=Bid;    //Set the open price to Ask price
       OpenPrice=Ask; 
      ///MP sample code how to get last price /////////////////////////////////////
      // calculating the lowest value on the 10 consequtive bars in the range
      // from the 10th to the 19th index inclusive on the current chart
      ///           double val=Low[iLowest(NULL,0,MODE_LOW,10,10)];
      ///////////////////////////////////////////////
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0){
         StopLossPrice=OpenPrice-DefaultStopLoss*Point;
      }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO){
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=StopLossPriceCalculate(OP_BUY);
      }
       
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0){
         TakeProfitPrice=OpenPrice+DefaultTakeProfit*Point;
      }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO){
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=TakeProfitCalculate(OP_BUY,StopLossPrice);
      }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //MP 08/01/22 added
      if (EA_showOrderArrows) PaintArrowOnSignal(0, TimeCurrent(),OpenPrice);
   
      //Submit the order  
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
   }
   else if(SignalEntry==SIGNAL_ENTRY_SELL){
      //MP03
      //if (CurrOrderNum != 0 && CurrOrderNum > 0 && CurrOrderType== ORDER_SELL_ORDER) return;
      //if ( TotalOpenSell > 0 ) return;
   
      RefreshRates();   //Get latest rates
      Operation=OP_SELL; //Set the operation to SELL
       // OpenPrice=Ask;    //Set the open price to Bid price MP changed from Ask in comments
      OpenPrice=Bid;    //Set the open price to Bid price MP changed from Ask in comments
      
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0){
         StopLossPrice=OpenPrice+DefaultStopLoss*Point();
      }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO){
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=StopLossPriceCalculate(OP_SELL);
      }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0){
         TakeProfitPrice=OpenPrice-DefaultTakeProfit*Point();
      }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO){
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=TakeProfitCalculate(OP_SELL,StopLossPrice);
      }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits()); 
      //MP 08/01/22 added
      if (EA_showOrderArrows) PaintArrowOnSignal(0, TimeCurrent(),OpenPrice);
     
      //Submit the order  
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
   }   
}

//Evaluate if there is an exit signal
void EvaluateExit(){
   SignalExit=SIGNAL_EXIT_NEUTRAL;
   if (EA_debug) Print ("EvaluateExit");
   if (!SaveOrderProperties())
   {
      if (EA_debug) Print ("Error , unable to save order properties");
      return;
   }
   if (CurrOrdType == ORDER_NA_ORDER )
   {
      if (EA_debug) Print ("Nothing to evaluate");
      return;
   }
   if (EA_debug) Print("LastOrdNum" ,   LastOrdNum  ); 
   if (EA_debug) Print("CurrOrdNum" ,   CurrOrdNum  ); 
   if (EA_debug) Print("CurrOrdType    " , CurrOrdType); 
   if (EA_debug) Print("LastOrderPnL    " ,LastOrderPnL); 
   if (EA_debug) Print("CurrOrderPnL     " , CurrOrderPnL);  
   FloatingPnL=AccountEquity();
   if (EA_debug) Print("FloatingPnL    " , FloatingPnL); 
   if (EA_debug) Print("LastFPL    " ,LastFPL); 
           
   LastOrderPnL = LastOrderClosedProfit();
   if (EA_debug) Print("NEW LastOrderPnL  " ,LastOrderPnL); 
  
   if (EA_debug) Print("MaxDrawdownAmtOnEachEARun " ,  MaxDrawdownAmtOnEachEARun); 
   
/////////////////////
  
  
   double RSICurrX= iCustom(Symbol(),PERIOD_CURRENT,XADAP_RSI_IND,EA_ADAP_RSI_Length,
    EA_ADAP_RSI_Length,
    EA_ADAP_RSI_MALength,
    EA_ADAP_RSI_Length_in,
    EA_ADAP_RSI_Length_out,
    EA_ADAP_RSI_anchorPeriod,
    EA_ADAP_RSI_BeginTime,
    EA_ADAP_RSI_MAFast_length,
    EA_ADAP_RSI_MASlow_length,
    EA_ADAP_RSI_MaxBarsToCalc,
    EA_ADAP_RSI_RSIBuf,EA_EXIT_CURRPER);


  double SmoothRSICurrX= iCustom(Symbol(),PERIOD_CURRENT,XADAP_RSI_IND,EA_ADAP_RSI_Length,
    EA_ADAP_RSI_Length,
    EA_ADAP_RSI_MALength,
    EA_ADAP_RSI_Length_in,
    EA_ADAP_RSI_Length_out,
    EA_ADAP_RSI_anchorPeriod,
    EA_ADAP_RSI_BeginTime,
    EA_ADAP_RSI_MAFast_length,
    EA_ADAP_RSI_MASlow_length,
    EA_ADAP_RSI_MaxBarsToCalc,
    EA_ADAP_RSI_SMOOTH,EA_EXIT_CURRPER);

  double HABullishX= iCustom(Symbol(),PERIOD_CURRENT,XHAHIST_TOS_IND,EA_HA_HIST_InpPeriod,
     EA_HA_HIST_InpSignalLength,
     EA_HA_HIST_InpMAMethod  ,
     EA_HA_HIST_InpWickThreshold,
     EA_HA_HIST_MaxBars,
     EA_HA_HIST_BufG,EA_EXIT_CURRPER);

 double HABearishX= iCustom(Symbol(),PERIOD_CURRENT,XHAHIST_TOS_IND,EA_HA_HIST_InpPeriod,
     EA_HA_HIST_InpSignalLength,
     EA_HA_HIST_InpMAMethod  ,
     EA_HA_HIST_InpWickThreshold,
     EA_HA_HIST_MaxBars,
     EA_HA_HIST_BufR,EA_EXIT_CURRPER);

  
  double HAStrongBullX= iCustom(Symbol(),PERIOD_CURRENT,XHAHIST_TOS_IND,EA_HA_HIST_InpPeriod,
     EA_HA_HIST_InpSignalLength,
     EA_HA_HIST_InpMAMethod  ,
     EA_HA_HIST_InpWickThreshold,
     EA_HA_HIST_MaxBars,
     EA_HA_HIST_BufC,EA_EXIT_CURRPER);
     
  double HAStrongBearX= iCustom(Symbol(),PERIOD_CURRENT,XHAHIST_TOS_IND,EA_HA_HIST_InpPeriod,
     EA_HA_HIST_InpSignalLength,
     EA_HA_HIST_InpMAMethod  ,
     EA_HA_HIST_InpWickThreshold,
     EA_HA_HIST_MaxBars,
     EA_HA_HIST_BufM,EA_EXIT_CURRPER);


   int currentBarNumber=iBarShift(Symbol(),Period(),TimeCurrent(),false); 
   if (EA_debug) Print("currentBarNumber " ,  currentBarNumber); 
   if (EA_debug) Print("LastBarTraded " ,  LastBarTraded); 
   if (EA_debug) Print("LastBN " ,  LastBN); 
  
   int barsSinceLastTrade = iBarShift(Symbol(), Period(), LastBarTraded, false) 
                         - iBarShift(Symbol(), Period(), TimeCurrent(), false);
   if (EA_debug) Print("barsSinceLastTrade " ,  barsSinceLastTrade); 
    
   bool exitLongCond1 = 
        (        
          (  RSICurrX > SmoothRSICurrX  )
          //|| HABearishX < 0 
            || HAStrongBearX < 0
        ) 
        ? true : false;
    
   bool exitShortCond1 =
        (
           RSICurrX < SmoothRSICurrX 
          // || HABullishX > 0 
           || HAStrongBullX > 0  
                        
        )     
        ? true : false;
   
   //if (EA_debug && exitShortCond1) Print("message Sell Order will be closed for Order Number: ",  CurrOrdNum  ); 
   //if (EA_debug) Print("exitLongCond1 HH" ,    HH   ); 
          
   // Exit long 
   if (
         exitLongCond1         
      && CurrOrdType == ORDER_BUY_ORDER)
   { 
      SignalExit=SIGNAL_EXIT_BUY ;
      if (EA_debug) Print("Buy Order will be closed for Order Number: ",  CurrOrdNum  ); 
   }         
   // Exit Short 
   if (
      exitShortCond1  
      && CurrOrdType == ORDER_SELL_ORDER)
   { 
      SignalExit=SIGNAL_EXIT_SELL ;
      if (EA_debug) Print("Sell Order will be closed for Order Number: " ,  CurrOrdNum ); 
   } 
   if ( CurrOrdType == ORDER_BUY_ORDER && ProfitLossReached(OP_BUY))
   { 
      SignalExit=SIGNAL_EXIT_BUY ;
      if (EA_debug) Print("Exit buy, Loss amt reached for Order Number: ",  CurrOrdNum  ); 
   }    
   if ( CurrOrdType == ORDER_SELL_ORDER && ProfitLossReached(OP_SELL))
   { 
      SignalExit=SIGNAL_EXIT_SELL ;
      if (EA_debug) Print("Exit sell, Loss amt reached for Order Number: ",  CurrOrdNum  ); 
   } 
   //This is where you should include your exit signal for ALL orders
   //If you want, include a condition to close all the open orders, condition will have to set SignalExit=SIGNAL_EXIT_ALL then return  
}


//Execute exit if there is an exit signal
void ExecuteExit(){
   //If there is no Exit Signal no point to continue the routine
   if(SignalExit==SIGNAL_EXIT_NEUTRAL) return;
   //If there is an exit signal for all orders
   if(SignalExit==SIGNAL_EXIT_ALL){
      //Close all orders
      CloseAll(OP_ALL);
   }
   double OpenPrice=0;
    //If there is an exit signal for BUY order
   if(SignalExit==SIGNAL_EXIT_BUY){
      //MP 08/01/22 added
      OpenPrice = Bid;
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      if (EA_showOrderArrows) PaintArrowOnSignal(0, TimeCurrent(),OpenPrice);
   
      //Close all BUY orders
      CloseAll(OP_BUY);
   }
   //If there is an exit signal for SELL orders
   if(SignalExit==SIGNAL_EXIT_SELL){
      //MP 08/01/22 added
      OpenPrice = Ask;
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      if (EA_showOrderArrows) PaintArrowOnSignal(0, TimeCurrent(),OpenPrice);
    
      //Close all SELL orders
      CloseAll(OP_SELL);
   }

}


//Execute Trailing Stop to limit losses and lock in profits
void ExecuteTrailingStop(){
      //If the option is off then exit
   if(!UseTrailingStop) 
   {
       if (EA_debug) Print ("Use of Trail stop disabled" ); 
       return;
   }
       
   //If there are no open orders no point to continue the code
   if(TotalOpenOrders==0) 
   {
        if (EA_debug) Print ("TotalOpenOrders is 0" ); 
      return;
   }
       if (EA_debug) Print ("1Evaluating NewSL for AdjustTrail" ); 
 
   //if(!IsNewCandle) return;      //If you only want to do the stop trailing once at the beginning of a new candle
   //Scan all the orders to see if some needs a stop loss update
   for(int i=0;i<OrdersTotal();i++) {
      //If there is a problem reading the order print the error, exit the function and return false
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         return;
      }
      //If the order is not for the instrument on chart we can ignore it
      if(OrderSymbol()!=Symbol()) continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(OrderMagicNumber()!=MagicNumber) continue;
      //Define current values
      RefreshRates();
      double SLPrice=NormalizeDouble(OrderStopLoss(),Digits());     //Current Stop Loss price for the order
      double TPPrice=NormalizeDouble(OrderTakeProfit(),Digits());   //Current Take Profit price for the order
      double Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point();       //Current Spread for the instrument
      double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point(); //Minimum distance between current price and stop loss

       if (EA_debug) Print ("Evaluating NewSL for AdjustTrail" ); 
      //If it is a buy order then trail stop for buy orders
      if(OrderType()==OP_BUY){
         //Include code to trail the stop for buy orders
         double NewSLPrice=0;       
         //This is where you should include the code to assign a new value to the STOP LOSS
         //MP03 added
          //changed from Bid to Ask, refer https://www.mql5.com/en/forum/156010
         if ((Bid - OrderOpenPrice()) > WhenToTrail * Point) //MP080922
          //MP03 if ( OrderStopLoss() < Bid - TrailStopLossAdjustBy  * Point() )   
            //MP04   if ( OrderStopLoss() < (Ask - TrailStopLossAdjustBy  * Point()) )   
               {   
                  NewSLPrice =  StopLossPriceCalculate(OP_BUY);
                  // MP04 NewSLPrice =   NormalizeDouble( OrderOpenPrice() -  TrailStopLossAdjustBy   * Point(), Digits)  ;
                  if (EA_debug) Print ("MP   NewSLPrice for Buy Order", NewSLPrice );  
                  if (EA_debug) Print ("MP   Buy order ",   OrderTicket());  
              } 
            //MP03 OrderTakeProfit stays the same
         //MP04double NewTPPrice=TPPrice;
         //MP0417 Do not set reward risk ratio price after first modification 
         //double NewTPPrice=TakeProfitCalculate(OP_BUY,NewSLPrice);
         //MP080922double NewTPPrice=Bid;  //MP0417     
         //Normalize the price before the submission
         NewSLPrice=NormalizeDouble(NewSLPrice,Digits());
         //If there is no new stop loss set then skip to next order
         if(NewSLPrice==0) continue;
         //If the new stop loss price is lower than the previous then skip to next order, we only move the stop closer to the price and not further away
         if(NewSLPrice<=SLPrice) continue;
         //If the distance between the current price and the new stop loss is not enough then skip to next order
         //This allows to avoid error 130 when trying to update the order
         //DO NOT CHANGE THIS MP
          if(Bid-NewSLPrice<StopLevel) continue;
         //Submit the update
         //ModifyOrder(OrderTicket(),OrderOpenPrice(),NewSLPrice,NewTPPrice);   
         //MP added  refer https://www.mql5.com/en/forum/348456
         ModifyOrderWhenExecuteTrail(OrderTicket(),OrderOpenPrice(),NewSLPrice); 
      }
      //If it is a sell order then trail stop for sell orders
      if(OrderType()==OP_SELL){
         //Include code to trail the stop for sell orders
         double NewSLPrice=0;
         
         //This is where you should include the code to assign a new value to the STOP LOSS           
         //MP03 added
         //changed from Ask to Bid
         //MP012422  if (( OrderOpenPrice() - Bid) > WhenToTrail  * Point() )
         if ((OrderOpenPrice() - Ask) > WhenToTrail  * Point )
         //MP04 if ( OrderStopLoss() > (Bid + TrailStopLossAdjustBy   * Point()) )   
          {
                  NewSLPrice =   StopLossPriceCalculate(OP_SELL);
                  //MP04 NewSLPrice =   NormalizeDouble( OrderOpenPrice() +  TrailStopLossAdjustBy   * Point(), Digits)  ;  
                  if (EA_debug) Print ("MP   NewSLPrice for Sell Order", NewSLPrice );  
                  if (EA_debug) Print ("MP   Sell order ",   OrderTicket());  
          }  
          //MP03 OrderTakeProfit stays the same
         //MP04 double NewTPPrice=TPPrice;
         //MP0417   double NewTPPrice=TakeProfitCalculate(OP_SELL,NewSLPrice);
         //MP080922 double NewTPPrice=Ask;
       
         //Normalize the price before the submission
         NewSLPrice=NormalizeDouble(NewSLPrice,Digits());
         //If there is no new stop loss set then skip to next order
         if(NewSLPrice==0) continue;
         //If the new stop loss price is higher than the previous then skip to next order, we only move the stop closer to the price and not further away
         if(NewSLPrice>=SLPrice) continue;
         //If the distance between the current price and the new stop loss is not enough then skip to next order
         //This allows to avoid error 130 when trying to update the order
        //DO NOT CHANGE THIS MP
         if(NewSLPrice-Ask<StopLevel) continue;
           //Submit the update
         //ModifyOrder(OrderTicket(),OrderOpenPrice(),NewSLPrice,NewTPPrice);  
               //MP added 
          ModifyOrderWhenExecuteTrail(OrderTicket(),OrderOpenPrice(),NewSLPrice); 
         
      }
   }
   return;
}


//Check and return if the spread is not too high
void CheckSpread(){
      //Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
      int SpreadCurr=(int)MarketInfo(Symbol(),MODE_SPREAD);
      if(SpreadCurr<=MaxSpread){
         IsSpreadOK=true;
      }
      else{
         IsSpreadOK=false;
      }
}


//Check and return if it is operation hours or not
void CheckOperationHours(){
   //If we are not using operating hours then IsOperatingHours is true and I skip the other checks
   if(!UseTradingHours){
      IsOperatingHours=true;
      return;
   }
   //Check if the current hour is between the allowed hours of operations, if so IsOperatingHours is set true
   if(TradingHourStart==TradingHourEnd && Hour()==TradingHourStart) IsOperatingHours=true;
   if(TradingHourStart<TradingHourEnd && Hour()>=TradingHourStart && Hour()<=TradingHourEnd) IsOperatingHours=true;
   if(TradingHourStart>TradingHourEnd && ((Hour()>=TradingHourStart && Hour()<=23) || (Hour()<=TradingHourEnd && Hour()>=0))) IsOperatingHours=true;
}


//Check if it is a new bar
datetime NewBarTime=TimeCurrent();
void CheckNewBar(){
   //NewBarTime contains the open time of the last bar known
   //if that open time is the same as the current bar then we are still in the current bar, otherwise we are in a new bar
   if(NewBarTime==iTime(Symbol(),PERIOD_CURRENT,0)) IsNewCandle=false;
   else{
      NewBarTime=iTime(Symbol(),PERIOD_CURRENT,0);
      IsNewCandle=true;
   }
}


//Check if there was already an order open this bar
datetime LastBarTraded;
void CheckTradedThisBar(){
   //LastBarTraded contains the open time the last trade
   //if that open time is in the same bar as the current then IsTradedThisBar is true
   if(iBarShift(Symbol(),PERIOD_CURRENT,LastBarTraded)==0) IsTradedThisBar=true;
   else IsTradedThisBar=false;
}


//Lot Size Calculator
void LotSizeCalculate(double SL=0){
   //If the position size is dynamic
   if(RiskDefaultSize==RISK_DEFAULT_AUTO){
      //If the stop loss is not zero then calculate the lot size
      if(SL!=0){
         double RiskBaseAmount=0;
         //TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
         TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);    
         //Define the base for the risk calculation depending on the parameter chosen    
         if(RiskBase==RISK_BASE_BALANCE) RiskBaseAmount=AccountBalance();
         if(RiskBase==RISK_BASE_EQUITY) RiskBaseAmount=AccountEquity();
         if(RiskBase==RISK_BASE_FREEMARGIN) RiskBaseAmount=AccountFreeMargin();
         //Calculate the Position Size
         LotSize=(RiskBaseAmount*MaxRiskPerTrade/100)/(SL*TickValue);
      }
      //If the stop loss is zero then the lot size is the default one
      if(SL==0){
         LotSize=DefaultLotSize;
      }
   }
   //Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size
   LotSize=MathFloor(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
   //Limit the lot size in case it is greater than the maximum allowed by the user
   if(LotSize>MaxLotSize) LotSize=MaxLotSize;
   //Limit the lot size in case it is greater than the maximum allowed by the broker
   if(LotSize>MarketInfo(Symbol(),MODE_MAXLOT)) LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
   //If the lot size is too small then set it to 0 and don't trade
   if(LotSize<MinLotSize || LotSize<MarketInfo(Symbol(), MODE_MINLOT)) LotSize=0;
}

//Profit target or Loss reached?
bool ProfitLossReached(int Command=-1){
      double profitBuy=0;
      double profitSell=0;
      double op=0;
      bool raisealert=false;
      if (EA_debug) Print("Point() will return", DoubleToString(Point(),5));
       if (EA_debug) Print("MODE_POINT returns", DoubleToString(MarketInfo( OrderSymbol( ) , MODE_POINT)));
                  
      for(int i=OrdersTotal()-1; i>=0; i--) {
        if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         raisealert=false;
         break;
         
        }
        if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol() && OrderType()==Command) {
           RefreshRates();
           op=NormalizeDouble(OrderOpenPrice(),Digits());
           if(Command==OP_BUY) 
           {   
                if (EA_LossMode == 1) profitBuy=profitBuy+(Bid - op) / Point();  // in points
                else profitBuy =  OrderProfit()+OrderCommission()+OrderSwap(); // in Amt
               
                if (profitBuy <= -EA_LossLevelAlert)
                {
                   if (EA_debug) Print("For buy order , Max Order Loss amount reached!! " + DoubleToString(profitBuy ,5));
                   raisealert=true;
                   break; 
                } 
              
           }
                      
           if(Command==OP_SELL)
           {
               if (EA_LossMode == 1) profitSell=profitSell+(op - Ask)/Point();  // in points
               else profitSell =  OrderProfit()+OrderCommission()+OrderSwap(); // in Amt
      
               if (profitSell <= -EA_LossLevelAlert)
               {
                   if (EA_debug) Print("For sell order , Max Order Loss amount reached!! " + DoubleToString(profitSell ,5));
                    raisealert=true;    
                    break;           
   
               }                          
           }                           
        }
      } // for
      return raisealert;
}

//Stop Loss Price Calculation if dynamic
double StopLossPriceCalculate(int Command=-1){
    double StopLossPrice=0;
    //Include a value for the stop loss, ideally coming from an indicator
    //MP03 added
    //double ticksize = MarketInfo(Symbol(),MODE_TICKSIZE);
    //if (ticksize == 0.00001  || ticksize == 0.001)
    // pips = ticksize * 10;
    //  else pips = ticksize;
    
    // TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);    
    //   if (EA_debug) Print ("LotSize", LotSize);  
         
    //Add minimum broker allowed stop loss
    double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL); //returns in Points eg 12 for Euros
    if (EA_debug) Print ("StopLevel=" , StopLevel);
    double PadAmount =  (StopLevel  +   BasePadAmount  ) * Point    ; 
    if (EA_debug) Print ("PadAmount" , PadAmount);
    if(Command==OP_BUY){    
       //MP double SLPriceCurr=  iCustom(Symbol(),PERIOD_CURRENT,"XChandelier_Exits_v3",CHAND_Range,CHAND_Shift,CHAND_ATRPeriod,CHAND_ATRMultipl,CHANDEXITBuyBuffer,1); 
       double SLPriceCurr=  EMPTY_VALUE;
      
       int buyStopCandle = iLowest(Symbol(),PERIOD_CURRENT, MODE_LOW, EA_CandlesBack,1); 
       double buyStopPrice = NormalizeDouble(Low[buyStopCandle] -  PadAmount, Digits)    ;   
  
       if (SLPriceCurr == EMPTY_VALUE )
       {
            
               StopLossPrice = buyStopPrice;  
       }
       //  else if (Ask < SLPriceCurr)
       //     StopLossPrice = buyStopPrice;       
        else
            StopLossPrice = SLPriceCurr;
     
      if (EA_debug) Print ("Buying StopLossPrice" , StopLossPrice);
    }
    if(Command==OP_SELL){  
        //MPdouble SLPriceCurr=  iCustom(Symbol(),PERIOD_CURRENT,"XChandelier_Exits_v3",CHAND_Range,CHAND_Shift,CHAND_ATRPeriod,CHAND_ATRMultipl,CHANDEXITSellBuffer,1); 
          double SLPriceCurr= EMPTY_VALUE;
          
        int sellStopCandle = iHighest(Symbol(),PERIOD_CURRENT, MODE_HIGH, EA_CandlesBack,1);
        double sellStopPrice = NormalizeDouble(High[sellStopCandle] +  PadAmount   , Digits)  ;
        if (SLPriceCurr == EMPTY_VALUE)          
        {            
             StopLossPrice=sellStopPrice;
        }
        // else if (Bid > SLPriceCurr)
        //   StopLossPrice=sellStopPrice;
        else  StopLossPrice=SLPriceCurr;    
       if (EA_debug) Print ("Selling StopLossPrice" , StopLossPrice);  
    }   
    return StopLossPrice;
}
/*
//Stop Loss Price Calculation if dynamic
double StopLossPriceCalculate(int Command=-1){
    double StopLossPrice=0;
    //Include a value for the stop loss, ideally coming from an indicator
    //MP03 added
    //double ticksize = MarketInfo(Symbol(),MODE_TICKSIZE);
    //if (ticksize == 0.00001  || ticksize == 0.001)
    // pips = ticksize * 10;
    //  else pips = ticksize;
    
    // TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);    
    //   if (EA_debug) Print ("LotSize", LotSize);  
         
    //Add minimum broker allowed stop loss
    double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL); //returns in Points eg 12 for Euros
    if (EA_debug) Print ("StopLevel=" , StopLevel);
    double PadAmount =  (StopLevel  +   BasePadAmount  ) * Point    ; 
    if (EA_debug) Print ("PadAmount" , PadAmount);
    if(Command==OP_BUY){
         int buyStopCandle = iLowest(Symbol(),PERIOD_CURRENT, MODE_LOW, EA_CandlesBack,1);
        double buyStopPrice = NormalizeDouble(Low[buyStopCandle] -  PadAmount, Digits)    ;
        StopLossPrice=buyStopPrice;
     
      if (EA_debug) Print ("Buy StopLossPrice" , StopLossPrice);
  
    }
    if(Command==OP_SELL){
       int sellStopCandle = iHighest(Symbol(),PERIOD_CURRENT, MODE_HIGH, EA_CandlesBack,1);
         double sellStopPrice = NormalizeDouble(High[sellStopCandle] +  PadAmount   , Digits)  ;
        StopLossPrice=sellStopPrice;
       
       if (EA_debug) Print ("sell StopLossPrice" , StopLossPrice);  
    }   
    return StopLossPrice;
}
*/

//Take Profit Price Calculation if dynamic
double TakeProfitCalculate(int Command=-1, double StopLossPrice=0){
   double TakeProfitPrice=0;
   //Include a value for the take profit, ideally coming from an indicator
        if (EA_debug) Print ("StopLossPrice" , StopLossPrice);
   if(Command==OP_BUY){
     double pips_to_bsl = NormalizeDouble(  Ask - StopLossPrice      ,  Digits) ; //changed from Bid to Ask
     TakeProfitPrice=Ask  + pips_to_bsl  * Reward_Ratio;
     if (EA_debug) Print ("pips_to_bsl " , pips_to_bsl );
     if (EA_debug) Print ("Buy TakeProfitPrice" , TakeProfitPrice);
   }
   if(Command==OP_SELL){
       double pips_to_ssl =NormalizeDouble(   StopLossPrice - Bid,  Digits);  
       TakeProfitPrice= Bid - pips_to_ssl  * Reward_Ratio  ;
       if (EA_debug) Print ("pips_to_ssl " , pips_to_ssl );
       if (EA_debug) Print ("Sell TakeProfitPrice" , TakeProfitPrice);
   }
   return TakeProfitPrice;
}



//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice,   datetime Expiration=0){
   //Retry a number of times in case the submission fails
   Expiration= DefaultOrderExpiry ;
   int lastBarTraded=iBarShift(Instrument,Period(),LastTradeTime,false); 
   //MP note: When LastTradeTime = 0, it returns a very large number
   
   for(int i=1; i<=OrderOpRetry; i++){
      //Set the color for the open arrow for the order
      color OpenColor=clrBlueViolet;
      if(Command==OP_BUY){
         OpenColor=clrChartreuse;
         
         //MP added
         messagetext=messagetextPrefix+" "+(string)lastBarTraded+" "+"Create BUY/Long Order ";
         AlertAndNotify(messagetext); 
         messagetext="";     
        
      }
      if(Command==OP_SELL){
         OpenColor=clrDarkTurquoise;
         //MP added
         messagetext=messagetextPrefix+" "+(string)lastBarTraded+" "+"Create SELL/Short Order ";
         AlertAndNotify(messagetext);
         messagetext="";     
      }
      //Calculate the position size, if the lot size is zero then exit the function
      double SLPoints=0;
      //If the Stop Loss price is set then find the points of distance between open price and stop loss price, and round it
      if(SLPrice>0) SLPoints=MathCeil(MathAbs(OpenPrice-SLPrice)/Point());
      //Call the function to calculate the position size
      LotSizeCalculate(SLPoints);
      //If the position size is zero then exit and don't submit any orderInit
      if(LotSize==0) return;
      //MP added 1/24/22
      //MP 08/01/22 Commented out and rewrote PaintArrow2 to display arrow earlier
      //if (EA_showOrderArrows) PaintArrow(Command, i, TimeCurrent(),OpenPrice);
    
      //Submit the order
      int res=OrderSend(Instrument,Command,LotSize,OpenPrice,Slippage,NormalizeDouble(SLPrice,Digits()),NormalizeDouble(TPPrice,Digits()),OrderNote,MagicNumber,Expiration,OpenColor);
      //If the submission is successful print it in the log and exit the function
      if(res!=-1){
         Print("TRADE - OPEN SUCCESS - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Stop ",SLPrice," Take ",TPPrice," Expiration ",Expiration);       
      
         //MP03
         //GlobalVariableSet("CurrOrderNumber", res);      
         //   if(Command==OP_BUY) 
         //       GlobalVariableSet("CurrOrderType",ORDER_BUY_ORDER);     
         // else  if(Command==OP_SELL)  
         //    GlobalVariableSet("CurrOrderType",ORDER_SELL_ORDER);  
         //else   
              // GlobalVariableSet("CurrOrderType",ORDER_NA_ORDER);
         // LastOrdNum = OrderTicket();
         // LastFPL = AccountEquity();
         // LastOrdType =ORDER_BUY_ORDER;
         LastBN=iBars(Symbol(),PERIOD_CURRENT); // capture total bar count    
         if (EA_debug) Print("LastBN",LastBN); 
         // MP080922 added delay next order entry
         LastTradeTime=TimeCurrent();
         NextTradeTime = LastTradeTime + (tfDelayMinutes * 60);   
           if (EA_debug) Print("LastTradeTime",LastTradeTime); 
          if (EA_debug) Print("NextTradeTime",NextTradeTime); 
      
         break;
      }
      //If the submission failed print the error
      else{
         Print("TRADE - OPEN FAILED - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Stop ",SLPrice," Take ",TPPrice," Expiration ",Expiration);
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - NEW - error sending order, return error: ",Error," - ",ErrorText);
          //MP03
          // GlobalVariableSet("CurrOrderNumber", 0);        
          //GlobalVariableSet("CurrOrderType",ORDER_NA_ORDER);   
          //  LastOrdNum =0;
          //  LastOrdType =ORDER_NA_ORDER;  
          // LastFPL = 0;      
      } 
   }
   return;
}

//Modify Order Function adjusted to handle errors and retry multiple times
void ModifyOrder(int Ticket, double OpenPrice, double SLPrice, double TPPrice){
   //Try to select the order by ticket number and print the error if failed
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==false){
      int Error=GetLastError();
      string ErrorText=GetLastErrorText(Error);
      Print("ERROR - SELECT TICKET - error selecting order ",Ticket," return error: ",Error);
      return;
   }
   //Normalize the digits for stop loss and take profit price
   SLPrice=NormalizeDouble(SLPrice,Digits());
   TPPrice=NormalizeDouble(TPPrice,Digits());
   //Try to submit the changes multiple times
   for(int i=1; i<=OrderOpRetry; i++){
      //Submit the change
      bool res=OrderModify(Ticket,OpenPrice,SLPrice,TPPrice,0,Blue);
      //If the change is successful print the result and exit the function
      if(res){
         Print("TRADE - UPDATE SUCCESS - Order ",Ticket," new stop loss ",SLPrice," new take profit ",TPPrice);
         break;
      }
      //If the change failed print the error with additional information to troubleshoot
      else{
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - UPDATE FAILED - error modifying order ",Ticket," return error: ",Error," Open=",OpenPrice,
               " Old SL=",OrderStopLoss()," Old TP=",OrderTakeProfit(),
               " New SL=",SLPrice," New TP=",TPPrice," Bid=",MarketInfo(OrderSymbol(),MODE_BID)," Ask=",MarketInfo(OrderSymbol(),MODE_ASK));
         Print("ERROR - ",ErrorText);
      } 
   }
   return;
}

//Modify Order Function adjusted to handle errors and retry multiple times
void ModifyOrderWhenExecuteTrail(int Ticket, double OpenPrice, double SLPrice){
   //Try to select the order by ticket number and print the error if failed
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==false){
      int Error=GetLastError();
      string ErrorText=GetLastErrorText(Error);
      Print("ERROR - SELECT TICKET - error selecting order ",Ticket," return error: ",Error);
      return;
   }
   //Normalize the digits for stop loss and take profit price
   SLPrice=NormalizeDouble(SLPrice,Digits());
   //MP 012422 TPPrice=NormalizeDouble(TPPrice,Digits());
   //Try to submit the changes multiple times
   for(int i=1; i<=OrderOpRetry; i++){
      //Submit the change
      bool res=OrderModify(Ticket,OpenPrice,SLPrice,OrderTakeProfit(),0,Blue);
      //If the change is successful print the result and exit the function
      if(res){
         Print("TRADE - UPDATE SUCCESS - Order ",Ticket," new stop loss ",SLPrice," when executing trail stop ");
         break;
      }
      //If the change failed print the error with additional information to troubleshoot
      else{
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - UPDATE FAILED - error modifying order ",Ticket," return error: ",Error," Open=",OpenPrice,
               " Old SL=",OrderStopLoss()," Old TP=",OrderTakeProfit(),
               " New SL=",SLPrice," when executing TRail stop" ," Bid=",MarketInfo(OrderSymbol(),MODE_BID)," Ask=",MarketInfo(OrderSymbol(),MODE_ASK));
         Print("ERROR - ",ErrorText);
      } 
   }
   return;
}



//Close Single Order Function adjusted to handle errors and retry multiple times
void CloseOrder(int Ticket, double Lots, double CurrentPrice, int Command){
   //Try to close the order by ticket number multiple times in case of failure
   for(int i=1; i<=OrderOpRetry; i++){
      //Send the close command
      bool res=OrderClose(Ticket,Lots,CurrentPrice,Slippage,Red);
      //If the close was successful print the resul and exit the function
      if(res){
         if (EA_debug) Print("TRADE - CLOSE SUCCESS - Order ",Ticket," closed at price ",CurrentPrice);
         //MP03 added reset 
         //GlobalVariableSet("CurrOrderNumber", 0);
         //GlobalVariableSet("CurrOrderType",ORDER_NA_ORDER);
         if (Command == OP_BUY)
         {
            TotalOpenBuy--; 
            TotalOpenOrders--; //MP added
               
         }
         else if (Command == OP_SELL) 
         {
            TotalOpenSell-- ;
            TotalOpenOrders--; //MP added       
         }
         //MP03 Save profit
         LastOrdNum=Ticket;  
         LastOrderPnL=OrderProfit();
         LastFPL = AccountEquity();
         break;
      }
      //If the close failed print the error
      else{
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - CLOSE FAILED - error closing order ",Ticket," return error: ",Error," - ",ErrorText);
         //MP03 added reset 
         // GlobalVariableSet("CurrOrderNumber", 0);
         //GlobalVariableSet("CurrOrderType",ORDER_NA_ORDER);
         //LastOrderPnL=OrderProfit();
         LastOrdNum=0;  
         LastOrderPnL=0;
         LastFPL=0;
      } 
   }
   return;
}

//Close All Orders of a specified type
const int OP_ALL=-1; //Constant to define the additional OP_ALL command which is the reference to all type of orders
void CloseAll(int Command){
   //If the command is OP_ALL then run the CloseAll function for both BUY and SELL orders
   if(Command==OP_ALL){
      CloseAll(OP_BUY);
      CloseAll(OP_SELL);
      return;
   }
   double ClosePrice=0;
   //Scan all the orders to close them individually
   //NOTE that the for loop scans from the last to the first, this is because when we close orders the list of orders is updated
   //hence the for loop would skip orders if we scan from first to last
   for(int i=OrdersTotal()-1; i>=0; i--) {
      //First select the order individually to get its details, if the selection fails print the error and exit the function
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      }
      //Check if the order is for the current symbol and was opened by the EA and is the type to be closed
      if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol() && OrderType()==Command) {
         //Define the close price
         RefreshRates();
        //  if(Command==OP_BUY) ClosePrice=Ask;
         // if(Command==OP_SELL) ClosePrice=Bid;
           if(Command==OP_BUY) ClosePrice=Bid;
           if(Command==OP_SELL) ClosePrice=Ask;
       
         //Get the position size and the order identifier (ticket)
         double Lots=OrderLots();
         int Ticket=OrderTicket();
         //Close the individual order
         CloseOrder(Ticket,Lots,ClosePrice,Command); //MP03 added Command
      }
   }
}


//Scan all orders to find the ones submitted by the EA
//NOTE This function is defined as bool because we want to return true if it is successful and false if it fails
bool ScanOrders(){
   //MP added 04/22/22
   TotalOpenBuy = 0;
   TotalOpenSell=0;
   TotalOpenOrders=0;
   
   //Scan all the orders, retrieving some of the details 
    for(int i=0;i<OrdersTotal();i++) {
      //If there is a problem reading the order print the error, exit the function and return false
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         return false;
      }
      //If the order is not for the instrument on chart we can ignore it
      if(OrderSymbol()!=Symbol()) continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(OrderMagicNumber()!=MagicNumber) continue;
      //If it is a buy order then increment the total count of buy orders
      if(OrderType()==OP_BUY) 
      {
          TotalOpenBuy++;
           //MP03  currentPL
          //CurrOrderPnL = OrderProfit();
      }
      //If it is a sell order then increment the total count of sell orders
      if(OrderType()==OP_SELL)
      {
         TotalOpenSell++;
         //MP03  currentPL
         //CurrOrderPnL = OrderProfit();
      }
      //Increment the total orders count
      TotalOpenOrders++;
 
      
      //Find what is the open time of the most recent trade and assign it to LastBarTraded
      //this is necessary to check if we already traded in the current candle
      if(OrderOpenTime()>LastBarTraded || LastBarTraded==0) LastBarTraded=OrderOpenTime();
   }
   return true;
}
 
bool SaveOrderProperties(){
   //Retrieve open orders
    
    for(int i=0;i<OrdersTotal();i++) {
      //If there is a problem reading the order print the error, exit the function and return false
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         if (EA_debug) Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         return false;
      }
      //If the order is not for the instrument on chart we can ignore it
      if(OrderSymbol()!=Symbol()) continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(OrderMagicNumber()!=MagicNumber) continue;
      //If it is a buy order then increment the total count of buy orders
      if(OrderType()==OP_BUY) 
      {
           CurrOrderPnL = OrderProfit();
           CurrOrdType = ORDER_BUY_ORDER;
           CurrOrdNum = OrderTicket();
      }
      //If it is a sell order then increment the total count of sell orders
      if(OrderType()==OP_SELL)
      {
           CurrOrderPnL = OrderProfit();
           CurrOrdType = ORDER_SELL_ORDER;
           CurrOrdNum = OrderTicket();
      }
   }
   return true;
}

//double GetLastPnL(){
//   double pips = 0.0;
//   for (int i = 0; i < 1; i++) {
//     bool orderReturnSelect=OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
//     if(OrderSymbol()!=Symbol()) continue;
//     if(OrderMagicNumber()!=MagicNumber) continue;
//     if ( OrderTicket() != LastOrdNum) continue;     
//     pips += OrderProfit();
//   }
 //  return(pips);
// }
 
 double LastOrderClosedProfit()
{
 // refer https://www.mql5.com/en/forum/161888
   int      ticket      =-1;
   datetime last_time   = 0;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
       if(OrderMagicNumber()!=MagicNumber) continue;  
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)&&OrderSymbol()==_Symbol&&OrderCloseTime()>last_time)
      {
         last_time = OrderCloseTime();
         ticket = OrderTicket();
      }
   }
   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      if (EA_debug) Print("OrderSelectError: ",GetLastError());
      return 0.0;
   }    
   return OrderProfit();
}
 
 
int PaintArrow (int Command,int i, datetime arrowTime, double OpenPrice ){
    uchar arrow_code=-0;
    color arrow_color=Violet;
    string arrow_name="";

   if(Command==OP_BUY){
      arrow_code = 233; //up arrow
      arrow_color = Yellow;
      arrow_name="ARROW_UP_"+_Symbol+"_"+IntegerToString(iTime(_Symbol,_Period,i));
    
   }
   if(Command==OP_SELL){
      arrow_code = 234; //dn arrow
      arrow_color = White;
      arrow_name="ARROW_DN_"+_Symbol+"_"+IntegerToString(iTime(_Symbol,_Period,i));

   }
   if(!ArrowCreate(0,arrow_name,0,arrowTime,OpenPrice,arrow_code,InpAnchor,arrow_color,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder)) 
   //if(!ArrowCreate(0,InpName,0,date[d],price[p],32,InpAnchor,InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder))
   {
         if (EA_debug) Print("Arrow creation fail");
   }  
   return 0;
}

int PaintArrowOnSignal (int i, datetime arrowTime, double OpenPrice ){
    uchar arrow_code=-0;
    color arrow_color=Violet;
    string arrow_name="";

   if(SignalEntry==SIGNAL_ENTRY_BUY){
      arrow_code = 233; //up arrow
      arrow_color = Yellow;
      arrow_name="ARROW_UP_"+_Symbol+"_"+IntegerToString(iTime(_Symbol,_Period,i));
    
   }
   if(SignalEntry==SIGNAL_ENTRY_SELL){
      arrow_code = 234; //dn arrow
      arrow_color = White;
      arrow_name="ARROW_DN_"+_Symbol+"_"+IntegerToString(iTime(_Symbol,_Period,i));

   }
    if(SignalExit==SIGNAL_EXIT_BUY){
      arrow_code = 234; //dn arrow
      arrow_color = Orange;
      arrow_name="ARROW_DN_"+_Symbol+"_"+IntegerToString(iTime(_Symbol,_Period,i));
    
   }
   if(SignalExit==SIGNAL_EXIT_SELL){
      arrow_code = 233; //up arrow
      arrow_color = Violet;
      arrow_name="ARROW_UP_"+_Symbol+"_"+IntegerToString(iTime(_Symbol,_Period,i));

   }

   if(!ArrowCreate(0,arrow_name,0,arrowTime,OpenPrice,arrow_code,InpAnchor,arrow_color,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder)) 
   //if(!ArrowCreate(0,InpName,0,date[d],price[p],32,InpAnchor,InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder))
   {
         if (EA_debug) Print("Arrow creation fail");
   }  
   return 0;
}

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Sound and Push-notifications                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void AlertAndNotify(string text)
{
   static datetime lastSignal = 0;
   if (lastSignal >= Time[0])
      return;
      
   lastSignal = Time[0];
    
   if (EA_isAlertAndNotify)
   {
      Alert(text);
   }
      
  // if (isNotify)
     //SendNotification(_Symbol + ", " + tfName + ": " + text);
}

 //+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Defining the current TF name                                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetCurrentTFName()
{
   switch(_Period)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_D1: return "D1";
      case PERIOD_W1: return "W1";
      case PERIOD_MN1: return "MN1";
   }
   
   return "U/D";
}
