//+------------------------------------------------------------------+
//|                                             kpltrading_panel.mq5 |
//|                                        Copyright 2022, lesotlhok |
//|                  https://www.linkedin.com/in/koorapetselesotlho/ |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, lesotlhok"
#property link      "https://www.linkedin.com/in/koorapetselesotlho/"
#property version   "1.6"
#property description "Trading in financial markets involves inherent risks and potential for loss. It is important to carefully consider your financial resources and risk tolerance before making any trades. It is also important to use leverage responsibly and maintain realistic profit expectations. Having a clear trading plan and being able to control your emotions can help mitigate some of the risks associated with trading."
#property icon   "files\kpl.ico"

input string TELEGRAM = "---------------Enter Telegram Group Details---------------";
input const string TelegramBotToken = "bot id";
input const string ChatId           = "telegram group ID";
const string TelegramApiUrl   = "https://api.telegram.org"; // Add this to Allow URLs

const int    UrlDefinedError  = 4014; // Because MT4 and MT5 are different


#include <Trade/Trade.mqh>
CTrade                 Trade;

#include <Trade/DealInfo.mqh>
//---
CDealInfo      m_deal;                       // object of CDealInfo class



// Set the initial corner for the trade panel
const ENUM_BASE_CORNER PanelCorner  = CORNER_RIGHT_UPPER;

// Gaps from top and side of screen
const int              YMargin      = 20;
const int              XMargin      = 20;

// gaps between elements
const int              XGap         = 20;
const int              YGap         = 20;

// Size of the elements, buttons first because text depends on that
const int              ButtonWidth  = 80;
const int              ButtonHeight = 30;
const int              TextWidth    = (ButtonWidth * 2 - 20) + XGap;
const int              TextHeight   = 20;

// To make things easier below, also set the locations
// Caution, placing in top right but measuring to lower left of each element
const int              TextX        = XMargin  + TextWidth;
const int              TextY        = YMargin + TextHeight;
const int              TextX2        = XMargin + TextWidth;
const int              TextY2        = YMargin  + 20 + TextHeight;
const int              SellX        = XMargin + ButtonWidth;
const int              SellY        = TextY + YGap + ButtonHeight;
const int              BuyX         = SellX + ButtonWidth; // could also just be TextX
const int              BuyY         = TextY + YGap + ButtonHeight;
const int              CloseY       = YMargin  + 78 + TextHeight;
const int              CloseX       = 100  + ButtonWidth ;

// Names of the screen elements
const string           TextName     = "Text_Volume";
const string           BuyName      = "Buy_Button";
const string           SellName     = "Sell_Button";
const string           NumberTrade = "Trade_Number";
const string           CloseName   = "Close_Button";

// set up an initial value for lot size
double                 TradeVolume  = 0.50;
int                TradeNumber = 2;


;
int OnInit() {

   CreatePanel();
   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectDelete(0, NumberTrade);
   ObjectDelete(0, TextName);
   ObjectDelete(0, BuyName);
   ObjectDelete(0, SellName);
   ObjectDelete(0, CloseName);


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {


   string ClickedObjectName = sparam;


   if (id == CHARTEVENT_OBJECT_ENDEDIT) {
      if(sparam == TextName) {
         string volumeText = ObjectGetString(0, TextName, OBJPROP_TEXT);
         SetVolume(volumeText);
         ObjectSetString(0, TextName, OBJPROP_TEXT, string(TradeVolume));
         return;
      }

      else if(sparam == NumberTrade) {
         string newNum_Trade = ObjectGetString(0, NumberTrade, OBJPROP_TEXT);
         SetTradeNumber(newNum_Trade);
         ObjectSetString(0, NumberTrade, OBJPROP_TEXT, string(TradeNumber));
         return;
      }
   }




   else if (id == CHARTEVENT_OBJECT_CLICK) {
      if (sparam == BuyName) {
         ObjectSetInteger(0, BuyName, OBJPROP_STATE, false);

         for (int i = 0; i < TradeNumber; i++) {


            OpenTrade(ORDER_TYPE_BUY, TradeVolume);


         }
         // Save a screen shot
         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot( 0, "MyScreenshot.png",  1228, 720,  ALIGN_CENTER );

         SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId, "KPL COMMUNITY" + "  TRADE TYPE:  BUY   " + "Timeframe: " + StringSubstr(EnumToString(_Period), 7) + " Symbol: " + _Symbol + " Time Taken: " + TimeToString( TimeLocal() ), "MyScreenshot.png" );

      }


      else if (sparam == SellName) {

         ObjectSetInteger(0, SellName, OBJPROP_STATE, false);
         for (int i = 0; i < TradeNumber; i++) {



            OpenTrade(ORDER_TYPE_SELL, TradeVolume);

         }        // Save a screen shot
         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot( 0, "MyScreenshot.png",  1228, 720, ALIGN_CENTER );

         SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId, "KPL COMMUNITY" + "  TRADE TYPE:  SELL   " + "Timeframe: " + StringSubstr(EnumToString(_Period), 7) + " Symbol: " + _Symbol + " Time Taken: " + TimeToString( TimeLocal() ), "MyScreenshot.png" );

      }



      else if (sparam == CloseName) {

         for(int i = PositionsTotal(); i >= 0; i--) {

            ulong ticket = PositionGetTicket(i);

            if( PositionSelect(_Symbol) == true) {
               Trade.PositionClose(_Symbol);

            }


         }
         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot( 0, "MyScreenshot.png",  1228, 720, ALIGN_CENTER );
         SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId, "KPL COMMUNITY" + " Trade Closed   " + "Timeframe: " + StringSubstr(EnumToString(_Period), 7) + " Symbol: " + _Symbol + " Time Taken: " + TimeToString( TimeLocal() ), "MyScreenshot.png" );

      }
   }
}


void CreatePanel() {

// First just get rid of any existing elements
   ObjectDelete(0, TextName);
   ObjectDelete(0, BuyName);
   ObjectDelete(0, SellName);
   ObjectDelete(0, NumberTrade);

   EditCreate(0, TextName, 0, TextX, TextY, TextWidth, TextHeight, string(TradeVolume), "Arial", 10, ALIGN_LEFT, false, PanelCorner, clrBlack, clrWhite, clrBlack, false, false,
              false, 0);

   EditCreate(0, NumberTrade, 0, TextX2, TextY2, TextWidth, TextHeight, string(TradeNumber), "Arial", 10, ALIGN_LEFT, false, PanelCorner, clrBlack, clrWhite, clrBlack, false, false,
              false, 0);
   ButtonCreate(0, BuyName, 0, BuyX, BuyY, ButtonWidth, ButtonHeight, PanelCorner, "Buy", "Arial", 10, clrWhite, clrBlue, clrBlack, false, false, false, false, 0);
   ButtonCreate(0, SellName, 0, SellX, SellY, ButtonWidth, ButtonHeight, PanelCorner, "Sell", "Arial", 10, clrWhite, clrRed, clrBlack, false, false, false, false, 0);
   ButtonCreate(0, CloseName, 0, CloseX, CloseY, 160, ButtonHeight, PanelCorner, "Close All", "Arial", 10, clrWhite, clrOrange, clrBlack, false, false, false, false, 0);

}

void SetVolume(string volumeText) {

   double newVolume = StringToDouble(volumeText);
   if (newVolume < 0) {
      Print("Invalid volume specified");
      return;
   }
   TradeVolume = newVolume;
}

void SetTradeNumber(string newNum_Trade) {

   double Num_Trade = StringToDouble(newNum_Trade);
   if (newNum_Trade < 0) {
      Print("Invalid number of trades specified");
      return;
   }
   TradeNumber = Num_Trade;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type == TRADE_TRANSACTION_DEAL_ADD) {
      if(HistoryDealSelect(trans.deal))
         m_deal.Ticket(trans.deal);
      else {
         Print(__FILE__, " ", __FUNCTION__, ", ERROR: HistoryDealSelect(", trans.deal, ")");
         return;
      }
      //---
      long reason = -1;
      if(!m_deal.InfoInteger(DEAL_REASON, reason)) {
         Print(__FILE__, " ", __FUNCTION__, ", ERROR: InfoInteger(DEAL_REASON,reason)");
         return;
      }
      if((ENUM_DEAL_REASON)reason == DEAL_REASON_SL && m_deal.Symbol() == _Symbol) {
         Alert("Stop Loss activation");


         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot( 0, "MyScreenshot.png",  1228, 720, ALIGN_CENTER );

         SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId, "KPL COMMUNITY" + "  TRADE STOPLOSS HIT" + " Symbol: " + _Symbol + " Time Taken: " + TimeToString( TimeTradeServer() ), "MyScreenshot.png" );

      }

      else if((ENUM_DEAL_REASON)reason == DEAL_REASON_TP && m_deal.Symbol() == _Symbol ) {
         ChartRedraw(); // Make sure the chart is up to date
         ChartScreenShot( 0, "MyScreenshot.png",  1228, 720, ALIGN_CENTER );

         SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId, "KPL COMMUNITY" + "  TRADE TAKEPROFIT HIT" + " Symbol: " + _Symbol + " Time Taken: " + TimeToString( TimeTradeServer() ), "MyScreenshot.png" );



      }

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenTrade(ENUM_ORDER_TYPE type, double volume ) {


   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   return Trade.PositionOpen(Symbol(), type, volume, price, 0, 0, "KPL TRADING-PANEL BUTTONS");



}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long             chart_ID   = 0,                 // chart's ID
                  const string           name       = "Button",          // button name
                  const int              sub_window = 0,                 // subwindow index
                  const int              x          = 0,                 // X coordinate
                  const int              y          = 0,                 // Y coordinate
                  const int              width      = 50,                // button width
                  const int              height     = 18,                // button height
                  const ENUM_BASE_CORNER corner     = CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string           text       = "Button",          // text
                  const string           font       = "Arial",           // font
                  const int              font_size  = 10,                // font size
                  const color            clr        = clrWhite,          // text color
                  const color            back_clr   = clrGray,           // background color
                  const color            border_clr = clrNONE,           // border color
                  const bool             state      = false,             // pressed/released
                  const bool             back       = false,             // in the background
                  const bool             selection  = false,             // highlight to move
                  const bool             hidden     = true,              // hidden in the object list
                  const long             z_order    = 0                  // priority for mouse click
                 ) {
//--- reset the error value
   ResetLastError();
//--- create the button
   if (!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ", GetLastError());
      return (false);
   }
//--- set button coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set button size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- set button state
   ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return (true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EditCreate(const long             chart_ID   = 0,                 // chart's ID
                const string           name       = "Edit",            // object name
                const int              sub_window = 0,                 // subwindow index
                const int              x          = 0,                 // X coordinate
                const int              y          = 0,                 // Y coordinate
                const int              width      = 50,                // width
                const int              height     = 18,                // height
                const string           text       = "Text",            // text
                const string           font       = "Arial",           // font
                const int              font_size  = 10,                // font size
                const ENUM_ALIGN_MODE  align      = ALIGN_CENTER,      // alignment type
                const bool             read_only  = false,             // ability to edit
                const ENUM_BASE_CORNER corner     = CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr        = clrBlack,          // text color
                const color            back_clr   = clrWhite,          // background color
                const color            border_clr = clrNONE,           // border color
                const bool             back       = false,             // in the background
                const bool             selection  = false,             // highlight to move
                const bool             hidden     = true,              // hidden in the object list
                const long             z_order    = 0                  // priority for mouse click
               ) {
//--- reset the error value
   ResetLastError();
//--- create edit field
   if (!ObjectCreate(chart_ID, name, OBJ_EDIT, sub_window, 0, 0)) {
      Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ", GetLastError());
      return (false);
   }
//--- set object coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set object size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID, name, OBJPROP_ALIGN, align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID, name, OBJPROP_READONLY, read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return (true);
}



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool SendTelegramMessage( string url, string token, string chat, string text,
                          string fileName = "" ) {

   string headers    = "";
   string requestUrl = "";
   char   postData[];
   char   resultData[];
   string resultHeaders;
   int    timeout = 5000; // 1 second, may be too short for a slow connection

   ResetLastError();

   if ( fileName == "" ) {
      requestUrl =
         StringFormat( "%s/bot%s/sendmessage?chat_id=%s&text=%s", url, token, chat, text );
   } else {
      requestUrl = StringFormat( "%s/bot%s/sendPhoto", url, token );
      if ( !GetPostData( postData, headers, chat, text, fileName ) ) {
         return ( false );
      }
   }

   ResetLastError();
   int response =
      WebRequest( "POST", requestUrl, headers, timeout, postData, resultData, resultHeaders );

   switch ( response ) {
   case -1: {
      int errorCode = GetLastError();
      Print( "Error in WebRequest. Error code  =", errorCode );
      if ( errorCode == UrlDefinedError ) {
         //--- url may not be listed
         PrintFormat( "Add the address '%s' in the list of allowed URLs", url );
      }
      break;
   }
   case 200:
      //--- Success
      Print( "The message has been successfully sent" );
      break;
   default: {
      string result = CharArrayToString( resultData );
      PrintFormat( "Unexpected Response '%i', '%s'", response, result );
      break;
   }
   }

   return ( response == 200 );
}

bool GetPostData( char &postData[], string & headers, string chat, string text, string fileName ) {

   ResetLastError();

   if ( !FileIsExist( fileName ) ) {
      PrintFormat( "File '%s' does not exist", fileName );
      return ( false );
   }

   int flags = FILE_READ | FILE_BIN;
   int file  = FileOpen( fileName, flags );
   if ( file == INVALID_HANDLE ) {
      int err = GetLastError();
      PrintFormat( "Could not open file '%s', error=%i", fileName, err );
      return ( false );
   }

   int   fileSize = ( int )FileSize( file );
   uchar photo[];
   ArrayResize( photo, fileSize );
   FileReadArray( file, photo, 0, fileSize );
   FileClose( file );

   string hash = "";
   AddPostData( postData, hash, "chat_id", chat );
   if ( StringLen( text ) > 0 ) {
      AddPostData( postData, hash, "caption", text );
   }
   AddPostData( postData, hash, "photo", photo, fileName );
   ArrayCopy( postData, "--" + hash + "--\r\n" );

   headers = "Content-Type: multipart/form-data; boundary=" + hash + "\r\n";

   return ( true );
}

void AddPostData( uchar & data[], string & hash, string key = "", string value = "" ) {

   uchar valueArr[];
   StringToCharArray( value, valueArr, 0, StringLen( value ) );

   AddPostData( data, hash, key, valueArr );
   return;
}

void AddPostData( uchar & data[], string & hash, string key, uchar & value[], string fileName = "" ) {

   if ( hash == "" ) {
      hash = Hash();
   }

   ArrayCopy( data, "\r\n" );
   ArrayCopy( data, "--" + hash + "\r\n" );
   if ( fileName == "" ) {
      ArrayCopy( data, "Content-Disposition: form-data; name=\"" + key + "\"\r\n" );
   } else {

      ArrayCopy( data, "Content-Disposition: form-data; name=\"" + key + "\"; filename=\"" +
                 fileName + "\"\r\n" );
   }
   ArrayCopy( data, "\r\n" );
   ArrayCopy( data, value, ArraySize( data ) );
   ArrayCopy( data, "\r\n" );

   return;
}

void ArrayCopy( uchar & dst[], string src ) {

   uchar srcArray[];
   StringToCharArray( src, srcArray, 0, StringLen( src ) );
   ArrayCopy( dst, srcArray, ArraySize( dst ), 0, ArraySize( srcArray ) );
   return;
}

string Hash() {

   uchar  tmp[];
   string seed = IntegerToString( TimeCurrent() );
   int    len  = StringToCharArray( seed, tmp, 0, StringLen( seed ) );
   string hash = "";
   for ( int i = 0; i < len; i++ )
      hash += StringFormat( "%02X", tmp[i] );
   hash = StringSubstr( hash, 0, 16 );

   return ( hash );
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
