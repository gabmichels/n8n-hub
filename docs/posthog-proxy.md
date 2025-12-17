# PostHog Analytics Proxy Setup

This guide explains how to set up the PostHog reverse proxy to bypass ad blockers.

## Why Use a Proxy?

Many ad blockers block requests to `posthog.com` domains. By proxying PostHog requests through your own domain, analytics data is more likely to be captured (typically 10-30% more events).

## How It Works

```
Browser -> e.yourdomain.com -> Caddy -> eu.i.posthog.com
```

The Caddy reverse proxy forwards requests to PostHog EU servers while:
- Rewriting the Host header
- Handling CORS headers
- Using HTTPS throughout

## Configuration

### 1. DNS Setup

Create an A record pointing to your server:
```
e.crowd-wisdom.com -> YOUR_SERVER_IP
```

### 2. Environment Variables

Add to your `.env` file:

```bash
POSTHOG_PROXY_HOST=e.crowd-wisdom.com
```

### 3. Restart Caddy

```bash
docker compose --profile prod restart caddy
```

## Frontend Integration

Update your PostHog initialization to use your proxy:

### JavaScript SDK

```javascript
posthog.init('YOUR_PROJECT_API_KEY', {
    api_host: 'https://e.crowd-wisdom.com',
    ui_host: 'https://eu.posthog.com'  // Keep original for dashboard links
});
```

### React/Next.js

```javascript
import posthog from 'posthog-js'

if (typeof window !== 'undefined') {
    posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
        api_host: 'https://e.crowd-wisdom.com',
        ui_host: 'https://eu.posthog.com'
    })
}
```

### PostHog React Provider

```jsx
import { PostHogProvider } from 'posthog-js/react'

function App({ children }) {
    return (
        <PostHogProvider
            apiKey={process.env.NEXT_PUBLIC_POSTHOG_KEY}
            options={{
                api_host: 'https://e.crowd-wisdom.com',
                ui_host: 'https://eu.posthog.com'
            }}
        >
            {children}
        </PostHogProvider>
    )
}
```

## Verification

### 1. Check proxy is working

```bash
curl -I https://e.crowd-wisdom.com/decide
```

Should return HTTP 200.

### 2. Check browser network tab

- Open your app with DevTools open
- Go to the Network tab
- Filter by your proxy domain
- Analytics requests should go to `e.crowd-wisdom.com`
- No blocked requests in console

### 3. Check PostHog dashboard

Events should appear in your PostHog project within a few minutes.

## Troubleshooting

### Requests Still Blocked

Some aggressive ad blockers block based on request patterns. Consider:
- Using a completely unrelated subdomain name
- Avoid names like `analytics`, `tracking`, `telemetry`, `ph`, `posthog`

### CORS Errors

The proxy handles CORS automatically. If you see CORS errors:

1. Check Caddy logs:
   ```bash
   docker compose logs caddy | grep -i cors
   ```

2. Verify the Caddyfile has proper header handling

### SSL Certificate Issues

Caddy automatically provisions certificates. If certificates fail:

1. Ensure DNS is properly configured
2. Check Caddy logs for Let's Encrypt errors:
   ```bash
   docker compose logs caddy | grep -i acme
   ```
3. Verify ports 80 and 443 are open in your firewall

### 401 Unauthorized Errors

If you get 401 errors from PostHog:
- Verify your API key is correct
- Check that `header_up Host` is set correctly in Caddyfile
- Ensure you're using the correct region (EU vs US)

## Security Notes

- This proxy only forwards to PostHog servers
- No data is stored on your server
- All traffic is encrypted (HTTPS)
- PostHog API key remains in frontend (this is normal and expected)
