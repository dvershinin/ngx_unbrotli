# ngx_unbrotli

The **ngx_unbrotli** is a filter module that decompresses responses encoded with Brotli (`Content-Encoding: br`) for clients that do not support Brotli. By storing responses in Brotli format, you can save on storage and I/O costs, and this module ensures that clients unable to handle Brotli still receive the appropriate decompressed content.

## Installation

### From source

You must compile NGINX with `./configure --add-dynamic-module=path/to/ngx_unbrotli` configuration parameter,

### RPM-based systems

```bash
sudo dnf -y install https://extras.getpagespeed.com/release-latest.rpm
sudo dnf -y install nginx-module-unbrotli
```

### Enabling the module

Enable it with the `load_module` directive:

```nginx
load_module modules/ngx_http_unbrotli_filter_module.so;
```

## Example Configuration

```nginx
location /storage/ {
    unbrotli on;
    unbrotli_buffers 32 4k;
    ...
}
```

## Configuration directives

### `unbrotli`

- **syntax**: `unbrotli  on | off;`
- **default**: `off`
- **context**: `http`, `server`, `location`

Enables or disables decompression of Brotli-compressed (Content-Encoding: br) responses for clients that do not support 
Brotli. When `unbrotli` is enabled, the server checks client capabilities (similar to how gzip handling is done) 
to determine if decompression is needed.

### `unbrotli_force`

- **syntax**: `unbrotli_force on | off;`
- **default**: `off`
- **context**: `http`, `server`, `location`

Forces decompression of Brotli-compressed responses, even if the client indicates support for Brotli. 
When `unbrotli_force` is `on`, all Brotli-encoded responses are decompressed before being sent to the client, 
regardless of the client’s Accept-Encoding header.

### `unbrotli_buffers`

- **syntax**: `unbrotli_buffers number size;`
- **default**: depends on system page size, commonly: `unbrotli_buffers 32 4k;` or `unbrotli_buffers 16 8k;`
- **context**: `http`, `server`, `location`

Sets the number and size of buffers used for decompressing Brotli responses. Typically, the size equals one memory page 
(4 KB or 8 KB, depending on the platform). Increasing the number or size of these buffers can improve performance for 
large responses at the cost of higher memory usage.
