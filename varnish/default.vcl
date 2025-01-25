vcl 4.0;

# Define backends for nginx1 and nginx2
backend nginx1 {
    .host = "nginx1";  # Name of the container or service for nginx1
    .port = "8080";    # Port where nginx1 is serving PHP or static content
}

backend nginx2 {
    .host = "nginx2";  # Name of the container or service for nginx2
    .port = "8080";    # Port where nginx2 is serving PHP or static content
}

# Handle incoming requests and route them based on the X-Backend header
sub vcl_recv {

     # Respond with 200 OK when the health check URL is requested
    if (req.url == "/health") {
        return (synth(200, "OK"));
    }

    # Check if the X-Backend header is set by HAProxy to route traffic
    if (req.http.X-Backend == "nginx1") {
        set req.backend_hint = nginx1;
    } else if (req.http.X-Backend == "nginx2") {
        set req.backend_hint = nginx2;
    } else {
        # If the header is not set, you could return an error or route to a default backend
        return (synth(503, "problem detected in default.vcl"));
    }
}

# Set cache TTL (Time To Live) for dynamic content, if needed
sub vcl_backend_response {

        set beresp.ttl = 5m;   # Default TTL
}

# Log cache hit/miss (optional)
sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";  # Indicates the response was served from cache
    } else {
        set resp.http.X-Cache = "MISS";  # Indicates the response was fetched from the backend
    }
}

