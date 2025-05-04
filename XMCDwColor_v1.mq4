//+------------------------------------------------------------------+
//|                                                XMCDwColor_v1.mq4 |
//|                                       manmohan.pardesi@gmail.com | 
//|                       manmohan.pardesi@gmail.com 04/30/25 01:19am|
//| Last revision:              Modified histograms         04/30/25 |
//+-------------------------------------------------------------------+
#property copyright   "manmohan.pardesi@gmail.com"
#property link        "manmohan.pardesi@gmail.com"
#property description "Median Convergence/Divergence"
#property strict
//#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 7
#property  indicator_color1  clrLimeGreen
#property  indicator_color2  clrGreen
#property  indicator_color3  clrRed
#property  indicator_color4  clrPaleVioletRed
#property  indicator_color5  clrGreen
#property  indicator_color6  clrNONE //clrWhite
#property  indicator_color7  clrNONE //clrOrange

#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  1
#property  indicator_width5  1
#property  indicator_width6  1
#property  indicator_width7  1

//--- indicator parameters
input int InpFast=10;   // Fast Period
input int InpSlow=20;   // Slow Period
input int InpSignal=10;  // Signal Period (Median MCD)
input int InpModePrice=MODE_CLOSE; //Price Mode 3-Close 2-High 1-Low 0 -Open 
input int InpSmoothPeriod = 5; // Smoothing period of MCD Line
//--- indicator buffers
double ExtMCDBuffer[];
double ExtSignalBuffer[];
double ExtMCDLineBuffer[];
double ExtSmoothingBuffer[];
double ExtPosAndUpBuffer[];
double ExtPosAndDownBuffer[];
double ExtNegAndDownBuffer[];
double ExtNegAndUpBuffer[];

color levelColor  = clrDimGray;   // Level zero color 

//--- right input parameters flag
bool ExtParameters=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorBuffers(8);
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
 
   // SetIndexDrawBegin(4,InpSignal);
    
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtPosAndUpBuffer);
   SetIndexBuffer(1,ExtPosAndDownBuffer);
   SetIndexBuffer(2,ExtNegAndDownBuffer);
   SetIndexBuffer(3,ExtNegAndUpBuffer);
   SetIndexBuffer(4,ExtSignalBuffer);
   SetIndexBuffer(5,ExtMCDLineBuffer);
   SetIndexBuffer(6,ExtSmoothingBuffer);
   SetIndexBuffer(7,ExtMCDBuffer);
  
   SetIndexLabel(0,"MCDPosAndUp");
   SetIndexLabel(1,"MCDPosAndDown");
   SetIndexLabel(2,"MCDNegAndDown");
   SetIndexLabel(3,"MCDNegAndUp");
   SetIndexLabel(4,"Signal"); //green line
   SetIndexLabel(5,"MCDLine");  //white line
   SetIndexLabel(6,"Smoothing"); //orange line
   SetIndexLabel(7,"Diff");

//--- name for DataWindow and indicator subwindow label
   IndicatorShortName(WindowExpertName() +"("+IntegerToString(InpFast)+","+IntegerToString(InpSlow)+","+IntegerToString(InpSignal)+")");
  
//MP added
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0.0);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,levelColor);  

//--- check for input parameters
   if(InpFast<=1 || InpSlow<=1 || InpSignal<=1 || InpFast>=InpSlow)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
   double mminF=0;
   double mmaxF=0;
   double mminS=0;
   double mmaxS=0;
   double medianF=0;
   double medianS=0;
   double mminMCD=0;
   double mmaxMCD=0;
   double medianMCD=0;
  
   
//---
   if(rates_total<=InpSignal || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if (prev_calculated>0) limit++;
    
   //--- median CD counted in the 1-st buffer
   for (i=limit-1; i>=0; i--)
   {
      //mminF=Close[Lowest(NULL,0,MODE_CLOSE,InpFast,i)];
      //mmaxF=Close[Highest(NULL,0,MODE_CLOSE,InpFast,i)];
      //mminS=Close[Lowest(NULL,0,MODE_CLOSE,InpSlow,i)];
      //mmaxS=Close[Highest(NULL,0,MODE_CLOSE,InpSlow,i)];  
      //mminF=iClose(NULL,0,iLowest(NULL,0,MODE_CLOSE,InpFast,i));
      //mmaxF=iClose(NULL,0,iHighest(NULL,0,MODE_CLOSE,InpFast,i));
      //mminS=iClose(NULL,0,iLowest(NULL,0,MODE_CLOSE,InpSlow,i));
      //mmaxS=iClose(NULL,0,iHighest(NULL,0,MODE_CLOSE,InpSlow,i));
      mminF=Close[iLowest(NULL,0,MODE_CLOSE,InpFast,i)];
      mmaxF=Close[iHighest(NULL,0,MODE_CLOSE,InpFast,i)];
      mminS=Close[iLowest(NULL,0,MODE_CLOSE,InpSlow,i)];
      mmaxS=Close[iHighest(NULL,0,MODE_CLOSE,InpSlow,i)];    
      medianF = (mminF + mmaxF) / 2.0;
      medianS = (mminS + mmaxS) / 2.0; 
      ExtMCDLineBuffer[i]= medianF - medianS;
  }
  //--- signal line counted in the 2-nd buffer
  // for(i=pos; i<rates_total && !IsStopped(); i++)
   
  for (i=limit-1; i>=0; i--)
  {
      ExtSmoothingBuffer[i] = iMAOnArray(ExtMCDLineBuffer,0,InpSmoothPeriod,0,MODE_EMA,i);
      //ExponentialMAOnBuffer(rates_total, prev_calculated,0,InpSmoothPeriod,ExtMCDLineBuffer,ExtSmoothingBuffer);   
     
      //mminMCD =  CalculateLowestValue(i,InpSignal,ExtMCDLineBuffer);
      //mmaxMCD = CalculateHighestValue(i,InpSignal,ExtMCDLineBuffer);
      mminMCD =  minValueOfArray(ExtMCDLineBuffer,InpSignal,i);
      mmaxMCD = maxValueOfArray(ExtMCDLineBuffer,InpSignal,i);
     
      medianMCD = (mminMCD + mmaxMCD) / 2.0;
      ExtSignalBuffer[i] = medianMCD; 
      //Diff/histogram
      //04/20/25ExtMCDBuffer[i] = ExtMCDLineBuffer[i] - ExtSignalBuffer[i];
      //ExtMCDBuffer[i] = ExtMCDLineBuffer[i] ;
      ExtMCDBuffer[i] = ExtSmoothingBuffer[i] - ExtSignalBuffer[i];
  
      if(ExtMCDBuffer[i]>=0) 
      {
         if ((i<rates_total-1))
         {
            if (ExtMCDBuffer[i]>ExtMCDBuffer[i+1]  )
            {
              ExtPosAndUpBuffer[i] = ExtMCDBuffer[i];
              ExtPosAndDownBuffer[i] = 0.0;
            }
         else 
            {
              ExtPosAndDownBuffer[i] = ExtMCDBuffer[i+1];
              ExtPosAndUpBuffer[i] = 0.0;
            }
         }
      }
      else 
      {
         if ((i<rates_total-1))
         {
            if (ExtMCDBuffer[i]<ExtMCDBuffer[i+1]  )
            {
              ExtNegAndDownBuffer[i] = ExtMCDBuffer[i];
              ExtNegAndUpBuffer[i] = 0.0;
            }
            else 
             {
              ExtNegAndUpBuffer[i] = ExtMCDBuffer[i];
              ExtNegAndDownBuffer[i] = 0.0;
            } 
         }
      }
   }
   
  //--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+

 
double maxValueOfArray(double &arrayToSearch[],int count=WHOLE_ARRAY,int start=0)
{ 
   int indexMaxValueOfArray = ArrayMaximum(arrayToSearch,count,start);  
   return(arrayToSearch[indexMaxValueOfArray]);  
}
double minValueOfArray(double &arrayToSearch[],int count=WHOLE_ARRAY,int start=0)
{ 
   int indexMinValueOfArray = ArrayMinimum(arrayToSearch,count,start);  
   return(arrayToSearch[indexMinValueOfArray]);  
}
