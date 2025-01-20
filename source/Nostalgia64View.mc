import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class Nostalgia64View extends WatchUi.WatchFace {

    var bg;
    var c64fnt;
    var c64num;
    var bgCol = 0x101080;
    var borderCol = 0x7C6EC5;
    var awake = true;
    var cursor = false;
    var cursorX;
    var cursorY;
    var clockCenterX = 0;
    var clockCenterY;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        c64fnt = WatchUi.loadResource(Rez.Fonts.c64fnt);
        c64num = WatchUi.loadResource(Rez.Fonts.c64num);

        var w = dc.getWidth();
        var h = dc.getHeight();
        clockCenterX = w/2;
        clockCenterY = h/2;
        var bitmapOpts = {:width => w,:height => h};
        bg = Graphics has :createBufferedBitmap ?
                    Graphics.createBufferedBitmap(bitmapOpts).get() as BufferedBitmap :
                new Graphics.BufferedBitmap(bitmapOpts);
        var bgDc = bg.getDc();
        bgDc.setColor(bgCol, borderCol);
        bgDc.clear();
        var sw = w * 0.73;
        var sh = h * 0.57;
        var offsetX = w / 2 - sw / 2;
        var offsetY = h / 2 - sh / 2;
        bgDc.fillRectangle(offsetX, offsetY, sw, sh);
        bgDc.setColor(borderCol, bgCol);

        drawBackgroundText(bgDc, w, offsetY, c64fnt);

        bgDc.drawText(offsetX, offsetY+28, c64fnt, "READY.", Graphics.TEXT_JUSTIFY_LEFT);
        cursorX = offsetX;
        cursorY = offsetY + 37;
        bgDc.setColor(Graphics.COLOR_WHITE, bgCol);
        bgDc.drawText(offsetX, 160, c64fnt, "@ABCDEFGHIJKLMNO", Graphics.TEXT_JUSTIFY_LEFT);
        bgDc.drawText(offsetX, 168, c64fnt, "PQRSTUVWXYZ 0123456789:;<=>?", Graphics.TEXT_JUSTIFY_LEFT);
        bgDc.drawText(offsetX, 176, c64fnt, "!\"#$%&'()*+,-./", Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function drawBackgroundText(bgDc, width, offsetY, c64fnt) {
        var backgroundTextArray = Application.loadResource(Rez.JsonData.jsonArray);
        var index = Math.rand() % backgroundTextArray.size();
        // index = 1;  // TO DEBUG / VIEW QUOTE OF CHOICE
        var backgroundTextSingle = backgroundTextArray[index] as String;

        // Split string on :
        var chars = backgroundTextSingle.toCharArray();
        var line1 = "LINE1";
        var line2 = "LINE2";
        for (var i = 0; i < chars.size(); i++) {
            if(chars[i].equals(":".toCharArray()[0])) {
                line1 = StringUtil.charArrayToString(chars.slice(0, i));
                line2 = StringUtil.charArrayToString(chars.slice(i+1, chars.size()));
            }
        }
        bgDc.drawText(width/2, offsetY+4, c64fnt, line1, Graphics.TEXT_JUSTIFY_CENTER);
        bgDc.drawText(width/2, offsetY+16, c64fnt, line2, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var timeString;
        var amPm = "";
           var hour = clockTime.hour;
           var min = clockTime.min;
        if (System.getDeviceSettings().is24Hour) {
           timeString = Lang.format("$1$:$2$", [hour.format("%02d"), min.format("%02d")]);
        } else {
           if (hour > 12) {
            hour = hour-12;
            amPm = "PM";
           } else if (hour == 0) {
            hour = 12;
            amPm = "AM";
           } else {
            amPm = "AM";
           }
           timeString = Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
           amPm = "PM";
        }
        dc.drawBitmap(0, 0, bg);
        var doDrawCursor = true;
        if (awake) {
            doDrawCursor = cursor;
            cursor = !cursor;
        }
        if (doDrawCursor) {
            dc.setColor(borderCol, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(bgCol, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(cursorX, cursorY, 8, 8);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(clockCenterX+6, clockCenterY+6, c64num, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(clockCenterX, clockCenterY, c64num, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(clockCenterX+80, clockCenterY-16, c64fnt, amPm, Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        awake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        awake = false;
    }

}
