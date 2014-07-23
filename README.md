# eLingua

A fontend for a language learning website.

The backend is a pure CouchDB app.

## Troubleshooting

### Package files give 404 errors
Change permissions to allow all users to read the files

### Resource interpreted as ... but transferred as ...
Add the following line to /etc/mime.types
```application/dart       dart```