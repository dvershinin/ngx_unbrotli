use Test::Nginx::Socket 'no_plan';

no_long_string();
run_tests();

__DATA__

=== TEST 1: brotli response is decompressed for a client without br support
--- config
location /b/ {
    alias html/;
    default_type text/plain;
    if_modified_since before;
    add_header Content-Encoding br;
}

location = /b/304 {
    add_header Content-Encoding br;
    return 304;
}

location = /b/204 {
    add_header Content-Encoding br;
    return 204;
}

location = /b/empty {
    add_header Content-Encoding br;
    return 200;
}

location /f/ {
    unbrotli on;
    proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT/b/;
}
--- user_files eval
">>> a.br\n\x8f\x05\x80hello world\n\x03"
--- request
GET /f/a.br
--- response_body
hello world
--- response_headers
!Content-Encoding
--- no_error_log
[error]

=== TEST 2: 304 from upstream is passed through, not decoded
--- config
location /b/ {
    alias html/;
    default_type text/plain;
    if_modified_since before;
    add_header Content-Encoding br;
}

location = /b/304 {
    add_header Content-Encoding br;
    return 304;
}

location = /b/204 {
    add_header Content-Encoding br;
    return 204;
}

location = /b/empty {
    add_header Content-Encoding br;
    return 200;
}

location /f/ {
    unbrotli on;
    proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT/b/;
}
--- user_files eval
">>> a.br\n\x8f\x05\x80hello world\n\x03"
--- request
GET /f/304
--- error_code: 304
--- response_headers
!Content-Encoding
--- no_error_log
[error]

=== TEST 3: 204 from upstream is passed through, not decoded
--- config
location /b/ {
    alias html/;
    default_type text/plain;
    if_modified_since before;
    add_header Content-Encoding br;
}

location = /b/304 {
    add_header Content-Encoding br;
    return 304;
}

location = /b/204 {
    add_header Content-Encoding br;
    return 204;
}

location = /b/empty {
    add_header Content-Encoding br;
    return 200;
}

location /f/ {
    unbrotli on;
    proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT/b/;
}
--- user_files eval
">>> a.br\n\x8f\x05\x80hello world\n\x03"
--- request
GET /f/204
--- error_code: 204
--- response_headers
!Content-Encoding
--- no_error_log
[error]

=== TEST 4: conditional request revalidated by the upstream static handler
--- config
location /b/ {
    alias html/;
    default_type text/plain;
    if_modified_since before;
    add_header Content-Encoding br;
}

location = /b/304 {
    add_header Content-Encoding br;
    return 304;
}

location = /b/204 {
    add_header Content-Encoding br;
    return 204;
}

location = /b/empty {
    add_header Content-Encoding br;
    return 200;
}

location /f/ {
    unbrotli on;
    proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT/b/;
}
--- user_files eval
">>> a.br\n\x8f\x05\x80hello world\n\x03"
--- request
GET /f/a.br
--- more_headers
If-Modified-Since: Thu, 31 Dec 2037 23:59:59 GMT
--- error_code: 304
--- response_headers
!Content-Encoding
--- no_error_log
[error]

=== TEST 5: empty 200 body is not a truncated stream
--- config
location /b/ {
    alias html/;
    default_type text/plain;
    if_modified_since before;
    add_header Content-Encoding br;
}

location = /b/304 {
    add_header Content-Encoding br;
    return 304;
}

location = /b/204 {
    add_header Content-Encoding br;
    return 204;
}

location = /b/empty {
    add_header Content-Encoding br;
    return 200;
}

location /f/ {
    unbrotli on;
    proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT/b/;
}
--- user_files eval
">>> a.br\n\x8f\x05\x80hello world\n\x03"
--- request
GET /f/empty
--- error_code: 200
--- response_body
--- no_error_log
[error]

=== TEST 6: HEAD response keeps working
--- config
location /b/ {
    alias html/;
    default_type text/plain;
    if_modified_since before;
    add_header Content-Encoding br;
}

location = /b/304 {
    add_header Content-Encoding br;
    return 304;
}

location = /b/204 {
    add_header Content-Encoding br;
    return 204;
}

location = /b/empty {
    add_header Content-Encoding br;
    return 200;
}

location /f/ {
    unbrotli on;
    proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT/b/;
}
--- user_files eval
">>> a.br\n\x8f\x05\x80hello world\n\x03"
--- request
HEAD /f/a.br
--- error_code: 200
--- response_headers
!Content-Encoding
--- no_error_log
[error]
