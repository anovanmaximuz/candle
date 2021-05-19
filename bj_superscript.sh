// @Bjorgum on StockTwits

// This script compiles multiple momentum strategies into one indicator making comparisons simple through the visual aid of bar color change 
// The user is able to select any of the available strategies through the strategy selector drop down menu
// Bj Reversal uses Tilson moving averages to identify trend changes 
// The Rolando Santos TRM uses 2 momentum indicators to give a 3 color scheme
// Hema uses HA smoothed EMAs to identify trend direction 
// RSI color changes bar color based on user defined RSI values 
// There are a number of strategy overrides that allow customization combining elements from each strategy at the users discretion 
// Speed selectors offer preset reference period changes allowing for easy changes of oscillator lengths for swing trades or longer holds

//@version=4

study("Bjorgum SuperScript", shorttitle="Bj SuperScript", overlay=true, format=format.price, precision=4)

strat = input(title="Select a Strategy", defval="Bj Reversal", options=["Bj Reversal", "HEMA", "TRM", "RSI Color"], group="Strategy Selector")
strat_val = strat == "Bj Reversal" ? 0 : strat == "HEMA" ? 1 : strat == "TRM" ? 2 : strat == "RSI Color" ? 3 : na

bjrev  = strat_val < 1
hema   = strat_val > 0 and strat_val < 2
trm    = strat_val > 1 and strat_val < 3 
rsicol = strat_val > 2 and strat_val < 4

t3vis = input(title="Show Tilson MA's Outside of Reversal", group="Strategy Overides", 
     type=input.bool, defval=false)
 
hemavis = input(title="Show HEMA MA's Outside of HEMA", 
     type=input.bool, defval=false, group="Strategy Overides")  

psarvis = input(title="Show PSAR", 
     type=input.bool, defval=false, group="Strategy Overides")  

arrowvis = input(title="Show Arrows", 
     type=input.bool, defval=false, group="Strategy Overides") 
 
// TRM

tsistrat = input(title="TRM Speed Control", defval="Fast", options=["Fast", "Slow"], group="Select a Speed")
tsistrat_val = tsistrat == "Fast" ? 0 : tsistrat == "Slow" ? 1 : na

tsifast  = tsistrat_val < 1
tsislow  = tsistrat_val > 0 

longf   = input(title="Long Length",   type=input.integer, defval=25, group="TRM Fast Settings")
shortf  = input(title="Short Length",  type=input.integer, defval=5,  group="TRM Fast Settings")
signalf = input(title="Signal Length", type=input.integer, defval=14, group="TRM Fast Settings")

longs   = input(title="Long Length",   type=input.integer, defval=25, group="TRM Slow Settings")
shorts  = input(title="Short Length",  type=input.integer, defval=13, group="TRM Slow Settings")
signals = input(title="Signal Length", type=input.integer, defval=13, group="TRM Slow Settings")

lenf = input(5,  minval=1, title="RSI Length", group="TRM Fast Settings")
lens = input(14, minval=1, title="RSI Length", group="TRM Slow Settings")

shortvar   = tsifast ? shortf   : tsislow ? shorts   : na
longvar    = tsifast ? longf    : tsislow ? longs    : na
signalvar  = tsifast ? signalf  : tsislow ? signals  : na

tsi = tsi(close,shortvar,longvar)
tsl = ema(tsi, signalvar)

// HA

haClose = (open + high + low + close) / 4
haOpen  = float(na)
haOpen := na(haOpen[1]) ? (open + close) / 2 : (nz(haOpen[1]) + nz(haClose[1])) / 2
haHigh  = max(high, max(haOpen, haClose))
haLow   = min(low,  min(haOpen, haClose))

// RSI Bar Color

rsistrat = input(title="RSI Bar Color Speed Control", defval="Slow", options=["Slow", "Fast"], group="Select a Speed")
rsistrat_val = rsistrat == "Slow" ? 11 : rsistrat == "Fast" ? 12 : na

rsifast  = rsistrat_val > 11
rsislow  = rsistrat_val < 12 

len =    tsifast and trm ? lenf :
         tsislow and trm ? lens :
         rsifast and rsicol ? lenf :
         rsislow and rsicol ? lens : lens

rsi = rsi(close,len)

buy   = tsi > tsl and rsi > 50
sell  = tsi < tsl and rsi < 50 

rsicross = cross(rsi, 50) 

// Bj Reversal

    ///T3 MA5

aLength = input(5, minval=1, group="T3 MA Lengths")
AxPrice = close
axe1 = ema(AxPrice, aLength)
axe2 = ema(axe1, aLength)
axe3 = ema(axe2, aLength)
axe4 = ema(axe3, aLength)
axe5 = ema(axe4, aLength)
axe6 = ema(axe5, aLength)
ab   = 0.7
ac1  = -ab*ab*ab
ac2  = 3*ab*ab+3*ab*ab*ab
ac3  = -6*ab*ab-3*ab-3*ab*ab*ab
ac4  = 1+3*ab+ab*ab*ab+3*ab*ab
anT3Average = ac1 * axe6 + ac2 * axe5 + ac3 * axe4 + ac4 * axe3
colOne = anT3Average > anT3Average[1] 
colTwo = anT3Average < anT3Average[1] 
color2 = colOne ? #64b5f6 : colTwo ? #ef5350 : na
p2 = plot(anT3Average, color= t3vis ? color2 : bjrev ? color2 : true ? na : #ffffff , title="T3 Fast")

    ///T3 MA8

Length = input(8, minval=1, group="T3 MA Lengths")
xPrice = close
xe1 = ema(xPrice, Length)
xe2 = ema(xe1, Length)
xe3 = ema(xe2, Length)
xe4 = ema(xe3, Length)
xe5 = ema(xe4, Length)
xe6 = ema(xe5, Length)
b   = 0.7
c1  = -b*b*b
c2  = 3*b*b+3*b*b*b
c3  = -6*b*b-3*b-3*b*b*b
c4  = 1+3*b+b*b*b+3*b*b
nT3Average = c1 * xe6 + c2 * xe5 + c3 * xe4 + c4 * xe3
upCol = nT3Average > nT3Average[1] 
downCol = nT3Average < nT3Average[1]
myColor = upCol ? #64b5f6 : downCol ? #ef5350 : na
p1 = plot(nT3Average, color=t3vis ? myColor : bjrev ? myColor : true ? na : #ffffff , title="T3 Slow")
revbar   = cross(close, nT3Average)
trendbar = cross(nT3Average, anT3Average)

// Bj Reversal Bar Color and Fill 

uc   = (close > nT3Average)   and (anT3Average >= nT3Average)
dc   = (close < nT3Average)   and (anT3Average <= nT3Average)  
dr   = (close < nT3Average)   and (anT3Average >= nT3Average) 
ur   = (close > nT3Average)   and (anT3Average <= nT3Average) 

hauc = (haClose > nT3Average) and (anT3Average >= nT3Average)
hadc = (haClose < nT3Average) and (anT3Average <= nT3Average)
hadr = (haClose < nT3Average) and (anT3Average >= nT3Average)
haur = (haClose > nT3Average) and (anT3Average <= nT3Average)

hadu = haClose >= haOpen
hadd = haClose <  haOpen

fillData = nT3Average < anT3Average
fillDtat = nT3Average > anT3Average
fillCol  = fillData ? #64b5f6 : fillDtat ? #ef5350 : na
fill(p1,p2, color=t3vis ? fillCol : bjrev ? fillCol : na, transp=80, title="T3 Fill")

// HEMA

hemaslow = input(5,title='EMA-Fast', group="EMA Lengths")
bjhemaslow = ema(haOpen, hemaslow)
up   = bjhemaslow > bjhemaslow[1]
down = bjhemaslow < bjhemaslow[1]
mycolor = up ? #64b5f6 : down ? #d32f2f : na
bjhemafast = ema(hl2, 1)
hemaslowplot = plot(bjhemaslow, color= hemavis ? mycolor : hema ? mycolor : true ? na : #ffffff, transp=55, title='EMA-5')
hemafastplot = plot(bjhemafast, color=#000000, transp=100, display=display.none, editable=false, title='EMA fast')

hemaslow2 = input(9,title='EMA-Medium', group="EMA Lengths")
bjhemaslow2 = ema(haOpen, hemaslow2)
up2   = bjhemaslow2 > bjhemaslow2[1]
down2 = bjhemaslow2 < bjhemaslow2[1]
mycolor2 = up2 ? #64b5f6 : down2 ? #d32f2f : na
hemaslowplot2 = plot(bjhemaslow2, color= hemavis ? mycolor2 : hema ? mycolor2 : true ? na : #ffffff, transp=45, title='EMA-9')

hemaslow3 = input(21,title='EMA-Slow', group="EMA Lengths")
bjhemaslow3 = ema(haOpen, hemaslow3)
up3   = bjhemaslow3 > bjhemaslow3[1]
down3 = bjhemaslow3 < bjhemaslow3[1]
mycolor3 = up3 ? #64b5f6 : down3 ? #d32f2f : na
hemaslowplot3 = plot(bjhemaslow3,  color= hemavis ? mycolor3 : hema ? mycolor3 : true ? na : #ffffff, transp=35, title='EMA-21')

emasig = cross(close, bjhemaslow) and cross(close, bjhemaslow2)

// HEMA area plot fill 

hfillData  = bjhemaslow > bjhemafast
hfillData2 = bjhemaslow < bjhemafast

hfillDtat  = bjhemaslow2 > bjhemaslow
hfillDtat2 = bjhemaslow2 < bjhemaslow

hfillDat   = bjhemaslow3 > bjhemaslow2
hfillDat2  = bjhemaslow3 < bjhemaslow2

hfillCol1  = hfillData ? #ef5350 : hfillData2 ? #64b5f6 : na
hfillCol2  = hfillDtat ? #ef5350 : hfillDtat2 ? #64b5f6 : na
hfillCol3  = hfillDat  ? #ef5350 : hfillDat2  ? #64b5f6 : na

fill(hemaslowplot,  hemafastplot,  color=hemavis ? hfillCol1 : hema ? hfillCol1 : na, transp=85, title="5 - Plot Fill")
fill(hemaslowplot,  hemaslowplot2, color=hemavis ? hfillCol2 : hema ? hfillCol2 : na, transp=80, title="5 - 9 Fill")
fill(hemaslowplot2, hemaslowplot3, color=hemavis ? hfillCol3 : hema ? hfillCol3 : na, transp=75, title="9 - 21 Fill")

hemauc = (close > bjhemaslow) and (close > bjhemaslow2)
hemadc = (close < bjhemaslow) and (close < bjhemaslow2)

/// PSAR 

sar = sar(.043, .043, .34)

colUp =  close >= sar ? #64b5f6 : 
         close <= sar ? #ef5350 : na

plot(sar ? sar : na, title="SAR", style=plot.style_circles, linewidth=1, color=false ? na : psarvis ? colUp : na)

// Arrows 

data = tsi > tsi[1] and tsi < tsl
dtat = tsi < tsi[1] and tsi > tsl

plotshape(data, style=shape.triangleup, location=location.belowbar,
                 color=false ? na : arrowvis ? #17ff00 : na, title="Curl Up")
plotshape(dtat, style=shape.triangledown, location=location.abovebar,
                 color=false ? na : arrowvis ? #FFEB3B : na, title="Curl Down")

// Colors

bullcol = input(#64b5f6, type = input.color, group="Bar Color", title="Bull Trend Color")
bearcol = input(#ef5350, type = input.color, group="Bar Color", title="Bear Trend Color")
bullrev = input(#fff176, type = input.color, group="Bar Color", title="Bullish Reversal Color")
bearrev = input(#fff176, type = input.color, group="Bar Color", title="Bearish Reversal Color")

hemabull= input(#64b5f6, type = input.color, group="Bar Color", title="HEMA Bull Color")
hemabear= input(#e91e63, type = input.color, group="Bar Color", title="HEMA Bear Color")
hemahold= input(#b2b5be, type = input.color, group="Bar Color", title="HEMA Hold Color")

trmbull = input(#3BB3E4, type = input.color, group="Bar Color", title="TRM Buy")
trmbear = input(#ffeb3b, type = input.color, group="Bar Color", title="TRM Sell")
trmhold = input(#b2b5be, type = input.color, group="Bar Color", title="TRM Hold")

rsi5    = input(#17ff00, type = input.color, group="Bar Color", title="RSI 0-5")
rsi10   = input(#17ff00, type = input.color, group="Bar Color", title="RSI 5-10")
rsi15   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 10-15")
rsi20   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 15-20")
rsi25   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 20-25")
rsi30   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 25-30")
rsi35   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 30-35")
rsi40   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 35-40")
rsi45   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 40-45")
rsi50   = input(#ffffff, type = input.color, group="Bar Color", title="RSI 45-50")
rsi55   = input(#2196f3, type = input.color, group="Bar Color", title="RSI 50-55")
rsi60   = input(#2196f3, type = input.color, group="Bar Color", title="RSI 55-60")
rsi65   = input(#2196f3, type = input.color, group="Bar Color", title="RSI 60-65")
rsi70   = input(#2196f3, type = input.color, group="Bar Color", title="RSI 65-70")
rsi75   = input(#2196f3, type = input.color, group="Bar Color", title="RSI 70-75")
rsi80   = input(#2196f3, type = input.color, group="Bar Color", title="RSI 75-80")
rsi85   = input(#9c27b0, type = input.color, group="Bar Color", title="RSI 80-85")
rsi90   = input(#9c27b0, type = input.color, group="Bar Color", title="RSI 85-90")
rsi95   = input(#ff0000, type = input.color, group="Bar Color", title="RSI 90-95")
rsi100  = input(#ff0000, type = input.color, group="Bar Color", title="RSI 95-100")

///Bar Coloring

hadefval = hadu ? bullcol : hadd ? bearcol : na

trmcolor = buy ? trmbull : sell ? trmbear : trmhold

bjrevcol = uc ? bullcol : 
           dc ? bearcol :
           dr ? bearrev :
           ur ? bullrev : na

habjrevcol = hauc ? bullcol :
             hadc ? bearcol :
             hadr ? bearrev :
             haur ? bullrev : hadefval

rsicon = rsi > 0  and rsi < 5  ? rsi5  :
         rsi > 5  and rsi < 10 ? rsi10 :
         rsi > 10 and rsi < 15 ? rsi15 :
         rsi > 15 and rsi < 20 ? rsi20 :
         rsi > 20 and rsi < 25 ? rsi25 :
         rsi > 25 and rsi < 30 ? rsi30 :
         rsi > 30 and rsi < 35 ? rsi35 :
         rsi > 35 and rsi < 40 ? rsi40 :
         rsi > 40 and rsi < 45 ? rsi45 :
         rsi > 45 and rsi < 50 ? rsi50 :
         rsi > 50 and rsi < 55 ? rsi55 :
         rsi > 55 and rsi < 60 ? rsi60 :
         rsi > 60 and rsi < 65 ? rsi65 :
         rsi > 65 and rsi < 70 ? rsi70 :
         rsi > 70 and rsi < 75 ? rsi75 :
         rsi > 75 and rsi < 80 ? rsi80 :
         rsi > 80 and rsi < 85 ? rsi85 :
         rsi > 85 and rsi < 90 ? rsi90 :
         rsi > 90 and rsi < 95 ? rsi95 :
         rsi > 95 and rsi < 100? rsi100: hadefval

hemabar = hemauc ? hemabull : hemadc ? hemabear : hemahold 

barColor =   trm    ? trmcolor : 
             bjrev  ? bjrevcol : 
             rsicol ? rsicon : 
             hema   ? hemabar : na

habarColor = trm    ? trmcolor : 
             bjrev  ? habjrevcol : 
             rsicol ? rsicon : 
             hema   ? hemabar : na

haover = input(title="Overlays HA bars in place of regular candles. (Must 'mute' main candles while in use. Toggle '👁' symbol next to ticker name to hide candles)", 
     type=input.bool, defval=false, group="Heikin-Ashi Bar Overlay")
rPrice = input(title="Real Price Line - Displays 'real close' level", type=input.bool, defval=false, group="Heikin-Ashi Bar Overlay")
plot(close, trackprice=rPrice ? true : na, offset=-9999, editable=false, color=rPrice ? habarColor : true ? na : habarColor)
plotbar(haOpen, haHigh, haLow, haClose, title='Heikin-Ashi', editable=false, color= haover ? habarColor : true ? na : habarColor) 

barcolor(color=barColor)

alertcondition(buy,          title='TRM Buy',           message='TRM Buy on {{interval}} chart. Price is {{close}}')
alertcondition(sell,         title='TRM Sell',          message='TRM Sell on {{interval}} chart. Price is {{close}}')
alertcondition(revbar,       title='Bj Reversal',       message='Reversal candle is forming on {{interval}} chart. Price is {{close}}')
alertcondition(trendbar,     title='T3 Crossing T3',    message='A new trend may be forming on {{interval}} chart. Price is {{close}}')
alertcondition(emasig,       title='HEMA Alert',        message='Price is crossing EMAs on {{interval}} chart. Price is {{close}}')
alertcondition(rsicross,     title='RSI Signal',        message='RSI crossed 50 on {{interval}} chart. Price is {{close}}')
alertcondition(data,         title='TSI Curl Up',       message='TSI curled up on {{interval}} chart. Price is {{close}}')
alertcondition(dtat,         title='TSI Curl Down',     message='TSI curled down on {{interval}} chart. Price is {{close}}')




