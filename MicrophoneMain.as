package {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.external.ExternalInterface;
import flash.media.Microphone;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;
import flash.system.Security;

/**
 * Audio main.
 */
public class MicrophoneMain extends Sprite {

    private var ns:String;
    private var debug:Boolean;

    private var mic:Microphone;
    private var frameBuffer:Array;

    /**
     * Constructor
     */
    public function MicrophoneMain() {
        if (!ExternalInterface.available) {
            throw new Error("ExternalInterface not available");
        }

        ns = loaderInfo.parameters["namespace"] || getQualifiedClassName(this);
        debug = false;

        Security.allowDomain("*");
        Security.allowInsecureDomain("*");

        frameBuffer = [];

        /**
         * Javascript can call these
         */
        ExternalInterface.addCallback("__initialize", initialize);
        ExternalInterface.addCallback("__enable", enable);
        ExternalInterface.addCallback("__disable", disable);
        ExternalInterface.addCallback("__receiveFrames", receiveFrames);
        ExternalInterface.addCallback("__setDebug", setDebug);

        invoke("__onFlashInitialized");
    }

    private function initialize():void {
        if (Microphone.names.length == 0) {
            invoke("__onLog", "No microphones detected.");
            return;
        }
        mic = Microphone["getEnhancedMicrophone"]();
        mic.gain = 50;
        mic.rate = 44;
        mic.setSilenceLevel(0);
    }

    private function enable():void {
        mic.addEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData);
    }

    private function disable():void {
        mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, handleSampleData);
        var frame:ByteArray = frameBuffer.shift();
        while (frame) {
            frame.clear();
            frame = frameBuffer.shift();
        }
    }

    private function encodePCM(data:ByteArray):String {
        var samples:ByteArray = new ByteArray();
        data.position = 0;
        while (data.bytesAvailable) {
            var val:int = (data.readFloat() * 27647) + 27647;
            if (val == 0 || val == 92 || val == 8232 || val == 8233) {
                val += 2;
            }
            samples.writeUTFBytes(String.fromCharCode(val));
        }
        return String(samples);
    }

    private function receiveFrames():String {
        var samples:Array = [];
        var frame:ByteArray = frameBuffer.shift();
        while (frame) {
            samples.push(encodePCM(frame));
            frame.clear();
            frame = frameBuffer.shift();
        }
        return samples.join("");
    }

    private function handleSampleData(event:SampleDataEvent):void {
        var frame:ByteArray = new ByteArray();
        frame.writeBytes(event.data, 0, event.data.length);
        frameBuffer.push(frame);
        invoke("__onQueuedSamples", frameBuffer.length);
    }

    private function setDebug(val:Boolean):void {
        invoke("__onLog", "setDebug");
        ExternalInterface.marshallExceptions = val;
        debug = val;
    }

    /**
     * Conveniently invoke a function in Javascript.
     *
     * @param method String The method to call.
     */
    private function invoke(method:String, ...params):void {
        params = params || [];
        ExternalInterface.call.apply(ExternalInterface,
                [ns + "." + method].concat(params));
    }

}

}
