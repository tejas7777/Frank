require 'faye/websocket'

module Chat
    class ChatMiddleware
        KEEP_ALIVE_TIME = 15
        def initialize(app)
            @app = app
            @clients = []
            @usernames = Hash.new()
            @objectids = []
        end

        def call(env)
            if Faye::WebSocket.websocket?(env)
                #request_cookies = Rack::Utils.parse_cookies(env)
                #request = ActionDispatch::Request.new(env)
                request = Rack::Request.new(env)
                cookie_str = env["HTTP_COOKIE"]
                username = findUsername(cookie_str)
                ws = Faye::WebSocket.new(env, nil, {ping: KEEP_ALIVE_TIME })
                
                ws.on :open do |event|
                    p [:open, ws.object_id]
                    @usernames[ws.object_id] = username
                    @clients << ws
                    @objectids << ws.object_id
                    p @usernames, @objectids
                end

                ws.on :message do |event|
                    p [:message, event]
                    @clients.each{|client| client.send(event.data)}
                end

                ws.on :close do |event|
                    p [:close, ws.object_id, event.code, event.reason]
                    @clients.delete(ws)
                    ws = nil
                end
                ws.rack_response
            else 
                @app.call(env)
            end
        end

        def findUsername(cookie_string)
            cookie_list = cookie_string.split(";")
            cookie_list.each do |x|
                if x.include? "username"
                    username = x.split("=")
                    return username[1]
                end
            end
        end
    end
end