package funkin.backend.system.net;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

import haxe.crypto.Base64;
import haxe.crypto.Sha1;

@:keep
class WebSocket extends FunkinSocket {
	public static var CONNECT_PATH:String = "ws";
	public static var HTTP_HEADER:String = "HTTP/1.1";

	public function new(?_host:String = "127.0.0.1", ?_port:Int = 5000) {
		super(_host, _port);
		BLOCKING = true;
		connect();
		write(
			new Header('GET /$CONNECT_PATH $HTTP_HEADER')
			.set("Host", '${this.host}:${this.port}')
			.set("Upgrade", "websocket")
			.set("Connection", "Upgrade")
			.set("Sec-WebSocket-Key", getWebSocketKey())
			.set("Sec-WebSocket-Version", "13")
			.toBytes()
		);
	}

	private function getWebSocketKey():String {
		var bytes = Bytes.alloc(16);
		for (i in 0...bytes.length) bytes.set(i, Std.int(Math.random() * 256));
		return Base64.encode(bytes);
	}
}

class Header {
    public var type:String;
    public var fields:Map<String, String> = new Map();

    public function new(?type:String = "") {
        this.type = type;
    }

    public function set(key:String, value:String):Header {
        fields.set(key, value);
        return this;
    }

    inline public function get(key:String):Null<String> { return fields.get(key); }
	inline public function keys():Iterator<String> { return fields.keys(); }

    public function toBytes():Bytes {
        var bytes = new BytesOutput();
		if (type.length > 0) bytes.writeString('${type}\r\n');
		for (k in keys()) bytes.writeString('$k: ${get(k)}\r\n');
		bytes.writeString('\r\n');
		return bytes.getBytes();
    }
}

@:enum abstract ResponseCode(Int) from Int to Int {
	var CONTINUE = 100;
	var SWITCHING_PROTOCOLS = 101;
	var PROCESSING = 102;
	var EARLY_HINTS = 103;

	var OK = 200;
	var CREATED = 201;
	var ACCEPTED = 202;
	var NON_AUTHORITATIVE_INFORMATION = 203;
	var NO_CONTENT = 204;
	var RESET_CONTENT = 205;
	var PARTIAL_CONTENT = 206;
	var MULTI_STATUS = 207;
	var ALREADY_REPORTED = 208;

	var IM_USED = 226;

	var MULTIPLE_CHOICES = 300;
	var MOVED_PERMANENTLY = 301;
	var FOUND = 302;
	var SEE_OTHER = 303;
	var NOT_MODIFIED = 304;

	var TEMPORARY_REDIRECT = 307;
	var PERMANENT_REDIRECT = 308;

	var BAD_REQUEST = 400;
	var UNAUTHORIZED = 401;
	var PAYMENT_REQUIRED = 402;
	var FORBIDDEN = 403;
	var NOT_FOUND = 404;
	var METHOD_NOT_ALLOWED = 405;
	var NOT_ACCEPTABLE = 406;
	var PROXY_AUTHENTICATION_REQUIRED = 407;
	var REQUEST_TIMEOUT = 408;
	var CONFLICT = 409;
	var GONE = 410;
	var LENGTH_REQUIRED = 411;
	var PRECONDITION_FAILED = 412;
	var CONTENT_TOO_LARGE = 413;
	var URI_TOO_LONG = 414;
	var UNSUPPORTED_MEDIA_TYPE = 415;
	var RANGE_NOT_SATISFIABLE = 416;
	var EXPECTATION_FAILED = 417;
	var TEAPOT = 418;

	var MISDIRECTED_REQUEST = 421;
	var UNPROCESSABLE_ENTITY = 422;
	var LOCKED = 423;
	var FAILED_DEPENDENCY = 424;
	var TOO_EARLY = 425;
	var UPGRADE_REQUIRED = 426;

	var PRECONDITION_REQUIRED = 428;
	var TOO_MANY_REQUESTS = 429;

	var REQUEST_HEADER_FIELDS_TOO_LARGE = 431;

	var UNAVAILABLE_FOR_LEGAL_REASONS = 451;

	var INTERNAL_SERVER_ERROR = 500;
	var NOT_IMPLEMENTED = 501;
	var BAD_GATEWAY = 502;
	var SERVICE_UNAVAILABLE = 503;
	var GATEWAY_TIMEOUT = 504;
	var HTTP_VERSION_NOT_SUPPORTED = 505;
	var VARIANT_ALSO_NEGOTIATES = 506;
	var INSUFFICIENT_STORAGE = 507;
	var LOOP_DETECTED = 508;

	var NOT_EXTENDED = 510;
	var NETWORK_AUTHENTICATION_REQUIRED = 511;

	public static inline function toString(code:ResponseCode):String {
		return switch (code)
		{
            case CONTINUE: "Continue";
            case SWITCHING_PROTOCOLS: "Switching Protocols";
            case PROCESSING: "Processing";
            case EARLY_HINTS: "Early Hints";
            case OK: "OK";
            case CREATED: "Created";
            case ACCEPTED: "Accepted";
            case NON_AUTHORITATIVE_INFORMATION: "Non-Authoritative Information";
            case NO_CONTENT: "No Content";
            case RESET_CONTENT: "Reset Content";
            case PARTIAL_CONTENT: "Partial Content";
            case MULTI_STATUS: "Multi-Status";
            case ALREADY_REPORTED: "Already Reported";
            case IM_USED: "IM Used";
            case MULTIPLE_CHOICES: "Multiple Choices";
            case MOVED_PERMANENTLY: "Moved Permanently";
            case FOUND: "Found";
            case SEE_OTHER: "See Other";
            case NOT_MODIFIED: "Not Modified";
            case TEMPORARY_REDIRECT: "Temporary Redirect";
            case PERMANENT_REDIRECT: "Permanent Redirect";
            case BAD_REQUEST: "Bad Request";
            case UNAUTHORIZED: "Unauthorized";
            case PAYMENT_REQUIRED: "Payment Required";
            case FORBIDDEN: "Forbidden";
            case NOT_FOUND: "Not Found";
            case METHOD_NOT_ALLOWED: "Method Not Allowed";
            case NOT_ACCEPTABLE: "Not Acceptable";
            case PROXY_AUTHENTICATION_REQUIRED: "Proxy Authentication Required";
            case REQUEST_TIMEOUT: "Request Timeout";
            case CONFLICT: "Conflict";
            case GONE: "Gone";
            case LENGTH_REQUIRED: "Length Required";
            case PRECONDITION_FAILED: "Precondition Failed";
            case CONTENT_TOO_LARGE: "Content Too Large";
            case URI_TOO_LONG: "URI Too Long";
            case UNSUPPORTED_MEDIA_TYPE: "Unsupported Media Type";
            case RANGE_NOT_SATISFIABLE: "Range Not Satisfiable";
            case EXPECTATION_FAILED: "Expectation Failed";
            case TEAPOT: "I'm a teapot";
            case MISDIRECTED_REQUEST: "Misdirected Request";
            case UNPROCESSABLE_ENTITY: "Unprocessable Entity";
            case LOCKED: "Locked";
            case FAILED_DEPENDENCY: "Failed Dependency";
            case UPGRADE_REQUIRED: "Upgrade Required";
            case PRECONDITION_REQUIRED: "Precondition Required";
            case TOO_MANY_REQUESTS: "Too Many Requests";
            case REQUEST_HEADER_FIELDS_TOO_LARGE: "Request Header Fields Too Large";
            case UNAVAILABLE_FOR_LEGAL_REASONS: "Unavailable For Legal Reasons";
            case INTERNAL_SERVER_ERROR: "Internal Server Error";
            case NOT_IMPLEMENTED: "Not Implemented";
            case BAD_GATEWAY: "Bad Gateway";
            case SERVICE_UNAVAILABLE: "Service Unavailable";
            case GATEWAY_TIMEOUT: "Gateway Timeout";
            case HTTP_VERSION_NOT_SUPPORTED: "HTTP Version Not Supported";
            case VARIANT_ALSO_NEGOTIATES: "Variant Also Negotiates";
            case INSUFFICIENT_STORAGE: "Insufficient Storage";
            case LOOP_DETECTED: "Loop Detected";
            case NOT_EXTENDED: "Not Extended";
            case NETWORK_AUTHENTICATION_REQUIRED: "Network Authentication Required";
            default: "Unknown";
		}
	}
}