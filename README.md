# Hyperion Web Socket Server Plugin

This plugin creates a web socket server for bidirectional communication with a running app. This WS server runs on port 5136.

All messages to / from the plugin are of the form:
```
{
    "message": "message_name",
    "data": {
        // any additional parameters
    }
}
```

## Currently supported features

### Network Sniffing

Sniff all network calls from the app (provided they use NSURLSession). To activate, send the following message:

```
{
    "message": "sniff",
    "data" {
        "enabled": true
    }
}
```

The app will reply:
```
{
    "message": "sniff_sniff",
    "data" {
        "enabled": true
    }
}
```

Afterwords it will send the following messages for each network call:
```
{
    "message": "sniff_response",
    "data" {
        "type": "will_send" | "response_body" | "response_error",
        "request_id": "<uuid for request>",
        "request_url": "<url of request>",
        // In the case of response_body type
        "status_code": null | http_status_code,
        "body": "<base64 encoded body of response>",
        // In the case of respons_error type
        "error": "<localized description of the error>"
    }
}
```

## Future development

* Support intercepting and replacing network calls (proxying)
* Support a custom port (through Hyperion Configuration plist)
* Support sending and recieving application defined messages

