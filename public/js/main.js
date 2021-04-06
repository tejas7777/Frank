isConnected = "false";

console.log("Script linked!")

function connectToSocket(){
    console.log("Here")
    if(!isConnected){
        isConnected = true;
        var scheme   = "ws://";
        var uri = scheme + window.document.location.host + "/";
        var ws  = new WebSocket(uri);
        console.log("Connected");
    }
}