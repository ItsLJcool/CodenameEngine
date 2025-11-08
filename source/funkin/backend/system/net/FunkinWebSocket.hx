package funkin.backend.system.net;

import flixel.util.typeLimit.OneOfThree;

import haxe.io.Bytes;

import flixel.util.FlxSignal.FlxTypedSignal;
import hx.ws.Log as LogWs;
import hx.ws.WebSocket;
import hx.ws.Types.MessageType;

/**
* This is a wrapper for hxWebSockets
**/
class FunkinWebSocket implements IFlxDestroyable {
	private static var LOG_INFO(default, set):Bool = false;
	private static function set_LOG_INFO(value:Bool):Bool {
		LOG_INFO = value;
		if (LOG_INFO) LogWs.mask |= LogWs.INFO;
		else LogWs.mask &= ~LogWs.INFO;
		return value;
	}
	private static var LOG_DEBUG(default, set):Bool = false;
	private static function set_LOG_DEBUG(value:Bool):Bool {
		LOG_DEBUG = value;
		if (LOG_DEBUG) LogWs.mask |= LogWs.DEBUG;
		else LogWs.mask &= ~LogWs.DEBUG;
		return value;
	}
	private static var LOG_DATA(default, set):Bool = false;
	private static function set_LOG_DATA(value:Bool):Bool {
		LOG_DATA = value;
		if (LOG_DATA) LogWs.mask |= LogWs.DATA;
		else LogWs.mask &= ~LogWs.DATA;
		return value;
	}
	
	private var _ws:WebSocket;

	public var onOpen:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
	public var onMessage:FlxTypedSignal<OneOfThree<String, Bytes, FunkinPacket>->Void> = new FlxTypedSignal<OneOfThree<String, Bytes, FunkinPacket>->Void>(); // cursed 😭😭
	public var onClose:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
	public var onError:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();

	public var url:String;
	public var handshakeHeaders(get, null):Map<String, String>;
	public function get_handshakeHeaders():Map<String, String> { return this._ws.additionalHeaders; }

	public var AUTO_DECODE_PACKETS:Bool = true;

	public function new(_url:String) {
		this.url = _url;

		this._ws = new WebSocket(this.url, false);
		this._ws.onopen = () -> onOpen.dispatch();
		this._ws.onmessage = (message:MessageType) -> {
			var data:OneOfThree<String, Bytes, FunkinPacket> = "";
			switch(message) {
				case StrMessage(content):
					data = content;
				case BytesMessage(buffer):
					data = buffer.readAllAvailableBytes();
					if (!AUTO_DECODE_PACKETS) return onMessage.dispatch(data);
					var packet:FunkinPacket = FunkinPacket.fromBytes(data);
					if (packet == null) return onMessage.dispatch(data);
					data = packet;
			}
			onMessage.dispatch(data);
		};
		this._ws.onclose = () -> onClose.dispatch();
		this._ws.onerror = (error) -> onError.dispatch(error);
	}

	public function open():FunkinWebSocket {
		Logs.traceColored([
			Logs.logText('[FunkinWebSocket] ', CYAN),
			Logs.logText('Opening WebSocket to ', NONE), Logs.logText(url, YELLOW),
		]);
		_ws.open();
		return this;
	}

	public function send(data:Dynamic):Bool {
		try {
			this._ws.send(data);
			return true;
		} catch(e) {
			Logs.traceColored([
				Logs.logText('[FunkinWebSocket] ', CYAN),
				Logs.logText('Failed to send data: ${e}', NONE),
			]);
		}
		return false;
	}

	public function close():Void {
		Logs.traceColored([
			Logs.logText('[FunkinWebSocket] ', CYAN),
			Logs.logText('Closing WebSocket from ', NONE), Logs.logText(url, YELLOW),
		]);
		_ws.close();
	}
	public function destroy():Void { close(); }
}