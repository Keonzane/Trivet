// Cloudflare Worker that holds every API key so the app ships with none.

const TMDB_PATHS = [/^\/3\/search\/(movie|tv|multi)$/, /^\/3\/(movie|tv)\/\d+$/];
const TMDB_PARAMS = ['query', 'include_adult', 'page', 'language', 'year'];

const RAWG_PARAMS = ['search', 'page_size', 'search_precise', 'exclude_additions', 'page'];

function makeReply(env) {
  const cors = {
    'Access-Control-Allow-Origin': env.ALLOWED_ORIGIN || '*',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
  const reply = (status, data, extra = {}) => {
    let body = data;
    if (typeof data === 'string') body = JSON.stringify({ error: data });
    else if (data && data.constructor === Object) body = JSON.stringify(data);
    return new Response(body, {
      status,
      headers: { ...cors, 'Content-Type': 'application/json', ...extra },
    });
  };
  return { cors, reply };
}

async function tmdb(request, env, url, reply) {
  if (request.method !== 'GET') return reply(405, 'GET only');
  const key = (env.TMDB_API_KEY || '').trim();
  if (!key) return reply(500, 'Proxy secret missing: wrangler secret put TMDB_API_KEY');

  const path = url.pathname.slice('/tmdb'.length);
  if (!TMDB_PATHS.some((r) => r.test(path))) return reply(404, 'Path not allowed');

  const target = new URL('https://api.themoviedb.org' + path);
  for (const name of TMDB_PARAMS) {
    const v = url.searchParams.get(name);
    if (v !== null) target.searchParams.set(name, v.slice(0, 200));
  }
  const bearer = key.length > 40;
  if (!bearer) target.searchParams.set('api_key', key);

  const res = await fetch(target, {
    headers: {
      Accept: 'application/json',
      ...(bearer ? { Authorization: `Bearer ${key}` } : {}),
    },
    cf: { cacheTtl: 3600, cacheEverything: true },
  });
  return reply(res.status, res.body, { 'Cache-Control': 'public, max-age=3600' });
}

async function rawg(request, env, url, reply) {
  if (request.method !== 'GET') return reply(405, 'GET only');
  const key = (env.RAWG_API_KEY || '').trim();
  if (!key) return reply(500, 'Proxy secret missing: wrangler secret put RAWG_API_KEY');

  const path = url.pathname.slice('/rawg'.length);
  if (!/^\/api\/games\/?$/.test(path)) return reply(404, 'Path not allowed');

  const target = new URL('https://api.rawg.io/api/games');
  for (const name of RAWG_PARAMS) {
    const v = url.searchParams.get(name);
    if (v !== null) target.searchParams.set(name, v.slice(0, 200));
  }
  const size = Number(target.searchParams.get('page_size') || 8);
  target.searchParams.set('page_size', String(Math.min(Math.max(size, 1), 20)));
  target.searchParams.set('key', key);

  const res = await fetch(target, {
    headers: { Accept: 'application/json', 'User-Agent': 'Trivet/1.0' },
    cf: { cacheTtl: 3600, cacheEverything: true },
  });
  return reply(res.status, res.body, { 'Cache-Control': 'public, max-age=3600' });
}

export default {
  async fetch(request, env) {
    const { cors, reply } = makeReply(env);
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });

    const url = new URL(request.url);
    try {
      if (url.pathname.startsWith('/tmdb/')) return await tmdb(request, env, url, reply);
      if (url.pathname.startsWith('/rawg/')) return await rawg(request, env, url, reply);
      if (url.pathname === '/') {
        return reply(200, {
          ok: true,
          tmdb: Boolean(env.TMDB_API_KEY),
          rawg: Boolean(env.RAWG_API_KEY),
        });
      }
      return reply(404, 'Not found');
    } catch (e) {
      return reply(502, String(e.message || e));
    }
  },
};
