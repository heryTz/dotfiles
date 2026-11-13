# Debugging Bun

Quick example

1. Create `server.ts`

```ts
Bun.serve({
  fetch(req) {
    console.log(req.url);
    return new Response("Hello, world!");
  },
});
```

2. Run inspect

```sh
bun --inspect server.ts
```
