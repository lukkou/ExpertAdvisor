// RCI_3Line.mq4
// Ver 1.30
// 2009/03/22
// Copyright © 2009,Nariten.
// http://www.nariten.com
#property copyright "Copyright © 2009,Nariten."
#property link      "http://www.nariten.com"
//----
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Maroon
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_minimum -100
#property indicator_maximum 100
//---- input parameters
extern int  tPr1 = 9;
extern int  tPr2 = 26;
extern int  tPr3 = 52;
//---- buffers
double Buff1[];
double Buff2[];
double Buff3[];
int D0[];
int D1[];
int D2[];
int D3[];
int tPrMax;
double n1,n2,n3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   int i;

   //---- indicator lines
   SetIndexBuffer(0,Buff1);
   SetIndexBuffer(1,Buff2);
   SetIndexBuffer(2,Buff3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexLabel(0,"RCI1:"+tPr1);
   SetIndexLabel(1,"RCI2:"+tPr2);
   SetIndexLabel(2,"RCI3:"+tPr3);
   IndicatorShortName("RCI 3line("+tPr1+","+tPr2+","+tPr3+")");

   //----
   ArrayResize(D1, tPr1);
   ArrayResize(D2, tPr2);
   ArrayResize(D3, tPr3);

   tPrMax=tPr1;
   if (tPr2>tPrMax) tPrMax=tPr2;
   if (tPr3>tPrMax) tPrMax=tPr3;

   ArrayResize(D0, tPrMax);
   for(i=0; i<tPrMax; i++) {
      D0[i]=-i*2;
   }

   n1=tPr1*(tPr1*tPr1-1)*2/3;
   n2=tPr2*(tPr2*tPr2-1)*2/3;
   n3=tPr3*(tPr3*tPr3-1)*2/3;
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int n;
   int count = IndicatorCounted();
   int i,j,limit;
   int d1,d2,d3;

   if(count==0)
      limit = Bars - tPrMax;
   else if(count>0)
      limit = Bars - count;

   ArrayCopy(D1,D0,0,0,tPr1);
   ArrayCopy(D2,D0,0,0,tPr2);
   ArrayCopy(D3,D0,0,0,tPr3);

   n=limit;
   d1=0;
   for(i=0; i<tPr1; i++) {
      for(j=i+1; j<tPr1; j++) {
         if(Close[n+i]<Close[n+j]) {
            D1[i]+=2;
         }
         else if(Close[n+i]==Close[n+j]) {
            D1[i]++;
            D1[j]++;
         }
         else {
            D1[j]+=2;
         }
      }
      d1+=D1[i]*D1[i];
   }
   Buff1[n]=(1-(d1/n1))*100;

   d2=0;
   for(i=0; i<tPr2; i++) {
      for(j=i+1; j<tPr2; j++) {
         if(Close[n+i]<Close[n+j]) {
            D2[i]+=2;
         }
         else if(Close[n+i]==Close[n+j]) {
            D2[i]++;
            D2[j]++;
         }
         else {
            D2[j]+=2;
         }
      }
      d2+=D2[i]*D2[i];
   }
   Buff2[n]=(1-(d2/n2))*100;

   d3=0;
   for(i=0; i<tPr3; i++) {
      for(j=i+1; j<tPr3; j++) {
         if(Close[n+i]<Close[n+j]) {
            D3[i]+=2;
         }
         else if(Close[n+i]==Close[n+j]) {
            D3[i]++;
            D3[j]++;
         }
         else {
            D3[j]+=2;
         }
      }
      d3+=D3[i]*D3[i];
   }
   Buff3[n]=(1-(d3/n3))*100;

   for(n=limit-1; n>=0; n--) {
      d1=0;
      for(i=tPr1-1; i>=1; i--) {
         D1[i]=D1[i-1]-2;
         if(Close[n+i]<Close[n])
            D1[i]+=2;
         else if(Close[n+i]==Close[n])
            D1[i]++;
         if(Close[n+i]<Close[n+tPr1])
            D1[i]-=2;
         else if(Close[n+i]==Close[n+tPr1])
            D1[i]--;
         d1+=D1[i]*D1[i];
      }
      D1[0]=0;
      for(j=1; j<tPr1; j++) {
         if(Close[n]<Close[n+j])
            D1[0]+=2;
         else if(Close[n]==Close[n+j])
            D1[0]++;
      }
      d1+=D1[0]*D1[0];
      Buff1[n]=(1-(d1/n1))*100;

      d2=0;
      for(i=tPr2-1; i>=1; i--) {
         D2[i]=D2[i-1]-2;
         if(Close[n+i]<Close[n])
            D2[i]+=2;
         else if(Close[n+i]==Close[n])
            D2[i]++;
         if(Close[n+i]<Close[n+tPr2])
            D2[i]-=2;
         else if(Close[n+i]==Close[n+tPr2])
            D2[i]--;
         d2+=D2[i]*D2[i];
      }
      D2[0]=0;
      for(j=1; j<tPr2; j++) {
         if(Close[n]<Close[n+j])
            D2[0]+=2;
         else if(Close[n]==Close[n+j])
            D2[0]++;
      }
      d2+=D2[0]*D2[0];
      Buff2[n]=(1-(d2/n2))*100;

      d3=0;
      for(i=tPr3-1; i>=1; i--) {
         D3[i]=D3[i-1]-2;
         if(Close[n+i]<Close[n])
            D3[i]+=2;
         else if(Close[n+i]==Close[n])
            D3[i]++;
         if(Close[n+i]<Close[n+tPr3])
            D3[i]-=2;
         else if(Close[n+i]==Close[n+tPr3])
            D3[i]--;
         d3+=D3[i]*D3[i];
      }
      D3[0]=0;
      for(j=1; j<tPr3; j++) {
         if(Close[n]<Close[n+j])
            D3[0]+=2;
         else if(Close[n]==Close[n+j])
            D3[0]++;
      }
      d3+=D3[0]*D3[0];
      Buff3[n]=(1-(d3/n3))*100;
   }

   return(0);
}
//+------------------------------------------------------------------+