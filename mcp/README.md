# My Academy MCP server

Lets an assistant such as Claude Desktop read a student's training data from the API: muscle
recovery and balance, progress summary, body weight, exercise suggestions, plate loading and the
server coach's advice. Reads only, apart from asking the coach, which changes nothing.

## Run

```bash
cd mcp
bun install
MY_ACADEMY_USER_ID=<user id> MY_ACADEMY_API_URL=http://localhost:9000/api node src/index.js
```

| Variable | Meaning |
|---|---|
| `MY_ACADEMY_USER_ID` | required: the student the tools read about |
| `MY_ACADEMY_API_URL` | API base URL, default `http://localhost:9000/api` |
| `MY_ACADEMY_TOKEN` | bearer token; with local mock auth use `mock-token:<uid>` |

## Claude Desktop

```json
{
  "mcpServers": {
    "my-academy": {
      "command": "node",
      "args": ["/absolute/path/to/my-academy/mcp/src/index.js"],
      "env": {
        "MY_ACADEMY_USER_ID": "<user id>",
        "MY_ACADEMY_API_URL": "http://localhost:9000/api"
      }
    }
  }
}
```

## Tests

```bash
bun run test:cov
```
